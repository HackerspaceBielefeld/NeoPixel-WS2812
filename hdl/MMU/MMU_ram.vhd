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

library work;
use work.ram_pkg.all;

entity MMU_ram is
  port(
    CLK_IN      : in  std_logic;
    RST_IN      : in  std_logic;
    
    WR_IN       : in  std_logic;
    
    ADR_IN      : in  std_logic_vector(11 downto 0);
    DATA_IN     : in  std_logic_vector(7 downto 0);
    DATA_OUT    : out std_logic_vector(7 downto 0);
    
    M_ADR_IN    : in  std_logic_vector(8 downto 0);
    M_DATA_OUT  : out std_logic_vector(23 downto 0) 
  );
end MMU_ram;

architecture RTL of MMU_ram is
  
  signal cCSR, nCSR : std_logic_vector(7 downto 0);
  
begin

  gRAM: ram_dual_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  9
  )
  port map(
    CLK_A_IN    =>  CLK_IN,
    WE_A_IN     =>  '0',
    ADR_A_IN    =>  ADR_IN(10 downto 2),
    DAT_A_IN    =>  DATA_IN,
    DAT_A_OUT   =>  open,

    CLK_B_IN    =>  CLK_IN,
    WE_B_IN     =>  '0',
    ADR_B_IN    =>  M_ADR_IN,
    DAT_B_IN    =>  "--------",
    DAT_B_OUT   =>  M_DATA_OUT(23 downto 16)
  );
  
  rRam: ram_dual_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  9
  )
  port map(
    CLK_A_IN    =>  CLK_IN,
    WE_A_IN     =>  '0',
    ADR_A_IN    =>  ADR_IN(10 downto 2),
    DAT_A_IN    =>  DATA_IN,
    DAT_A_OUT   =>  open,
    
    CLK_B_IN    =>  CLK_IN,
    WE_B_IN     =>  '0',
    ADR_B_IN    =>  M_ADR_IN,
    DAT_B_IN    =>  "--------",
    DAT_B_OUT   =>  M_DATA_OUT(15 downto 8)
  );
  
  bRam: ram_dual_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  9
  )
  port map(
    CLK_A_IN    =>  CLK_IN,
    WE_A_IN     =>  '0',
    ADR_A_IN    =>  ADR_IN(10 downto 2),
    DAT_A_IN    =>  DATA_IN,
    DAT_A_OUT   =>  open,
    
    CLK_B_IN    =>  CLK_IN,
    WE_B_IN     =>  '0',
    ADR_B_IN    =>  M_ADR_IN,
    DAT_B_IN    =>  "--------",
    DAT_B_OUT   =>  M_DATA_OUT(7 downto 0)
  );

  gPalRAM: ram_single_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  8
  )
  port map(
    CLK_IN      =>  CLK_IN,
    WE_IN       =>  '0',
    ADR_IN      =>  ADR_IN(7 downto 0),
    DAT_IN      =>  DATA_IN,
    DAT_OUT     =>  open
  );

  rPalRAM: ram_single_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  8
  )
  port map(
    CLK_IN      =>  CLK_IN,
    WE_IN       =>  '0',
    ADR_IN      =>  ADR_IN(7 downto 0),
    DAT_IN      =>  DATA_IN,
    DAT_OUT     =>  open
  );

  bPalRAM: ram_single_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  8
  )
  port map(
    CLK_IN      =>  CLK_IN,
    WE_IN       =>  '0',
    ADR_IN      =>  ADR_IN(7 downto 0),
    DAT_IN      =>  DATA_IN,
    DAT_OUT     =>  open
  );  
end RTL;