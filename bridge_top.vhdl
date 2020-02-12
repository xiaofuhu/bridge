LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Top entity of the bridge
-- Take a 16-cycle reader to take data from a 17-cycle encoder, which
-- warms up at the first cycle and outputs 16 bits of data.
--
-- The bridge uses a sub-entity to generate an output clock (clk_out) at the same
-- frequency as the protocol clock (clk_in) to take 17 bits of data from
-- the encoder, with the MSB being invalid. The data is constantly read
-- into the buffer. The bridge uses a sub-entity to take the protocol clock
-- and reads the 16 least significant bits from the buffer.

ENTITY bridge_top IS
    PORT (
        clk             : IN    STD_LOGIC;          -- fpga clock
        rst             : IN    STD_LOGIC;          -- fpga reset
        clk_in          : IN    STD_LOGIC;          -- protocal clock
        data_out        : OUT   STD_LOGIC;          -- data to roboteq
        clk_out         : OUT   STD_LOGIC;          -- new clock
        data_in         : IN    STD_LOGIC           -- data from encoder
    );
END bridge_top;

ARCHITECTURE rtl OF bridge_top IS

    SIGNAL      data_from_buffer        : STD_LOGIC;
    SIGNAL      data_to_buffer          : STD_LOGIC;
    SIGNAL      clk_out_s               : STD_LOGIC;

BEGIN

    clk_out <= clk_out_s;

    fake_enc : ENTITY work.bridge_fake_enc
        PORT MAP (
            clk         => clk,
            rst         => rst,
            clk_in      => clk_in,
            data_out    => data_out,
            data_in     => data_from_buffer
        );

    buff : ENTITY work.bridge_buffer
        PORT MAP (
            clk         => clk,
            rst         => rst,
            clk_in      => clk_in,
            clk_out     => clk_out_s,             -- NOTE: this is an input (signal from fake rob)
            data_out    => data_from_buffer,
            data_in     => data_to_buffer
        );

    fake_rob : ENTITY work.bridge_fake_rob
        PORT MAP (
            clk         => clk,
            rst         => rst,
            clk_in      => clk_in,
            clk_out     => clk_out_s,
            data_out    => data_to_buffer,
            data_in     => data_in
        );
    
END rtl;