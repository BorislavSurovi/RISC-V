library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU_DECODER is
    port (
        --******** Controlpath ulazi *********
        alu_2bit_op_i : in std_logic_vector(1 downto 0);
        --******** Polja instrukcije *******
        funct3_i : in std_logic_vector (2 downto 0);
        funct7_i : in std_logic_vector (6 downto 0);
        --******** Datapath izlazi ********
        alu_op_o : out std_logic_vector(4 downto 0));
end entity;

architecture Behavioral of ALU_DECODER is

begin

    alu_decoder:process(alu_2bit_op_i, funct3_i, funct7_i)
    begin
        
        if alu_2bit_op_i = "00" then --Load i Store Word
            alu_op_o <= "00010"; -- Add
            
        elsif alu_2bit_op_i = "10" then --R type instrukcije
            if funct3_i = "000" then
                if  funct7_i = "0000000" then
                        alu_op_o <= "00010"; --Add
                elsif funct7_i = "0100000" then
                        alu_op_o <= "00110"; --Sub
                else 
                        alu_op_o <= "11111"; --Invalid code
                end if;
            elsif funct3_i = "111" then
                if  funct7_i = "0000000" then
                        alu_op_o <= "00000"; --And
                else
                        alu_op_o <= "11111"; --Invalid Code
                end if;
            elsif funct3_i = "110" then
                if  funct7_i = "0000000" then
                        alu_op_o <= "00001"; --Or
                else  
                        alu_op_o <= "11111"; --Invalid Code
                end if;
            else
                        alu_op_o <= "11111"; --Invalid code
            end if;
        elsif alu_2bit_op_i = "11" then --I type instrukcije
                if funct3_i = "000" then
                        alu_op_o <= "00010"; --Add
                else 
                        alu_op_o <= "11111"; --Invalid Code(Dok nemamo SUBI i ostale immediate instrukcije)
                end if;
        else --alu_2_bit_op_i = "01" B type instrukcije
                        alu_op_o <= "00110"; --Moze sta god posto se ALU ne koristi
        end if;
                    
        
    
    end process;
    


end Behavioral;