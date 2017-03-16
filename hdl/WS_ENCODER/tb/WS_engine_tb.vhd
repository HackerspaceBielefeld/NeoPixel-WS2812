--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:04:12 03/16/2017
-- Design Name:   
-- Module Name:   C:/Users/Fki/Documents/NeoPixel/hdl/WS_ENCODER/tb/WS_engine_tb.vhd
-- Project Name:  NeoPixel
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: WS_engine
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY WS_engine_tb IS
END WS_engine_tb;
 
ARCHITECTURE behavior OF WS_engine_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT WS_engine
    PORT(
         CLK_IN : IN  std_logic;
         RST_IN : IN  std_logic;
         ENA_IN : IN  std_logic;
         T1H_IN : IN  std_logic_vector(7 downto 0);
         T0H_IN : IN  std_logic_vector(7 downto 0);
         BIT_SEQ_IN : IN  std_logic_vector(7 downto 0);
         RST_CNT_IN : IN  std_logic_vector(15 downto 0);
         LED_CNT_IN : IN  std_logic_vector(8 downto 0);
         ADR_OUT : OUT  std_logic_vector(8 downto 0);
         DATA_IN : IN  std_logic_vector(23 downto 0);
         PIXEL_OUT : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_IN : std_logic := '0';
   signal RST_IN : std_logic := '1';
   signal ENA_IN : std_logic := '0';
   signal T1H_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal T0H_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal BIT_SEQ_IN : std_logic_vector(7 downto 0) := (others => '0');
   signal RST_CNT_IN : std_logic_vector(15 downto 0) := (others => '0');
   signal LED_CNT_IN : std_logic_vector(8 downto 0) := (others => '0');
   signal DATA_IN : std_logic_vector(23 downto 0) := (others => '0');

 	--Outputs
   signal ADR_OUT : std_logic_vector(8 downto 0);
   signal PIXEL_OUT : std_logic;

   -- Clock period definitions
   constant CLK_IN_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: WS_engine PORT MAP (
          CLK_IN => CLK_IN,
          RST_IN => RST_IN,
          ENA_IN => ENA_IN,
          T1H_IN => T1H_IN,
          T0H_IN => T0H_IN,
          BIT_SEQ_IN => BIT_SEQ_IN,
          RST_CNT_IN => RST_CNT_IN,
          LED_CNT_IN => LED_CNT_IN,
          ADR_OUT => ADR_OUT,
          DATA_IN => DATA_IN,
          PIXEL_OUT => PIXEL_OUT
        );

   -- Clock process definitions
   CLK_IN_process :process
   begin
		CLK_IN <= '0';
		wait for CLK_IN_period/2;
		CLK_IN <= '1';
		wait for CLK_IN_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      RST_IN <= '0';
      wait for CLK_IN_period*10;

      T0H_IN      <=  std_logic_vector(to_unsigned(39, 8));
      T1H_IN      <=  std_logic_vector(to_unsigned(79, 8));
      BIT_SEQ_IN  <=  std_logic_vector(to_unsigned(124, 8));
      RST_CNT_IN  <=  std_logic_vector(to_unsigned(4999, 16));
      LED_CNT_IN  <=  std_logic_vector(to_unsigned(511, 9));
      DATA_IN     <=  x"000000";
      wait until falling_edge(CLK_IN);
      
      ENA_IN <= '1';
      wait until falling_edge(CLK_IN);
      
      ENA_IN <= '0';
      
      wait until ADR_OUT(0) = '1';
      wait until falling_edge(CLK_IN);
      DATA_IN <=  x"F90F09";
      wait;
   end process;

END;
