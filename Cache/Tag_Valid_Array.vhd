library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-----------------------------
--this module is about to save 4_bit Tag and 1_bit Valid 
-----@arch 
-----@Yasaman M 
-----@9431022
--------------------------------------------------------

entity Tag_Valid_Array is

port(	clk :in std_logic;
      reset_n:in std_logic;
	    address:	in std_logic_vector(5 downto 0); --input index as address
	    wren:	in std_logic;
	    inValidate:	in std_logic;  --a bit for finding out if it is valid or not
	    wrdata:	in std_logic_vector(3 downto 0); --4_bit input Tag
	    output:	out std_logic_vector(4 downto 0)

);

end Tag_Valid_Array ;

--------------------------------------------------------

architecture bhv of Tag_Valid_Array  is

 type array_tag_And_valid is array (63 downto 0) of STD_LOGIC_VECTOR(4 downto 0);  -- tag + valid
 signal tag_valid : array_tag_And_valid := (others => STD_LOGIC_VECTOR(to_unsigned(0,5)));
 
 
 
begin 
      output <= tag_valid(to_integer(unsigned(address)));
        
--process
process(clk,inValidate,reset_n,wren)
    begin
    
    --clock edge
   if (clk='1' and clk'event) then
     
        if(reset_n = '1') then
            tag_valid <= (others => STD_LOGIC_VECTOR(to_unsigned(0,5)));
        end if;

   if(wren = '1') then
            tag_valid(to_integer(unsigned(address)))(3 downto 0) <= wrdata;  --write data(tag) in the specific address
        end if;
 
	 if(  inValidate='1' )  then 
	      tag_valid(to_integer(unsigned(address)))(4) <= '0';   --5th bit is valid bit, here  we force '0' to it     	                                                                                        
	   
	   
      end if ;
    end if ;
    end process;	
    
    end bhv;

--------------------------------------------------------



--variable x :='1';
--signal y <= '1';