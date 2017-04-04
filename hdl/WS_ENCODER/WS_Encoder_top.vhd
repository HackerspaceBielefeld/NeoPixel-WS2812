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
--     8       W      LED-color data register
--     9      R/W     LED VRAM pointer low
--    10      R/W     LED VRAM pointer high
--    11      R/W     Palette-RAM-pointer
--    12       W      Palette-Data-Register
--
--    Control/Status register
--    BIT   R/W   DESC
--     0    R/W   Enable transmitter.
--     1     R    Transmission in progress.
--     2    R/W   Bit 2 und 3 legen das Farbformat fest.
--     3    R/W   0: 24-Bit, 1: 16-Bit 1555, 2: 16-Bit 565, 3: 8-Bit via Palette
--     4     W    Clear LED VRAM pointer
--     5     W    Clear Palette-Data-Pointer
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
    
    ADR_IN      : in  std_logic_vector(3 downto 0);
    DATA_IN     : in  std_logic_vector(7 downto 0);
    DATA_OUT    : out std_logic_vector(7 downto 0);
    
    PIXEL_OUT   : out std_logic
  );
end WS_Encoder_top;

architecture RTL of WS_Encoder_top is

  component WS_engine is
    port(
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      ENA_IN      : in  std_logic;
      BUSY_OUT    : out std_logic;
      
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
  
  component WS_VRAM_Control is
    port(
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      COL_MODE_IN : in  std_logic_vector(1 downto 0);
      
      V_ADR_RST_IN: in  std_logic;
      V_ADR_EN_IN : in  std_logic;
      V_ADR_IN    : in  std_logic_vector(8 downto 0);
      V_ADR_OUT   : out std_logic_vector(8 downto 0);
      
      P_ADR_RST_IN: in  std_logic;
      P_ADR_EN_IN : in  std_logic;
      P_ADR_IN    : in  std_logic_vector(7 downto 0);
      P_ADR_OUT   : out std_logic_vector(7 downto 0);
      
      V_DATA_EN_IN: in  std_logic;
      V_DATA_IN   : in  std_logic_vector(7 downto 0);
      
      P_DATA_EN_IN: in  std_logic;
      P_DATA_IN   : in  std_logic_vector(7 downto 0);
      
      LED_ADR_IN  : in  std_logic_vector(8 downto 0);
      LED_DATA_OUT: out std_logic_vector(23 downto 0) 
    );
  end component;
  
  signal cCSR, nCSR               : std_logic_vector(5 downto 0); --Control/Status-Register
  
  signal cT1H_Steps, nT1H_Steps   : std_logic_vector(7 downto 0); --High-time in clocks for 1-bits
  signal cT0H_Steps, nT0H_Steps   : std_logic_vector(7 downto 0); --High-time in clocks for 0-bits
  signal cBitSteps, nBitSteps     : std_logic_vector(7 downto 0); --Amount of clocks for whole bits.
  
  signal cRstCntL, nRstCntL       : std_logic_vector(7 downto 0); --Clocks for reset pulse, low-byte
  signal cRstCntH, nRstCntH       : std_logic_vector(7 downto 0); --Clocks for reset pulse, high-byte
  signal rstCnt                   : std_logic_vector(15 downto 0);
  
  signal cLedCntL, nLedCntL       : std_logic_vector(7 downto 0); --Amount of LEDs - 1, low-byte
  signal cLedCntH, nLedCntH       : std_logic;                    --Amount of LEDs - 1, high-bit (511 max)
  signal ledCnt                   : std_logic_vector(8 downto 0); --Amount of LEDs - 1, high-byte
  signal engineBusy               : std_logic;
  
  signal ledData                  : std_logic_vector(23 downto 0);
  signal ledAdr                   : std_logic_vector( 8 downto 0);

  signal vAdrRst                  : std_logic;
  signal vAdrEn                   : std_logic;
  signal vAdrIn                   : std_logic_vector(8 downto 0);
  signal vAdrOut                  : std_logic_vector(8 downto 0);
  signal vDataEn                  : std_logic;
  
  signal pAdrRst                  : std_logic;
  signal pAdrEn                   : std_logic;
  signal pAdrOut                  : std_logic_vector(7  downto 0);
  signal pDataEn                  : std_logic;
  
begin

  rstCnt  <=  cRstCntH & cRstCntL;
  ledCnt  <=  cLedCntH & cLedCntL;
  
  encoder: WS_engine port map(
    CLK_IN      =>  CLK_IN,
    RST_IN      =>  RST_IN,
    ENA_IN      =>  cCSR(0),
    BUSY_OUT    =>  engineBusy,
    T1H_IN      =>  cT1H_Steps,
    T0H_IN      =>  cT0H_Steps,
    BIT_SEQ_IN  =>  cBitSteps,
    RST_CNT_IN  =>  rstCnt,
    LED_CNT_IN  =>  ledCnt,
    ADR_OUT     =>  ledAdr,
    DATA_IN     =>  ledData,
    PIXEL_OUT   =>  PIXEL_OUT
  );
  
  vram: WS_VRAM_Control port map(
    CLK_IN        => CLK_IN,
    RST_IN        => RST_IN,
    COL_MODE_IN   => cCSR(3 downto 2),
    V_ADR_RST_IN  => vAdrRst,
    V_ADR_EN_IN   => vAdrEn,
    V_ADR_IN      => vAdrIn,
    V_ADR_OUT     => vAdrOut,
    P_ADR_RST_IN  => pAdrRst,
    P_ADR_EN_IN   => pAdrEn,
    P_ADR_IN      => DATA_IN,
    P_ADR_OUT     => pAdrOut,
    V_DATA_EN_IN  => vDataEn,
    V_DATA_IN     => DATA_IN,
    P_DATA_EN_IN  => pDataEn,
    P_DATA_IN     => DATA_IN,
    LED_ADR_IN    => ledAdr,
    LED_DATA_OUT  => ledData
  );
  
  adr_dec: process(cCSR, cT1H_Steps, cT0H_Steps, cBitSteps, cRstCntL, cRstCntH, 
                   cLedCntL, cLedCntH, WR_IN, ADR_IN, DATA_IN, engineBusy, pAdrOut, vAdrOut)
  begin
  
    DATA_OUT    <=  "00" & cCSR;
  
    nCSR        <=  cCSR;
    nCSR(1)     <=  engineBusy;
    nCSR(4)     <=  '0';
    nCSR(5)     <=  '0';
    nT1H_Steps  <=  cT1H_Steps;
    nT0H_Steps  <=  cT0H_Steps;
    nBitSteps   <=  cBitSteps;
    nRstCntL    <=  cRstCntL;
    nRstCntH    <=  cRstCntH;
    nLedCntL    <=  cLedCntL;
    nLedCntH    <=  cLedCntH;
    vAdrRst     <=  cCSR(4);
    pAdrRst     <=  cCSR(5);
    vDataEn     <=  '0';
    vAdrEn      <=  '0';
    pAdrEn      <=  '0';
    pDataEn     <=  '0';
    vAdrIn      <=  vAdrOut;
    
    
    case ADR_IN is
      when x"0"  =>
        if WR_IN = '1' then
          nCSR(5 downto 2)  <=  DATA_IN(5 downto 2);
          nCSR(0)           <=  DATA_IN(0);
        end if;
        
      when x"1"  =>
        DATA_OUT  <=  cT1H_Steps;
        if WR_IN = '1' then
          nT1H_Steps  <=  DATA_IN;
        end if;
        
      when x"2"  =>
        DATA_OUT  <=  cT0H_Steps;
        if WR_IN = '1' then
          nT0H_Steps  <=  DATA_IN;
        end if;
        
      when x"3"  =>
        DATA_OUT  <=  cBitSteps;
        if WR_IN = '1' then
          nBitSteps   <=  DATA_IN;
        end if;
        
      when x"4"  =>
        DATA_OUT  <=  cRstCntL;
        if WR_IN = '1' then
          nRstCntL    <=  DATA_IN;
        end if;
        
      when x"5"  =>
        DATA_OUT  <=  cRstCntH;
        if WR_IN = '1' then
          nRstCntH    <=  DATA_IN;
        end if;
        
      when x"6"  =>
        DATA_OUT  <=  cLedCntL;
        if WR_IN = '1' then
          nLedCntL    <=  DATA_IN;
        end if;
        
      when x"7"  =>
        DATA_OUT  <=  "0000000" & cLedCntH;
        if WR_IN = '1' then
          nLedCntH    <=  DATA_IN(0);
        end if;
        
      when x"8"  =>
        vDataEn <=  WR_IN;
        
      when x"9"  =>
        DATA_OUT  <= vAdrOut(7 downto 0);
        if WR_IN = '1' then
          vAdrIn  <= vAdrOut(8) & DATA_IN;
          vAdrEn  <= '1';
        end if;
        
      when x"A"  =>
        DATA_OUT  <= "0000000" & vAdrOut(8);
        if WR_IN = '1' then
          vAdrIn  <= DATA_IN(0) & vAdrOut(7 downto 0);
          vAdrEn  <= '1';
        end if;
        
      when x"B"  =>
        DATA_OUT  <= pAdrOut;
        pAdrEn    <= WR_IN;
        
      when x"C"  =>
        pDataEn <=  WR_IN;
        
      when others =>
    end case;
  end process;

  regs: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        --Werte für 100 MHz
        cCSR        <=  (others=>'0');
        cT1H_Steps  <=  (others=>'0');
        cT0H_Steps  <=  (others=>'0');
        cBitSteps   <=  (others=>'0');
        cRstCntL    <=  (others=>'0');
        cRstCntH    <=  (others=>'0');
        cLedCntL    <=  (others=>'0');
        cLedCntH    <=  '0';
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