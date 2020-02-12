LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY bridge_fake_rob IS
    GENERIC (
        half_period     : NATURAL := 500           -- protocol clock 1000 times slower than fpga clock
    );
    PORT (
        clk             : IN    STD_LOGIC;          -- fpga clock
        rst             : IN    STD_LOGIC;          -- fpga reset
        clk_out         : OUT   STD_LOGIC;          -- new clock
        data_out        : OUT   STD_LOGIC;          -- data to buffer
        data_in         : IN    STD_LOGIC           -- data from encoder
    );
END bridge_fake_rob;

ARCHITECTURE rtl OF bridge_fake_rob IS

    TYPE edge_type IS ARRAY (0 TO 1) OF STD_LOGIC;
    SIGNAL      edge     : edge_type;                   -- edge detector for protocal clock

    SUBTYPE count_type IS INTEGER RANGE 0 TO half_period;
    SIGNAL      count   : count_type;
    SIGNAL      clk_i   : STD_LOGIC;

BEGIN

    clk_out <= clk_i;

    PROC_EDGE :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                edge(1) <= '1';
                edge(0) <= '1';
            ELSE   
                edge(1) <= edge(0);
                edge(0) <= clk_i;
            END IF;
        END IF;
    END PROCESS;

    PROC_CLK_GEN :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                clk_i <= '1';
                count <= 0;
            ELSE
                IF count >= half_period - 1 THEN
                    clk_i <= NOT clk_i;
                    count <= 0;
                ELSE
                    count <= count + 1;
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