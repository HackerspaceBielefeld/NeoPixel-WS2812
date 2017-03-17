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

entity WS_engine is
  port(
    CLK_IN      : in  std_logic;
    RST_IN      : in  std_logic;
    
    ENA_IN      : in  std_logic;
    
    T1H_IN      : in  std_logic_vector(7 downto 0);
    T0H_IN      : in  std_logic_vector(7 downto 0);
    BIT_SEQ_IN  : in  std_logic_vector(7 downto 0);
    RST_CNT_IN  : in  std_logic_vector(15 downto 0);
    LED_CNT_IN  : in  std_logic_vector(8 downto 0);
    
    ADR_OUT     : out std_logic_vector(8 downto 0);
    DATA_IN     : in  std_logic_vector(23 downto 0);
    
    PIXEL_OUT   : out std_logic
  );
end WS_engine;

architecture RTL of WS_engine is

  signal cLedCnt, nLedCnt : unsigned(8 downto 0);
  signal ledCnt           : unsigned(8 downto 0);
  signal cBitSeq, nBitSeq : unsigned(7 downto 0);
  signal bitSeq           : unsigned(7 downto 0);
  signal t1h              : unsigned(7 downto 0);
  signal t0h              : unsigned(7 downto 0);

  signal cNumBit, nNumBit : natural range 0 to 23 := 23;
  
  signal cRstCnt, nRstCnt : unsigned(15 downto 0);
  signal rstCnt           : unsigned(15 downto 0);
  
  signal cData, nData     : std_logic_vector(23 downto 0);
  
  type WS_FSM_STATE_TYPE is (FETCH, IDLE, HI, LO, SHIFT, LOAD, RST);
  signal cState, nState   : WS_FSM_STATE_TYPE;
  
begin

  ADR_OUT   <=  std_logic_vector(cLedCnt);
  
  bitSeq    <=  unsigned(BIT_SEQ_IN);
  t1h       <=  unsigned(T1H_IN);
  t0h       <=  unsigned(T0H_IN);
  ledCnt    <=  unsigned(LED_CNT_IN);
  rstCnt    <=  unsigned(RST_CNT_IN);

  fsm: process(ENA_IN, DATA_IN,
              cBitSeq, bitSeq, t1h, t0h, cLedCnt, ledCnt,
              cNumBit, cRstCnt, rstCnt , cData, cState)
  begin
    PIXEL_OUT <=  '0';
    
    nBitSeq   <=  cBitSeq;
    
    nNumBit   <=  cNumBit;
    nRstCnt   <=  cRstCnt;
    nLedCnt   <=  cLedCnt;
    
    nData     <=  cData;
    nState    <=  cState;
    
    case cState is
        
      when IDLE =>
        nBitSeq <=  (others => '0');
        nLedCnt <=  (others => '0');
        nNumBit <=  23;
        if ENA_IN = '1' then
          nState  <=  FETCH;
        end if;
          
      when FETCH =>
        nData   <=  DATA_IN;
        nState  <=  HI;
        
      when HI =>
        PIXEL_OUT <=  '1';
        nBitSeq   <=  cBitSeq + 1;

        if cData(23) = '1' then
          if cBitSeq = t1h then
            nState  <= SHIFT;
          end if;
        else
          if cBitSeq = t0h then
            nState  <= SHIFT;
          end if;
        end if;
      
      when SHIFT =>
        nBitSeq <=  cBitSeq + 1;
        nData   <=  cData(22 downto 0) & '-';
        nNumBit <=  cNumBit - 1;
        if cNumBit = 0 then
          nNumBit <=  23;
          nLedCnt <=  cLedCnt + 1;
          nState  <=  LOAD;
        else
          nState  <=  LO;
        end if;
        
      when LOAD =>
        nBitSeq <=  cBitSeq + 1;
        nData   <=  DATA_IN;
        nState  <=  LO;
        
      when LO =>
        nBitSeq <=  cBitSeq + 1;
        if cBitSeq = bitSeq then
          nBitSeq <=  (others => '0');
          if cLedCnt = ledCnt + 1 and cNumBit = 23 then
            nState  <=  RST;
            nLedCnt <=  (others => '0');
          else
            nState  <=  HI;
          end if;
        end if;
      
      when RST =>
        nRstCnt <=  cRstCnt + 1;
        if cRstCnt = rstCnt then
          nState <= IDLE;
        end if;
        
      when others =>
    end case;
    
  end process;
  
  regs: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        cBitSeq <=  (others=>'0');
        cLedCnt <=  (others=>'0');
        cRstCnt <=  (others=>'0');
        cData   <=  (others=>'0');
        cState  <=  IDLE;
      else
        cBitSeq <=  nBitSeq;
        cLedCnt <=  nLedCnt;     
        cRstCnt <=  nRstCnt;
        cNumBit <=  nNumBit;
        cData   <=  nData;
        cState  <=  nState;
      end if;
    end if;
  end process;
end RTL;