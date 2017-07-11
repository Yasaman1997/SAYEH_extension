library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
------ Controller---------------------------
entity cache_controller is
  
    port( clock : in STD_LOGIC;
              read : in STD_LOGIC;
              write : in STD_LOGIC;
              
              hit : in STD_LOGIC;
            
             cache_is_ready: in STD_LOGIC := '0';
             memory_is_ready : in STD_LOGIC := '0';
             write_to_cache: out STD_LOGIC := '0';
             
             write_to_ram: out STD_LOGIC := '0';
             invalidate : out STD_LOGIC := '0'
    );
end cache_controller;

architecture bhv of cache_controller is
  
  constant cache : integer := 2;
  constant start : integer := 0;
  constant write_in_cache : integer := 1;
    
    
    
  
begin
    process(clock)
        variable current_state : integer := start; 
    begin
        if( current_state = Start) then
        
          if(hit = '1') then
                    invalidate <= '1';
                end if;
                
                
            if(write = '1' and read = '0') then
               write_to_cache <= '0';
                write_to_ram <= '1';
              
               elsif( read = '1' and write = '0' ) then
                if(cache_is_ready = '1') then
                    if (hit = '1') then
                        write_to_ram <= '0';
                        write_to_cache  <= '0';
             
              
           
                       
                        invalidate <= '0';
                    else
                      current_state := write_in_cache;
                         write_to_ram  <= '0';
                         write_to_cache <= '1';
                         invalidate <= '0';
                        
                    end if;
                end if;
            else
              
               invalidate <= '0';
               
                 write_to_ram  <= '0';
                 write_to_cache <= '0';
               
               

            end if;
        elsif( current_state = write_in_cache) then
            if(cache_is_ready /= '0') then
                current_state := cache;
                write_to_cache <= '1';
              
                invalidate <= '0';
                 write_to_ram <= '0';
            end if;

        elsif( current_state = cache ) then
            if(cache_is_ready = '1') then
                current_state := start;
                
                 invalidate <= '0'; 
                 
                 write_to_ram <= '0';
                write_to_cache <= '1';
             
               
               
            end if;
        end if;
    end process;
end bhv;