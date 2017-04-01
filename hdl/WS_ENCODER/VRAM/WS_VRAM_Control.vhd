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

entity WS_VRAM_Control is
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
end WS_VRAM_Control;

architecture RTL of WS_VRAM_Control is
  
  component WS_PRAM_block is
    port(
      CLK_IN    : in  std_logic;
      
      WR_IN     : in  std_logic;
      
      ADR_IN    : in  std_logic_vector( 7 downto 0);
      DATA_IN   : in  std_logic_vector(23 downto 0);
      DATA_OUT  : out std_logic_vector(23 downto 0) 
    );
  end component;
  
  component WS_VRAM_block is
    port(
      CLK_IN      : in  std_logic;
      
      WR_A_IN     : in  std_logic;
      
      ADR_A_IN    : in  std_logic_vector( 8 downto 0);
      DATA_A_IN   : in  std_logic_vector(23 downto 0);
      
      ADR_B_IN    : in  std_logic_vector( 8 downto 0);
      DATA_B_OUT  : out std_logic_vector(23 downto 0) 
    );
  end component;
  
  signal vWrData  : std_logic;
  signal vDataIn  : std_logic_vector(23 downto 0);
  
  signal nVWrData, cVWrData : std_logic;
  signal cVAdrCnt, nVAdrCnt : unsigned(8 downto 0);
  signal cVDatCnt, nVDatCnt : natural range 0 to 2;
  signal cVData, nVData     : std_logic_vector(15 downto 0); 
  
  signal pWrData  : std_logic;
  signal pAdr     : std_logic_vector( 7 downto 0);
  signal pDataIn  : std_logic_vector(23 downto 0);
  signal pDataOut : std_logic_vector(23 downto 0);
  
  signal cPAdrCnt, nPAdrCnt : unsigned(7 downto 0);
  signal cPDatCnt, nPDatCnt : natural range 0 to 2;
  signal cPData, nPData     : std_logic_vector(15 downto 0);
  
begin

  vram_inst: WS_VRAM_block port map(
    CLK_IN      => CLK_IN,  
    WR_A_IN     => vWrData,  
    ADR_A_IN    => std_logic_vector(cVAdrCnt),  
    DATA_A_IN   => vDataIn,  
    ADR_B_IN    => LED_ADR_IN,  
    DATA_B_OUT  => LED_DATA_OUT  
  );
  
  pram_inst: WS_PRAM_block port map(
    CLK_IN      => CLK_IN,
    WR_IN       => pWrData,
    ADR_IN      => pAdr,
    DATA_IN     => pDataIn,
    DATA_OUT    => pDataOut
  );
  
  pDataIn   <= cPData & P_DATA_IN;
  P_ADR_OUT <= std_logic_vector(cPAdrCnt);
  V_ADR_OUT <= std_logic_vector(cVAdrCnt);
  
  logic: process(COL_MODE_IN, P_ADR_EN_IN, P_ADR_IN, P_DATA_EN_IN, P_DATA_IN, 
                 V_DATA_EN_IN, V_DATA_IN, cVWrData, cVAdrCnt, cVDatCnt, cVData,
                 pDataOut, cPAdrCnt, cPDatCnt, cPData, V_ADR_IN, V_ADR_EN_IN)
  begin
    
    nPAdrCnt  <= cPAdrCnt;
    nPDatCnt  <= cPDatCnt;
    nPData    <= cPData;
    
    pWrData   <= '0';
    pAdr      <= V_DATA_IN;
    
    nVWrData  <= '0';
    vWrData   <= '0';
    nVAdrCnt  <= cVAdrCnt;
    nVDatCnt  <= cVDatCnt;
    nVData    <= cVData;
    vDataIn   <= cVData & V_DATA_IN;
    
    if V_ADR_EN_IN = '1' then
      nVAdrCnt  <= unsigned(V_ADR_IN);
      nVDatCnt  <= 0;
    end if;
    

    case COL_MODE_IN is
      when "00" =>
        case cVDatCnt is
          when 0 =>
            nVData(15 downto 8) <= V_DATA_IN;
            nVDatCnt  <= cVDatCnt + 1;
            
          when 1 =>
            nVData(7 downto 0) <= V_DATA_IN;
            nVDatCnt  <= cVDatCnt + 1;
            
          when 2 =>
            nVDatCnt  <= 0;
            vWrData   <= V_DATA_EN_IN;
            nVAdrCnt  <= cVAdrCnt + 1;
        end case;
        
      when "01" =>
        case cVDatCnt is
          when 0 =>
            nVData(7 downto 0) <= V_DATA_IN;
            nVDatCnt  <= cVDatCnt + 1;
            
          when 1 =>
            nVDatCnt  <= 0;
            vWrData   <= V_DATA_EN_IN;
            vDataIn   <= cVData(6) & cVData(5) & cVData(4) & cVData(4) &
                         cVData(3) & cVData(3) & cVData(2) & cVData(2) &
                         cVData(1) & cVData(0) & V_DATA_IN(7) & V_DATA_IN(7) &
                         V_DATA_IN(6) & V_DATA_IN(6) & V_DATA_IN(5) & V_DATA_IN(5) &
                         V_DATA_IN(4) & V_DATA_IN(3) & V_DATA_IN(2) & V_DATA_IN(2) &
                         V_DATA_IN(1) & V_DATA_IN(1) & V_DATA_IN(0) & V_DATA_IN(0);
            nVAdrCnt  <= cVAdrCnt + 1;
            
            when others =>
        end case;
        
      when "10" =>
        case cVDatCnt is
          when 0 =>
            nVData(7 downto 0) <= V_DATA_IN;
            nVDatCnt  <= cVDatCnt + 1;
            
          when 1 =>
            nVDatCnt  <= 0;
            vWrData   <= V_DATA_EN_IN;
            vDataIn   <= cVData(7) & cVData(6) & cVData(5) & cVData(5) &
                         cVData(4) & cVData(4) & cVData(3) & cVData(3) &
                         cVData(2) & cVData(1) & cVData(0) & V_DATA_IN(7) &
                         V_DATA_IN(6) & V_DATA_IN(6) & V_DATA_IN(5) & V_DATA_IN(5) &
                         V_DATA_IN(4) & V_DATA_IN(3) & V_DATA_IN(2) & V_DATA_IN(2) &
                         V_DATA_IN(1) & V_DATA_IN(1) & V_DATA_IN(0) & V_DATA_IN(0);
            nVAdrCnt  <= cVAdrCnt + 1;
            
            when others =>
        end case;
        
      when "11" =>
        vDataIn   <= pDataOut;
        nVWrData  <= V_DATA_EN_IN;
        vWrData   <= cVWrData;
    
        if cVWrData = '1' then
          nVAdrCnt  <= cVAdrCnt + 1;
        end if;
  
      when others =>
    end case;
    
    if P_ADR_EN_IN = '1' then
      nPAdrCnt  <= unsigned(P_ADR_IN);
      nPDatCnt  <= 0;
    end if;
    
    if P_DATA_EN_IN = '1' then
      case cPDatCnt is
        when 0 =>
          nPDatCnt  <=  cPDatCnt + 1;
          nPData(15 downto 8) <=  P_DATA_IN;
          
        when 1 =>
          nPDatCnt  <=  cPDatCnt + 1;
          nPData(7 downto 0)  <=  P_DATA_IN;
          
        when 2 =>
          nPDatCnt  <= 0;
          pWrData   <= '1';
          nPAdrCnt  <= cPAdrCnt + 1;
          pAdr      <= std_logic_vector(cPAdrCnt);
      end case;
    end if;
    
  end process;
  
  PRAM_regs: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' or P_ADR_RST_IN = '1' then
        cPAdrCnt  <=  (others=>'0');
        cPDatCnt  <=  0;
      else
        cPAdrCnt  <=  nPAdrCnt;
        cPDatCnt  <=  nPDatCnt;
        cPData    <=  nPData;
      end if;
    end if;
  end process;
  
  VRAM_regs: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' or V_ADR_RST_IN = '1' then
        cVAdrCnt  <=  (others=>'0');
        cVDatCnt  <=  0;
      else
        cVAdrCnt  <=  nVAdrCnt;
        cVDatCnt  <=  nVDatCnt;
        cVWrData  <=  nVWrData;
        cVData    <=  nVData;
      end if;
    end if;
  end process;

end RTL;