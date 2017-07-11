library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--------------------------------------------------------

entity Miss_Hit_Logic is

port( tag:	in std_logic_vector(3 downto 0);
	    w0:	in std_logic_vector(4 downto 0);  --write0 =  tag 0 + valid 0 
	    w1:	in std_logic_vector(4 downto 0);  --write1 = tag 1  +  valid 1 
	    hit:	out std_logic;
	    w0_valid:	out std_logic;
	    w1_valid:	out std_logic
	
	    );

end Miss_Hit_Logic ;

--------------------------------------------------------

architecture gate_description of Miss_Hit_Logic  is

    signal is_equal_w0: STD_LOGIC_VECTOR(3 downto 0);
    signal is_equal_w1: STD_LOGIC_VECTOR(3 downto 0);
    signal is_in_w0: STD_LOGIC;
    signal is_in_w1: STD_LOGIC;



  begin 
     is_equal_w0 <= w0(3 downto 0) xnor tag;
     is_equal_w1 <= w1(3 downto 0) xnor tag;
    
     is_in_w0 <= is_equal_w0(3) and is_equal_w0(2) and is_equal_w0(1) and is_equal_w0(0);
     is_in_w1 <= is_equal_w1(3) and is_equal_w1(2) and is_equal_w1(1) and is_equal_w1(0);
    
    w0_valid <= is_in_w0 and w0(4);   --w0(0) is valid bit 
    w1_valid <= is_in_w1 and w1(4);   --w1(1) is valid bit
    
    hit <= (is_in_w0 and w0(4) ) or (is_in_w1 and w1(4));

  
  -- if (found in 0)
       --hit <= '1' ; 
    --  wo_valid <='1';
	  -- w1_valid <='0';
	  
	   --elsif(found in 1)
	        --hit <= '1' ; 
	  --  wo_valid <='0';
	  -- w1_valid <='1';

--else
  --  wo_valid <='0';
	  -- w1_valid <='0';
    
    end gate_description;

--------------------------------------------------------


