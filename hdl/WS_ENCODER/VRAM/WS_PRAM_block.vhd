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

entity WS_PRAM_block is
  port(
    CLK_IN    : in  std_logic;
    
    WR_IN     : in  std_logic;
    
    ADR_IN    : in  std_logic_vector( 7 downto 0);
    DATA_IN   : in  std_logic_vector(23 downto 0);
    DATA_OUT  : out std_logic_vector(23 downto 0) 
  );
end WS_PRAM_block;

architecture RTL of WS_PRAM_block is

  signal dat_r_in  : std_logic_vector(7 downto 0);
  signal dat_g_in  : std_logic_vector(7 downto 0);
  signal dat_b_in  : std_logic_vector(7 downto 0);
  
  signal dat_r_out : std_logic_vector(7 downto 0);
  signal dat_g_out : std_logic_vector(7 downto 0);
  signal dat_b_out : std_logic_vector(7 downto 0);
  
begin

  DATA_OUT  <=  dat_r_out & dat_g_out & dat_b_out;
  
  dat_r_in    <=  DATA_IN(23 downto 16);
  dat_g_in    <=  DATA_IN(15 downto  8);
  dat_b_in    <=  DATA_IN( 7 downto  0);
  
  rRAM: ram_single_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  8
  )
  port map(
    CLK_IN    =>  CLK_IN,
    
    WE_IN     =>  WR_IN,
    
    ADR_IN    =>  ADR_IN,
    DAT_IN    =>  dat_r_in,
    DAT_OUT   =>  dat_r_out
  );
  
  gRam: ram_single_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  8
  )
  port map(
    CLK_IN    =>  CLK_IN,
    
    WE_IN     =>  WR_IN,
    
    ADR_IN    =>  ADR_IN,
    DAT_IN    =>  dat_g_in,
    DAT_OUT   =>  dat_g_out
  );
  
  bRam: ram_single_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  8
  )
  port map(
    CLK_IN    =>  CLK_IN,
    
    WE_IN     =>  WR_IN,
    
    ADR_IN    =>  ADR_IN,
    DAT_IN    =>  dat_b_in,
    DAT_OUT   =>  dat_b_out
  );
end RTL;