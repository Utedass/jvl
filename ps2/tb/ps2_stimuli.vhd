library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.simulation_utilities.all;

package ps2_tb_utils is

    type ps2_receiver_inputs_t is record
        clk        : std_logic;
        rstn       : std_logic;
        ps2_dat_in : std_logic;
        ps2_clk_in : std_logic;
    end record;

    type ps2_receiver_outputs_t is record
        ps2_dat_out   : std_logic;
        ps2_dat_oe    : std_logic;
        ps2_clk_out   : std_logic;
        ps2_clk_oe    : std_logic;
        available     : std_logic;
        scancode      : unsigned(7 downto 0);
        ok            : std_logic;
        framing_error : std_logic;
        parity_error  : std_logic;
    end record;

    procedure ps2_receiver_reset(
        signal clk    : in std_logic;
        signal inputs : out ps2_receiver_inputs_t);

    procedure async_rx_byte(
        signal ps2_inputs     : out ps2_receiver_inputs_t;
        constant scancode     : in unsigned(7 downto 0);
        constant parity_error : in boolean := false;
        constant missing_stop : in boolean := false;
        constant freq         : in integer := 10000
    );

end package;

package body ps2_tb_utils is
    procedure ps2_receiver_reset(
        signal clk    : in std_logic;
        signal inputs : out ps2_receiver_inputs_t) is
    begin
        inputs.rstn       <= '0';
        inputs.ps2_dat_in <= '1';
        inputs.ps2_clk_in <= '1';
        wait_num_rising(clk, 2);
        inputs.rstn <= '1';
        wait_num_rising(clk, 1);
    end procedure;

    procedure async_rx_byte(
        signal ps2_inputs     : out ps2_receiver_inputs_t;
        constant scancode     : in unsigned(7 downto 0);
        constant parity_error : in boolean := false;
        constant missing_stop : in boolean := false;
        constant freq         : in integer := 10000
    ) is
        constant half_period : time := (1000000000 / freq / 2) * 1 ns;

        variable fifo : std_logic_vector(10 downto 0);

    begin
        -- Prepare data to shift out
        fifo(0) := '0'; -- Start bit

        fifo(8 downto 1) := std_logic_vector(scancode);

        if not parity_error then
            fifo(9) := '1';
        else
            fifo(9) := '0';
        end if;

        if not missing_stop then
            fifo(10) := '1';
        else
            fifo(10) := '0';
        end if;

        -- Default to high signals at start
        ps2_inputs.ps2_dat_in <= '1';
        ps2_inputs.ps2_clk_in <= '1';

        -- Shift out 
        for i in 0 to 10 loop
            report "Entering loop " & integer'image(i);
            wait for half_period;
            ps2_inputs.ps2_clk_in <= '0';
            wait for half_period;
            fifo(9) := fifo(9) xor fifo(i);
            ps2_inputs.ps2_clk_in <= '1';
            ps2_inputs.ps2_dat_in <= fifo(i);
        end loop;

        if missing_stop then
            wait for half_period;
            ps2_inputs.ps2_dat_in <= '1';
        end if;

    end procedure;

end package body;
