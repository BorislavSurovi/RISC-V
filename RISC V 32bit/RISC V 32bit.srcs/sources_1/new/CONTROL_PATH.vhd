library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CONTROL_PATH is
    port( -- sinhronizacija
        clk : in std_logic;
        reset : in std_logic;
        -- instrukcija dolazi iz datapah-a
        instruction_i : in std_logic_vector (31 downto 0);
        -- Statusni signaln iz datapath celine
        branch_condition_i : in std_logic;
        -- kontrolni signali koji se prosledjiuju u datapath
        mem_to_reg_o : out std_logic;
        alu_op_o : out std_logic_vector(4 downto 0);
        alu_src_b_o : out std_logic;
        rd_we_o : out std_logic;
        pc_next_sel_o : out std_logic;
        data_mem_we_o : out std_logic_vector(3 downto 0);
        rs1_src_o: out std_logic;
        -- kontrolni signali za prosledjivanje operanada u ranije faze protocne obrade
        alu_forward_a_o : out std_logic_vector (1 downto 0);
        alu_forward_b_o : out std_logic_vector (1 downto 0);
        branch_forward_a_o : out std_logic; -- mux a
        branch_forward_b_o : out std_logic; -- mux b
        -- kontrolni signal za resetovanje if/id registra
        if_id_flush_o : out std_logic;
        -- kontrolni signali za zaustavljanje protocne obrade
        pc_en_o : out std_logic;
        if_id_en_o : out std_logic);
end entity;

architecture Behavioral of CONTROL_PATH is
    
    signal mem_to_reg_s_id, mem_to_reg_s_ex, mem_to_reg_s_mem, mem_to_reg_s_wb: std_logic;
    signal data_mem_we_s_id, data_mem_we_s_ex, data_mem_we_s_mem: std_logic;
    signal rd_we_s_id, rd_we_s_ex, rd_we_s_mem, rd_we_s_wb: std_logic;
    signal alu_src_b_s_id, alu_src_b_s_ex: std_logic;
    signal branch_s_id: std_logic;
    signal alu_2bit_op_s_id, alu_2bit_op_s_ex: std_logic_vector(1 downto 0);
    signal opcode_s: std_logic_vector(6 downto 0);
    
    signal funct3_s_id, funct3_s_ex : std_logic_vector(2 downto 0);
    signal funct7_s_id, funct7_s_ex : std_logic_vector(6 downto 0);
    signal rd_address_s_id, rd_address_s_ex, rd_address_s_mem, rd_address_s_wb: std_logic_vector(4 downto 0);
    signal rs1_address_s_id, rs1_address_s_ex: std_logic_vector(4 downto 0);
    signal rs2_address_s_id, rs2_address_s_ex:std_logic_vector(4 downto 0);
    
    signal and_gate_out_s : std_logic;
    
    signal rs1_in_use_s, rs2_in_use_s : std_logic;
    
    signal control_pass_s: std_logic;
    
begin
    
    opcode_s <= instruction_i(6 downto 0);
    funct3_s_id <= instruction_i(14 downto 12);
    funct7_s_id <= instruction_i(31 downto 25);
    rd_address_s_id <= instruction_i(11 downto 7);
    rs1_address_s_id <= instruction_i(19 downto 15);
    rs2_address_s_id <= instruction_i(24 downto 20);
    
    And_gate:and_gate_out_s <= branch_condition_i and branch_s_id;
    pc_next_sel_o <= and_gate_out_s;
    if_id_flush_o <= and_gate_out_s;
    

    control_decoder:entity work.CTRL_DECODER(Behavioral)
        port map(opcode_s, branch_s_id, mem_to_reg_s_id, data_mem_we_s_id, alu_src_b_s_id, rd_we_s_id, alu_2bit_op_s_id, rs1_in_use_s, rs2_in_use_s, rs1_src_o); 
        
    hazard_unit:entity work.HAZARD_UNIT(Behavioral)
        port map(rs1_address_s_id, rs2_address_s_id, rs1_in_use_s, rs2_in_use_s, branch_s_id, rd_address_s_ex, mem_to_reg_s_ex, rd_we_s_ex, rd_address_s_mem, mem_to_reg_s_mem, pc_en_o, if_id_en_o, control_pass_s);
        
        
    id_ex:process(clk)
        begin
            if(clk'event and clk = '1') then
                if(reset = '0' or control_pass_s = '0') then
                    mem_to_reg_s_ex <= '0';
                    data_mem_we_s_ex <= '0';
                    rd_we_s_ex <= '0';
                    alu_src_b_s_ex <= '0';
                    alu_2bit_op_s_ex <= (others => '0');
                    funct3_s_ex <= (others => '0');
                    funct7_s_ex <= (others => '0');
                    rd_address_s_ex <= (others => '0');
                    rs1_address_s_ex <= (others => '0');
                    rs2_address_s_ex <= (others => '0');
                else  
                    mem_to_reg_s_ex <= mem_to_reg_s_id;
                    data_mem_we_s_ex <= data_mem_we_s_id;
                    rd_we_s_ex <= rd_we_s_id;
                    alu_src_b_s_ex <= alu_src_b_s_id;
                    alu_2bit_op_s_ex <= alu_2bit_op_s_id;
                    funct3_s_ex <= funct3_s_id;
                    funct7_s_ex <= funct7_s_id;
                    rd_address_s_ex <= rd_address_s_id;
                    rs1_address_s_ex <= rs1_address_s_id;
                    rs2_address_s_ex <= rs2_address_s_id;
                end if;
            end if;
        end process;

    alu_out:alu_src_b_o <= alu_src_b_s_ex;
    
    ALU_DECODER:entity work.ALU_DECODER(Behavioral)
        port map(alu_2bit_op_s_ex, funct3_s_ex, funct7_s_ex, alu_op_o);
        
    forwarding_unit:entity work.FORWARDING_UNIT(Behavioral)
        port map(rs1_address_s_id, rs2_address_s_id, rs1_address_s_ex, rs2_address_s_ex, rd_we_s_mem, rd_address_s_mem, rd_we_s_wb, rd_address_s_wb, alu_forward_a_o, alu_forward_b_o, branch_forward_a_o, branch_forward_b_o);
        
    ex_mem:process(clk)
        begin
            if(clk'event and clk = '1') then
                if(reset = '0') then
                    mem_to_reg_s_mem <= '0';
                    data_mem_we_s_mem <= '0';
                    rd_we_s_mem <= '0';
                    rd_address_s_mem <= (others => '0');
                else
                    mem_to_reg_s_mem <= mem_to_reg_s_ex;
                    data_mem_we_s_mem <= data_mem_we_s_ex;
                    rd_we_s_mem <= rd_we_s_ex;
                    rd_address_s_mem <= rd_address_s_ex;
                end if;
            end if;
        end process;
 
    mux_data_mem:data_mem_we_o <= "1111" when data_mem_we_s_mem = '1' else "0000";
    
    mem_wb:process(clk)
        begin
            if(clk'event and clk = '1') then
                if(reset = '0') then
                    mem_to_reg_s_wb <= '0';
                    rd_we_s_wb <= '0';
                    rd_address_s_wb <= (others => '0');
                else
                    mem_to_reg_s_wb <= mem_to_reg_s_mem;
                    rd_we_s_wb <= rd_we_s_mem;
                    rd_address_s_wb <= rd_address_s_mem;
                end if;
            end if;
        end process;
        
    rd_we_out:rd_we_o <= rd_we_s_wb;
    mem_to_reg_out:mem_to_reg_o <= mem_to_reg_s_wb;
    
    

end Behavioral;