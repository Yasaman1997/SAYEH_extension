LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--------------------------------------------------------

entity Data_Array is

port(	clk :in std_logic;
	    address:	in std_logic_vector(5 downto 0);    --index is as an address
	    wren:	in std_logic;
	    wrdata:	in std_logic_vector(15 downto 0);
	    data:	out std_logic_vector(15 downto 0)
	    --------
	 -- input_Tag : in std_logic_vector(3 downto 0)  
	   
	 );

end Data_Array;

--------------------------------------------------------

architecture bhv of Data_Array is
  
   --64 cells , each one, 2sets of a 16 bit address , 1 bit valid , 4 bit tag
   -- 31 downto 16: set1 
   -- 15 downto 0 : set2
  
 
type array_of_data is array (63 downto 0) of std_logic_vector (15 downto 0) ;


signal new_Data : array_of_data ;


--signal tag_0 : set0(0 to 63)of(1 to 5);
--signal tag_1 : set1(0 to 63)of (1 to 5);

--signal valid_0 ;
--signal valid_1 ;

begin 

--process
process(clk,wren)
    begin
           data <= new_Data(to_integer(unsigned(address)));
          
           
           
          -- clock rising edge
       if (clk='1' and clk'event) then
         
           --address signal should select the row 
          if (wren ='1') then 
         new_Data(to_integer(unsigned(address))) <= wrdata ; 
         
	end if;
  end if ;
    end process;	
    
    end bhv;



