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

entity WS_Encoder_top is
  port(
    CLK_IN      : in  std_logic;
    RST_IN      : in  std_logic;
    
    WR_IN       : in  std_logic;
    
    ADR_IN      : in  std_logic_vector(7 downto 0);
    DATA_IN     : in  std_logic_vector(7 downto 0);
    DATA_OUT    : out std_logic_vector(7 downto 0);
    
    M_RD_OUT    : out std_logic;
    
    M_ADR_OUT   : out std_logic_vector(7 downto 0);
    M_DATA_IN   : in  std_logic_vector(7 downto 0) 
  );
end WS_Encoder_top;