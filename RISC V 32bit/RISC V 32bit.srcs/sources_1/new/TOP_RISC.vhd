library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TOP_RISCV is
port(
    -- Globalna sinhronizacija
    clk : in std_logic;
    reset : in std_logic;
    -- Interfejs ka memoriji za podatke
    instr_mem_address_o : out std_logic_vector(31 downto 0);
    instr_mem_read_i : in std_logic_vector(31 downto 0);
    -- Interfejs ka memoriji za instrukcije
    data_mem_address_o : out std_logic_vector(31 downto 0);
    data_mem_read_i : in std_logic_vector(31 downto 0);
    data_mem_write_o : out std_logic_vector(31 downto 0);
    data_mem_we_o : out std_logic_vector(3 downto 0));
end entity;

architecture Structural of TOP_RISCV is
    signal if_id_en_s: std_logic;
    signal pc_en_s: std_logic;
    signal if_id_flush_s: std_logic;
    signal branch_forward_a_s, branch_forward_b_s: std_logic;
    signal alu_forward_a_s, alu_forward_b_s: std_logic_vector(1 downto 0);
    signal branch_condition_s: std_logic;
    signal mem_to_reg_s: std_logic;
    signal rd_we_i_s: std_logic;
    signal alu_src_s: std_logic;
    signal alu_op_s: std_logic_vector(4 downto 0);
    signal pc_next_sel_s: std_logic;
    signal instruction_s: std_logic_vector(31 downto 0);
    signal rs1_src_s: std_logic;

begin

    control_path:entity work.CONTROL_PATH(Behavioral)
        port map(clk, reset, instruction_s, branch_condition_s, mem_to_reg_s, alu_op_s, alu_src_s, rd_we_i_s, pc_next_sel_s,
         data_mem_we_o, rs1_src_s, alu_forward_a_s, alu_forward_b_s, branch_forward_a_s, branch_forward_b_s, if_id_flush_s, pc_en_s, if_id_en_s);
        
    data_path:entity work.DATA_PATH(Behavioral)
        port map(clk, reset, instr_mem_address_o, instr_mem_read_i, instruction_s, data_mem_address_o, data_mem_write_o,
         data_mem_read_i, mem_to_reg_s, alu_op_s, pc_next_sel_s, alu_src_s, rd_we_i_s, rs1_src_s, branch_condition_s, alu_forward_a_s,
          alu_forward_b_s, branch_forward_a_s, branch_forward_b_s, if_id_flush_s, pc_en_s, if_id_en_s);
          
    


end Structural;