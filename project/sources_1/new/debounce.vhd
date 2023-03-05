library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
port(
    clk, sw      :in     std_logic;
    db_level, db_tick   :out    std_logic
    );
end debounce;

architecture archdebounce of debounce is
    type state_type is (zero, wait0, one, wait1);
    signal state_reg, state_next    :   state_type;
    signal q_reg, q_next            :   unsigned(12 downto 0); -- 2^13 * 10ns = 8,2 us
begin
    process(clk)
    begin
        
        if (rising_edge(clk)) then
            state_reg <= state_next;
            q_reg <= q_next;
        end if;
    end process;
    
    process(state_reg, q_reg, sw, q_next)
    begin
        state_next <= state_reg;
        q_next <= q_reg;
        db_tick <= '0';
        case state_reg is
            when zero =>
                db_level <= '0';
                if (sw = '1') then
                    state_next <= wait1;
                    q_next <= (others => '1');
                end if;
             when wait1 =>
                db_level <= '0';
                if (sw = '1') then
                    q_next <= q_reg -1;
                    if (q_next = 0) then
                        state_next <= one;
                        db_tick <= '1';
                    end if;
                 else
                    state_next <= zero;
                 end if;
             when one =>
                db_level <= '1';
                if (sw  = '0') then
                    state_next <= wait0;
                    q_next <= (others => '1');
                end if;
             when wait0 =>
                db_level <= '1';
                if (sw = '0') then
                    q_next <= q_reg -1;
                    if (q_next = 0) then
                        state_next <= zero;
                    end if;
                else
                    state_next <= one;
                end if;
             end case;
          end process;                             
end archdebounce;
