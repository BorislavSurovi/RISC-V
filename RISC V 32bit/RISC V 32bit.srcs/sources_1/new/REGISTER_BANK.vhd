library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--***************OPIS MODULA*********************
--Registarska banka sa dva interfejsa za citanje
--podataka i jednim interfejsom za upis podataka.
--Broj registara u banci je 32.
--WIDTH je parametar koji odredjuje sirinu poda-
--data u registrima
--***********************************************
entity REGISTER_BANK is
    port (clk : in std_logic;
          reset : in std_logic;
        
          -- Interfejs 1 za citanje podataka
          rs1_address_i : in std_logic_vector(4 downto 0);
          rs1_data_o : out std_logic_vector(31 downto 0);
        
          -- Interfejs 2 za citanje podataka
          rs2_address_i : in std_logic_vector(4 downto 0);
          rs2_data_o : out std_logic_vector(31 downto 0);
        
          -- Interfejs za upis podataka
          rd_we_i : in std_logic; -- port za dozvolu upisa
          rd_address_i : in std_logic_vector(4 downto 0);
          rd_data_i : in std_logic_vector(31 downto 0));

end entity;

architecture Behavioral of REGISTER_BANK is

    type reg_bank_t is array (0 to 31) of std_logic_vector(31 downto 0);
    signal reg_bank_s : reg_bank_t := (others => (others => '0'));
    
begin
    --Upis u reg banku, imamo signal dozvole upisa, sinhroni reset. Posto je X0 uvek 0, ne dozvoljava se upis u taj registar.
    write_to_bank:process(clk, reset)
        begin
            if(clk'event and clk = '0') then
                if(reset = '0') then
                    reg_bank_s <= (others => (others => '0'));
                else
                    if(rd_we_i = '1') then
                        if(rd_address_i /= "00000") then
                            reg_bank_s(to_integer(unsigned(rd_address_i))) <= rd_data_i;
                        end if;
                    end if;
                end if;
            end if; 
        end process;
    
    --Citanje registra rs1. Ako je dovedena adresa registra X0, na izlaz se prosledjuju sve 0.
    read_from_bank_rs1:process(rs1_address_i, reg_bank_s)
                begin
                    if(rs1_address_i = "00000") then
                        rs1_data_o <= (others => '0');
                    else
                        rs1_data_o <= reg_bank_s(to_integer(unsigned(rs1_address_i)));
                    end if;
                end process;
                
    --Citanje registra rs2. Ako je dovedena adresa registra X0, na izlaz se prosledjuju sve 0.            
    read_from_bank_rs2:process(rs2_address_i, reg_bank_s)
                begin
                    if(rs2_address_i = "00000") then
                        rs2_data_o <= (others => '0');
                    else
                        rs2_data_o <= reg_bank_s(to_integer(unsigned(rs2_address_i)));
                    end if;
                end process;
 
    

end Behavioral;