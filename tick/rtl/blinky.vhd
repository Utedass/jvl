library ieee;
use ieee.std_logic_1164.all;

entity blinky is
    port (
        clk : in std_logic;
        led : out std_logic
    );
end blinky;

architecture rtl of blinky is
    signal iblinky : std_logic := '0';
begin
    led <= iblinky;
    process (clk) is
    begin
        if rising_edge(clk) then
            iblinky <= not iblinky;
        end if;
    end process;
end architecture;