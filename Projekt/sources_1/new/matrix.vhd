
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity matrix is
    Port (
        clk : in std_logic;
        data_in : in std_logic_vector(5 downto 0);
        clk_enable : in std_logic;
        reset : in std_logic;
        an_sel : out unsigned(3 downto 0);
        out_en : out std_logic;
        latch : out std_logic;
        clk_out : out std_logic;
        out_a : out std_logic_vector(2 downto 0);
        out_b : out std_logic_vector(2 downto 0);
        pixel_address : out unsigned(9 downto 0);
        write_complete : out std_logic 
    );
end matrix;

architecture Behavioral of matrix is

    type state is (state_update, state_latch, state_display);
    signal current_state, next_state    : state := state_update;
    signal count : unsigned(15 downto 0) := (others => '0');
    signal countt : unsigned(15 downto 0) := (others => '0');
    signal count_en : std_logic := '1';
    signal an_sel_int : unsigned(3 downto 0) := "1111";
    signal address_int : unsigned(9 downto 0) := "0000000000";

begin
    pixel_address <= address_int;
    an_sel <= an_sel_int;
       
    sync_process : process(clk, clk_enable)
    begin
        if (rising_edge(clk)) then
            if (clk_enable = '1') then
                countt <= countt+1;
                current_state <= next_state;
            
                if (count_en = '1') then
                    count <= count+1;
                end if;
            
                if (count(10 downto 0) = "11111111000") then
                    an_sel_int <= an_sel_int+1;
                end if;
            end if;
            
            if (reset = '1') then
                count <= (others => '0');
                an_sel_int <= "1111";
            end if;
            
            
        end if;
    end process;
   
    comb_process : process(count,countt, data_in, current_state, address_int, an_sel_int,clk_enable)
    begin
        latch <= '0';
        clk_out <= count(5);
        out_en <= '0';
        out_a <= "000";
        out_b <= "000";
        address_int <= (others => '0');
        next_state <= current_state;
        write_complete <= '0';
            
        case current_state is
            when state_update =>
                latch <= '0';
                out_en <= '0';
                count_en <= '1';           
                address_int <= count(15 downto 6);                 

                if (count(10 downto 4) = "1111111") then   -- Every 32 pix                       
                    clk_out <= '1';
                    out_en <= '1';
                    next_state <= state_latch;
                else
                    next_state <= state_update;
                end if;
                
                if (clk_enable = '1') then
                    if (address_int < 512) then          -- Top/bot select
                        out_a <= data_in(5 downto 3);
                        out_b <= "000";
                    else
                        out_a <= "000";
                        out_b <= data_in(2 downto 0);
                    end if;
                 else
                    out_a <= "000";
                    out_b <= "000";
                 end if;    
            when state_latch =>
                
                out_en <= '1';
                latch <= '1';               
                
                if (countt(5 downto 1) = "11111") then
                    next_state <= state_display;
                else
                    next_state <= state_latch;
                end if;
                
            when state_display =>
                latch <= '0';
                out_en <= '1';
                
                if ( (count(15 downto 0) = "1111111111111111") or (count(15 downto 0) = "0000000000000000") ) then
                    write_complete <= '1';
                else
                    write_complete <= '0';
                end if;
                              
                if (countt(6 downto 1) = "111111") then
                    next_state <= state_update;
                else
                    next_state <= state_display;
                end if;
            when others =>             
        end case;
    end process;
end Behavioral;
