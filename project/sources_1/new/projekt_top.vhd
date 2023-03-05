library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity projekt_top is
    port (
        clk, btnr, btnl, btnd, btnu : in std_logic;
        an_sel : out unsigned(3 downto 0);
        out_en, latch, clk_out : out std_logic;
        out_a, out_b : out std_logic_vector(2 downto 0)
    );
end projekt_top;

architecture arch of projekt_top is
    signal s_clk, w_en1, w_en2 : std_logic := '0';
    signal write_a, read_a, read_b, read_d, read_e : unsigned(9 downto 0) := (others => '0');
    signal d_ina, d_outa, d_outb, d_outd, d_oute : std_logic_vector(2 downto 0);
    signal db_tickR, db_tickL, db_tickU, db_tickD, db_tick_reset : std_logic;
    signal soft_reset : std_logic;
    
    component clk_wiz_0
        port
         (-- Clock in ports
          -- Clock out ports
          clk_out1          : out    std_logic;
          -- Status and control signals
          reset             : in     std_logic;
          clk_in1           : in     std_logic
         );
    end component;
begin
    RAM1 : entity work.minne port map(clk => clk, soft_reset => soft_reset, w_en => w_en1, addr_a => write_a, addr_b => read_a, addr_c => read_b, d_ina => d_ina, d_outb => d_outa, d_outc => d_outb, addr_d => read_d, d_outd => d_outd, addr_e => read_e, d_oute => d_oute);
    RGBM : entity work.matrisen port map(s_clk => s_clk, reset => soft_reset, in_a => d_outa, in_b => d_outb, addr_ra => read_a, addr_rb => read_b, an_sel => an_sel, out_en => out_en, latch => latch, clk_out => clk_out, out_a => out_a, out_b => out_b);
    BedounceR : entity work.debounce port map(sw => btnr, clk => clk, db_tick => db_tickR);
    BedounceL : entity work.debounce port map(sw => btnl, clk => clk, db_tick => db_tickL);
    BedounceU : entity work.debounce port map(sw => btnu, clk => clk, db_tick => db_tickU);
    BedounceD : entity work.debounce port map(sw => btnd, clk => clk, db_tick => db_tickD);
    SNAKE :      entity work.snake port map(btnr => db_tickR, btnl => db_tickL, btnu => db_tickU, btnd => db_tickD, clk => clk, inf => d_ina, w_addr => write_a, w_en => w_en1, soft_reset1 => soft_reset, target_cell => d_outd, read_addr => read_d, apple_target => d_oute, apple_addr => read_e);
    ------------- Begin Cut here for INSTANTIATION Template ----- INST_TAG
    clock : clk_wiz_0
       port map ( 
      -- Clock out ports  
       clk_out1 => s_clk,
      -- Status and control signals                
       reset => soft_reset,
       -- Clock in ports
       clk_in1 => clk
     );
     
     
end arch;
