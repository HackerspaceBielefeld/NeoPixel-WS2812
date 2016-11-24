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

entity SPI_shifter is
  port(
    CLK_IN    : in  std_logic;
    RST_IN    : in  std_logic;
    
    ENA_IN    : in  std_logic;
    
    LD_OUT    : out std_logic;
    ST_OUT    : out std_logic; 
    ABORT_OUT : out std_logic;
    
    DATA_IN   : in  std_logic_vector(7 downto 0);
    DATA_OUT  : out std_logic_vector(7 downto 0);
    
    SCK_IN    : in  std_logic;
    MOSI_IN   : in  std_logic;
    MISO_OUT  : out std_logic
  );
end SPI_shifter;

architecture RTL of SPI_shifter is

  signal cRxDta, nRxDta   : std_logic_vector(7 downto 0);
  signal cTxDta, nTxDta   : std_logic_vector(7 downto 0);
  
  signal cSrCnt, nSrCnt   : natural range 0 to 7;
  
  signal cSckSr, nSckSr   : std_logic_vector(2 downto 0);
  signal cMosiSr, nMosiSr : std_logic_vector(1 downto 0);

  signal rEdge   : std_logic;
  signal fEdge   : std_logic;
  
  type SPI_FSM_TYPE is (IDLE, TRANSFER);
  signal cState, nState   :  SPI_FSM_TYPE;
  
begin

  --Flankenerkennung SCK_IN
  rEdge     <=  '1' when cSckSr(2 downto 1) = "01" else '0';
  fEdge     <=  '1' when cSckSr(2 downto 1) = "10" else '0';
  
  nSckSr    <=  cSckSr(1 downto 0) & SCK_IN;
  nMosiSr   <=  cMosiSr(0) & MOSI_IN;
  
  --MISO_OUT is Tri-State when SPI is disabled.
  MISO_OUT  <=  cTxDta(7) when ENA_IN = '1' else 'Z';
  DATA_OUT  <=  cRxDta;

  logic: process(cRxDta, cTxDta, cSckSr, cMosiSr, cSrCnt, SCK_IN, MOSI_IN, fEdge, rEdge, cState, DATA_IN, ENA_IN)
  begin
    nState    <=  cState;
    
    nRxDta    <=  cRxDta;
    nTxDta    <=  cTxDta;
    
    nSrCnt    <=  cSrCnt;
    
    LD_OUT    <=  '0';
    ST_OUT    <=  '0';
    ABORT_OUT <=  '0';
    
    case cState is
      when IDLE =>
        if ENA_IN = '1' then
          LD_OUT    <=  '1';
          nTxDta    <=  DATA_IN;
          nState    <=  TRANSFER;
        end if;
        
      when TRANSFER =>
        if ENA_IN = '1' then
          if rEdge = '1' then
            nRxDta <= cRxDta(6 downto 0) & cMosiSr(1);
          end if;
          if fEdge = '1' then
            nSrCnt  <=  cSrCnt - 1;
            nTxDta  <=  cTxDta(6 downto 0) & cTxDta(7);
            if cSrCnt = 0 then
              nState  <=  IDLE;
              nSrCnt  <=  7;
              ST_OUT  <=  '1';
            end if;
          end if;
        else
          nState    <= IDLE;
          if cSrCnt /= 7 then
            ABORT_OUT <=  '1';
          end if;
        end if;
      
    end case;
    
  end process;
  
  regs: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        cState  <=  IDLE;
        
        cRxDta  <= (others=>'-');
        cTxDta  <= (others=>'-');
        
        cSrCnt  <= 7;

        cSckSr  <= (others=>'-');
        cMosiSr <= (others=>'-');
      else
        cState  <=  nState;
        
        cRxDta  <=  nRxDta;
        cTxDta  <=  nTxDta;
        
        cSrCnt  <=  nSrCnt;
        
        cSckSr  <=  nSckSr;
        cMosiSr <=  nMosiSr;
      end if;
    end if;
  end process;
  
end RTL;