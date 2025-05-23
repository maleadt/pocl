// LLVM module pass to inline only required functions (those accessing
// per-workgroup variables) into the kernel.
//
// Copyright (c) 2011 Universidad Rey Juan Carlos
//               2012-2015 Pekka Jääskeläinen
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#include "CompilerWarnings.h"
IGNORE_COMPILER_WARNING("-Wmaybe-uninitialized")
#include <llvm/ADT/Twine.h>
POP_COMPILER_DIAGS
IGNORE_COMPILER_WARNING("-Wunused-parameter")
#include <llvm/ADT/SmallPtrSet.h>
#include <llvm/IR/InstIterator.h>
#include <llvm/IR/Module.h>
#include <llvm/Pass.h>
#include <llvm/Support/CommandLine.h>

#include "FlattenGlobals.hh"
#include "LLVMUtils.h"
#include "Workgroup.h"
#include "WorkitemHandlerChooser.h"
POP_COMPILER_DIAGS

#include <iostream>
#include <string>

#include "KernelCompilerUtils.h"
#include "WorkitemHandlerChooser.h"
#include "pocl_llvm_api.h"

//#define DEBUG_FLATTEN

#define PASS_NAME "flatten-globals"
#define PASS_CLASS pocl::FlattenGlobals
#define PASS_DESC                                                              \
  "Kernel function flattening pass - flatten global vars' users only"

namespace pocl {

using namespace llvm;

static bool flattenGlobals(Module &M) {
  SmallPtrSet<Function *, 8> FunctionsToInline;
  SmallVector<Value *, 8> Pending;

  for (auto & GVarName : WorkgroupVariablesVector) {
    GlobalVariable *GV = M.getGlobalVariable(GVarName);
    if (GV != nullptr)
      Pending.push_back(GV);
  }

  for (auto &WIFuncName : WIFuncNameVec) {
    Function *WIFunc = M.getFunction(WIFuncName);
    if (WIFunc != nullptr)
      Pending.push_back(WIFunc);
  }

  // force-inline all functions with unreachable instructions, for both
  // the CBS and Loopvec WI handlers.
  for (auto &F : M.functions()) {
    for (auto &I : instructions(F)) {
      if (isa<UnreachableInst>(I)) {
#ifdef DEBUG_FLATTEN
        std::cerr << "UNREACHABLE: must inline because of UnreachableInst\n";
#endif
        FunctionsToInline.insert(&F);
        break;
      }
    }
  }

  while (!Pending.empty()) {
    Value *Current = Pending.back();
    Pending.pop_back();

    for (auto U: Current->users()) {
      if (Instruction *ci = dyn_cast<Instruction>(U)) {
        Function *f = ci->getParent()->getParent();
        assert((f != NULL) &&
            "Per-workgroup global variable used on function with no parent!");

        // Prevent infinite looping on recursive functions
        // (though OpenCL does not allow this?)
        if (FunctionsToInline.count(f))
          continue;

        // if it's an OpenCL kernel with OptNone attribute, assume we're debugging,
        // and don't inline the kernel into the workgroup launcher.
        // this makes it possible to debug kernel code with GDB.
        if (pocl::isKernelToProcess(*f) &&
            f->hasFnAttribute(Attribute::OptimizeNone))
          continue;

        FunctionsToInline.insert(f);
        Pending.push_back(f);
      }
    }
  }

  for (auto F : FunctionsToInline) {
#ifdef DEBUG_FLATTEN
    std::cerr << "UNREACHABLE: inlining function " << F->getName().str()
              << "\n";
#endif
    markFunctionAlwaysInline(F);
  }

  StringRef barrier(BARRIER_BUILTIN_NAME);
  for (llvm::Module::iterator i = M.begin(), e = M.end(); i != e; ++i) {
    llvm::Function *f = &*i;
    if (f->isDeclaration())
      continue;
    if (f->getName() == barrier) {
      markFunctionAlwaysInline(f);
    }
  }

  return true;
}


llvm::PreservedAnalyses FlattenGlobals::run(llvm::Module &M,
                                            llvm::ModuleAnalysisManager &AM) {
  PreservedAnalyses PAChanged = PreservedAnalyses::none();
  PAChanged.preserve<WorkitemHandlerChooser>();
  return flattenGlobals(M) ? PAChanged : PreservedAnalyses::all();
}

REGISTER_NEW_MPASS(PASS_NAME, PASS_CLASS, PASS_DESC);

} // namespace pocl
