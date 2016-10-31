----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     
-- Module Name:     
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
-- 
--
--
-- Revision:
-- Revision 0.1 File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity NeoPixel_top is
  port(
    CLK_IN      : in  std_logic;
    
    RST_BTN_IN  : in  std_logic;
    
    CS_IN       : in  std_logic;
    SCLK_IN     : in  std_logic;
    MOSI_IN     : in  std_logic;
    MISO_OUT    : out std_logic;
    
    RXD_IN      : in  std_logic;
    TXD_OUT     : out std_logic;
    
    PIXEL_OUT   : out std_logic
  );
end NeoPixel_top;