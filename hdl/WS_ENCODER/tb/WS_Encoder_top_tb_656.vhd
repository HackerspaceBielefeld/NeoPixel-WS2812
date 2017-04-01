--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:45:57 03/15/2017
-- Design Name:   
-- Module Name:   C:/Users/Fki/Documents/NeoPixel/hdl/WS_ENCODER/tb/WS_Encoder_top_tb.vhd
-- Project Name:  NeoPixel
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: WS_Encoder_top
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
 
ENTITY WS_Encoder_top_tb_565 IS
END WS_Encoder_top_tb_565;
 
ARCHITECTURE behavior OF WS_Encoder_top_tb_565 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT WS_Encoder_top
    PORT(
         CLK_IN     : IN  std_logic;
         RST_IN     : IN  std_logic;
         WR_IN      : IN  std_logic;
         ADR_IN     : IN  std_logic_vector(3 downto 0);
         DATA_IN    : IN  std_logic_vector(7 downto 0);
         DATA_OUT   : OUT std_logic_vector(7 downto 0);
         PIXEL_OUT  : OUT std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK_IN    : std_logic := '0';
   signal RST_IN    : std_logic := '1';
   signal WR_IN     : std_logic := '0';
   signal ADR_IN    : std_logic_vector(3 downto 0)  := (others => '0');
   signal DATA_IN   : std_logic_vector(7 downto 0)  := (others => '0');


 	--Outputs
   signal PIXEL_OUT : std_logic;
   signal DATA_OUT   : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant CLK_IN_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: WS_Encoder_top PORT MAP (
          CLK_IN    => CLK_IN,
          RST_IN    => RST_IN,
          WR_IN     => WR_IN,
          ADR_IN    => ADR_IN,
          DATA_IN   => DATA_IN,
          DATA_OUT  => DATA_OUT,
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
      RST_IN  <=  '0';
      wait until rising_edge(CLK_IN);
      
      ADR_IN  <=  "0000";
      DATA_IN <=  x"08";
      WR_IN   <=  '1';
      wait until rising_edge(CLK_IN);
      
      WR_IN   <=  '0';
      wait until rising_edge(CLK_IN);
      
      ADR_IN  <=  "1000";
      DATA_IN <=  x"AA";
      WR_IN   <=  '1';
      wait until rising_edge(CLK_IN);
      
      --WR_IN   <=  '0';
      --wait until rising_edge(CLK_IN);
      
      --ADR_IN  <=  "1000";
      DATA_IN <=  x"55";
      --WR_IN   <=  '1';
      wait until rising_edge(CLK_IN);
      
      --WR_IN   <=  '0';
      --wait until rising_edge(CLK_IN);
      

      --ADR_IN  <=  "1000";
      DATA_IN <=  x"cd";
      --WR_IN   <=  '1';
      wait until rising_edge(CLK_IN);
      
      --WR_IN   <=  '0';
      --wait until rising_edge(CLK_IN);
      
      --ADR_IN  <=  "1000";
      DATA_IN <=  x"24";
      --WR_IN   <=  '1';
      wait until rising_edge(CLK_IN);
      
      WR_IN   <=  '0';
      wait until rising_edge(CLK_IN);
      
      ADR_IN  <=  "0000";
      DATA_IN <=  x"09";
      WR_IN   <=  '1';
      wait until rising_edge(CLK_IN);
      
      WR_IN   <=  '0';
      wait until rising_edge(CLK_IN);
      
      wait;
   end process;

END;
