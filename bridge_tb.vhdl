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

BEGIN
    b0 : bridge_top
        PORT MAP (
            clk => clk,
            rst => rst,
            clk_in => clk_in,
            clk_out => clk_out,
            data_in => data_in,
            data_out => data_out
        );
    
    PROCESS
        TYPE arr IS ARRAY (0 TO 13) OF STD_LOGIC;
        CONSTANT input : arr :=
            ('1','0','1','0','1','0','1','0','1','0','1','0','1','0');
    
    BEGIN
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        FOR i IN 1 TO 200 LOOP
            clk <= NOT clk;
            wait for 5 ns;
            clk <= NOT clk;
            wait for 5 ns;
        END LOOP;
        WAIT;
    END PROCESS;

    PROCESS BEGIN
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        FOR i IN 0 TO 5 LOOP
            FOR j in 0 TO 15 LOOP
                clk_in <= NOT clk_in;
                wait for 20 ns;
                clk_in <= NOT clk_in;
                wait for 20 ns;
            END LOOP;
            wait for 300 ns;
        END LOOP;
        WAIT;
    END PROCESS;
END BEHAV;