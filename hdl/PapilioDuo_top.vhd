----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     NeoPixel
-- Module Name:     NeoPixel_top
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

entity PapilioDuo_top is
  port(
    --System clock
    CLK_IN          : in  std_logic;
    
    --Reset button, negative logic, needs synchronisation
    RST_BTN_N_IN    : in  std_logic;
    AVR_RST_OUT		  : out std_logic;
    
    --UART-lines
    RXD_IN          : in  std_logic;
    TXD_OUT         : out std_logic;

    --SPI-lines
    CS_IN           : in  std_logic;
    SCLK_IN         : in  std_logic;
    MOSI_IN         : in  std_logic;
    MISO_OUT        : out std_logic;
    
    --Data signal to NeoPixel-LED
    PIXEL_OUT       : out std_logic;
    
    --Config-Pins, needs synchronisation
    AUTO_SWITCH_IN  : in  std_logic;
    
    --Diagnosis LEDs
    --LED_RST_OUT     : out std_logic;
    LED_AUTO_OUT    : out std_logic
    --LED_RX_OUT      : out std_logic;
    --LED_RUNNING_OUT : out std_logic
  );
end PapilioDuo_top;


architecture RTL of PapilioDuo_top is

component NeoPixel_top is
  port(
    --System clock
    CLK_IN          : in  std_logic;
    
    RST_BTN_N_IN    : in  std_logic;
    
    --Config-Pins, negative logic, needs synchronisation
    AUTO_SWITCH_IN  : in  std_logic;
    AUTO_LED_OUT    : out std_logic;

    --SPI-lines
    CS_IN           : in  std_logic;
    SCLK_IN         : in  std_logic;
    MOSI_IN         : in  std_logic;
    MISO_OUT        : out std_logic;
    
    --UART-lines
    RXD_IN          : in  std_logic;
    TXD_OUT         : out std_logic;
    
    --Data signal to NeoPixel-LED
    PIXEL_OUT       : out std_logic
  );
end component;

begin

Engine: NeoPixel_top 
  port map(
    --System clock
    CLK_IN          => CLK_IN,
    
    RST_BTN_N_IN    => RST_BTN_N_IN,
    --Config-Pins, negative logic, needs synchronisation
    AUTO_SWITCH_IN  => AUTO_SWITCH_IN,
    AUTO_LED_OUT    => LED_AUTO_OUT,

    --SPI-lines
    CS_IN           => CS_IN,
    SCLK_IN         => SCLK_IN,
    MOSI_IN         => MOSI_IN,
    MISO_OUT        => MISO_OUT,
    
    --UART-lines
    RXD_IN          => RXD_IN,
    TXD_OUT         => TXD_OUT,
    
    --Data signal to NeoPixel-LED
    PIXEL_OUT       => PIXEL_OUT
  );
  
AVR_RST_OUT <=  '1'; --AVR active

end RTL;