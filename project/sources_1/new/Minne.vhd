library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Minne is
    port(
        clk, w_en, soft_reset : in std_logic;
        addr_a, addr_b, addr_c, addr_d, addr_e : in unsigned(9 downto 0);
        d_ina : in std_logic_vector(2 downto 0);
        d_outb, d_outc, d_outd, d_oute : out std_logic_vector(2 downto 0)
    );
end Minne;

architecture arch of Minne is
    type ram_type is array (0 to 1023) of std_logic_vector(2 downto 0);
    signal RAM : ram_type := (others => "000");
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if soft_reset = '1' then
               RAM <= (others => "000"); 
            elsif(w_en = '1') then
                RAM(to_integer(addr_a)) <= d_ina;
            end if;
            d_outb <= RAM(to_integer(addr_b));
            d_outc <= RAM(to_integer(addr_c));
            d_outd <= RAM(to_integer(addr_d));
            d_oute <= RAM(to_integer(addr_e));
        end if;
    end process;

end arch;
