LIBRARY ieee;
USE ieee.std_logic_1164. ALL;
USE ieee.numeric_std. ALL;

ENTITY ALU IS
    port(a_i : in STD_LOGIC_VECTOR (31 DOWNTO 0); --prvi operand
         b_i : in STD_LOGIC_VECTOR (31 DOWNTO 0); --drugi operand
         op_i : in STD_LOGIC_VECTOR (4 DOWNTO 0 ); --port za izbor operacije
         res_o : out STD_LOGIC_VECTOR (31 DOWNTO 0)); --rezultat
         
END ALU;

architecture Behavioral of ALU is

begin

ALU_REZ:process(a_i, b_i, op_i)
            begin
                case op_i is
                    when "00010" => --add
                        res_o <= std_logic_vector(signed(a_i) + signed(b_i));
                    when "00110" => --sub 
                        res_o <= std_logic_vector(signed(a_i) - signed(b_i));
                    when "00001" => --or
                        res_o <= a_i or b_i;
                    when "00000" => --and
                        res_o <= a_i and b_i;
                    when others =>
                        res_o <= (others => '0');
                end case;
            end process;    

end Behavioral;