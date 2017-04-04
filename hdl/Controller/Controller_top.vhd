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

entity Controller_top is
  port(
    CLK_IN      : in  std_logic;
    RST_IN      : in  std_logic;
    
    INT0_IN     : in  std_logic;
    INT1_IN     : in  std_logic;
    
    CONF_AUTO_IN: in  std_logic;
    LED_OUT     : out std_logic;
    
    A_RD_OUT    : out std_logic;
    A_WR_OUT    : out std_logic;
    
    A_ADR_OUT   : out std_logic_vector(3 downto 0);
    A_DATA_OUT  : out std_logic_vector(7 downto 0);
    A_DATA_IN   : in  std_logic_vector(7 downto 0);
    
    B_WR_OUT    : out std_logic;
    
    B_ADR_OUT   : out std_logic_vector(3 downto 0);
    B_DATA_OUT  : out std_logic_vector(7 downto 0);
    B_DATA_IN   : in  std_logic_vector(7 downto 0) 
  );
end Controller_top;

architecture RTL of Controller_top is

  --Werte für 100 MHz
  constant SPI_DATA   : std_logic_vector(3 downto 0)  := x"0";
  constant SPI_CSR    : std_logic_vector(3 downto 0)  := x"1";
  
  constant SPI_CONF   : std_logic_vector(7 downto 0)  := x"0F";
  
  constant UART_DATA  : std_logic_vector(3 downto 0)  := x"8";
  constant UART_CSR   : std_logic_vector(3 downto 0)  := x"9";
  constant UART_BRL   : std_logic_vector(3 downto 0)  := x"A";
  constant UART_BRH   : std_logic_vector(3 downto 0)  := x"B";
  constant UART_IER   : std_logic_vector(3 downto 0)  := x"C";
  
  --115200 Baud, Transmitter, Receiver and Ints enabled.
  constant UART_CSR_C : std_logic_vector(7 downto 0)  := x"07";
  constant UART_BRL_C : std_logic_vector(7 downto 0)  := x"63";
  constant UART_BRH_C : std_logic_vector(7 downto 0)  := x"03";
  constant UART_IER_C : std_logic_vector(7 downto 0)  := x"07";
  
  constant WS_CSR     : std_logic_vector(3 downto 0)  := x"0";
  constant WS_T1H     : std_logic_vector(3 downto 0)  := x"1";
  constant WS_T0H     : std_logic_vector(3 downto 0)  := x"2";
  constant WS_TBIT    : std_logic_vector(3 downto 0)  := x"3";
  constant WS_RSTL    : std_logic_vector(3 downto 0)  := x"4";
  constant WS_RSTH    : std_logic_vector(3 downto 0)  := x"5";
  constant WS_LEDL    : std_logic_vector(3 downto 0)  := x"6";
  constant WS_LEDH    : std_logic_vector(3 downto 0)  := x"7";
  
  constant WS_LDAT    : std_logic_vector(3 downto 0)  := x"8";
  constant WS_LADL    : std_logic_vector(3 downto 0)  := x"9";
  constant WS_LADH    : std_logic_vector(3 downto 0)  := x"A";
  constant WS_PADR    : std_logic_vector(3 downto 0)  := x"B";
  constant WS_PDAT    : std_logic_vector(3 downto 0)  := x"C";
  
  --Transmitter enabled, clear pointer, 24-Bit-Format, 150 LEDs
  constant WS_CSR_C   : std_logic_vector(7 downto 0)  := x"31";
  constant WS_T1H_C   : std_logic_vector(7 downto 0)  := x"4F";
  constant WS_T0H_C   : std_logic_vector(7 downto 0)  := x"27";
  constant WS_TBIT_C  : std_logic_vector(7 downto 0)  := x"7C";
  constant WS_RSTL_C  : std_logic_vector(7 downto 0)  := x"87";
  constant WS_RSTH_C  : std_logic_vector(7 downto 0)  := x"13";
  constant WS_LEDL_C  : std_logic_vector(7 downto 0)  := x"95";
  constant WS_LEDH_C  : std_logic_vector(7 downto 0)  := x"00";


  type FSM_STATE is (ST_INIT, ST_INIT0, ST_INIT1, ST_INIT2, ST_INIT3, ST_INIT4);
  signal cState, nState : FSM_STATE;

begin

  LED_OUT <=  CONF_AUTO_IN;
  
  logic_p: process(cState)
  begin
    A_RD_OUT    <=  '0';
    A_WR_OUT    <=  '0';
        
    A_ADR_OUT   <=  x"0";
    A_DATA_OUT  <=  x"00";
        
    B_WR_OUT    <=  '0';
    B_ADR_OUT   <=  x"0";
    B_DATA_OUT  <=  x"00";
  
    nState      <=  cState;
    
    case cState is
      when ST_INIT =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  SPI_CSR;
        A_DATA_OUT  <=  SPI_CONF;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_LEDL;
        B_DATA_OUT  <=  WS_LEDL_C;
        
        nState      <=  ST_INIT0;
    
      when ST_INIT0 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_IER;
        A_DATA_OUT  <=  UART_IER_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_RSTL;
        B_DATA_OUT  <=  WS_RSTL_C;
        
        nState      <=  ST_INIT1;
      
      when ST_INIT1 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_BRH;
        A_DATA_OUT  <=  UART_BRH_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_RSTH;
        B_DATA_OUT  <=  WS_RSTH_C;
        
        nState      <=  ST_INIT2;
        
      when ST_INIT2 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_BRL;
        A_DATA_OUT  <=  UART_BRL_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_TBIT;
        B_DATA_OUT  <=  WS_TBIT_C;
        
        nState      <=  ST_INIT3;
        
      when ST_INIT3 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_CSR;
        A_DATA_OUT  <=  UART_CSR_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_T0H;
        B_DATA_OUT  <=  WS_T0H_C;
        
        nState      <=  ST_INIT4;
        
      when others =>
      
    end case;
  end process;

  regs_p: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        cState  <=  ST_INIT;
      else
        cState  <=  nState;
      end if;
    end if;
  end process;

end RTL;