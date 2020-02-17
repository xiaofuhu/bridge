LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY bridge_tb IS
END bridge_tb;

ARCHITECTURE BEHAV OF bridge_tb IS
    COMPONENT bridge_top
        PORT (
            clk             : IN    STD_LOGIC;          -- fpga clock
            rst             : IN    STD_LOGIC;          -- fpga reset
            clk_in          : IN    STD_LOGIC;          -- protocal clock
            data_out        : OUT   STD_LOGIC;          -- data to roboteq
            data_out_inv    : OUT   STD_LOGIC;          -- data to roboteq
            clk_out         : OUT   STD_LOGIC;          -- new clock
            data_in         : IN    STD_LOGIC           -- data from encoder
        );
    END COMPONENT;


    FOR b0 : bridge_top USE ENTITY work.bridge_top;

    SIGNAL clk      : STD_LOGIC := '1';
    SIGNAL rst      : STD_LOGIC := '0';
    SIGNAL clk_in   : STD_LOGIC := '1';
    SIGNAL clk_out  : STD_LOGIC;
    SIGNAL data_in  : STD_LOGIC;
    SIGNAL data_out : STD_LOGIC;
    SIGNAL data_out_inv : STD_LOGIC;

BEGIN
    b0 : bridge_top
        PORT MAP (
            clk => clk,
            rst => rst,
            clk_in => clk_in,
            clk_out => clk_out,
            data_in => data_in,
            data_out => data_out,
            data_out_inv => data_out_inv
        );
    
    PROCESS BEGIN
        rst <= '1';
        wait for 200 ns;
        rst <= '0';
        FOR i IN 1 TO 4000 LOOP
            clk <= NOT clk;
            wait for 1 ns;
            clk <= NOT clk;
            wait for 1 ns;
        END LOOP;
        WAIT;
    END PROCESS;

    PROCESS
        TYPE arr IS ARRAY (0 TO 15) OF STD_LOGIC;
        CONSTANT input : arr :=
            ('0','1','1','1','1','0','0','1','0','0','0','1','0','1','0','1');
    BEGIN
        wait for 200 ns;
        FOR i IN 0 TO 4 LOOP
            FOR j in 0 TO 15 LOOP
                clk_in <= NOT clk_in;
                wait for 20 ns;
                data_in <= input(j);
                clk_in <= NOT clk_in;
                wait for 20 ns;
            END LOOP;
            wait for 600 ns;
        END LOOP;
        WAIT;
    END PROCESS;
    
--    PROCESS 
--        TYPE arr IS ARRAY (0 TO 15) OF STD_LOGIC;
--        CONSTANT input : arr :=
--            ('1','1','1','1','1','0','0','1','0','0','0','1','0','1');
--    BEGIN
--        wait for 200 ns;
--        FOR i IN 0 TO 4 LOOP
--            FOR j in input'RANGE LOOP
--                data_in <= input(j);
--                wait for 40 ns;
--            END LOOP;
--            wait for 600 ns;
--        END LOOP;
--        WAIT;
--    END PROCESS;
END BEHAV;