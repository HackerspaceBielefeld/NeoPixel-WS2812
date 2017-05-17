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
    --System clock and master reset
    CLK_I       : in  std_logic;
    RST_I       : in  std_logic;
    
    --Bus interface (Master!)
    CYC_O       : out std_logic;
    STB_O       : out std_logic;
    WE_O        : out std_logic;
    ADR_O       : out std_logic_vector(7 downto 0);
    DAT_O       : out std_logic_vector(7 downto 0);
    DAT_I       : in  std_logic_vector(7 downto 0);
    ACK_I       : in  std_logic;
    
    --Interrups from COMs
    INT0_IN     : in  std_logic;
    INT1_IN     : in  std_logic;
    
    CONF_AUTO_IN: in  std_logic;
    LED_OUT     : out std_logic
  );
end Controller_top;

architecture RTL of Controller_top is

  --Werte für 100 MHz
  constant SPI_DAT    : std_logic_vector(7 downto 0)  := x"40";
  constant SPI_CSR    : std_logic_vector(3 downto 0)  := x"1";
  
  constant SPI_CONF   : std_logic_vector(7 downto 0)  := x"0B";
  
  constant UART_DAT   : std_logic_vector(7 downto 0)  := x"00";
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

  constant RD_CMD     : std_logic_vector(7 downto 0)  := x"5A";

  type FSM_STATE is (IDLE, GET_CMD, WAIT_ADR, GET_ADR, WAIT_CNT, GET_CNT, DECODE_CMD,
                     READ_DAT, GET_DAT, WRITE_BACK, WRITE_TO);
  signal cState, nState : FSM_STATE;
  
  signal cAdr, nAdr : std_logic_vector(7 downto 0);
  signal cDta, nDta : std_logic_vector(7 downto 0);
  signal cCnt, nCnt : unsigned(7 downto 0);
  signal cCmd, nCmd : std_logic_vector(7 downto 0);
  signal cSrc, nSrc : std_logic;

begin

  LED_OUT <=  CONF_AUTO_IN;
  
  logic_p: process(cState, cAdr, cDta, cCnt, cCmd, cSrc, DAT_I, ACK_I, 
                   INT0_IN, INT1_IN, CONF_AUTO_IN)
  begin
    nAdr    <=  cAdr;
    nDta    <=  cDta;
    nCnt    <=  cCnt;
    nCmd    <=  cCmd;
    nSrc    <=  cSrc;
    nState  <=  cState;
    
    CYC_O   <=  '0';
    STB_O   <=  '0';
    WE_O    <=  '0';
    ADR_O   <=  x"00";
    DAT_O   <=  x"00";
    
    case cState is
      when IDLE =>
        if INT0_IN = '1' then
          nSrc    <=  '0';
          nState  <=  GET_CMD;
        end if;
        
        if INT1_IN = '1' then
          nSrc    <=  '1';
          nState  <=  GET_CMD;
        end if;
        
      when GET_CMD =>
        CYC_O   <=  '1';
        STB_O   <=  '1';
        if cSrc = '1' then
          ADR_O   <=  SPI_DAT;
        else
          ADR_O   <=  UART_DAT;
        end if;
        
        if ACK_I = '1' then
          nCmd    <=  DAT_I;
          nState  <=  WAIT_ADR;
        end if;
        
      when WAIT_ADR =>
        if cCmd /= x"A5" and cCmd /= x"5A" then
          nState  <=  IDLE;
        elsif (cSrc = '0' and INT0_IN = '1') or (cSrc = '1' and INT1_IN = '1') then
          nState  <=  GET_ADR;
        end if;
        
      when GET_ADR =>
        CYC_O   <=  '1';
        STB_O   <=  '1';
        if cSrc = '1' then
          ADR_O   <=  SPI_DAT;
        else
          ADR_O   <=  UART_DAT;
        end if;
        
        if ACK_I = '1' then
          nAdr    <=  DAT_I;
          nState  <=  WAIT_CNT;
        end if;
        
      when WAIT_CNT =>
        if (cSrc = '0' and INT0_IN = '1') or (cSrc = '1' and INT1_IN = '1') then
          nState  <=  GET_CNT;
        end if;
        
      when GET_CNT =>
        CYC_O   <=  '1';
        STB_O   <=  '1';
        if cSrc = '1' then
          ADR_O   <=  SPI_DAT;
        else
          ADR_O   <=  UART_DAT;
        end if;
        
        if ACK_I = '1' then
          nCnt    <=  unsigned(DAT_I);
          nState  <=  DECODE_CMD;
        end if;
        
      when DECODE_CMD =>
        if cCmd = RD_CMD then
          nState    <= READ_DAT;
        else
          nState    <=  GET_DAT;
        end if;
        
      when GET_DAT  =>
        CYC_O   <=  '1';
        STB_O   <=  '1';
        if cSrc = '1' then
          ADR_O   <=  SPI_DAT;
        else
          ADR_O   <=  UART_DAT;
        end if;
        
        if ACK_I = '1' then
          nDta    <=  DAT_I;
          nState  <=  WRITE_TO;
        end if;
        
      when WRITE_TO =>
        CYC_O   <=  '1';
        STB_O   <=  '1';
        ADR_O   <=  cAdr;
        WE_O    <=  '1';
        DAT_O   <=  cDta;
        
        if ACK_I = '1' then
          if cCnt = x"00" then
            nState  <=  IDLE;
          else
            nCnt    <=  cCnt - 1;
            nState  <=  GET_DAT;
          end if;
        end if;
        
      when READ_DAT =>
        CYC_O   <=  '1';
        STB_O   <=  '1';
        ADR_O   <=  cAdr;
        if ACK_I = '1' then
          nDta    <=  DAT_I;
          nState  <=  WRITE_BACK;
        end if;
        
      when WRITE_BACK =>
        CYC_O   <=  '1';
        STB_O   <=  '1';
        WE_O    <=  '1';
        if cSrc = '1' then
          ADR_O   <=  SPI_DAT;
        else
          ADR_O   <=  UART_DAT;
        end if;
        DAT_O   <=  cDta;
        
        if ACK_I = '1' then
          if cCnt = x"00" then
            nState  <=  IDLE;
          else
            nCnt    <=  cCnt - 1;
            nState  <=  READ_DAT;
          end if;
        end if;
        
      when others=>
    end case;
  end process;
  
  regs: process(CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        cAdr    <=  (others=>'0');
        cDta    <=  (others=>'0');
        cCnt    <=  (others=>'0');
        cCmd    <=  (others=>'0');
        cSrc    <=  '0';
        cState  <=  IDLE;
      else
        cAdr    <=  nAdr;
        cDta    <=  nDta;
        cCnt    <=  nCnt;
        cCmd    <=  nCmd;
        cSrc    <=  nSrc;
        cState  <=  nState;
      end if;
    end if;
  end process;
  
end RTL;