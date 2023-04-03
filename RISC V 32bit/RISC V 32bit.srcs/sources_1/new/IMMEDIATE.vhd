library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity IMMEDIATE is
    port(instruction_i : in std_logic_vector (31 downto 0);
         immediate_extended_o : out std_logic_vector (31 downto 0));
end entity;

architecture Behavioral of IMMEDIATE is
    signal opcode : std_logic_vector(6 downto 0);
    signal extension_regular : std_logic_vector(19 downto 0);

begin
    
    opcode <= instruction_i(6 downto 0);
    extension_regular <= (others => instruction_i(31));
    
    immediate_ext:process(opcode, instruction_i)
    begin
        case opcode is 
            when "0000011" => --I instruction opcode for LW
                immediate_extended_o <= extension_regular & instruction_i(31 downto 20);
            when "0010011" => -- I instruction opcode for ADDI
                immediate_extended_o <= extension_regular & instruction_i(31 downto 20);
            when "0100011" => --S instruction opcode for SW
                immediate_extended_o <= extension_regular & instruction_i(31 downto 25) & instruction_i(11 downto 7);
            when "1100011" => --B instruction opcode for BEQ
                immediate_extended_o <= extension_regular & instruction_i(31) & instruction_i(7) & instruction_i(30 downto 25) & instruction_i(11 downto 8);
            when "0110111" => --LUI instruction
                immediate_extended_o <= instruction_i(31 downto 12) & "000000000000";
            when others => --R instruction opcode(not used)
                immediate_extended_o <= (others => '0');
        end case;
            
    end process;


end Behavioral;