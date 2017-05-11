----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Version:         0.1
--
-- Design Name:     Syscon
-- Module Name:     WS_ENCODER
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7 / Vivado
-- Description:
-- Encapsulates the PLL and the sychronisation for RST_BTN_IN.
--
-- Revision:
-- Revision 0.1 File created
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
    CLK_IN1           : in     std_logic;
    -- Clock out ports
    CLK_OUT1          : out    std_logic;
    -- Status and control signals
    RESET             : in     std_logic;
    LOCKED            : out    std_logic
  );
end component;

signal sysClk : std_logic;
signal locked : std_logic;
signal rstSr  : std_logic_vector(1 downto 0);

begin

SysClk_inst : PLL
  port map
  (-- Clock in ports
    CLK_IN1 => EXT_CLK_IN,
    -- Clock out ports
    CLK_OUT1 => sysClk,
    -- Status and control signals
    RESET  => '0',
    LOCKED => locked
  );

  CLK_O   <=  sysClk;
  
  sync: process(sysClk)
  begin
    if rising_edge(sysClk) then
      if locked = '1' then
        rstSr   <=  rstSr(0) & RST_BTN_N_IN;
        RST_O   <=  (not rstSr(1)) and (not locked);
      end if;
    end if;
  end process;
  
end RTL;