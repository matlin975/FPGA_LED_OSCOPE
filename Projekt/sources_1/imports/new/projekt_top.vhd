----------------------------------------------------------------------------------
-- Engineer: Mattias Lindström
-- Create Date: 21.02.2020 16:59:56
-- Module Name: projekt_top - Behavioral

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity projekt_top is
    Port (
        ADC : in std_logic_vector(1 downto 0);
        clk : in std_logic; 
        sw : in std_logic_vector(15 downto 0);
        led : out std_logic_vector(7 downto 0);
        dbgled : out std_logic;
        an_sel : out unsigned(3 downto 0);
        out_en, latch, clk_out : out std_logic;
        out_a, out_b : out std_logic_vector(2 downto 0)
    );
end projekt_top;

architecture Behavioral of projekt_top is
component xadc_wiz_0 is
   port
   (
    daddr_in        : in  STD_LOGIC_VECTOR (6 downto 0);     -- Address bus for the dynamic reconfiguration port
    den_in          : in  STD_LOGIC;                         -- Enable Signal for the dynamic reconfiguration port
    di_in           : in  STD_LOGIC_VECTOR (15 downto 0);    -- Input data bus for the dynamic reconfiguration port
    dwe_in          : in  STD_LOGIC;                         -- Write Enable for the dynamic reconfiguration port
    do_out          : out  STD_LOGIC_VECTOR (15 downto 0);   -- Output data bus for dynamic reconfiguration port
    drdy_out        : out  STD_LOGIC;                        -- Data ready signal for the dynamic reconfiguration port
    dclk_in         : in  STD_LOGIC;                         -- Clock input for the dynamic reconfiguration port
    reset_in        : in  STD_LOGIC;                         -- Reset signal for the System Monitor control logic
    vauxp14         : in  STD_LOGIC;                         -- Auxiliary Channel 14
    vauxn14         : in  STD_LOGIC;
    busy_out        : out  STD_LOGIC;                        -- ADC Busy signal
    channel_out     : out  STD_LOGIC_VECTOR (4 downto 0);    -- Channel Selection Outputs
    eoc_out         : out  STD_LOGIC;                        -- End of Conversion Signal
    eos_out         : out  STD_LOGIC;                        -- End of Sequence Signal
    alarm_out       : out STD_LOGIC;                         -- OR'ed output of all the Alarms
    vp_in           : in  STD_LOGIC;                         -- Dedicated Analog Input Pair
    vn_in           : in  STD_LOGIC
);
end component;

signal count : unsigned(23 downto 0) := (others => '0');

--RAM signals
signal ram_we : std_logic := '0';
signal ram_clear : std_logic := '0';
signal ram_address : unsigned(9 downto 0) := "0000000000";
signal ram_d_in : std_logic_vector(2 downto 0) := "000";
signal ram_d_out : std_logic_vector(2 downto 0) := "000";

--ADC signals
signal ADC_data : std_logic_vector(15 downto 0);
signal ADC_en : std_logic := '1';
signal voltage : integer := 0;
signal row : integer := 0;
signal col : integer := 0;

--MATRIX signals
signal pixel_data : std_logic_vector(5 downto 0) := "000000";
signal pixel_address : unsigned(9 downto 0) := (others => '0');
signal display_en : std_logic := '1';
signal display_reset : std_logic := '0';
signal display_frame_complete : std_logic := '0';

--TRIGGEGRING
signal trig_fire : std_logic := '0';
signal trig_rst : std_logic := '0';
signal trig_level : unsigned(4 downto 0) := "10000";

--states
type state is (state_write, state_inc, state_display, state_wait);
signal current_state, next_state    : state := state_display;

begin
    RAM: entity work.ram
        port map(
            clk             => clk,
            we              => ram_we,
            clear           => ram_clear,
            address         => ram_address,
            d_in            => ram_d_in,
            d_out           => ram_d_out);
            
    MATRIX: entity work.matrix
        port map(
            clk             => clk,
            clk_enable    => display_en,
            reset           => display_reset,
            data_in         => pixel_data,
            an_sel          => an_sel,
            out_en          => out_en,
            latch           => latch,
            clk_out         => clk_out,
            out_a           => out_a,
            out_b           => out_b,
            pixel_address   => pixel_address,
            write_complete  => display_frame_complete);
            
    dbgled <= trig_fire;
    TRIGGER: entity work.trigger
        port map(
            clk             => clk,
            en              => sw(3),
            rst             => trig_rst,
--            level           => unsigned(sw(6 downto 4)),
            level           => trig_level,
            input           => unsigned(ADC_data(15 downto 11)),
--            input           => count(10 downto 6),
            fire            => trig_fire);
        
    XADC: xadc_wiz_0
        port map(
            daddr_in        => "0011110",           -- Address bus for the dynamic reconfiguration port
            den_in          => ADC_en,              -- Enable Signal for the dynamic reconfiguration port
            di_in           => (others => '0'),     -- Input data bus for the dynamic reconfiguration port
            dwe_in          => '0',                 -- Write Enable for the dynamic reconfiguration port
            do_out          => ADC_data,            -- Output data bus for dynamic reconfiguration port
            drdy_out        => open,                -- Data ready signal for the dynamic reconfiguration port
            dclk_in         => clk,                 -- Clock input for the dynamic reconfiguration port
            reset_in        => '0',                 -- Reset signal for the System Monitor control logic
            vauxp14         => ADC(0),              -- Auxiliary Channel 14
            vauxn14         => ADC(1),
            busy_out        => open,                -- ADC Busy signal
            channel_out     => open,                -- Channel Selection Outputs
            eoc_out         => ADC_en,              -- End of Conversion Signal
            eos_out         => open,                -- End of Sequence Signal
            alarm_out       => open,                -- OR'ed output of all the Alarms
            vp_in           => '0',                 -- Dedicated Analog Input Pair
            vn_in           => '0');
    process_ADC : process(ADC_data)
    begin
        led <= ADC_data(15 downto 8);
    end process process_ADC;
    
    sync_process : process(clk, sw)
    begin
            if (rising_edge(clk)) then
                count <= count+1;               
                
                if(count(11 downto 0) = unsigned(sw(15 downto 4))) then
                    count <= (others => '0');
                    current_state <= next_state;  
                                         
                    if (current_state = state_inc) then
                          if (col < 31) then
                              col <= col+1;
                          else                             
                              col <= 0;
                          end if;
                    end if; 
                
                    if (next_state = state_wait) and (current_state = state_display) then
                        ram_clear <= '1';
                    else
                        ram_clear <= '0';
                    end if;
                end if; 
            end if;
    end process;
    
--    voltage <= to_integer(unsigned(count(16 downto 12))); -for simulation
--    voltage <= to_integer(unsigned(count(10 downto 6)));  -for simulation
    voltage <= to_integer(unsigned(ADC_data(15 downto 11)));
    row <= 32-voltage;
  
    comb_process : process(count, voltage, row, col, pixel_address, ram_d_out, current_state, display_frame_complete, sw, trig_fire, trig_level)
    begin
    
    next_state <= current_state; 
    ram_we <= '0';
    display_en <= '1';
    display_reset <= '0';
    pixel_data(5 downto 3) <= ram_d_out;
    pixel_data(2 downto 0) <= ram_d_out;
    ram_address <= pixel_address;
    ram_d_in <= (others => '0');
    
        case current_state is
            when state_write =>
                display_en <= '0';
                display_reset <= '0';
                
                if (trig_fire = '1') then
                    ram_we <= '1';
                    ram_address <= to_unsigned((row*32)+col, 10);
                    ram_d_in <= sw(2 downto 0);
                    next_state <= state_inc;
                else
                    ram_we <= '0';
                    ram_address <= pixel_address;
                    ram_d_in <= (others => '0');
                    next_state <= state_display;
                end if;             
            when state_inc =>
                display_en <= '0';
                if (col < 31) then
                    ram_we <= '1';
                    ram_address <= to_unsigned((row*32)+col, 10);
                    ram_d_in <= sw(2 downto 0);
                    next_state <= state_write;
                else
                    display_reset <= '1';
                    ram_we <= '0';
                    ram_address <= pixel_address;
                    next_state <= state_display;
                end if;
            when state_display =>           
                  if ((display_frame_complete = '1') and (voltage < trig_level)) then
                      display_en <= '0';
                      display_reset <= '1';
                      trig_rst <= '1';
                      next_state <= state_wait;
                  else
                      display_reset <= '0';
                      display_en <= '1';
                      pixel_data(5 downto 3) <= ram_d_out;
                      pixel_data(2 downto 0) <= ram_d_out;
                       next_state <= state_display;
                   end if;
             when state_wait =>
                    trig_rst <= '0';
                    if (trig_fire = '1') then
                        next_state <= state_write;
                    else
                        next_state <= state_wait;
                    end if;
            when others =>
        end case;
    end process;
end Behavioral;