--------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:   20:12:27 09/13/2016
-- Design Name:
-- Module Name:   C:/Users/Fki/Documents/VHDL-Components/ws2812/test/bit_transfer_tb.vhd
-- Project Name:  GlowLine
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: bit_transfer
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

ENTITY bit_send_tb IS
END bit_send_tb;

ARCHITECTURE behavior OF bit_send_tb IS

    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT bit_send
    PORT(
         CLK_IN : IN  std_logic;
         RST_IN : IN  std_logic;
         START_IN : IN  std_logic;
         SEQ_STP_IN : IN  std_logic_vector(7 downto 0);
         STP_0H_IN : IN  std_logic_vector(7 downto 0);
         STP_1H_IN : IN  std_logic_vector(7 downto 0);
         BIT_IN : IN  std_logic;
         DAT_OUT : OUT  std_logic;
         BSY_OUT : OUT  std_logic;
         NB_OUT   : out std_logic
        );
    END COMPONENT;


   --Inputs
   signal CLK_IN : std_logic := '0';
   signal RST_IN : std_logic := '0';
   signal START_IN : std_logic := '0';
   signal SEQ_STP_IN : std_logic_vector(7 downto 0) := x"64";
   signal STP_0H_IN : std_logic_vector(7 downto 0) := x"28";
   signal STP_1H_IN : std_logic_vector(7 downto 0) := x"3C";
   signal BIT_IN : std_logic := '0';

  --Outputs
   signal DAT_OUT : std_logic;
   signal BSY_OUT : std_logic;
   signal NB_OUT : std_logic;

   -- Clock period definitions
   constant CLK_IN_period : time := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
   uut: bit_send PORT MAP (
          CLK_IN => CLK_IN,
          RST_IN => RST_IN,
          START_IN => START_IN,
          SEQ_STP_IN => SEQ_STP_IN,
          STP_0H_IN => STP_0H_IN,
          STP_1H_IN => STP_1H_IN,
          BIT_IN => BIT_IN,
          DAT_OUT => DAT_OUT,
          BSY_OUT => BSY_OUT,
          NB_OUT => NB_OUT
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
      RST_IN  <= '1';

      wait for CLK_IN_period*2;

      RST_IN  <= '0';

      wait until rising_edge(CLK_IN);

      START_IN  <= '1';
      wait until rising_edge(CLK_IN);

      START_IN  <= '0';
      wait until BSY_OUT = '0';
      --wait until rising_edge(CLK_IN);
      START_IN  <= '1';
      BIT_IN    <= '1';
      wait until rising_edge(CLK_IN);

      START_IN  <= '0';
      wait until NB_OUT = '1';

      START_IN  <= '1';
      BIT_IN    <= '1';

      wait until NB_OUT = '1';
      START_IN  <= '0';

      wait until BSY_OUT = '0';

      wait;
   end process;

END;
