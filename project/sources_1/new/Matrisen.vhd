library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Matrisen is
    port (
        s_clk, reset : in std_logic;
        in_a, in_b : in std_logic_vector(2 downto 0);
        addr_ra, addr_rb : out unsigned(9 downto 0);
        an_sel : out unsigned(3 downto 0);
        out_en, latch, clk_out : out std_logic;
        out_a, out_b : out std_logic_vector(2 downto 0)
    );
end Matrisen;

architecture arch of Matrisen is
    signal clk_en : std_logic := '1';
    signal count_s : unsigned(4 downto 0) := (others => '0');
    signal count_adr : unsigned(8 downto 0) := (others => '0');
    signal an_count, an_count_nxt : unsigned(3 downto 0) := (others => '1');
    
    type state_type is (mata, visa_0, visa_1, visa_2, visa_3);
    signal state_reg, state_nxt : state_type := mata;
    
begin
    
    out_a <= in_a;
    out_b <= in_b;
    an_sel <= an_count;
    addr_ra <= '0' & count_adr;
    addr_rb <= '1' & count_adr;
    clk_out <= s_clk when clk_en = '1' else '1';
    
    process(s_clk)
    begin
        if rising_edge(s_clk) then
            if reset = '1' then
                count_adr <= (others => '0');
                count_s <= (others => '0');
                an_count <= (others => '1');
                state_reg <= mata;
            elsif clk_en = '1' then
                count_adr <= count_adr + 1;
                count_s <= count_s + 1;
            end if;
            state_reg <= state_nxt;
            an_count <= an_count_nxt;
        end if;
    end process;
    
    process(state_reg, count_s, an_count)
    begin
        case state_reg is
            when mata =>
                clk_en <= '1';
                out_en <= '0';
                latch <= '0';
                an_count_nxt <= an_count;
                
                if count_s = 31 then
                    state_nxt <= visa_0;
                else 
                    state_nxt <= mata;
                end if;
                
            when visa_0 =>
                clk_en <= '0';
                out_en <= '1';
                latch <= '0';
                an_count_nxt <= an_count;
                state_nxt <= visa_1;
            when visa_1 =>
                clk_en <= '0';
                out_en <= '1';
                an_count_nxt <= an_count + 1;
                latch <= '1';
                state_nxt <= visa_2;
            when visa_2 =>
                clk_en <= '0';
                out_en <= '1';
                an_count_nxt <= an_count;
                latch <= '0';
                state_nxt <= visa_3;
            when visa_3 =>
                clk_en <= '1';
                out_en <= '0';
                latch <= '0';
                an_count_nxt <= an_count;
                state_nxt <= mata;
        end case;
    end process;
end arch;
