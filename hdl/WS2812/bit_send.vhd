----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     WS2812_TOP
-- Module Name:     BIT_TRANSFER
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
--    This is the line modulator on bit layer.
--    It encodes the sequences for 0 of 1 bits.
--
-- Revision:
-- Revision 0.1 File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bit_send is
  Port(
    CLK_IN        : in  std_logic;  --Main clock
    RST_IN        : in  std_logic;  --Main reset

    START_IN      : in  std_logic;  --Starts encoding

    SEQ_STP_IN    : in  std_logic_vector(7 downto 0); --amount of steps for one bit sequence
    STP_0H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 0-bit
    STP_1H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 1-bit

    BIT_IN        : in  std_logic;  --the actual bit to encode

    DAT_OUT       : out std_logic;  --LED data line
    BSY_OUT       : out std_logic;  --High, if encoding in Progress.
    NB_OUT        : out std_logic   --Load Next Bit output. If it's gone high during transmission,
  );                                --the fsm has read the current bit and is ready for the next one.
end bit_send;

architecture RTL of bit_send is
  type fsm_state_type is (IDLE_S, HIGH_S, LOW_S );
  signal c_state, n_state : fsm_state_type;

  signal c_cnt, n_cnt     : unsigned(7 downto 0);

begin

  encoder: process(START_IN, SEQ_STP_IN, STP_0H_IN, STP_1H_IN, BIT_IN, c_cnt, c_state)

    variable inc_c_cnt  : unsigned(7 downto 0);

  begin
    BSY_OUT   <=  '1';
    NB_OUT    <=  '0';
    DAT_OUT   <=  '0';

    inc_c_cnt   :=  c_cnt + 1;

    n_cnt       <=  inc_c_cnt;
    n_state     <=  c_state;

    case c_state is
      when IDLE_S =>
        BSY_OUT   <= '0';
        n_cnt     <= (others=>'0');

        if START_IN = '1' then
          n_state <=  HIGH_S;
        end if;

      when HIGH_S =>
        DAT_OUT   <=  '1';

        if  (BIT_IN = '0' and inc_c_cnt = unsigned(STP_0H_IN)) or
            (BIT_IN = '1' and inc_c_cnt = unsigned(STP_1H_IN)) then
          NB_OUT  <=  '1';
          n_state <=  LOW_S;
        end if;

      when LOW_S =>
        if inc_c_cnt = unsigned(SEQ_STP_IN) then
          if START_IN = '1' then
            n_cnt   <=  (others=>'0');
            n_state <=  HIGH_S;
          else
            n_state <=  IDLE_S;
          end if;
        end if;

      when others =>
    end case;
  end process;

  regs: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        c_state <=  IDLE_S;
      else
        c_state <=  n_state;
        c_cnt   <=  n_cnt;
      end if;
    end if;
  end process;

end RTL;