library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.simulation_utilities.all;
use work.ps2_tb_utils.all;

entity ps2_receiver_tb is
    generic (
        pulses : integer := 10
    );
end entity;

architecture sim of ps2_receiver_tb is
    constant freq        : integer := 50000000; -- Hz
    constant period      : time    := 1000000000 / freq * 1 ns;
    constant half_period : time    := period / 2;

    signal running : boolean   := true;
    signal clk     : std_logic := '0';
    signal rstn    : std_logic := '1';

    signal num_rising_edges            : integer := 0;
    signal num_rising_edges_since_rstn : integer := 0;

    signal ps2_dat_in_async : std_logic;
    signal ps2_dat_in_sync  : std_logic;

    signal ps2_clk_in_async : std_logic;
    signal ps2_clk_in_sync  : std_logic;

    signal ps2_dat_in    : std_logic;
    signal ps2_dat_out   : std_logic;
    signal ps2_dat_oe    : std_logic;
    signal ps2_clk_in    : std_logic;
    signal ps2_clk_out   : std_logic;
    signal ps2_clk_oe    : std_logic;
    signal available     : std_logic;
    signal scancode      : unsigned(7 downto 0);
    signal ok            : std_logic;
    signal framing_error : std_logic;
    signal parity_error  : std_logic;

    signal dut_inputs  : ps2_receiver_inputs_t;
    signal dut_outputs : ps2_receiver_outputs_t;
begin

    -- Stimuli and test process
    process
    begin
        ps2_receiver_reset(clk, dut_inputs);

        async_rx_byte(dut_inputs, x"ab");

        wait_num_rising(clk, 10);
        -- End of run
        running <= false;
        wait;
    end process;

    clock : entity work.clock
        generic map
        (
            freq => freq)
        port map
        (
            clk                         => clk,
            run                         => running,
            rstn                        => rstn,
            num_rising_edges            => num_rising_edges,
            num_rising_edges_since_rstn => num_rising_edges_since_rstn);

    dut : entity work.ps2_receiver
        port map
        (
            clk           => clk,
            rstn          => dut_inputs.rstn,
            ps2_dat_in    => dut_inputs.ps2_dat_in,
            ps2_clk_in    => dut_inputs.ps2_clk_in,
            ps2_dat_out   => dut_outputs.ps2_dat_out,
            ps2_dat_oe    => dut_outputs.ps2_dat_oe,
            ps2_clk_out   => dut_outputs.ps2_clk_out,
            ps2_clk_oe    => dut_outputs.ps2_clk_oe,
            available     => dut_outputs.available,
            scancode      => dut_outputs.scancode,
            ok            => dut_outputs.ok,
            framing_error => dut_outputs.framing_error,
            parity_error  => dut_outputs.parity_error
        );

    process (clk)
    begin
        if rising_edge(clk) then
            ps2_clk_in_sync <= ps2_clk_in_async;
            ps2_clk_in      <= ps2_clk_in_sync;
            ps2_dat_in_sync <= ps2_dat_in_async;
            ps2_dat_in      <= ps2_dat_in_sync;
        end if;
    end process;

end architecture;