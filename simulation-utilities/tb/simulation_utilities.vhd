library ieee;
use ieee.std_logic_1164.all;

package simulation_utilities is

    procedure reset(
        signal clk  : in std_logic;
        signal rstn : out std_logic);

    procedure wait_num_rising(signal sig : std_logic; constant num : natural);

end package;

package body simulation_utilities is

    procedure reset(
        signal clk  : in std_logic;
        signal rstn : out std_logic) is
    begin
        wait until clk = '1';
        rstn <= '0';
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        rstn <= '1';
    end procedure;

    procedure wait_num_rising(signal sig : std_logic; constant num : natural) is
    begin
        for i in 1 to num loop
            wait until rising_edge(sig);
        end loop;
    end procedure;

end package body;