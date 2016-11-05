--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pic_pkg is

  component PIC is
    generic(
      CNT_WIDTH : positive        :=  16
    );
    port(
      CLK_IN    : in  std_logic;        -- Main clock
      CNT_EN_IN : in  std_logic;        -- Counter enable
      LOAD_IN   : in  std_logic_vector(CNT_WIDTH-1 downto 0);  --  Initial value for counter
      TICK_OUT  : out std_logic         -- Generated clock tick
    );
  end component;

end pic_pkg;

package body pic_pkg is
 
end pic_pkg;
