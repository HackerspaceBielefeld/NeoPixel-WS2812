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

entity Controller_top is
  port(
    CLK_IN      : in  std_logic;
    RST_IN      : in  std_logic;
    
    A_RD_OUT    : out  std_logic;
    A_WR_OUT    : out  std_logic;
    
    A_ADR_OUT   : out std_logic_vector(7 downto 0);
    A_DATA_OUT  : out std_logic_vector(7 downto 0);
    A_DATA_IN   : in  std_logic_vector(7 downto 0);
    
    B_WR_OUT    : out std_logic;
    
    B_ADR_OUT   : out std_logic_vector(7 downto 0);
    B_DATA_OUT  : out std_logic_vector(7 downto 0);
    B_DATA_IN   : in  std_logic_vector(7 downto 0) 
  );
end Controller_top;