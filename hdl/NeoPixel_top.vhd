----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     NeoPixel
-- Module Name:     NeoPixel_top
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

entity NeoPixel_top is
  port(
    --System clock
    CLK_IN        : in  std_logic;
    
    --Reset button, negative logic, needs synchronisation
    RST_BTN_N_IN  : in  std_logic;
    
    --SPI-lines
    CS_IN         : in  std_logic;
    SCLK_IN       : in  std_logic;
    MOSI_IN       : in  std_logic;
    MISO_OUT      : out std_logic;
    
    --UART-lines
    RXD_IN        : in  std_logic;
    TXD_OUT       : out std_logic;
    
    --Data signal to NeoPixel-LED
    PIXEL_OUT     : out std_logic
  );
end NeoPixel_top;


architecture RTL of NeoPixel_top is

  component UART_top is
    port(
      --System clock and master reset
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      --Bus interface
      RD_IN       : in  std_logic;
      WR_IN       : in  std_logic;
      
      ADR_IN      : in  std_logic_vector(2 downto 0);
      DATA_IN     : in  std_logic_vector(7 downto 0);
      DATA_OUT    : out std_logic_vector(7 downto 0);
      
      --UART-lines
      RXD_IN      : in  std_logic;
      TXD_OUT     : out std_logic;
      
      --Interrupt line
      INT_OUT     : out std_logic
    );
  end component;
  
  component SPI_top is
    port(
      --System clock and master reset
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      --Bus interface
      RD_IN       : in  std_logic;
      WR_IN       : in  std_logic;
      
      ADR_IN      : in  std_logic_vector(2 downto 0);
      DATA_IN     : in  std_logic_vector(7 downto 0);
      DATA_OUT    : out std_logic_vector(7 downto 0);
      
      --SPI-lines
      CS_IN       : in  std_logic;
      SCLK_IN     : in  std_logic;
      MOSI_IN     : in  std_logic;
      MISO_OUT    : out std_logic;
      
      --Interrupt line
      INT_OUT     : out std_logic
    );
  end component;
  
  component BIUI_top is
    port(
      --Master bus interface
      M_RD_IN     : in  std_logic;
      M_WR_IN     : in  std_logic;
      
      M_ADR_IN    : in  std_logic_vector(3 downto 0);
      M_DATA_IN   : in  std_logic_vector(7 downto 0);
      M_DATA_OUT  : out std_logic_vector(7 downto 0);
      
      --Bus interface for slave 0 (SPI)
      S0_RD_OUT   : out std_logic;
      S0_WR_OUT   : out std_logic;
  
      S0_ADR_OUT  : out std_logic_vector(2 downto 0);
      S0_DATA_OUT : out std_logic_vector(7 downto 0);
      S0_DATA_in  : in  std_logic_vector(7 downto 0);
      
      --Bus interface for slave 1 (UART)
      S1_RD_OUT   : out std_logic;
      S1_WR_OUT   : out std_logic;
  
      S1_ADR_OUT  : out std_logic_vector(2 downto 0);
      S1_DATA_OUT : out std_logic_vector(7 downto 0);
      S1_DATA_in  : in  std_logic_vector(7 downto 0) 
    );
  end component;

  component Controller_top is
    port(
      --System clock and master reset
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      --Interrups from COMs
      INT0_IN     : in  std_logic;
      INT1_IN     : in  std_logic;
    
      --Bus interface to serial com ports
      A_RD_OUT    : out  std_logic;
      A_WR_OUT    : out  std_logic;
      
      A_ADR_OUT   : out std_logic_vector(3 downto 0);
      A_DATA_OUT  : out std_logic_vector(7 downto 0);
      A_DATA_IN   : in  std_logic_vector(7 downto 0);
      
      --Bus interface to MMU and WS-driver
      B_WR_OUT    : out std_logic;
      
      B_ADR_OUT   : out std_logic_vector(11 downto 0);
      B_DATA_OUT  : out std_logic_vector(7 downto 0);
      B_DATA_IN   : in  std_logic_vector(7 downto 0) 
    );
  end component;

  component BIUO_top is
    port(
      --Master bus interface
      M_WR_IN     : in  std_logic;
      
      M_ADR_IN    : in  std_logic_vector(11 downto 0);
      M_DATA_IN   : in  std_logic_vector(7 downto 0);
      M_DATA_OUT  : out std_logic_vector(7 downto 0);
      
      --Bus interface to slave 0 (MMU)
      S0_WR_OUT   : out std_logic;
  
      S0_ADR_OUT  : out std_logic_vector(10 downto 0);
      S0_DATA_OUT : out std_logic_vector(7 downto 0);
      S0_DATA_in  : in  std_logic_vector(7 downto 0);
      
      --Bus interface to slave 1 (WS_Encoder)
      S1_WR_OUT   : out std_logic;
  
      S1_ADR_OUT  : out std_logic_vector(10 downto 0);
      S1_DATA_OUT : out std_logic_vector(7 downto 0);
      S1_DATA_in  : in  std_logic_vector(7 downto 0) 
    );
  end component;

  component MMU_top is
    port(
      --System clock and master reset
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      --Bus interface
      WR_IN       : in  std_logic;
      
      ADR_IN      : in  std_logic_vector(10 downto 0);
      DATA_IN     : in  std_logic_vector(7 downto 0);
      DATA_OUT    : out std_logic_vector(7 downto 0);
      
      --WS_Encoder interface
      M_RD_IN     : in  std_logic;
      
      M_ADR_IN    : in  std_logic_vector(8 downto 0);
      M_DATA_OUT  : out std_logic_vector(23 downto 0) 
    );
  end component;

  component WS_Encoder_top is
    port(
      --System clock and master reset
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      --Bus interface
      WR_IN       : in  std_logic;
      
      ADR_IN      : in  std_logic_vector(7 downto 0);
      DATA_IN     : in  std_logic_vector(7 downto 0);
      DATA_OUT    : out std_logic_vector(7 downto 0);
      
      --MMU interface
      M_RD_OUT    : out std_logic;
      
      M_ADR_OUT   : out std_logic_vector(8 downto 0);
      M_DATA_IN   : in  std_logic_vector(23 downto 0);
      
      --LED data out
      PIXEL_OUT   : out std_logic
    );
  end component;

  --Master reset
  signal reset      : std_logic;
  
  --UART-BIUI-lines
  signal UART_rd    : std_logic;
  signal UART_wr    : std_logic;
  signal UART_int   : std_logic;
  signal UART_adr   : std_logic_vector(2 downto 0);
  signal UART_din   : std_logic_vector(7 downto 0);
  signal UART_dout  : std_logic_vector(7 downto 0);
  
  --SPI-BIUI-lines
  signal SPI_rd     : std_logic;
  signal SPI_wr     : std_logic;
  signal SPI_int    : std_logic;
  signal SPI_adr    : std_logic_vector(2 downto 0);
  signal SPI_din    : std_logic_vector(7 downto 0);
  signal SPI_dout   : std_logic_vector(7 downto 0);

  --BIUI-Controller-lines
  signal BIUI_rd    : std_logic;
  signal BIUI_wr    : std_logic;
  signal BIUI_adr   : std_logic_vector(3 downto 0);
  signal BIUI_din   : std_logic_vector(7 downto 0);
  signal BIUI_dout  : std_logic_vector(7 downto 0);

  --BIUO-Controller-lines
  signal BIUO_wr    : std_logic;
  signal BIUO_adr   : std_logic_vector(11 downto 0);
  signal BIUO_din   : std_logic_vector(7 downto 0);
  signal BIUO_dout  : std_logic_vector(7 downto 0);

  --MMU-BIUO-lines
  signal MMU_wr     : std_logic;
  signal MMU_adr    : std_logic_vector(10 downto 0);
  signal MMU_din    : std_logic_vector(7 downto 0);
  signal MMU_dout   : std_logic_vector(7 downto 0);
  
  --MMU-WS_Encoder-lines
  signal MMU_WS_rd  : std_logic;
  signal MMU_WS_adr : std_logic_vector(8 downto 0);
  signal MMU_WS_dta : std_logic_vector(23 downto 0);
  
  --WS-BIUO-lines
  signal WS_wr      : std_logic;
  signal WS_adr     : std_logic_vector(10 downto 0);
  signal WS_din     : std_logic_vector(7 downto 0);
  signal WS_dout    : std_logic_vector(7 downto 0);
  
begin

  --Connects master reset to reset button.
  reset   <=  not RST_BTN_N_IN; --Todo: RST_BTN_N_IN einsynchronisieren
  
  --Instatiations of submodules
  UART: UART_top port map(
    CLK_IN    =>  CLK_IN,
    RST_IN    =>  reset,
    
    RD_IN     =>  UART_rd,
    WR_IN     =>  UART_wr,
    
    ADR_IN    =>  UART_adr,
    DATA_IN   =>  UART_din,
    DATA_OUT  =>  UART_dout,
      
    RXD_IN    =>  RXD_IN,
    TXD_OUT   =>  TXD_OUT,
    
    INT_OUT   =>  UART_int 
  );
  
  SPI: SPI_top port map(
    CLK_IN    =>  CLK_IN,
    RST_IN    =>  reset,
    
    RD_IN     =>  SPI_rd,
    WR_IN     =>  SPI_wr,
      
    ADR_IN    =>  SPI_adr,
    DATA_IN   =>  SPI_din,
    DATA_OUT  =>  SPI_dout,
      
    CS_IN     =>  CS_IN,
    SCLK_IN   =>  SCLK_IN,
    MOSI_IN   =>  MOSI_IN,
    MISO_OUT  =>  MISO_OUT,
      
    INT_OUT   =>  SPI_int
  );
  
  BIUI: BIUI_top port map(
    M_RD_IN     =>  BIUI_rd,
    M_WR_IN     =>  BIUI_wr,

    M_ADR_IN    =>  BIUI_adr,
    M_DATA_IN   =>  BIUI_din,
    M_DATA_OUT  =>  BIUI_dout,

    S0_RD_OUT   =>  SPI_rd,
    S0_WR_OUT   =>  SPI_wr,

    S0_ADR_OUT  =>  SPI_adr,
    S0_DATA_OUT =>  SPI_din,
    S0_DATA_in  =>  SPI_dout,

    S1_RD_OUT   =>  UART_rd,
    S1_WR_OUT   =>  UART_wr,

    S1_ADR_OUT  =>  UART_adr,
    S1_DATA_OUT =>  UART_din,
    S1_DATA_in  =>  UART_dout
  );
  
  Controller: Controller_top port map(
    CLK_IN      =>  CLK_IN,
    RST_IN      =>  reset,
    
    INT0_IN     =>  SPI_int,
    INT1_IN     =>  UART_int,
      
    A_RD_OUT    =>  BIUI_rd,
    A_WR_OUT    =>  BIUI_wr,
      
    A_ADR_OUT   =>  BIUI_adr,
    A_DATA_OUT  =>  BIUI_din,
    A_DATA_IN   =>  BIUI_dout,
      
    B_WR_OUT    =>  BIUO_wr,
      
    B_ADR_OUT   =>  BIUO_adr,
    B_DATA_OUT  =>  BIUO_din,
    B_DATA_IN   =>  BIUO_dout
  );
  
  BIUO: BIUO_top port map(
    M_WR_IN     =>  BIUO_wr,
    
    M_ADR_IN    =>  BIUO_adr,
    M_DATA_IN   =>  BIUO_din,
    M_DATA_OUT  =>  BIUO_dout,
    
    S0_WR_OUT   =>  MMU_wr,

    S0_ADR_OUT  =>  MMU_adr,
    S0_DATA_OUT =>  MMU_din,
    S0_DATA_in  =>  MMU_dout,
    
    S1_WR_OUT   =>  WS_wr,

    S1_ADR_OUT  =>  WS_adr,
    S1_DATA_OUT =>  WS_din,
    S1_DATA_in  =>  WS_dout
  );
  
  MMU: MMU_top port map(
    CLK_IN      =>  CLK_IN,
    RST_IN      =>  reset,
    
    WR_IN       =>  MMU_wr,
    
    ADR_IN      =>  MMU_adr,
    DATA_IN     =>  MMU_din,
    DATA_OUT    =>  MMU_dout,
    
    M_RD_IN     =>  MMU_WS_rd,
    
    M_ADR_IN    =>  MMU_WS_adr,
    M_DATA_OUT  =>  MMU_WS_dta
  );
  
  WS_Encoder: WS_Encoder_top port map(
    CLK_IN      =>  CLK_IN,
    RST_IN      =>  reset,

    WR_IN       =>  WS_wr,

    ADR_IN      =>  WS_adr(7 downto 0),
    DATA_IN     =>  WS_din,
    DATA_OUT    =>  WS_dout,

    M_RD_OUT    =>  MMU_WS_rd,

    M_ADR_OUT   =>  MMU_WS_adr,
    M_DATA_IN   =>  MMU_WS_dta,

    PIXEL_OUT   =>  PIXEL_OUT
  );
end RTL;