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

entity BIUI_top is
  port(
    M_RD_IN     : in  std_logic;
    M_WR_IN     : in  std_logic;
    
    M_ADR_IN    : in  std_logic_vector(3 downto 0);
    M_DATA_IN   : in  std_logic_vector(7 downto 0);
    M_DATA_OUT  : out std_logic_vector(7 downto 0);
    
    S0_RD_OUT   : out std_logic;
    S0_WR_OUT   : out std_logic;

    S0_ADR_OUT  : out std_logic_vector(2 downto 0);
    S0_DATA_OUT : out std_logic_vector(7 downto 0);
    S0_DATA_IN  : in  std_logic_vector(7 downto 0);
    
    S1_RD_OUT   : out std_logic;
    S1_WR_OUT   : out std_logic;

    S1_ADR_OUT  : out std_logic_vector(2 downto 0);
    S1_DATA_OUT : out std_logic_vector(7 downto 0);
    S1_DATA_IN  : in  std_logic_vector(7 downto 0) 
  );
end BIUI_top;

architecture RTL of BIUI_top is

begin
  
  M_DATA_OUT  <=  S0_DATA_IN when M_ADR_IN(3) = '0' else S1_DATA_IN;
  
  S0_RD_OUT   <=  M_RD_IN when M_ADR_IN(3) = '0' else '0';
  S0_WR_OUT   <=  M_WR_IN when M_ADR_IN(3) = '0' else '0';
  S0_ADR_OUT  <=  M_ADR_IN(2 downto 0);
  S0_DATA_OUT <=  M_DATA_IN;
  
  S1_RD_OUT   <=  M_RD_IN when M_ADR_IN(3) = '1' else '0';
  S1_WR_OUT   <=  M_WR_IN when M_ADR_IN(3) = '1' else '0';
  S1_ADR_OUT  <=  M_ADR_IN(2 downto 0);
  S1_DATA_OUT <=  M_DATA_IN;

end RTL;