--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   00:27:36 04/16/2017
-- Design Name:   
-- Module Name:   C:/Users/Fki/Documents/NeoPixel/hdl/tb/PapilioDuo_top_tb.vhd
-- Project Name:  NeoPixel
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PapilioDuo_top
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
--USE ieee.numeric_std.ALL;
 
ENTITY PapilioDuo_top_tb IS
END PapilioDuo_top_tb;
 
ARCHITECTURE behavior OF PapilioDuo_top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PapilioDuo_top
    PORT(
         CLK_IN : IN  std_logic;
         RST_BTN_N_IN : IN  std_logic;
         AUTO_SWITCH_IN : IN  std_logic;
         AUTO_LED_OUT : OUT  std_logic;
         CS_IN : IN  std_logic;
         SCLK_IN : IN  std_logic;
         MOSI_IN : IN  std_logic;
         MISO_OUT : OUT  std_logic;
         RXD_IN : IN  std_logic;
         TXD_OUT : OUT  std_logic;
         PIXEL_OUT : OUT  std_logic;
         AVR_RST_OUT : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_IN : std_logic := '0';
   signal RST_BTN_N_IN : std_logic := '0';
   signal AUTO_SWITCH_IN : std_logic := '1';
   signal CS_IN : std_logic := '0';
   signal SCLK_IN : std_logic := '0';
   signal MOSI_IN : std_logic := '0';
   signal RXD_IN : std_logic := '0';

 	--Outputs
   signal AUTO_LED_OUT : std_logic;
   signal MISO_OUT : std_logic;
   signal TXD_OUT : std_logic;
   signal PIXEL_OUT : std_logic;
   signal AVR_RST_OUT : std_logic;

   -- Clock period definitions
   constant CLK_IN_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PapilioDuo_top PORT MAP (
          CLK_IN => CLK_IN,
          RST_BTN_N_IN => RST_BTN_N_IN,
          AUTO_SWITCH_IN => AUTO_SWITCH_IN,
          AUTO_LED_OUT => AUTO_LED_OUT,
          CS_IN => CS_IN,
          SCLK_IN => SCLK_IN,
          MOSI_IN => MOSI_IN,
          MISO_OUT => MISO_OUT,
          RXD_IN => RXD_IN,
          TXD_OUT => TXD_OUT,
          PIXEL_OUT => PIXEL_OUT,
          AVR_RST_OUT => AVR_RST_OUT
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
        RST_BTN_N_IN  <= '1';
      wait for CLK_IN_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
