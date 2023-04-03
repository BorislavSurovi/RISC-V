library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CTRL_DECODER is
    port (
        --************ Opcode polje instrukcije************
        opcode_i : in std_logic_vector (6 downto 0);
        --************ Kontrolni signali*******************
        branch_o : out std_logic;
        mem_to_reg_o : out std_logic;
        data_mem_we_o : out std_logic;
        alu_src_b_o : out std_logic;
        rd_we_o : out std_logic;
        alu_2bit_op_o : out std_logic_vector(1 downto 0);
        rs1_in_use_o: out std_logic;
        rs2_in_use_o: out std_logic;
        rs1_src_o: out std_logic
    );
end entity;

architecture Behavioral of CTRL_DECODER is

begin
    
    ctrol_decoder:process(opcode_i)
    begin
    
        --pocetni signali
        alu_src_b_o <= '0';
        mem_to_reg_o <= '0';
        rd_we_o <= '0';
        data_mem_we_o <= '0';
        branch_o <= '0';
        alu_2bit_op_o <= "00";
        rs1_in_use_o <= '0';
        rs2_in_use_o <= '0';
        rs1_src_o <= '0';
        
        case opcode_i is
            when "0110011" =>  --R type instrukcije
                alu_src_b_o <= '0';
                mem_to_reg_o <= '0';
                rd_we_o <= '1';
                data_mem_we_o <= '0';
                branch_o <= '0';
                alu_2bit_op_o <= "10";
                rs1_in_use_o <= '1';
                rs2_in_use_o <= '1';
                rs1_src_o <= '0';
                
            when "0000011" =>  --I type za Load Word
                
                alu_src_b_o <= '1';
                mem_to_reg_o <= '1';
                rd_we_o <= '1';
                data_mem_we_o <= '0';
                branch_o <= '0';
                alu_2bit_op_o <= "00";
                rs1_in_use_o <= '1';
                rs2_in_use_o <= '0';
                rs1_src_o <= '0';
            
            when "0100011" =>  --S type za Store Word
            
                alu_src_b_o <= '1';
               -- mem_to_reg_o <= '0'; moze biti x, pa ne menjamo
                rd_we_o <= '0';
                data_mem_we_o <= '1';
                branch_o <= '0';
                alu_2bit_op_o <= "00";
                rs1_in_use_o <= '1';
                rs2_in_use_o <= '1';
                rs1_src_o <= '0';
                
            when "1100011" =>  --B type
                
                --alu_src_b_o <= '0'; moze biti x, pa ne menjamo
                mem_to_reg_o <= '0';
                rd_we_o <= '0';
                data_mem_we_o <= '0';
                branch_o <= '1';
                alu_2bit_op_o <= "01";
                rs1_in_use_o <= '1';
                rs2_in_use_o <= '1';
                rs1_src_o <= '0';
           
            when "0010011" =>  -- I type za ADDI
                
                alu_src_b_o <= '1';
                mem_to_reg_o <= '0';
                rd_we_o <= '1';
                data_mem_we_o <= '0';
                branch_o <= '0';
                alu_2bit_op_o <= "11";
                rs1_in_use_o <= '1';
                rs2_in_use_o <= '0';
                rs1_src_o <= '0';
                
            when "0110111" => --U za LUI
                
                alu_src_b_o <= '1';
                mem_to_reg_o <= '0';
                rd_we_o <= '1';
                data_mem_we_o <= '0';
                branch_o <= '0';
                alu_2bit_op_o <= "00";
                rs1_in_use_o <= '0';
                rs2_in_use_o <= '0';
                rs1_src_o <= '1';
                
            when others =>
                alu_src_b_o <= '0';
                mem_to_reg_o <= '0';
                rd_we_o <= '0';
                data_mem_we_o <= '0';
                branch_o <= '0';
                alu_2bit_op_o <= "00";
                rs1_in_use_o <= '0';
                rs2_in_use_o <= '0';
                rs1_src_o <= '0';
                
            end case;
        end process; 

end Behavioral;