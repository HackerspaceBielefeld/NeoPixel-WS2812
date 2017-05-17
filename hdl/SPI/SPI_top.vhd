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
--
--   Control/Status register (CSR)
--   BIT  R/W   DESC
--    0   R/W   SE      - SPI enable.
--    1   R/W   IE      - Interrupt enable
--    2   R/W   TDEIE   - Transfer Data Empty Interrupt Enable
--    3   R/W   RDNEIE  - Receive Data Not Empty Interrupt Enable
--    4    R    TE      - Transfer error.
--    5    R    TDE     - Transfer Data Empty
--    6    R    RDNE    - Receive Data Not Empty
--    7    R    OVR     - Overrun error.
--
-- Revision:
-- Revision 0.1 File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SPI_top is
  port(
    --System clock and master reset
    CLK_I       : in  std_logic;
    RST_I       : in  std_logic;
    
    --Bus interface
    CYC_I       : in  std_logic;
    STB_I       : in  std_logic;
    WE_I        : in  std_logic;
    ADR_I       : in  std_logic_vector(0 downto 0);
    DAT_I       : in  std_logic_vector(7 downto 0);
    DAT_O       : out std_logic_vector(7 downto 0);
    ACK_O       : out std_logic;
    
    --SPI-lines
    CS_IN       : in  std_logic;
    SCLK_IN     : in  std_logic;
    MOSI_IN     : in  std_logic;
    MISO_OUT    : out std_logic;
    
    --Interrupt line
    INT_OUT     : out std_logic
  );
end SPI_top;

architecture RTL of SPI_top is

  component SPI_shifter is
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
  end component;

  signal cCsSr, nCsSr : std_logic_vector(1 downto 0);
  
  signal cRDR, nRDR   : std_logic_vector(7 downto 0);
  signal cTDR, nTDR   : std_logic_vector(7 downto 0);
  signal cCSR, nCSR   : std_logic_vector(7 downto 0);
  
  signal cs_ena       : std_logic;
  
  signal shift_ena    : std_logic;
  signal shift_ld     : std_logic;
  signal shift_st     : std_logic;
  signal shift_abrt   : std_logic;
  signal shift_rdr    : std_logic_vector(7 downto 0);
  
begin

  shifter_inst: SPI_shifter port map(
    CLK_IN    =>  CLK_I,
    RST_IN    =>  RST_I,
    ENA_IN    =>  shift_ena,
    LD_OUT    =>  shift_ld,
    ST_OUT    =>  shift_st,
    ABORT_OUT =>  shift_abrt,
    DATA_IN   =>  cTDR,
    DATA_OUT  =>  shift_rdr,
    SCK_IN    =>  SCLK_IN,
    MOSI_IN   =>  MOSI_IN,
    MISO_OUT  =>  MISO_OUT
  );
  
  --CS einsynchronisieren
  nCsSr     <=  cCsSr(0) & CS_IN;
  cs_ena    <=  cCsSr(1);
  shift_ena <=  cs_ena and cCSR(0);
  
  INT_OUT   <=  cCSR(1) and ((cCSR(2) and cCSR(5)) or (cCSR(3) and cCSR(6)));
  
  decoder: process(CYC_I, STB_I, ADR_I, DAT_I, WE_I, cCSR, cRDR, cTDR, 
                   shift_st, shift_ld, shift_rdr, shift_abrt)
  begin
    DAT_O   <=  "--------";
    ACK_O   <=  '0';
    
    nCSR      <=  cCSR;
    nRDR      <=  cRDR;
    nTDR      <=  cTDR;
    
    if shift_st = '1' then
      nRDR    <=  shift_rdr;
      nCSR(6) <=  '1';
      if cCSR(6) = '1' then
        nCSR(7) <=  '1';
      end if;
    end if;
    
    if shift_ld = '1' then
      nCSR(4) <=  '0';
      nCSR(5) <=  '1';
    end if;
    
    if shift_abrt = '1' then
      nCSR(4) <=  '1';
    end if;
    
    if CYC_I = '1' and STB_I = '1' then
      ACK_O   <=  '1';
      
      case ADR_I(0) is
        when '0' =>
          DAT_O  <=  cRDR;
          
          if WE_I = '1' then
            nTDR    <=  DAT_I;
            nCSR(5) <=  '0';
          else
            nCSR(6) <=  '0';
            nCSR(7) <=  '0';
          end if;
        
        when '1' =>
          DAT_O  <=  cCSR;
          if WE_I = '1' then
            nCSR(3 downto 0)  <= DAT_I(3 downto 0);
          end if;
        
        when others =>
      end case;
    end if;
  end process;
  
  regs: process(CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        cRDR  <=  (others=>'0');
        cTDR  <=  (others=>'0');
        cCSR  <=  x"0F";
        cCsSr <=  (others=>'0');
      else
        cRDR  <=  nRDR;
        cTDR  <=  nTDR;
        cCSR  <=  nCSR;
        cCsSr <=  nCsSr;
      end if;
    end if;
  end process;
  
end RTL;