
LIBRARY ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity memory is
    port(clk, wr:in STD_LOGIC;
         -- Address size is equal to index + tag
         address:in STD_LOGIC_VECTOR(9 downto 0);
         data_in:in STD_LOGIC_VECTOR(15 downto 0);
         data_out:out STD_LOGIC_VECTOR(15 downto 0);
         memory_ready:out STD_LOGIC := '0'
     );
end memory;

architecture bhv of memory is
    type array_of_data is array (1023 downto 0) of STD_LOGIC_VECTOR (15 downto 0); --10 address bit , 1024 address line
    signal data_array : array_of_data;
begin
    data_out <= data_array(to_integer(unsigned(address)));

    process(clk)
    begin
        memory_ready <= '0';
        if(wr = '1') then
            data_array(to_integer(unsigned(address))) <= data_in;
        end if;

        memory_ready <= '1';

    end process;

end bhv;

