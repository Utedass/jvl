library ieee;
use ieee.std_logic_1164.all;

-- Dude
entity clock is
    generic (
        freq : in integer -- In hz
    );
    port (
        signal clk                         : out std_logic;
        signal run                         : in boolean;
        signal rstn                        : in std_logic;
        signal num_rising_edges            : out integer;
        signal num_rising_edges_since_rstn : out integer
    );
end entity;

architecture sim of clock is
    constant period      : time := 1000000000 / freq * 1 ns;
    constant half_period : time := period / 2;

    signal i_clk : std_logic := '0';

    signal i_num_rising_edges            : integer := 0;
    signal i_num_rising_edges_since_rstn : integer := 0;
begin
    clk <= i_clk;

    process
    begin
        if run then
            wait for half_period;
            i_clk <= not i_clk;
        else
            wait;
        end if;
    end process;

    num_rising_edges            <= i_num_rising_edges;
    num_rising_edges_since_rstn <= i_num_rising_edges_since_rstn;
    process (i_clk)
    begin
        if rising_edge(i_clk) then
            if rstn = '0' then
                i_num_rising_edges_since_rstn <= 0;
            else
                i_num_rising_edges_since_rstn <= i_num_rising_edges_since_rstn + 1;
                i_num_rising_edges            <= i_num_rising_edges + 1;
            end if;
        end if;
    end process;
end architecture;