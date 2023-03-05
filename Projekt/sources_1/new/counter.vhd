----------------------------------------------------------------------------------
-- Engineer: Mattias Lindström

-- Module Name: counter
-- Project Name: Projekt
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter is
    port (  clk     : in std_logic;
            count     : out unsigned(15 downto 0)
         );
end counter;

architecture Behavioral of counter is
    signal int_ct   : unsigned(15 downto 0) := (others => '0');    -- intern 30-bit count-signal
begin
    process_count : process(clk) is
        begin
            --count
            if (rising_edge(clk)) then
                int_ct <= int_ct+1;         -- r?kna upp
            end if; 
    end process process_count;

count <= int_ct;
end Behavioral;
