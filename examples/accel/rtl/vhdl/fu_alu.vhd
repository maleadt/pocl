-- Module generated by TTA Codesign Environment
-- 
-- Generated on Mon May 17 18:47:56 2021
-- 
-- Function Unit: alu
-- 
-- Operations:
--  add      : 0
--  and      : 1
--  eq       : 2
--  gt       : 3
--  gtu      : 4
--  ior      : 5
--  shr1_32  : 6
--  shru1_32 : 7
--  sub      : 8
--  xor      : 9
-- 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

entity fu_alu is
  port (
    clk : in std_logic;
    rstx : in std_logic;
    glock_in : in std_logic;
    glockreq_out : out std_logic;
    operation_in : in std_logic_vector(4-1 downto 0);
    data_in1t_in : in std_logic_vector(32-1 downto 0);
    load_in1t_in : in std_logic;
    data_in2_in : in std_logic_vector(32-1 downto 0);
    load_in2_in : in std_logic;
    data_out1_out : out std_logic_vector(32-1 downto 0));
end entity fu_alu;

architecture rtl of fu_alu is

  constant op_add_c : std_logic_vector(3 downto 0) := "0000";
  constant op_and_c : std_logic_vector(3 downto 0) := "0001";
  constant op_eq_c : std_logic_vector(3 downto 0) := "0010";
  constant op_gt_c : std_logic_vector(3 downto 0) := "0011";
  constant op_gtu_c : std_logic_vector(3 downto 0) := "0100";
  constant op_ior_c : std_logic_vector(3 downto 0) := "0101";
  constant op_shr1_32_c : std_logic_vector(3 downto 0) := "0110";
  constant op_shru1_32_c : std_logic_vector(3 downto 0) := "0111";
  constant op_sub_c : std_logic_vector(3 downto 0) := "1000";
  constant op_xor_c : std_logic_vector(3 downto 0) := "1001";

  signal add_op1 : std_logic_vector(31 downto 0);
  signal add_op2 : std_logic_vector(31 downto 0);
  signal add_op3 : std_logic_vector(31 downto 0);
  signal and_op1 : std_logic_vector(31 downto 0);
  signal and_op2 : std_logic_vector(31 downto 0);
  signal and_op3 : std_logic_vector(31 downto 0);
  signal eq_op1 : std_logic_vector(31 downto 0);
  signal eq_op2 : std_logic_vector(31 downto 0);
  signal eq_op3 : std_logic;
  signal gt_op1 : std_logic_vector(31 downto 0);
  signal gt_op2 : std_logic_vector(31 downto 0);
  signal gt_op3 : std_logic;
  signal gtu_op1 : std_logic_vector(31 downto 0);
  signal gtu_op2 : std_logic_vector(31 downto 0);
  signal gtu_op3 : std_logic;
  signal ior_op1 : std_logic_vector(31 downto 0);
  signal ior_op2 : std_logic_vector(31 downto 0);
  signal ior_op3 : std_logic_vector(31 downto 0);
  signal shr1_32_op1 : std_logic_vector(31 downto 0);
  signal shr1_32_op2 : std_logic_vector(31 downto 0);
  signal shru1_32_op1 : std_logic_vector(31 downto 0);
  signal shru1_32_op2 : std_logic_vector(31 downto 0);
  signal sub_op1 : std_logic_vector(31 downto 0);
  signal sub_op2 : std_logic_vector(31 downto 0);
  signal sub_op3 : std_logic_vector(31 downto 0);
  signal xor_op1 : std_logic_vector(31 downto 0);
  signal xor_op2 : std_logic_vector(31 downto 0);
  signal xor_op3 : std_logic_vector(31 downto 0);
  signal data_in1t : std_logic_vector(31 downto 0);
  signal data_in2 : std_logic_vector(31 downto 0);
  signal data_out1 : std_logic_vector(31 downto 0);

  signal shadow_in2_r : std_logic_vector(31 downto 0);
  signal operation_1_r : std_logic_vector(3 downto 0);
  signal optrig_1_r : std_logic;
  signal data_out1_1_r : std_logic_vector(31 downto 0);
  signal data_out1_1_valid_r : std_logic;
  signal data_out1_r : std_logic_vector(31 downto 0);

begin

  data_in1t <= data_in1t_in;

  shadow_in2_sp : process(clk, rstx)
  begin
    if rstx = '0' then
      shadow_in2_r <= (others => '0');
    elsif clk = '1' and clk'event then
      if ((glock_in = '0') and (load_in2_in = '1')) then
        shadow_in2_r <= data_in2_in;
      end if;
    end if;
  end process shadow_in2_sp;

  shadow_in2_cp : process(shadow_in2_r, data_in2_in, load_in1t_in, load_in2_in)
  begin
    if ((load_in1t_in = '1') and (load_in2_in = '1')) then
      data_in2 <= data_in2_in;
    else
      data_in2 <= shadow_in2_r;
    end if;
  end process shadow_in2_cp;

  input_pipeline_sp : process(clk, rstx)
  begin
    if rstx = '0' then
      operation_1_r <= (others => '0');
      optrig_1_r <= '0';
    elsif clk = '1' and clk'event then
      if (glock_in = '0') then
        optrig_1_r <= load_in1t_in;
        if (load_in1t_in = '1') then
          operation_1_r <= operation_in;
        end if;
      end if;
    end if;
  end process input_pipeline_sp;

  operations_actual_cp : process(load_in1t_in, data_in2, and_op1, gt_op2, xor_op2, eq_op2, sub_op2, operation_in, ior_op1, sub_op1, shr1_32_op1, ior_op2, xor_op1, gt_op1, gtu_op2, and_op2, add_op2, eq_op1, add_op1, gtu_op1, data_in1t, shru1_32_op1)
  begin
    xor_op3 <= (others => '-');
    xor_op1 <= data_in1t;
    xor_op2 <= data_in2;
    sub_op3 <= (others => '-');
    sub_op1 <= data_in1t;
    sub_op2 <= data_in2;
    shr1_32_op2 <= (others => '-');
    shr1_32_op1 <= data_in1t;
    and_op3 <= (others => '-');
    and_op1 <= data_in1t;
    and_op2 <= data_in2;
    add_op3 <= (others => '-');
    add_op1 <= data_in1t;
    add_op2 <= data_in2;
    gtu_op3 <= '-';
    gtu_op1 <= data_in1t;
    gtu_op2 <= data_in2;
    ior_op3 <= (others => '-');
    ior_op1 <= data_in1t;
    ior_op2 <= data_in2;
    eq_op3 <= '-';
    eq_op1 <= data_in1t;
    eq_op2 <= data_in2;
    shru1_32_op2 <= (others => '-');
    shru1_32_op1 <= data_in1t;
    gt_op3 <= '-';
    gt_op1 <= data_in1t;
    gt_op2 <= data_in2;
    if (load_in1t_in = '1') then
      case operation_in is
        when op_add_c =>
          add_op3 <= std_logic_vector(signed(add_op1) + signed(add_op2));
        when op_and_c =>
          and_op3 <= and_op1 and and_op2;
        when op_eq_c =>
          if eq_op1 = eq_op2 then
            eq_op3 <= '1';
          else
            eq_op3 <= '0';
          end if;
        when op_gt_c =>
          if signed(gt_op1) > signed(gt_op2) then
            gt_op3 <= '1';
          else
            gt_op3 <= '0';
          end if;
        when op_gtu_c =>
          if unsigned(gtu_op1) > unsigned(gtu_op2) then
            gtu_op3 <= '1';
          else
            gtu_op3 <= '0';
          end if;
        when op_ior_c =>
          ior_op3 <= ior_op1 or ior_op2;
        when op_shr1_32_c =>
          shr1_32_op2 <= shr1_32_op1(31) & shr1_32_op1(31 downto 1);
        when op_shru1_32_c =>
          shru1_32_op2 <= "0" & shru1_32_op1(31 downto 1);
        when op_sub_c =>
          sub_op3 <= std_logic_vector(signed(sub_op1) - signed(sub_op2));
        when op_xor_c =>
          xor_op3 <= xor_op1 xor xor_op2;
        when others =>
      end case;
    end if;
  end process operations_actual_cp;

  output_pipeline_sp : process(clk, rstx)
  begin
    if rstx = '0' then
      data_out1_r <= (others => '0');
      data_out1_1_valid_r <= '0';
      data_out1_1_r <= (others => '0');
    elsif clk = '1' and clk'event then
      if (glock_in = '0') then
        data_out1_1_valid_r <= '1';
        if ((operation_in = op_xor_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= xor_op3;
        elsif ((operation_in = op_sub_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= sub_op3;
        elsif ((operation_in = op_shru1_32_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= shru1_32_op2;
        elsif ((operation_in = op_shr1_32_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= shr1_32_op2;
        elsif ((operation_in = op_ior_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= ior_op3;
        elsif ((operation_in = op_gtu_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= ((32-1 downto 1 => '0') & gtu_op3);
        elsif ((operation_in = op_gt_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= ((32-1 downto 1 => '0') & gt_op3);
        elsif ((operation_in = op_eq_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= ((32-1 downto 1 => '0') & eq_op3);
        elsif ((operation_in = op_and_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= and_op3;
        elsif ((operation_in = op_add_c) and (load_in1t_in = '1')) then
          data_out1_1_r <= add_op3;
        else
          data_out1_1_valid_r <= '0';
        end if;
        data_out1_r <= data_out1;
      end if;
    end if;
  end process output_pipeline_sp;

  output_pipeline_cp : process(data_out1, data_out1_1_r)
  begin
    data_out1 <= data_out1_1_r;
    data_out1_out <= data_out1;
  end process output_pipeline_cp;
  glockreq_out <= '0';

end architecture rtl;
