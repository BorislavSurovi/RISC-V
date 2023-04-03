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