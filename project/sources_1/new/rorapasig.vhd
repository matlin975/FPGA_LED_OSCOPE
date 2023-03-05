library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity snake is
    port(
         btnr, btnl, btnu, btnd        :in         std_logic;
         target_cell, apple_target     :in         std_logic_vector(2 downto 0);
         clk                           :in         std_logic;
         w_en                          :out        std_logic;
         inf                           :out        std_logic_vector(2 downto 0);
         w_addr, read_addr, apple_addr :out        unsigned(9 downto 0);
         soft_reset1                   :out        std_logic
    );    
end snake;

architecture Behavioral of snake is
    signal addr_crnt, addr_nxt            : unsigned(9 downto 0) := (others => '0');
    signal apple, apple_nxt               : unsigned(9 downto 0) := "0111110000";
    constant rgb                          : std_logic_vector(2 downto 0) := "101";
    type state_type is (zero, set, snake, regtime, eat, appletime, applecheck);
    signal crnt_state, nxt_state          : state_type := set;
    type state_type2 is (R, U, D, L);
    signal crnt_dir, nxt_dir              : state_type2 := R;
    signal counter                        : unsigned(22 downto 0) := "00000000000000000000000";
    signal counter2, counter2_nxt         : unsigned(9 downto 0) := (others => '0');
    signal div, div2, turn_crnt, turn_nxt : std_logic := '0';
    signal addr_head, addr_ass            : unsigned(9 downto 0);
    signal length, length_nxt             : unsigned(9 downto 0) := "0000000010";
    signal soft_reset                     : std_logic := '0';
    
begin
    soft_reset1 <= soft_reset;
    ormreg : entity work.regorm port map(clk => clk, soft_reset => soft_reset, div => div, data_in => addr_crnt, addr_out => length, data_out1 => addr_head, data_out2 => addr_ass);
    
    process(clk)
    begin
        if rising_edge(clk) then
            if  soft_reset = '1' then
                crnt_state <= zero;
                addr_crnt <= (others => '0');
                counter <= "00000000000000000000000";
                crnt_dir <= R;
                length <= "0000000010";
            else    
                addr_crnt <= addr_nxt;
                crnt_state <= nxt_state;
                crnt_dir <= nxt_dir;
                counter <= counter +1;
                counter2 <= counter2_nxt;
                turn_crnt <= turn_nxt;
                length <= length_nxt;
                apple <= apple_nxt;
            end if;
        end if;
    end process;
      
    process(counter)
    begin
        if counter = "11111111111111111111111" then
            div <= '1';
            div2 <= '0';
        elsif counter = "00000000000000000000000" then
            div <= '0';
            div2 <= '1';   
        else
            div <= '0';
            div2 <= '0';
        end if;      
    end process;
    

    
--- SKRIV/NOLLA FSM    
    process(addr_crnt, crnt_state, crnt_dir, div2, addr_head, addr_ass, length, target_cell, counter2, apple, apple_target)
    begin
    read_addr <= addr_crnt;
    apple_addr <= apple;
        case(crnt_state) is
            when set =>
                w_addr <= addr_crnt;
                inf <= rgb;
                length_nxt <= length;
                apple_nxt <= apple;
                soft_reset <= '0';                
                if div2 = '1' then
                    nxt_state <= appletime;
                    w_en <= '0';
                else
                    nxt_state <= crnt_state;
                    w_en <= '1';
                end if;
            when appletime => 
                w_en <= '0';
                w_addr <= addr_crnt;
                inf <= rgb;
                nxt_state <= regtime;
                if target_cell = "110" then
                    length_nxt <= length;
                    soft_reset <= '1';
                    apple_nxt <= apple;
                elsif target_cell = "011" then
                    length_nxt <= length + 1;
                    soft_reset <= '0';
                    apple_nxt <= addr_ass xor counter2;
                else
                    length_nxt <= length;
                    soft_reset <= '0';
                    apple_nxt <= apple;
                end if;  
            when regtime =>
                w_en <= '0';
                w_addr <= addr_crnt;
                inf <= rgb;
                soft_reset <= '0';
                length_nxt <= length;
                apple_nxt <= apple;     
                nxt_state <= applecheck;
            when applecheck =>
                w_en <= '0';
                w_addr <= addr_crnt;
                inf <= rgb;
                soft_reset <= '0';
                length_nxt <= length;
                apple_nxt <= apple;
                if apple_target = "110" or apple_target = "101" then 
                    nxt_state <= appletime;
                else
                    nxt_state <= snake;
                end if;
            when snake =>
                length_nxt <= length;
                w_en <= '1';
                w_addr <= addr_head;
                inf <= "110";
                soft_reset <= '0';
                apple_nxt <= apple;                
                nxt_state <= zero;
            when zero =>
                length_nxt <= length;
                w_en <= '1';
                w_addr <= addr_ass;
                inf <= "000";
                soft_reset <= '0';  
                apple_nxt <= apple;
                nxt_state <= eat;
            when eat =>
                length_nxt <= length;
                w_en <= '1';
                w_addr <= apple;
                inf <= "011";
                apple_nxt <= apple;
                soft_reset <= '0';
                nxt_state <= set;
        end case;
    end process;      

----- TEST FSM
    process(btnr, btnd, btnl, btnu, addr_nxt, nxt_dir, crnt_dir, addr_crnt, div, turn_crnt, counter2)
    begin 
         case(crnt_dir) is
            when R =>
                if  btnr = '0' and btnd = '0' and btnl = '0' and btnu = '0' then
                    if addr_crnt(4 downto 0) = "11111" and div = '1' then
                       addr_nxt <= addr_crnt(9 downto 5) & "00000";
                       turn_nxt <= '1';               
                    elsif div = '1' then
                       addr_nxt <= addr_crnt +1;
                       turn_nxt <= '1';
                    else
                       addr_nxt <= addr_crnt;
                       turn_nxt <= turn_crnt;   
                    end if;       
                    counter2_nxt <= counter2 + 1;
                    nxt_dir <= crnt_dir;
                elsif btnr = '0' and btnd = '1' and btnl = '0' and btnu = '0' and turn_crnt = '1' then              
                      addr_nxt <= addr_crnt;
                      turn_nxt <= '0';
                      counter2_nxt <= counter2 xnor addr_crnt;    
                      nxt_dir <= D;
                elsif btnr = '0' and btnd = '0' and btnl = '0' and btnu = '1' and turn_crnt = '1' then                 
                      addr_nxt <= addr_crnt;
                      turn_nxt <= '0';  
                      counter2_nxt <= counter2 xnor addr_crnt;               
                      nxt_dir <= U;
                else                 
                      addr_nxt <= addr_crnt;
                      turn_nxt <= turn_crnt; 
                      counter2_nxt <= counter2 + 1; 
                      nxt_dir <= crnt_dir;                   
                end if;

            when D =>
                if btnr = '0' and btnd = '0' and btnl = '0' and btnu = '0' then
                    if div = '1' then
                        addr_nxt <= addr_crnt +32;
                        turn_nxt <= '1';
                    else
                        addr_nxt <= addr_crnt;
                        turn_nxt <= turn_crnt;
                    end if;
                    counter2_nxt <= counter2 + 1;
                    nxt_dir <= crnt_dir;
              elsif btnr = '0' and btnd = '0' and btnl = '1' and btnu = '0' and turn_crnt = '1' then                 
                    addr_nxt <= addr_crnt;
                    turn_nxt <= '0'; 
                    counter2_nxt <= counter2 xnor addr_crnt;
                    nxt_dir <= L;
              elsif btnr = '1' and btnd = '0' and btnl = '0' and btnu = '0' and turn_crnt = '1' then                  
                    addr_nxt <= addr_crnt;
                    turn_nxt <= '0';   
                    counter2_nxt <= counter2 xnor addr_crnt;
                    nxt_dir <= R;
               else          
                    addr_nxt <= addr_crnt;
                    turn_nxt <= turn_crnt; 
                    counter2_nxt <= counter2 + 1; 
                    nxt_dir <= crnt_dir;                           
               end if;
                
            when L =>
                 if btnr = '0' and btnd = '0' and btnl = '0' and btnu = '0' then
                    if addr_crnt(4 downto 0) = "00000" and div ='1' then
                       addr_nxt <= addr_crnt(9 downto 5) & "11111";
                       turn_nxt <= '1';                
                    elsif div = '1' then
                       addr_nxt <= addr_crnt -1;
                       turn_nxt <= '1';
                    else
                       addr_nxt <= addr_crnt;
                       turn_nxt <= turn_crnt;   
                    end if;
                    counter2_nxt <= counter2 + 1;
                     nxt_dir <= crnt_dir;
                 elsif btnr = '0' and btnd = '1' and btnl = '0' and btnu = '0' and turn_crnt = '1' then                
                       addr_nxt <= addr_crnt;
                       turn_nxt <= '0';   
                       counter2_nxt <= counter2 xnor addr_crnt;              
                       nxt_dir <= D;
                 elsif btnr = '0' and btnl = '0' and btnu = '1' and btnd = '0' and turn_crnt = '1' then              
                       addr_nxt <= addr_crnt;     
                       turn_nxt <= '0';  
                       counter2_nxt <= counter2 xnor addr_crnt;          
                       nxt_dir <= U;
                 else              
                       addr_nxt <= addr_crnt;
                       turn_nxt <= turn_crnt; 
                       counter2_nxt <= counter2 + 1;     
                       nxt_dir <= crnt_dir;                               
                 end if;      
                 
            when U =>
                 if btnr = '0' and btnd = '0' and btnl = '0' and btnu = '0' then
                    if div = '1' then
                         addr_nxt <= addr_crnt -32;
                         turn_nxt <= '1';
                     else
                         addr_nxt <= addr_crnt;
                         turn_nxt <= turn_crnt;
                     end if;
                     counter2_nxt <= counter2 + 1;
                     nxt_dir <= crnt_dir;
                 elsif btnr = '0' and btnd = '0' and btnl = '1' and btnu = '0' and turn_crnt = '1' then             
                       addr_nxt <= addr_crnt;          
                       turn_nxt <= '0';   
                       counter2_nxt <= counter2 xnor addr_crnt;
                       nxt_dir <= L;
                 elsif btnr = '1' and btnl = '0' and btnu = '0' and btnd = '0' and turn_crnt = '1' then            
                       addr_nxt <= addr_crnt;            
                       turn_nxt <= '0';   
                       counter2_nxt <= counter2 xnor addr_crnt;  
                       nxt_dir <= R;
                 else             
                       addr_nxt <= addr_crnt;
                       turn_nxt <= turn_crnt;  
                       counter2_nxt <= counter2 + 1; 
                       nxt_dir <= crnt_dir;                                                     
                 end if;                            
        end case;      
    end process;

-- KOLLISION
    

       
end Behavioral;
