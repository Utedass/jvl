library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_receiver is
    port (
        clk           : in std_logic;
        rstn          : in std_logic;
        ps2_dat_in    : in std_logic; -- Should be synced to clk already!
        ps2_dat_out   : out std_logic;
        ps2_dat_oe    : out std_logic;
        ps2_clk_in    : in std_logic; -- Should be synced to clk already!
        ps2_clk_out   : out std_logic;
        ps2_clk_oe    : out std_logic;
        available     : out std_logic; -- Received scancode available, active for 1 clk cycle
        scancode      : out unsigned(7 downto 0);
        ok            : out std_logic; -- Received scancode OK
        framing_error : out std_logic; -- Framing error, scancode corrupt
        parity_error  : out std_logic); -- Parity error, scancode corrupt
end entity;

architecture rtl of ps2_receiver is
    signal i_data_in_reg : std_logic_vector(10 downto 0);
    signal i_data_in     : unsigned(7 downto 0);
    signal i_start_bit   : std_logic;
    signal i_stop_bit    : std_logic;

    signal i_data_in_delay_reg                : std_logic;
    signal i_clk_in_falling_edge_detector_reg : std_logic;
    signal i_clk_in_falling_edge_detected     : std_logic;

    signal i_current_parity_reg : std_logic;

    signal i_start_bit_detected : std_logic;
begin
    ps2_dat_out <= '0';
    ps2_dat_oe  <= '0';

    ps2_clk_out <= '0';
    ps2_clk_oe  <= '0';

    -- Map the shift register positions to named signals
    i_start_bit <= i_data_in_reg(0);
    i_data_in   <= unsigned(i_data_in_reg(8 downto 1));
    i_stop_bit  <= i_data_in_reg(10);

    -- PS2 clock falling edge detector
    i_clk_in_falling_edge_detected <= not ps2_clk_in and i_clk_in_falling_edge_detector_reg;
    process (clk)
    begin
        if rising_edge(clk) then
            i_data_in_delay_reg                <= ps2_dat_in;
            i_clk_in_falling_edge_detector_reg <= ps2_clk_in;
        end if;
    end process;

    -- Shift data in, when the rightmost bit in the register is low it will be detected as the start bit
    -- Also keeps track of parity
    i_start_bit_detected <= not i_data_in_reg(0);
    process (clk)
    begin
        if rising_edge(clk) then
            if rstn = '0' or i_start_bit_detected = '1' then
                i_data_in_reg        <= (others => '1');
                i_current_parity_reg <= '0';
            elsif i_clk_in_falling_edge_detected = '1' then
                -- Right shift
                i_data_in_reg(10 downto 0) <= i_data_in_delay_reg & i_data_in_reg(10 downto 1);
                i_current_parity_reg       <= i_data_in_delay_reg xor i_current_parity_reg;
            end if;
        end if;
    end process;

    -- Transfer shift register to output registers when start bit is detected
    -- Evaluate data to determine errors etc
    process (clk)
    begin
        if rising_edge(clk) then
            if i_start_bit_detected = '1' then
                scancode      <= i_data_in;
                framing_error <= i_start_bit or not i_stop_bit; -- Start bit expected low, stop bit expected high
                parity_error  <= i_current_parity_reg;
                ok            <= not i_start_bit and i_stop_bit and not i_current_parity_reg;
            end if;
        end if;
    end process;

    -- Transfer available every clock cycle, so that it is only active for one cycle
    process (clk)
    begin
        if rising_edge(clk) then
            available <= i_start_bit_detected;
        end if;
    end process;

end architecture;
