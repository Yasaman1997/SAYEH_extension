library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplexer_16 is
    port(sel:in STD_LOGIC;
         w0:in STD_LOGIC_VECTOR(15 downto 0);
         w1:in STD_LOGIC_VECTOR(15 downto 0);
         output: out STD_LOGIC_VECTOR(15 downto 0)
     );
end multiplexer_16;

architecture behavioral of multiplexer_16 is
begin
    with sel select
        output <= w0 when '0',
                  w1 when '1',
                  "XXXXXXXXXXXXXXXX" when others;
end behavioral;

