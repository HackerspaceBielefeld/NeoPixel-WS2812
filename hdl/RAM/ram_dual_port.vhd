----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    12:34:27 07/05/2016
-- Design Name:
-- Module Name:    ram - RTL
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

library work;
use work.ram_pkg.all;

entity ram_dual_port is
  generic(
    DATA_WIDTH  : positive  :=  8;
    ADR_WIDTH   : positive  :=  8
  );
  port(
  -- Port A
    CLK_A_IN  : in  std_logic;
    WE_A_IN   : in  std_logic;
    ADR_A_IN  : in  std_logic_vector(ADR_WIDTH-1 downto 0);
    DAT_A_IN  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DAT_A_OUT : out std_logic_vector(DATA_WIDTH-1 downto 0);
  -- Port B
    CLK_B_IN  : in  std_logic;
    WE_B_IN   : in  std_logic;
    ADR_B_IN  : in  std_logic_vector(ADR_WIDTH-1 downto 0);
    DAT_B_IN  : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DAT_B_OUT : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end ram_dual_port;

architecture RTL of ram_dual_port is
  type RAM_T is array (0 to (2**ADR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  shared variable ram : RAM_T;

begin

  process(CLK_A_IN)
  begin
    if rising_edge(CLK_A_IN) then
      DAT_A_OUT <=  ram(to_integer(unsigned(ADR_A_IN)));

      if WE_A_IN = '1' then
        ram(to_integer(unsigned(ADR_A_IN))) := DAT_A_IN;
      end if;
    end if;
  end process;

  process(CLK_B_IN)
  begin
    if rising_edge(CLK_B_IN) then
      DAT_B_OUT <=  ram(to_integer(unsigned(ADR_B_IN)));

      if WE_B_IN = '1' then
        ram(to_integer(unsigned(ADR_B_IN))) := DAT_B_IN;
      end if;
    end if;
  end process;

end RTL;

