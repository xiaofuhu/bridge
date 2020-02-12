LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY bridge_fake_enc IS
    PORT (
        clk             : IN    STD_LOGIC;          -- fpga clock
        rst             : IN    STD_LOGIC;          -- fpga reset
        clk_in          : IN    STD_LOGIC;          -- protocal clock
        data_out        : OUT   STD_LOGIC;          -- data to roboteq
        data_in         : IN    STD_LOGIC           -- data from buffer
    );
END bridge_top;

ARCHITECTURE rtl OF bridge_top IS

    TYPE edge_type IS ARRAY (0 TO 1) OF STD_LOGIC;
    SIGNAL      edge     : edge_type;                   -- edge detector for protocal clock

BEGIN

    PROC_EDGE :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                edge(1) <= '1';
                edge(0) <= '1';
            ELSE   
                edge(1) <= edge(0);
                edge(0) <= clk_in;
            END IF;
        END IF;
    END PROCESS;

    PROC_DATA :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                data_out <= '0';
            ELSIF edge(0) = '0' AND edge(1) = '1' THEN
                data_out <= data_in;
            END IF;
        END IF;
    END PROCESS;

END rtl;