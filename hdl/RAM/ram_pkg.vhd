--
--  Package File Template
--
--  Purpose: This package defines supplemental types, subtypes,
--     constants, and functions
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;

library work;
--use work.util_pkg.all;

package ram_pkg is

component ram_single_port is
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
end component;

component ram_dual_port is
  generic(
    DATA_WIDTH  : positive  :=  8;
    ADR_WIDTH   : positive  :=  8
  );
  port(
  -- Port A
    CLK_A_IN    : in  std_logic;
    WE_A_IN     : in  std_logic;
    ADR_A_IN    : in  std_logic_vector(ADR_WIDTH-1 downto 0);
    DAT_A_IN    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DAT_A_OUT   : out std_logic_vector(DATA_WIDTH-1 downto 0);
  -- Port B
    CLK_B_IN    : in  std_logic;
    WE_B_IN     : in  std_logic;
    ADR_B_IN    : in  std_logic_vector(ADR_WIDTH-1 downto 0);
    DAT_B_IN    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    DAT_B_OUT   : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end component;

type RAM_T is array (0 to 4095) of std_logic_vector(7 downto 0);

impure function InitRamFromFile(RamFileName : in string) return RAM_T;

end ram_pkg;

package body ram_pkg is

  impure function InitRamFromFile(RamFileName : in string) return RAM_T is
    file RamFile : text is in RamFileName;
    variable RamFileLine : line;
    variable RAM : RAM_T;
  begin
    for I in RAM_T'range loop
      readline(RamFile, RamFileLine);
      read(RamFileLine, RAM(I));
    end loop;
    return RAM;
  end function;

end ram_pkg;
