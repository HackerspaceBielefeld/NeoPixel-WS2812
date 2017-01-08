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

entity MMU_vram is
  port(
    CLK_IN      : in  std_logic;
    
    WR_A_IN     : in  std_logic;
    
    ADR_A_IN    : in  std_logic_vector( 8 downto 0);
    DATA_A_IN   : in  std_logic_vector(23 downto 0);

    
    ADR_B_IN    : in  std_logic_vector( 8 downto 0);
    DATA_B_OUT  : out std_logic_vector(23 downto 0) 
  );
end MMU_vram;

architecture RTL of MMU_vram is

  signal dat_r_in  : std_logic_vector(7 downto 0);
  signal dat_g_in  : std_logic_vector(7 downto 0);
  signal dat_b_in  : std_logic_vector(7 downto 0);
  
  signal dat_r_out : std_logic_vector(7 downto 0);
  signal dat_g_out : std_logic_vector(7 downto 0);
  signal dat_b_out : std_logic_vector(7 downto 0);
  
begin

  -----------------------------------------------------------------------------------
  -- Achtung, hier wird das Ausgabeformat festgelegt, bei Bedarf kann ein
  -- Multiplexer eingebaut werden, der GRB oder RGB oder jede andere Kombination
  -- ermöglicht.
  DATA_B_OUT  <=  dat_g_out & dat_r_out & dat_b_out;
  -----------------------------------------------------------------------------------
  
  dat_r_in    <=  DATA_A_IN(23 downto 16);
  dat_g_in    <=  DATA_A_IN(15 downto  8);
  dat_b_in    <=  DATA_A_IN( 7 downto  0);
  
  rRAM: ram_dual_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  9
  )
  port map(
    CLK_A_IN    =>  CLK_IN,
    
    WE_A_IN     =>  WR_A_IN,
    
    ADR_A_IN    =>  ADR_A_IN,
    DAT_A_IN    =>  dat_r_in,
    DAT_A_OUT   =>  open,

    CLK_B_IN    =>  CLK_IN,
    
    WE_B_IN     =>  '0',
    
    ADR_B_IN    =>  ADR_B_IN,
    DAT_B_IN    =>  "--------",
    DAT_B_OUT   =>  dat_r_out
  );
  
  gRam: ram_dual_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  9
  )
  port map(
    CLK_A_IN    =>  CLK_IN,
    
    WE_A_IN     =>  WR_A_IN,
    
    ADR_A_IN    =>  ADR_A_IN,
    DAT_A_IN    =>  dat_g_in,
    DAT_A_OUT   =>  open,
    
    CLK_B_IN    =>  CLK_IN,
    
    WE_B_IN     =>  '0',
    
    ADR_B_IN    =>  ADR_B_IN,
    DAT_B_IN    =>  "--------",
    DAT_B_OUT   =>  dat_g_out
  );
  
  bRam: ram_dual_port 
  generic map(
    DATA_WIDTH  =>  8,
    ADR_WIDTH   =>  9
  )
  port map(
    CLK_A_IN    =>  CLK_IN,
    
    WE_A_IN     =>  WR_A_IN,
    
    ADR_A_IN    =>  ADR_A_IN,
    DAT_A_IN    =>  dat_b_in,
    DAT_A_OUT   =>  open,
    
    CLK_B_IN    =>  CLK_IN,
    
    WE_B_IN     =>  '0',
    
    ADR_B_IN    =>  ADR_B_IN,
    DAT_B_IN    =>  "--------",
    DAT_B_OUT   =>  dat_b_out
  );
end RTL;