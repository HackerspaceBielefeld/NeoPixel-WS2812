----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Version:         1.0
--
-- Design Name:     Syscon
-- Module Name:     WS_ENCODER
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7 / Vivado
-- Description:
-- Encapsulates the PLL IP CORE and provides the internal clock (100MHz from 32MHz)
-- and the system RESET signal. The external reset signal (RST_BTN_N_IN) is active
-- low, the internal one (RST_O) active high.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Syscon is
  port(
    EXT_CLK_IN    : in  std_logic;
    RST_BTN_N_IN  : in  std_logic;

    CLK_O         : out std_logic;
    RST_O         : out std_logic
  );
end Syscon;

architecture RTL of Syscon is

component PLL
port
 (-- Clock in ports
  CLK_IN           : in     std_logic;
  -- Clock out ports
  CLK_OUT          : out    std_logic;
  -- Status and control signals
  RST_IN           : in     std_logic;
  CLK_VALID_OUT    : out    std_logic
 );
end component;

signal clk_valid : std_logic;
signal ext_reset : std_logic;

begin

SysClk_inst : PLL
  port map
  ( -- Clock in ports
    CLK_IN          => EXT_CLK_IN,
    -- Clock out ports
    CLK_OUT         => CLK_O,
    -- Status and control signals
    RST_IN          => ext_reset,
    CLK_VALID_OUT => clk_valid
  );

  ext_reset <=  (not RST_BTN_N_IN);
  RST_O   <=  (not clk_valid);

end RTL;