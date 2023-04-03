library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DATA_PATH is
    port(
        -- ********* Globalna sinhronizacija ******************
        clk : in std_logic;
        reset : in std_logic;
        -- ********* Interfejs ka Memoriji za instrukcije *****
        instr_mem_address_o : out std_logic_vector(31 downto 0);
        instr_mem_read_i : in std_logic_vector(31 downto 0);
        instruction_o : out std_logic_vector(31 downto 0);
        -- ********* Interfejs ka Memoriji za podatke *****
        data_mem_address_o : out std_logic_vector(31 downto 0);
        data_mem_write_o : out std_logic_vector(31 downto 0);
        data_mem_read_i : in std_logic_vector(31 downto 0);
        -- ********* Kontrolni signali ************************
        mem_to_reg_i : in std_logic;
        alu_op_i : in std_logic_vector(4 downto 0);
        pc_next_sel_i : in std_logic;
        alu_src_i : in std_logic;
        rd_we_i : in std_logic;
        rs1_src_i: in std_logic; --Dodat zbog LUI
        -- ********* Statusni signali *************************
        branch_condition_o : out std_logic;
        -- ******************************************************
        alu_forward_a_i : in std_logic_vector (1 downto 0);
        alu_forward_b_i : in std_logic_vector (1 downto 0);
        branch_forward_a_i : in std_logic;
        branch_forward_b_i : in std_logic;
        -- kontrolni signal za resetovanje if/id registra
        if_id_flush_i : in std_logic;
        -- kontrolni signali za zaustavljanje protocne obrade
        pc_en_i : in std_logic;
        if_id_en_i : in std_logic);
end entity;

architecture Behavioral of DATA_PATH is

    signal pc_reg_out_s : std_logic_vector(31 downto 0);
    signal pc_reg_in_s : std_logic_vector(31 downto 0);
    signal pc_adder_out_s : std_logic_vector(31 downto 0);
    
    signal imm_adder_in_s_id : std_logic_vector(31 downto 0);
    signal imm_adder_out_s_id : std_logic_vector(31 downto 0);
    signal imm_shift_out_s_id : std_logic_vector(31 downto 0);
 
    signal instruction_s_if, instruction_s_id : std_logic_vector(31 downto 0);
    
    signal rs1_in_s_id : std_logic_vector(4 downto 0);
    signal rs2_in_s_id : std_logic_vector(4 downto 0);
    
    signal rd_address_s_id, rd_address_s_ex, rd_address_s_mem, rd_address_s_wb : std_logic_vector(4 downto 0);
    
    signal immediate_out_s_id, immediate_out_s_ex : std_logic_vector(31 downto 0);
    
    signal rs1_data_out_s_id, rs1_data_out_s_ex : std_logic_vector(31 downto 0);
    signal rs2_data_out_s_id, rs2_data_out_s_ex, rs2_data_out_s_mem : std_logic_vector(31 downto 0);

    signal alu_a_in_s, alu_b_in_s : std_logic_vector(31 downto 0);
    
    signal alu_res_out_s_ex, alu_res_out_s_mem, alu_res_out_s_wb : std_logic_vector(31 downto 0);

    signal data_memory_out_s_mem : std_logic_vector(31 downto 0);
    signal data_memory_out_s_wb : std_logic_vector(31 downto 0);
    
    signal alu_b_mux_in_s: std_logic_vector(31 downto 0);
    
    signal comparator_input_1_s: std_logic_vector(31 downto 0);
    signal comparator_input_2_s: std_logic_vector(31 downto 0);
    
    signal rd_data_s_wb: std_logic_vector(31 downto 0);
    
    signal rs1_address_s_id: std_logic_vector(4 downto 0);
    
begin

--IF DEO---------------------------

--PC reg
    PC:process(clk)
    begin
        if(clk'event and clk = '1') then
            if(reset = '0') then
                pc_reg_out_s <= (others => '0');
            else
                if(pc_en_i = '1') then
                        pc_reg_out_s <= pc_reg_in_s;
                end if;
            end if;
        end if;
    end process;
    
--PC in mux 
    PC_in_mux:pc_reg_in_s <= pc_adder_out_s when pc_next_sel_i = '0' else imm_adder_out_s_id; --greska u shemi (imm_adder_out_s_id umesto imm_adder_out_s_if)
    
--PC adder +4   
    PC_adder:pc_adder_out_s <= std_logic_vector(unsigned(pc_reg_out_s) + to_unsigned(4, 32));
    
--Instruction memory    
    instruction_o <= instruction_s_id;
    instr_mem_address_o <= pc_reg_out_s;
    instruction_s_if <= instr_mem_read_i;
      
--IF_ID register   
    if_id:process(clk) -- greska u shemi (izbacen imm_adder_out_s_if)
    begin
        if(clk'event and clk = '1') then
            if(if_id_flush_i = '1' or reset = '0') then
                instruction_s_id <= (others => '0');
                imm_adder_in_s_id <= (others => '0');
            else
                if(if_id_en_i = '1') then
                    instruction_s_id <= instruction_s_if;
                    imm_adder_in_s_id <= pc_reg_out_s;
                end if;
            end if;
        end if;
    end process;
    
 --ID DEO---------------------------
 
 --Podela instrukcije za reg banku    
    rs1_address_s_id <= instruction_s_id(19 downto 15);
    rs2_in_s_id <= instruction_s_id(24 downto 20);
    rd_address_s_id <= instruction_s_id(11 downto 7); --treba zakasniti
 
--Imm module  
    immediate_modul:entity work.IMMEDIATE(Behavioral)
        port map(instruction_s_id, immediate_out_s_id);
        
--Shifter 1 bit of immediate        
    shifter:imm_shift_out_s_id <= immediate_out_s_id(30 downto 0)&'0';
    
--Imm adder of shifter out and PC value   
    immediate_adder:imm_adder_out_s_id <= std_logic_vector(signed(imm_shift_out_s_id) + signed(imm_adder_in_s_id));
    
--Mux chosing rs1 address for LUI or regular   
    Mux_rs1address_or_xo:rs1_in_s_id <= rs1_address_s_id when rs1_src_i = '0' else "00000"; --Mux koji bira da li se adresira x0 za LUI ili se vadi iz instrukcije
    
--Reg Bank Module     
    reg_bank:entity work.REGISTER_BANK(Behavioral)
        port map(clk, reset, rs1_in_s_id, rs1_data_out_s_id, rs2_in_s_id, rs2_data_out_s_id, rd_we_i, rd_address_s_wb, rd_data_s_wb);
   
--Branch forward mux A 
  comparator_input_1:comparator_input_1_s <= rs1_data_out_s_id when branch_forward_a_i = '0' else alu_res_out_s_mem; 
                                                                                                                        --greska u shemi(oba ulaza komparatora dobijaju vrendost iz MEM faze)
--Branch forward mux B
  comparator_input_2:  comparator_input_2_s <= rs2_data_out_s_id when branch_forward_b_i = '0' else alu_res_out_s_mem;
        
--Branch comparator for BEQ
    comparator:branch_condition_o <= '1' when comparator_input_1_s = comparator_input_2_s else '0';
    
--ID_EX register  
    id_ex:process(clk)
    begin
        if(clk'event and clk = '1') then
            if(reset = '0') then
                rs1_data_out_s_ex <= (others => '0');
                rs2_data_out_s_ex <= (others => '0');
                rd_address_s_ex <= (others => '0');
                immediate_out_s_ex <= (others => '0');
            else
                rs1_data_out_s_ex <= rs1_data_out_s_id;
                rs2_data_out_s_ex <= rs2_data_out_s_id;
                rd_address_s_ex <= rd_address_s_id;
                immediate_out_s_ex <= immediate_out_s_id;
            end if;
        end if;
    end process;
 
 --EX DEO---------------------------
    
--B operand forward mux
    alu_b_forward_mux:process(alu_forward_b_i, rs2_data_out_s_ex, rd_data_s_wb, alu_res_out_s_mem)
        begin
            if(alu_forward_b_i = "00") then
                alu_b_mux_in_s <= rs2_data_out_s_ex;
            elsif(alu_forward_b_i = "01") then
                alu_b_mux_in_s <= rd_data_s_wb;
            else
                alu_b_mux_in_s <= alu_res_out_s_mem;
            end if;
        end process;
        
--B operand input mux      
    alu_b_mux:alu_b_in_s <= alu_b_mux_in_s when alu_src_i = '0' else immediate_out_s_ex;
    
--A operand input
    alu_a_forward_mux:process(alu_forward_a_i, rs1_data_out_s_ex, rd_data_s_wb, alu_res_out_s_mem)
    begin
        if(alu_forward_a_i = "00") then
            alu_a_in_s <= rs1_data_out_s_ex;
        elsif(alu_forward_a_i = "01") then
            alu_a_in_s <= rd_data_s_wb;
        else
            alu_a_in_s <= alu_res_out_s_mem;
        end if;
    end process;
    
    
--ALU Module   
    ALU:entity work.ALU(Behavioral)
        port map(alu_a_in_s, alu_b_in_s, alu_op_i, alu_res_out_s_ex);
        
--EX_MEM register      
    ex_mem:process(clk)
    begin
        if(clk'event and clk = '1') then
            if(reset = '0') then
                alu_res_out_s_mem <= (others => '0');
                rs2_data_out_s_mem <= (others => '0');
                rd_address_s_mem <= (others => '0');
            else
                alu_res_out_s_mem <= alu_res_out_s_ex;
                rs2_data_out_s_mem <= rs2_data_out_s_ex;
                rd_address_s_mem <= rd_address_s_ex;
            end if;
        end if;
    end process;

--MEM DEO---------------------------

--Data memory 
    data_mem_address_o <= alu_res_out_s_mem;
    data_mem_write_o <= rs2_data_out_s_mem;
    data_memory_out_s_mem <= data_mem_read_i;
    
--MEM_WB register  
    mem_wb:process(clk)
    begin
        if(clk'event and clk = '1') then
            if(reset = '0') then
                data_memory_out_s_wb <= (others => '0');
                alu_res_out_s_wb <= (others => '0');
                rd_address_s_wb <= (others => '0');
            else
                data_memory_out_s_wb <= data_memory_out_s_mem;
                alu_res_out_s_wb <= alu_res_out_s_mem;
                rd_address_s_wb <= rd_address_s_mem;
            end if;     
        end if;
    end process;
  
--WB DEO---------------------------
    
--WB mux  
    wb_mux:rd_data_s_wb <= data_memory_out_s_wb when mem_to_reg_i = '1' else alu_res_out_s_wb;
    
    

end Behavioral;