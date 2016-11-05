----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     PIC
-- Module Name:     PIC_TOP
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
--    This is a Programmable Intervall Counter, which generates a tick (TICK_OUT)
--    after counting down from LOAD_IN to zero.
--
--    Funktion:
--    If CNT_EN_IN is '0', the counter registers permanently the value of LOAD_IN.
--    If the counter ist enabled (CNT_EN_IN = '1'), it counts down to zero and
--    generates a tick of one clock duration. It is also reloaded with LOAD_IN
--    and TICK_OUT goes high for one clock pulse of CLK_IN.
--
-- Dependencies:
--
-- Revision:
-- Revision 1.0   Works fine.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PIC is
  generic(
    CNT_WIDTH : positive        :=  16
  );
  port(
    CLK_IN    : in  std_logic;        -- Main clock
    CNT_EN_IN : in  std_logic;        -- Counter enable
    LOAD_IN   : in  std_logic_vector(CNT_WIDTH-1 downto 0);  --  Initial value for counter
    TICK_OUT  : out std_logic         -- Generated clock tick
  );
end PIC;

architecture RTL of PIC is

  signal c_cnt, n_cnt : unsigned(CNT_WIDTH-1 downto 0); --  Counter register

begin

-- Logic of counter.
  cnt_l : process(c_cnt, LOAD_IN, CNT_EN_IN)
  begin
    TICK_OUT  <= '0';       -- TICK_OUT is low by default.
    n_cnt     <= c_cnt - 1; -- New state of counter in next clock tick.

    if c_cnt  = 0 then
      if CNT_EN_IN = '1' then
        TICK_OUT  <=  '1';    -- TICK_OUT is 1 for one tick of CLK_IN.
      end if;
      n_cnt     <=  unsigned(LOAD_IN);    -- Reload prescaler.
    end if;
  end process;

-- Register of counter.
  cnt_r : process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if CNT_EN_IN = '0' then
        c_cnt   <=  unsigned(LOAD_IN);      -- Register PRESCALER_IN
      else
        c_cnt   <=  n_cnt;                  -- Normal operation: Count down / reload
      end if;                               -- as controlled by logic process.
    end if;
  end process;
end RTL;

