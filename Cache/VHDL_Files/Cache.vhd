library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cache is
    port(clk, wren, reset_n :in STD_LOGIC;
         Cpu_full_address :in STD_LOGIC_VECTOR(9 downto 0);
         wrdata :in STD_LOGIC_VECTOR(15 downto 0);
         invalidate :in STD_LOGIC;
         data: out STD_LOGIC_VECTOR(15 downto 0);
         hit: out STD_LOGIC;
         cache_ready: out STD_LOGIC := '1'
     );
end cache;

architecture gate_level of cache is
  
    component Data_Array is
      port(	clk :in std_logic;
	          address:	in std_logic_vector(5 downto 0);    --index
	          wren:	in std_logic;
	          wrdata:	in std_logic_vector(15 downto 0);
	          data:	out std_logic_vector(15 downto 0)
	          --------
	          -- input_Tag : in std_logic_vector(3 downto 0)  
	   
	 );
    end component;

    component tag_valid_array is
        port(clk,wren,reset_n,invalidate:in STD_LOGIC;
             address:in STD_LOGIC_VECTOR(5 downto 0);
             wrdata:in STD_LOGIC_VECTOR(3 downto 0);
             output:out STD_LOGIC_VECTOR(4 downto 0)
         );
    end component;

    component Mru_array is
        port(address : in STD_LOGIC_VECTOR(5 downto 0);
             k : in STD_LOGIC;
             clk : in STD_LOGIC;
             enable : in STD_LOGIC;
             reset : in STD_LOGIC;
             w0_valid : out STD_LOGIC
         );
    end component;

    component miss_hit_logic is
        port(tag : in STD_LOGIC_VECTOR(3 downto 0);
             w0 : in STD_LOGIC_VECTOR(4 downto 0);
             w1 : in STD_LOGIC_VECTOR(4 downto 0);
             hit : out STD_LOGIC;
             w0_valid : out STD_LOGIC;
             w1_valid : out STD_LOGIC
         );
    end component;

    component  multiplexer_16 is
    port(sel:in STD_LOGIC;
         w0:in STD_LOGIC_VECTOR(15 downto 0);
         w1:in STD_LOGIC_VECTOR(15 downto 0);
         output: out STD_LOGIC_VECTOR(15 downto 0)
     );
    end component;



    type array_of_data is array (63 downto 0) of STD_LOGIC_VECTOR (15 downto 0);
    
    signal S0_data : STD_LOGIC_VECTOR(15 downto 0);
    signal S1_data : STD_LOGIC_VECTOR(15 downto 0);
    
    signal S0_tag_valid_out : STD_LOGIC_VECTOR(4 downto 0);
    signal S1_tag_valid_out : STD_LOGIC_VECTOR(4 downto 0);
    
    signal S0_wren : STD_LOGIC := '0';
    signal S1_wren : STD_LOGIC := '0';
    
    signal enable : STD_LOGIC := '1';
    signal K : STD_LOGIC := '0';
    signal hit_readable : STD_LOGIC;
    signal w0_valid, w1_valid : STD_LOGIC;
    signal w0_valid_Mru : STD_LOGIC;
begin
    --Data array instantiation--
    W0_data_array: Data_Array port map(clk => clk ,
                                       wren => S0_wren, 
                                       address =>  Cpu_full_address(5 downto 0), 
                                       wrdata => wrdata, 
                                       data => S0_data);
                                       
    W1_data_array: Data_Array port map(clk => clk , 
                                       wren => S1_wren, 
                                       address => Cpu_full_address(5 downto 0), 
                                       wrdata => wrdata,
                                       data => S1_data);

    --Tag valid instantiation--
    W0_tag_valid: tag_valid_array port map(clk => clk, 
                                           wren => S0_wren,
                                           reset_n => reset_n,
                                           invalidate => invalidate,
                                           address => Cpu_full_address(5 downto 0), 
                                           wrdata => Cpu_full_address(9 downto 6),
                                           output => S0_tag_valid_out);

    W1_tag_valid: tag_valid_array port map(clk => clk, 
                                           wren => S1_wren, 
                                           reset_n => reset_n,
                                           invalidate => invalidate,
                                           address => Cpu_full_address(5 downto 0),
                                           wrdata => Cpu_full_address(9 downto 6),
                                           output => S1_tag_valid_out);

    --Miss hit instantiation--
    miss_hit: miss_hit_logic port map(tag => Cpu_full_address(9 downto 6),
                                      w0 => S0_tag_valid_out,
                                      w1 => S1_tag_valid_out,
                                      hit => hit_readable,
                                      w0_valid => w0_valid,
                                      w1_valid => w1_valid);

    hit <= hit_readable;
    
    --Mru array instantiation--
    Mru_logic: Mru_array port map(address => Cpu_full_address(5 downto 0),
                                  k => k,
                                  clk => clk,
                                  reset=> invalidate,
                                  w0_valid => w0_valid_Mru,
                                  enable => enable);

    mux  :  multiplexer_16 port map(k, 
                                   S0_data, 
                                   S1_data, 
                                   data);


    process(clk)
        variable current : integer := 0;
        constant begin_write : integer := 1;
        constant begin_read : integer := 2;
        constant start : integer := 0;
        variable one_loop : integer := 0;
        variable address_to_be_written: STD_LOGIC_VECTOR(9 downto 0);
        variable last_address : STD_LOGIC_VECTOR(9 downto 0);
        variable last_write : STD_LOGIC;
        variable last_wrdata : STD_LOGIC_VECTOR(15 downto 0);
    begin
        if(current = start) then
            if(last_address /= Cpu_full_address or last_write /= wren or wrdata /= last_wrdata) then
                if(wren = '1') then
                    current := begin_write;
                    S0_wren <= '0';
                    S1_wren <= '0';
                    cache_ready <= '0';
                    enable <= '0';
                    address_to_be_written := Cpu_full_address;
                else
                    current := start;
                    S1_wren <= '0';
                    k <= w1_valid;
                    if(one_loop = 1) then
                        S0_wren <= '0';
                    end if;

                end if;
            else
                k <= w1_valid;
                S0_wren <= '0';
                S1_wren <= '0';
                enable <= '0';
            end if;
        elsif(current = begin_write) then
            if(address_to_be_written = Cpu_full_address) then
                current := start;
                S0_wren <= (not hit_readable and w0_valid_Mru and wren) or (hit_readable and w0_valid and wren);
                S1_wren <= ((not w0_valid_Mru) and wren and not hit_readable) or (hit_readable and w1_valid and wren);
                k <= (not hit_readable and w0_valid_Mru and wren) or (hit_readable and w0_valid and wren);
                enable <= '1';
                one_loop := 1;
                cache_ready <= '1';
            else
                one_loop := 1;
                current := start;
            end if;
        end if;
        last_address := Cpu_full_address;
        last_wrdata := wrdata;
        last_write := wren;
    end process;
    
end gate_level;
