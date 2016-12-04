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

entity ram_single_port is
  generic(
    DATA_WIDTH  : positive  :=  8;
    ADR_WIDTH   : positive  :=  8
  );
  port(
    CLK_IN      : in  std_logic;
    WE_IN       : in  std_logic;
    ADR_IN      : in  std_logic_vector(ADR_WIDTH-1 downto 0);
    DAT_IN      : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DAT_OUT     : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end ram_single_port;

architecture RTL of ram_single_port is
  type RAM_T is array (0 to (2**ADR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
  shared variable ram : RAM_T;

begin

  process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      DAT_OUT <=  ram(to_integer(unsigned(ADR_IN)));

      if WE_IN = '1' then
        ram(to_integer(unsigned(ADR_IN))) := DAT_IN;
      end if;
    end if;
  end process;

end RTL;