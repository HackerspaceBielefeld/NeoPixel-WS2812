----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     
-- Module Name:     
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
-- 
--    Register map:
--    ADR     R/W     DESC
--     0      R/W     Control/Status register.
--     1      R/W     T1H cnt.
--     2      R/W     T0H cnt.
--     3      R/W     TBit cnt.
--     4      R/W     Reset cnt low.
--     5      R/W     Reset cnt high.
--     6      R/W     Num LED low.
--     7      R/W     Num LED high.
--
--    Control/Status register
--    BIT   VAL   R/W   DESC
--     0     1    R/W   Enable transmitter.
--     1     1     R    Transmission in progress.
--
-- Revision:
-- Revision 0.1 File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity WS_Encoder_top is
  port(
    CLK_IN      : in  std_logic;
    RST_IN      : in  std_logic;
    
    WR_IN       : in  std_logic;
    
    ADR_IN      : in  std_logic_vector(7 downto 0);
    DATA_IN     : in  std_logic_vector(7 downto 0);
    DATA_OUT    : out std_logic_vector(7 downto 0);
    
    M_RD_OUT    : out std_logic;
    
    M_ADR_OUT   : out std_logic_vector(8 downto 0);
    M_DATA_IN   : in  std_logic_vector(23 downto 0);
    
    PIXEL_OUT   : out std_logic
  );
end WS_Encoder_top;

architecture RTL of WS_Encoder_top is

  component WS_engine is
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
  end component;
  
  signal cCSR, nCSR               : std_logic_vector(7 downto 0); --Control/Status-Register
  
  signal cT1H_Steps, nT1H_Steps   : std_logic_vector(7 downto 0); --High-time in clocks for 1-bits
  signal cT0H_Steps, nT0H_Steps   : std_logic_vector(7 downto 0); --High-time in clocks for 0-bits
  signal cBitSteps, nBitSteps     : std_logic_vector(7 downto 0); --Amount of clocks for whole bits.
  
  signal cRstCntL, nRstCntL       : std_logic_vector(7 downto 0); --Clocks for reset pulse, low-byte
  signal cRstCntH, nRstCntH       : std_logic_vector(7 downto 0); --Clocks for reset pulse, high-byte
  
  signal cLedCntL, nLedCntL       : std_logic_vector(7 downto 0); --Amount of LEDs - 1, low-byte
  signal cLedCntH, nLedCntH       : std_logic_vector(7 downto 0); --Amount of LEDs - 1, high-byte

begin

  encoder: WS_engine port map(
    CLK_IN      =>  CLK_IN,
    RST_IN      =>  RST_IN,
    ENA_IN      =>  cCSR(0),
    T1H_IN      =>  cT1H_Steps,
    T0H_IN      =>  cT0H_Steps,
    BIT_SEQ_IN  =>  cBitSteps,
    RST_CNT_IN  =>  cRstCntH & cRstCntL,
    LED_CNT_IN  =>  cLedCntH(0) & cLedCntL,
    ADR_OUT     =>  M_ADR_OUT,
    DATA_IN     =>  M_DATA_IN,
    PIXEL_OUT   =>  PIXEL_OUT
  );
  
  adr_dec: process(cCSR, cT1H_Steps, cT0H_Steps, cBitSteps, cRstCntL, cRstCntH, cLedCntL, cLedCntH, WR_IN, ADR_IN, DATA_IN)
  begin
  
    DATA_OUT    <=  cCSR;
  
    nCSR        <=  cCSR;
    nT1H_Steps  <=  cT1H_Steps;
    nT0H_Steps  <=  cT0H_Steps;
    nBitSteps   <=  cBitSteps;
    nRstCntL    <=  cRstCntL;
    nRstCntH    <=  cRstCntH;
    nLedCntL    <=  cLedCntL;
    nLedCntH    <=  cLedCntH;
    
    case ADR_IN(2 downto 0) is
      when "000"  =>
        if WR_IN = '1' then
          nCSR        <=  DATA_IN;
        end if;
        
      when "001"  =>
        DATA_OUT  <=  cT1H_Steps;
        if WR_IN = '1' then
          nT1H_Steps  <=  DATA_IN;
        end if;
        
      when "010"  =>
        DATA_OUT  <=  cT0H_Steps;
        if WR_IN = '1' then
          nT0H_Steps  <=  DATA_IN;
        end if;
        
      when "011"  =>
        DATA_OUT  <=  cBitSteps;
        if WR_IN = '1' then
          nBitSteps   <=  DATA_IN;
        end if;
        
      when "100"  =>
        DATA_OUT  <=  cRstCntL;
        if WR_IN = '1' then
          nRstCntL    <=  DATA_IN;
        end if;
        
      when "101"  =>
        DATA_OUT  <=  cRstCntH;
        if WR_IN = '1' then
          nRstCntH    <=  DATA_IN;
        end if;
        
      when "110"  =>
        DATA_OUT  <=  cLedCntL;
        if WR_IN = '1' then
          nLedCntL    <=  DATA_IN;
        end if;
        
      when "111"  =>
        DATA_OUT  <=  cLedCntH;
        if WR_IN = '1' then
          nLedCntH    <=  DATA_IN;
        end if;
        
      when others =>
    end case;
  end process;

  regs: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        cCSR        <=  (others=>'0');
        cT1H_Steps  <=  (others=>'0');
        cT0H_Steps  <=  (others=>'0');
        cBitSteps   <=  (others=>'0');
        cRstCntL    <=  (others=>'0');
        cRstCntH    <=  (others=>'0');
        cLedCntL    <=  (others=>'0');
        cLedCntH    <=  (others=>'0');
      else
        cCSR        <=  nCSR;
        cT1H_Steps  <=  nT1H_Steps;
        cT0H_Steps  <=  nT0H_Steps;
        cBitSteps   <=  nBitSteps;
        cRstCntL    <=  nRstCntL;
        cRstCntH    <=  nRstCntH;
        cLedCntL    <=  nLedCntL;
        cLedCntH    <=  nLedCntH;
      end if;
    end if;
  end process;

end RTL;