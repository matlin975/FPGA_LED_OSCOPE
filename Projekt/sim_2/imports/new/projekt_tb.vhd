
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity projekt_tb is
--  Port ( );
end projekt_tb;

architecture Behavioral of projekt_tb is
    -- inputs to the Unit Under Test (UUT)
    signal ADC : std_logic_vector(1 downto 0) := (others => '0');
    signal clk : std_logic;
    signal sw : std_logic_vector(15 downto 0) := (others => '0');
    
    -- outputs from the UUT
    signal led : std_logic_vector(7 downto 0) := (others => '0');
    signal dbgled : std_logic := '0';
    signal an_sel : std_logic_vector(3 downto 0);
    signal out_en, latch, clk_out : std_logic := '0';
    signal out_a, out_b : std_logic_vector(2 downto 0) := (others => '0');
     
     
    -- clock period definition
    constant clk_period : time := 100 ns;
    
begin
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    -- instantiate the UUT
    uut: entity work.projekt_top port map (
          ADC => ADC,
          clk => clk,
          sw => sw,
          led => led,
          dbgled => dbgled,
          unsigned(an_sel) => an_sel,
          out_en => out_en,
          latch => latch,
          clk_out => clk_out,
          out_a => out_a,
          out_b => out_b
    );
        
--     stimulus process
    stim_proc : process
    begin		    
--        sw(1) <= '1';
--        sw(3) <= '1';
--        sw(3) <= '1';
        sw(15 downto 0) <= "0011111111111011";
        wait for 20 ns;
--        sw <= '1'; 
        wait;    
    end process; 
end;
