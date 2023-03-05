----------------------------------------------------------------------------------
-- Engineer: 
-- Create Date: 21.02.2020 16:59:56
-- Module Name: projekt_top - Behavioral

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity projekt_top is
    Port (
        ADC : in std_logic_vector(1 downto 0);
        clk : in std_logic; 
--        btnu, btnl, btnr, btnd : in std_logic;
--        sw : in std_logic_vector(15 downto 0);
        sw : in std_logic;
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

--signal count : unsigned(29 downto 0);
signal ram_we : std_logic := '0';
signal ram_address : std_logic_vector(9 downto 0) := "0000000000";
signal ram_d_in : std_logic_vector(2 downto 0) := "000";
signal ram_d_out : std_logic_vector(2 downto 0) := "000";

signal ADC_data : std_logic_vector(15 downto 0);
signal ADC_en : std_logic := '1';

begin
--    CT: entity work.counter port map (clk => clk, count => count);
    RAM: entity work.ram
        port map(
            clk             => clk,
            we              => ram_we,
            address         => ram_address,
            d_in            => ram_d_in,
            d_out           => ram_d_out);
        
   
    MATRIX: entity work.matrix
        port map(
            clk             => clk,
            enable          => sw,
            data_in         => ADC_data(15 downto 10),
            an_sel          => an_sel,
            out_en          => out_en,
            latch           => latch,
            clk_out         => clk_out,
            out_a           => out_a,
            out_b           => out_b);
        
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
    
--    process_count : process(count, sw)
--    begin
----        if (rising_edge(count(25))) then
----            led <= led+1;
----        end if;
--        case sw(2 downto 1) is
--            when "00" =>
--                if (rising_edge(count(23))) then
--                    an_sel <= an_sel+1;
--                end if;
--            when "01" =>
--                    if (rising_edge(count(21))) then
--                        an_sel <= an_sel+1;
--                    end if;
--            when "10" =>
--                    if (rising_edge(count(19))) then
--                        an_sel <= an_sel+1;
--                    end if;
--            when "11" =>
--                    if (rising_edge(count(10))) then
--                        an_sel <= an_sel+1;
--                    end if;
--          end case;
--    end process process_count;
    
--    process_btn : process(btnU, btnL, btnR, btnD, count)
--    begin
--        if (btnu = '1') then
--            clk_out <= count(8);
--        else
--            clk_out <= '0';
--        end if;
        
--        if (btnd = '1') then
--            latch <= '1';
--        else
--            latch <= '0';
--        end if;
--    end process process_btn;


--out_a <= ADC_data(15 downto 13);
--out_b <= ADC_data (12 downto 10);
--latch <= count(8);
--out_en <= sw(0);
--dbgled <= sw;
end Behavioral;