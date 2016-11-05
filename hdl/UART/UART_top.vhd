----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     
-- Module Name:     
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
-- 
--  Register map:
--   ADR    R/W   DESC
--    0      R    Received serial data.
--    0      W    Data to be transmitted.
--    1      R    Status register.
--    1      W    Control register.
--    2     R/W   Baudrate low byte.
--    3     R/W   Baudrate high byte.
--    4     R/W   Interrupt enable register
--
--
--   Control/Status register (CSR)
--   BIT  R/W   DESC
--    0   R/W   UE    - UART enable.
--    1   R/W   TE    - Transmitter enable.
--    2   R/W   RE    - Receiver enable.
--    3    R    TDE   - Transmitter data empty.
--    4    R    RDNE  - Receiver data not empty.
--    5    R    TC    - Transfer complete.
--    6    R    RI    - Receiver idle.
--    7    R    OVR   - Overrun error.
--
--   Interrupt Enable Register (IER)
--   BIT  DESC
--    0   IE      - Interrupts enable.
--    1   TDEIE   - Transmitter data empty interrupt enable.
--    2   RDNEIE  - Receiver data not empty interrupt enable.
--
-- Revision:
-- Revision 0.1 File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_top is
  port(
    CLK_IN    : in  std_logic;
    RST_IN    : in  std_logic;
    
    RD_IN     : in  std_logic;
    WR_IN     : in  std_logic;
    
    ADR_IN    : in  std_logic_vector(2 downto 0);
    DATA_IN   : in  std_logic_vector(7 downto 0);
    DATA_OUT  : out std_logic_vector(7 downto 0);
    
    RXD_IN    : in  std_logic;
    TXD_OUT   : out std_logic;
    
    INT_OUT   : out std_logic
  );
end UART_top;

architecture RTL of UART_top is

  component UART_rxd is
    port(
      CLK_IN        : in  std_logic;
      RST_IN        : in  std_logic;
      
      RX_ENA_IN     : in  std_logic;
      
      BAUDRATE_IN   : in  std_logic_vector(15 downto 0);
      
      RXD_IN        : in  std_logic;
      
      DTA_WR_OUT    : out std_logic;
      DTA_OUT       : out std_logic_vector( 7 downto 0);
      
      RX_IDLE_OUT   : out std_logic
    );
  end component;
  
  component UART_txd is
    port(
      CLK_IN        : in  std_logic;
      RST_IN        : in  std_logic;
  
      TX_ENA_IN     : in  std_logic;
      
      DTA_RDY_IN    : in  std_logic;
      DTA_IN        : in  std_logic_vector( 7 downto 0);
      
      BAUDRATE_IN   : in  std_logic_vector(15 downto 0);
  
      DTA_RD_OUT    : out std_logic;
      TX_IDLE_OUT   : out std_logic;

      TXD_OUT       : out std_logic
    );
  end component;
  
  signal cTDR, nTDR   : std_logic_vector(7 downto 0); --TransmitDataRegister
  signal cRDR, nRDR   : std_logic_vector(7 downto 0); --ReceiveDataRegister
  signal cCSR, nCSR   : std_logic_vector(7 downto 0); --Control/StatusRegister
  signal cBLR, nBLR   : std_logic_vector(7 downto 0); --BaudrateLowbyteRegister
  signal cBHR, nBHR   : std_logic_vector(7 downto 0); --BaudrateHighbyteRegister
  signal cIER, nIER   : std_logic_vector(2 downto 0); --InterruptEnableRegister
  
  signal rxd_idle     : std_logic;
  signal rxd_ena      : std_logic;
  signal rxd_wr       : std_logic;
  signal rxd_dta      : std_logic_vector(7 downto 0);
  
  signal txd_ena      : std_logic;
  signal txd_rd       : std_logic;
  signal txd_dta_rdy  : std_logic;
  signal txd_idle     : std_logic;
  
  signal baudrate     : std_logic_vector(15 downto 0);

begin
  
  receiver: UART_rxd 
    port map(
      CLK_IN      =>  CLK_IN,
      RST_IN      =>  RST_IN,
      RX_ENA_IN   =>  rxd_ena,
      BAUDRATE_IN =>  baudrate,
      RXD_IN      =>  RXD_IN,
      DTA_WR_OUT 	=>  rxd_wr,
      DTA_OUT     =>  rxd_dta,
      RX_IDLE_OUT =>  rxd_idle
    );
    
  transmitter: UART_txd
    port map(
      CLK_IN      =>  CLK_IN,
      RST_IN      =>  RST_IN,
      TX_ENA_IN   =>  txd_ena,
      DTA_RDY_IN  =>  txd_dta_rdy,
      DTA_IN      =>  cTDR,
      BAUDRATE_IN =>  baudrate,
      DTA_RD_OUT  =>  txd_rd,
      TX_IDLE_OUT =>  txd_idle,
      TXD_OUT     =>  TXD_OUT
    );
    
  INT_OUT     <=  cIER(0) and ((cIER(1) and cCSR(3)) or (cIER(2) and cCSR(4)));
  baudrate    <=  cBHR & cBLR;
  rxd_ena     <=  cCSR(2) and cCSR(0);
  txd_ena     <=  cCSR(1) and cCSR(0);
  txd_dta_rdy <=  not cCSR(3);
  
  decoder: process(ADR_IN, RD_IN, WR_IN, DATA_IN, rxd_idle, rxd_wr,
                   rxd_dta, cTDR, cRDR, cCSR, cBLR, cBHR, cIER, txd_idle, txd_rd)
  begin
    
    nTDR  <=  cTDR;
    nCSR  <=  cCSR;
    nBLR  <=  cBLR;
    nBHR  <=  cBHR;
    nIER  <=  cIER;
    
    nCSR(6)   <=  rxd_idle;
    nCSR(5)   <=  txd_idle;
    
    if rxd_wr = '1' then
      nRDR    <=  rxd_dta;
      nCSR(4) <=  '1';
      if cCSR(4) = '1' then
        nCSR(7) <= '1';
      end if;
    else
      nRDR  <= cRDR;
    end if;
    
    if txd_rd = '1' then
      nCSR(3)  <=  '1';
    end if;
    
    DATA_OUT  <=  "--------";
    
    case ADR_IN is
      when "000" =>
        DATA_OUT  <=  cRDR;
        
        if RD_IN = '1' then
          nCSR(4) <=  '0';
          nCSR(7) <=  '0';
        end if;
        
        if WR_IN = '1' then
          nTDR    <=  DATA_IN;
          nCSR(3) <=  '0';
        end if;
        
      when "001" =>
        DATA_OUT  <=  cCSR;
        
        if WR_IN = '1' then
          nCSR(2 downto 0) <=  DATA_IN(2 downto 0);
        end if;
        
      when "010" =>
        DATA_OUT  <=  cBLR;
        
        if WR_IN = '1' then
          nBLR    <=  DATA_IN;
        end if;
        
      when "011" =>
        DATA_OUT  <=  cBHR;
        
        if WR_IN = '1' then
          nBHR    <=  DATA_IN;
        end if;
        
      when "100" =>
        DATA_OUT  <=  "00000" & cIER;
        
        if WR_IN = '1' then
          nIER    <=  DATA_IN(2 downto 0);
        end if;
        
      when others=>
    end case;
  end process;

  regs: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        cTDR  <=  (others=>'0');
        cRDR  <=  (others=>'0');
        cCSR  <=  (others=>'0');
        cBLR  <=  (others=>'0');
        cBHR  <=  (others=>'0');
        cIER  <=  (others=>'0');
      else
        cTDR  <=  nTDR;
        cRDR  <=  nRDR;
        cCSR  <=  nCSR;
        cBLR  <=  nBLR;
        cBHR  <=  nBHR;
        cIER  <=  nIER;
      end if;
    end if;
  end process;
  
end RTL;