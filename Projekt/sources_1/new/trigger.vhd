
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity trigger is
    Port (
    clk : in std_logic;
    en  :   in std_logic;
    rst :   in std_logic;
    level : in unsigned(4 downto 0);
    input : in unsigned (4 downto 0);
    fire  : out std_logic
);
end trigger;

architecture Behavioral of trigger is
type state is (state_read, state_eval, state_fire);
signal current_state, next_state    : state := state_read;

signal counter : unsigned(15 downto 0) := (others => '0');
signal prev_sample : unsigned(4 downto 0) := (others => '0');
signal cur_sample : unsigned(4 downto 0) := (others => '0');
signal count : unsigned(4 downto 0) := (others => '0');

begin

    sync_process : process(clk)
    begin
        if (rising_edge(clk)) then
            counter <= counter+1;
            current_state <= next_state;
                           
                if (rst = '0') then
                    if (current_state = state_read) then
                        prev_sample <= cur_sample;
                    else
                        prev_sample <= prev_sample;
                    end if;
                    
                    if (next_state = state_eval) then
                        if ((cur_sample > prev_sample) and (cur_sample > level)) then
                            count <= count+1;
                        end if;
                    end if;
                else
                    prev_sample <= (others => '0');
                    count <= (others => '0');
                end if;
        end if;
    end process;

    comb_process : process(current_state, count, input, en, prev_sample, rst)
    begin
        
        next_state <= current_state;
        fire <= '0';
        
        case current_state is
            when state_read =>
                fire <= '0';               
                cur_sample <= input;
                
                if (en = '1') then
                    next_state <= state_eval;
                else
                    next_state <= state_fire;
                end if;
            when state_eval =>
                fire <= '0';
                cur_sample <= input;
                
                if (count > 2) then
                    next_state <= state_fire;
                else
                    next_state <= state_read;
                end if;
            when state_fire =>
                fire <= '1';
                
                if (en = '1') then
                    if (rst = '0') then
                        next_state <= state_fire;
                    else
                        next_state <= state_read;
                    end if;
                else
                    next_state <= state_fire;
                end if;
            when others =>             
        end case;
    end process;

end Behavioral;
