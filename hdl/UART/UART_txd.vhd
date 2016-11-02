----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     TRANSMITTER
-- Module Name:     UART_TOP
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
--    This is a fifo buffered transmitter for an uart with wishbone interface.
--
--    Funktion:
--    Once a byte is written to the fifo and the transmitter is enabled, it starts
--    transmitting the byte via TXD_OUT and continues, until the fifo is empty.
--    FIFO_FREE_OUT gives back the amount of free bytes in the fifo. It is a
--    first word fall through type.
--    The bit time is given by a PIC, loaded by PIC_LOAD_IN.
--
-- Dependencies:
--    fifo
--    pic
--
-- Revision:
-- Revision 1.0   Works fine.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pic_pkg.all;

------------
-- Entity --
------------
entity UART_txd is
  port(
    CLK_IN        : in  std_logic;
    RESET_IN      : in  std_logic;

    TE_IN         : in  std_logic;
    TDE_IN        : in  std_logic;

    DATA_IN       : in  std_logic_vector( 7 downto 0);
    BOUDRATE_IN   : in  std_logic_vector(15 downto 0);

    TC_OUT        : out std_logic;

    TXD_OUT       : out std_logic
  );
end UART_txd;

------------------
-- Architecture --
------------------
architecture rtl of UART_txd is

-------------
--Constants--
-------------

  constant PIC_CNT_WIDTH    : positive  :=  16;

-------------
-- Signals --
-------------

  type TxD_Type is(IDLE, START, TRANSMIT, STOP);
  signal c_tx_state, n_tx_state   : TxD_Type;

  signal c_tx_dta, n_tx_dta       : std_logic_vector(7 downto 0);

  signal c_bit_cnt, n_bit_cnt     : natural range 0 to 7;

  signal pic_en    : std_logic;
  signal pic_tick   : std_logic;

begin

  pic_inst  : PIC
    generic map(
      CNT_WIDTH     =>  PIC_CNT_WIDTH
    )
    port map(
      CLK_IN        =>  CLK_IN,
      CNT_EN_IN     =>  pic_en,
      LOAD_IN       =>  PIC_LOAD_IN,
      TICK_OUT      =>  pic_tick
    );

  txd_logic:  process(c_tx_state, c_tx_dta, c_bit_cnt, fifo_empty, fifo_dout, pic_tick, TX_ENABLE_IN)
  begin
    n_tx_state  <=  c_tx_state;
    n_tx_dta    <=  c_tx_dta;
    TX_BUSY_OUT <=  '1';
    TXD_OUT     <=  '1';
    pic_en      <=  '1';
    fifo_rd     <=  '0';
    n_bit_cnt   <=  c_bit_cnt;

    case c_tx_state is
      when IDLE =>
        TX_BUSY_OUT   <=  '0';
        pic_en   <=  '0';
        if TX_ENABLE_IN = '1' and fifo_empty = '0' then
          n_tx_state  <= START;
        end if;

      when START =>
        TXD_OUT   <=  '0';
        n_tx_dta  <=  fifo_dout;
        if pic_tick = '1' then
          n_tx_state  <=  TRANSMIT;
          fifo_rd     <=  '1';
        end if;

      when TRANSMIT =>
        TXD_OUT   <=  c_tx_dta(c_bit_cnt);
        if pic_tick = '1' then
          n_bit_cnt <= c_bit_cnt + 1;
          if c_bit_cnt = 7 then
            n_tx_state  <=  STOP;
            n_bit_cnt   <= 0;
          end if;
        end if;

      when STOP =>
        if pic_tick = '1' then
          if TX_ENABLE_IN = '1' and fifo_empty = '0' then
            n_tx_state  <= START;
          else
            n_tx_state  <= IDLE;
          end if;
        end if;

    end case;
  end process;

  reg : process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RESET_IN = '1' then
        c_tx_state  <=  IDLE;
        c_bit_cnt   <=  0;
        c_tx_dta    <= (others => '-');
      elsif TX_ENABLE_IN = '1' then
        c_tx_state  <=  n_tx_state;
        c_bit_cnt   <=  n_bit_cnt;
        c_tx_dta    <=  n_tx_dta;
      end if;
    end if;
  end process;

end rtl;
