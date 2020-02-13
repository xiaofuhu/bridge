LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY bridge_buffer IS
    GENERIC (
        ram_len         : NATURAL := 17
    );
    PORT (
        clk             : IN    STD_LOGIC;          -- fpga clock
        rst             : IN    STD_LOGIC;          -- fpga reset
        clk_in          : IN    STD_LOGIC;          -- protocal clock
        clk_out         : IN    STD_LOGIC;          -- new clock
        data_out        : OUT   STD_LOGIC;          -- data to fake enc
        data_in         : IN    STD_LOGIC           -- data from fake rob
    );
END bridge_buffer;

ARCHITECTURE rtl OF bridge_buffer IS

    TYPE ram_type IS ARRAY (0 TO ram_len - 1) OF STD_LOGIC;
    SIGNAL      ram         : ram_type;

    TYPE edge_type IS ARRAY (0 TO 1) OF STD_LOGIC;
    SIGNAL      edge_wr     : edge_type;                -- edge detector for protocal clock in
    SIGNAL      edge_rd     : edge_type;                -- edge detector for protocal clock out

    SUBTYPE index_type IS INTEGER RANGE ram_type'range;
    SIGNAL      wr_i        : index_type;               -- writer index
    SIGNAL      rd_i        : index_type;               -- reader index
    
    SIGNAL      h_period        : INTEGER;
    SIGNAL      tmp_h_period    : INTEGER;
    SIGNAL      count           : INTEGER RANGE 0 TO INTEGER'HIGH;
    SIGNAL      realign         : STD_LOGIC := '0';

BEGIN

    PROC_EDGE :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                edge_wr(1) <= '1';
                edge_wr(0) <= '1';
                edge_rd(1) <= '1';
                edge_rd(0) <= '1';                      -- so as to capture the first falling edge to come
            ELSE   
                edge_wr(1) <= edge_wr(0);
                edge_wr(0) <= clk_out;
                edge_rd(1) <= edge_rd(0);
                edge_rd(0) <= clk_in;
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
                IF (edge_wr(0) = '0' AND edge_wr(1) = '1') OR (edge_wr(0) = '1' AND edge_wr(1) = '0') THEN
                    h_period <= tmp_h_period;
                    tmp_h_period <= 0;
                ELSE
                    tmp_h_period <= tmp_h_period + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    
    PROC_ADJUST :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' THEN
                count <= 0;
            ELSE
                IF (edge_wr(0) = '0' AND edge_wr(1) = '1') OR (edge_wr(0) = '1' AND edge_wr(1) = '0') THEN
                    count <= 0;
                ELSIF count < 4 * h_period THEN
                    count <= count + 1;
                ELSE
                    count <= count;
                END IF;
                IF count > 2 * h_period AND count < 3 * h_period THEN
                    realign <= '1';
                ELSE
                    realign <= '0';
                END IF;
            END IF;
        END IF;
    END PROCESS;

    PROC_WRITE :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' OR realign = '1' THEN
                wr_i <= 0;
            ELSIF edge_wr(0) = '0' AND edge_wr(1) = '1' THEN
                ram(wr_i) <= data_in;                   -- write ram
                IF wr_i >= ram_len THEN
                    wr_i <= 0;
                ELSE
                    wr_i <= wr_i + 1;
                END IF;                                 -- move pointer
            END IF;
        END IF;
    END PROCESS;

    PROC_READ :
    PROCESS(clk) BEGIN
        IF RISING_EDGE(clk) THEN
            IF rst = '1' OR realign = '1' THEN
                rd_i <= 1;
            ELSIF edge_rd(0) = '0' AND edge_rd(1) = '1' THEN
                data_out <= ram(rd_i);
                IF rd_i >= ram_len THEN
                    rd_i <= 1;                        -- read starts at index 1
                ELSE
                    rd_i <= rd_i + 1;
                END IF;                                 -- move pointer
            END IF;
        END IF;
    END PROCESS;
    
END rtl;