library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity regorm is
  Port (
        clk, div, soft_reset   :in     std_logic;
        addr_out, data_in             :in     unsigned(9 downto 0);
        data_out1, data_out2          :out    unsigned(9 downto 0) 
        );
end regorm;

architecture Behavioral of regorm is
    type ram_type is array (0 to 1023) of unsigned(9 downto 0);
    signal RAM : ram_type := (others => (others => '1'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if soft_reset = '1' then
                RAM <= (others => (others => '1'));
            elsif div = '1' then
                RAM <= data_in & RAM(0 to 1022);
            end if;
            data_out1 <= RAM(0);
            data_out2 <= RAM(to_integer(addr_out));    
         end if;
    end process;
end Behavioral;
