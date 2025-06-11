library ieee;
use ieee.std_logic_1164.all;

entity blinky_tb is
    generic (
        pulses : integer := 10
    );
end blinky_tb;

architecture sim of blinky_tb is
    signal running : boolean   := true;
    signal clk     : std_logic := '0';

    signal led : std_logic;

    constant freq        : integer := 50; -- MHz
    constant period      : time    := 1000 / freq * 1 ns;
    constant half_period : time    := period / 2;
begin
    running <= true,
        false after 20 * period;

    process
    begin
        if running then
            wait for half_period;
            clk <= not clk;
        else
            wait;
        end if;
    end process;

    dut : entity work.blinky(rtl)
        port map
            (clk => clk, led => led);
end architecture;