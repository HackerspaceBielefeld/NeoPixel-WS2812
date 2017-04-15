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
    
    --Config-Pins, needs synchronisation
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
    PIXEL_OUT       : out std_logic;
	
    AVR_RST_OUT		  : out std_logic
  );
end PapilioDuo_top;


architecture RTL of PapilioDuo_top is

component PLL
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_OUT1          : out    std_logic;
  -- Status and control signals
  RESET             : in     std_logic;
  LOCKED            : out    std_logic
 );
end component;

component NeoPixel_top is
  port(
    --System clock
    CLK_IN          : in  std_logic;
    RST_IN          : in  std_logic;
    
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

signal sysClk   : std_logic;
signal sysRst   : std_logic;
signal locked   : std_logic;
signal pllRst   : std_logic;
signal rstSync  : std_logic_vector(5 downto 0);

signal shiftEna : std_logic;
signal cBtnPre  : unsigned(7 downto 0);
signal nBtnPre  : unsigned(7 downto 0);

begin

Engine: NeoPixel_top 
  port map(
    --System clock
    CLK_IN          => sysClk,
    RST_IN          => sysRst,
    
    --Config-Pins, negative logic, needs synchronisation
    AUTO_SWITCH_IN  => AUTO_SWITCH_IN,
    AUTO_LED_OUT    => AUTO_LED_OUT,

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

SysClk_inst : PLL
  port map
  (-- Clock in ports
    CLK_IN1 => CLK_IN,
    -- Clock out ports
    CLK_OUT1 => sysClk,
    -- Status and control signals
    RESET  => pllRst,
    LOCKED => locked
  );
  
pllRst      <=  '0';
sysRst      <=  (not locked) or pllRst;
AVR_RST_OUT <=  '0';

rstSync_tl: process(cBtnPre, rstSync)
begin
  nBtnPre     <=  cBtnPre + 1;
  shiftEna    <=  '0';
  
  if cBtnPre = x"FF" then
    nBtnPre   <=  x"00";
    shiftEna  <=  '1';
  end if;
  
end process;
  
rstSync_reg: process(sysClk)
begin
  if rising_edge(sysClk) then
    if locked = '0' then
      cBtnPre   <=  x"00";
      rstSync   <=  "000000";
    else
      cBtnPre   <=  nBtnPre;
    
      if shiftEna = '1' then
        rstSync   <=  rstSync(4 downto 0) & RST_BTN_N_IN;
      end if;
    end if;
  end if;
end process;

end RTL;