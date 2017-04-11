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
  
  constant SPI_CONF   : std_logic_vector(7 downto 0)  := x"0B";
  
  constant UART_DATA  : std_logic_vector(3 downto 0)  := x"8";
  constant UART_CSR   : std_logic_vector(3 downto 0)  := x"9";
  constant UART_BRL   : std_logic_vector(3 downto 0)  := x"A";
  constant UART_BRH   : std_logic_vector(3 downto 0)  := x"B";
  constant UART_IER   : std_logic_vector(3 downto 0)  := x"C";
  
  --115200 Baud, Transmitter, Receiver and Ints enabled.
  constant UART_CSR_C : std_logic_vector(7 downto 0)  := x"07";
  constant UART_BRL_C : std_logic_vector(7 downto 0)  := x"63";
  constant UART_BRH_C : std_logic_vector(7 downto 0)  := x"03";
  constant UART_IER_C : std_logic_vector(7 downto 0)  := x"05";
  
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


  type FSM_STATE is (ST_CONF0, ST_CONF1, ST_CONF2, ST_CONF3, ST_CONF4, 
                     ST_CONF5, ST_CONF6, ST_CONF7, ST_CONF8, ST_IDLE,
                     ST_SET_DTA);
  signal cState, nState : FSM_STATE;
  
  signal cSerialDta, nSerialDta : std_logic_vector(7 downto 0);

begin

  LED_OUT <=  CONF_AUTO_IN;
  
  logic_p: process(cState, cSerialDta, CONF_AUTO_IN, INT0_IN, INT1_IN, A_DATA_IN)
  begin
    A_RD_OUT    <=  '0';
    A_WR_OUT    <=  '0';
        
    A_ADR_OUT   <=  x"0";
    A_DATA_OUT  <=  x"00";
        
    B_WR_OUT    <=  '0';
    B_ADR_OUT   <=  x"0";
    B_DATA_OUT  <=  x"00";
  
    nState      <=  cState;
    nSerialDta  <=  cSerialDta;
    
    case cState is
      when ST_CONF0 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  SPI_CSR;
        A_DATA_OUT  <=  SPI_CONF;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_LEDH;
        B_DATA_OUT  <=  WS_LEDH_C;
        
        nState      <=  ST_CONF1;
    
      when ST_CONF1 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_IER;
        A_DATA_OUT  <=  UART_IER_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_LEDL;
        B_DATA_OUT  <=  WS_LEDL_C;
        
        nState      <=  ST_CONF2;
      
      when ST_CONF2 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_BRH;
        A_DATA_OUT  <=  UART_BRH_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_RSTH;
        B_DATA_OUT  <=  WS_RSTH_C;
        
        nState      <=  ST_CONF3;
        
      when ST_CONF3 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_BRL;
        A_DATA_OUT  <=  UART_BRL_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_RSTL;
        B_DATA_OUT  <=  WS_RSTL_C;
        
        nState      <=  ST_CONF4;
        
      when ST_CONF4 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_CSR;
        A_DATA_OUT  <=  UART_CSR_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_TBIT;
        B_DATA_OUT  <=  WS_TBIT_C;
        
        nState      <=  ST_CONF5;
        
      when ST_CONF5 =>
        A_WR_OUT    <=  '1';
        A_ADR_OUT   <=  UART_CSR;
        A_DATA_OUT  <=  UART_CSR_C;
        
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_T0H;
        B_DATA_OUT  <=  WS_T0H_C;
        
        nState      <=  ST_CONF6;
        
      when ST_CONF6 =>
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_T0H;
        B_DATA_OUT  <=  WS_T0H_C;
        
        nState      <=  ST_CONF7;
        
      when ST_CONF7 =>
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_T1H;
        B_DATA_OUT  <=  WS_T1H_C;
        
        nState      <=  ST_CONF8;
        
      when ST_CONF8 =>
        B_WR_OUT    <=  '1';
        B_ADR_OUT   <=  WS_CSR;
        B_DATA_OUT  <=  WS_CSR_C;
        
        nState      <=  ST_IDLE;
        
      when ST_IDLE =>
        if CONF_AUTO_IN = '1' then
          if INT0_IN = '1' then
            A_ADR_OUT   <=  SPI_DATA;
            A_RD_OUT    <=  '1';
            nSerialDta  <=  A_DATA_IN;
            
            nState      <=  ST_SET_DTA;
          end if;
          
          if INT1_IN = '1' then
            A_ADR_OUT   <=  UART_DATA;
            A_RD_OUT    <=  '1';
            nSerialDta  <=  A_DATA_IN;
            
            nState      <=  ST_SET_DTA;
          end if;
        else
          
        end if;
        
      when ST_SET_DTA =>
        B_ADR_OUT   <=  WS_LDAT;
        B_WR_OUT    <=  '1';
        B_DATA_OUT  <=  cSerialDta;
        
        nState      <=  ST_IDLE;
      when others =>
      
    end case;
  end process;

  regs_p: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        cState      <=  ST_CONF0;
      else
        cState      <=  nState;
        cSerialDta  <=  nSerialDta;
      end if;
    end if;
  end process;

end RTL;