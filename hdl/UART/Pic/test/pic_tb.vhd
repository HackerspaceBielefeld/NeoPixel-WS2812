----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     PIC
-- Module Name:     PIC_TB
-- Target Device:
-- Tool versions:
-- Description:
--
-- VHDL Test Bench Created by ISE for module: PIC
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
USE ieee.numeric_std.ALL;

ENTITY PIC_TB IS
END PIC_TB;

ARCHITECTURE behavior OF PIC_TB IS

    -- Component Declaration for the Unit Under Test (UUT)

  COMPONENT PIC is
    generic(
      CNT_WIDTH : positive        :=  16
    );
    port(
      CLK_IN    : in  std_logic;        -- Main clock
      CNT_EN_IN : in  std_logic;        -- Counter enable
      LOAD_IN   : in  std_logic_vector(CNT_WIDTH-1 downto 0);  --  Initial value for counter
      TICK_OUT  : out std_logic         -- Generated clock tick
    );
  end component;

  constant  CNT_WIDTH : positive  :=  16;

   --Inputs
   signal CLK_IN      : std_logic := '0';
   signal CNT_EN_IN   : std_logic := '0';
   signal LOAD_IN     : std_logic_vector(CNT_WIDTH-1 downto 0) := (others => '0');

  --Outputs
   signal TICK_OUT    : std_logic;

   -- Clock period definitions
   constant CLK_IN_period : time := 10 ns;

BEGIN

  -- Instantiate the Unit Under Test (UUT)
  uut: PIC
    generic map(
      CNT_WIDTH =>  CNT_WIDTH
    )
    PORT MAP (
      CLK_IN    => CLK_IN,
      CNT_EN_IN => CNT_EN_IN,
      LOAD_IN   => LOAD_IN,
      TICK_OUT  => TICK_OUT
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

    wait until rising_edge(CLK_IN);
    LOAD_IN <=  x"000A";

    wait until rising_edge(CLK_IN);

    wait until rising_edge(CLK_IN);
    CNT_EN_IN   <= '1';

    wait for CLK_IN_period * 25;
    CNT_EN_IN   <= '0';

    wait until rising_edge(CLK_IN);
    wait for CLK_IN_period * 25;

    wait;
  end process;

END;
