LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY bridge_fake_rob IS
    GENERIC (
        num_clk         : NATURAL := 17
    );
    PORT (
        clk             : IN    STD_LOGIC;          -- fpga clock
        rst             : IN    STD_LOGIC;          -- fpga reset
        clk_in          : IN    STD_LOGIC;          -- protocal clock
        clk_out         : OUT   STD_LOGIC;          -- new clock
        data_out        : OUT   STD_LOGIC;          -- data to buffer
        data_in         : IN    STD_LOGIC           -- data from encoder
    );
END bridge_fake_rob;

ARCHITECTURE rtl OF bridge_fake_rob IS

    TYPE edge_type IS ARRAY (0 TO 1) OF STD_LOGIC;
    SIGNAL      edge            : edge_type;                   -- edge detector for protocal clock
    SIGNAL      edge_gen        : edge_type;

    SIGNAL      h_period        : INTEGER;
    SIGNAL      tmp_h_period    : INTEGER;
    SIGNAL      count           : INTEGER;
    SIGNAL      ticks           : INTEGER;
    SIGNAL      clk_s           : STD_LOGIC;
    SIGNAL      clk_i           : STD_LOGIC;
    SIGNAL      rst_data        : STD_LOGIC;

BEGIN

    clk_out <= clk_s;

    PROC_EDGE :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                edge(1) <= '1';
                edge(0) <= '1';
                edge_gen(1) <= '1';
                edge_gen(0) <= '1';
            ELSE   
                edge(1) <= edge(0);
                edge(0) <= clk_in;
                edge_gen(1) <= edge_gen(0);
                edge_gen(0) <= clk_s;
            END IF;
        END IF;
    END PROCESS;

    PROC_H_PERIOD :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                h_period <= 0;
                tmp_h_period <= 0;
            ELSE
                IF edge(0) = '0' AND edge(1) = '1' THEN
                    tmp_h_period <= 0;
                ELSIF edge(0) = '1' AND edge(1) = '0' THEN
                    h_period <= tmp_h_period;
                ELSE
                    tmp_h_period <= tmp_h_period + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROC_CLK_GEN :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                clk_s <= '1';
                clk_i <= '1';
                count <= 0;
                ticks <= 0;
                rst_data <= '0';
            ELSE
                IF edge_gen(0) = '1' AND edge_gen(1) = '0' THEN
                    IF ticks < num_clk THEN
                        ticks <= ticks + 1;
                    ELSE
                        ticks <= 0;
                    END IF;
                END IF;

                IF ticks >= num_clk - 1 THEN
                    IF count < h_period THEN
                        clk_i <= '1';
                        count <= count + 1;
                    ELSIF count < h_period + h_period THEN
                        clk_i <= '0';
                        count <= count + 1;
                    ELSE
                        clk_i <= '1';
                        count <= 0;
                    END IF;
                END IF;

                IF ticks < num_clk - 1 THEN
                    clk_s <= clk_in;
                ELSE
                    clk_s <= clk_i;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROC_DATA :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' OR rst_data = '1' THEN
                data_out <= '1';
            ELSIF edge(0) = '0' AND edge(1) = '1' THEN
                data_out <= data_in;
            END IF;
        END IF;        
    END PROCESS;

END rtl;