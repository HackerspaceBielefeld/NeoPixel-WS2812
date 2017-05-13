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
    CLK_IN          : in  std_logic;
    
    RST_BTN_N_IN    : in  std_logic;
    
    --Config-Pins, needs synchronisation
    AUTO_SWITCH_IN  : in  std_logic;
    AUTO_LED_OUT    : out std_logic;

    --SPI-lines
    CS_IN           : in  std_logic;
    SCLK_IN         : in  std_logic;
    MOSI_IN         : in  std_logic;
    MISO_OUT        : out std_logic;
    
    --UART-lines
    RXD_IN          : in  std_logic;
    TXD_OUT         : out std_logic;
    
    --Data signal to NeoPixel-LED
    PIXEL_OUT       : out std_logic
  );
end NeoPixel_top;


architecture RTL of NeoPixel_top is

  component syscon is
    port(
      EXT_CLK_IN    : in  std_logic;
      RST_BTN_N_IN  : in  std_logic;
      
      CLK_O         : out std_logic;
      RST_O         : out std_logic
    );
  end component;
  
  component intercon_1M_4S is
    generic(
      ADR_WIDTH   : positive range 3 to positive'High := 8;
      DAT_WIDTH   : positive := 8
    );
    port(
      -- from master
      CYC_I   : in  std_logic;
      STB_I   : in  std_logic;
      WE_I    : in  std_logic;
      ADR_I   : in  std_logic_vector(ADR_WIDTH - 1 downto 0);
      DAT_I   : in  std_logic_vector(DAT_WIDTH - 1 downto 0);
      
      DAT_O   : out std_logic_vector(DAT_WIDTH - 1 downto 0);
      ACK_O   : out std_logic;
      
      -- to slave0
      CYC0_O  : out std_logic;
      STB0_O  : out std_logic;
      WE0_O   : out std_logic;
      ADR0_O  : out std_logic_vector(ADR_WIDTH - 3 downto 0); -- because of predecoding
      DAT0_O  : out std_logic_vector(DAT_WIDTH - 1 downto 0);
      
      DAT0_I  : in  std_logic_vector(DAT_WIDTH - 1 downto 0);
      ACK0_I  : in  std_logic;
      
      -- to slave1
      CYC1_O  : out std_logic;
      STB1_O  : out std_logic;
      WE1_O   : out std_logic;
      ADR1_O  : out std_logic_vector(ADR_WIDTH - 3 downto 0); -- because of predecoding
      DAT1_O  : out std_logic_vector(DAT_WIDTH - 1 downto 0);
      
      DAT1_I  : in  std_logic_vector(DAT_WIDTH - 1 downto 0);
      ACK1_I  : in  std_logic;
      
      -- to slave2
      CYC2_O  : out std_logic;
      STB2_O  : out std_logic;
      WE2_O   : out std_logic;
      ADR2_O  : out std_logic_vector(ADR_WIDTH - 3 downto 0); -- because of predecoding
      DAT2_O  : out std_logic_vector(DAT_WIDTH - 1 downto 0);
      
      DAT2_I  : in  std_logic_vector(DAT_WIDTH - 1 downto 0);
      ACK2_I  : in  std_logic;
      
      -- to slave3
      CYC3_O  : out std_logic;
      STB3_O  : out std_logic;
      WE3_O   : out std_logic;
      ADR3_O  : out std_logic_vector(ADR_WIDTH - 3 downto 0); -- because of predecoding
      DAT3_O  : out std_logic_vector(DAT_WIDTH - 1 downto 0);
      
      DAT3_I  : in  std_logic_vector(DAT_WIDTH - 1 downto 0);
      ACK3_I  : in  std_logic
    );
  end component;
  
  component UART_top is
    port(
      --System clock and master reset
      CLK_I       : in  std_logic;
      RST_I       : in  std_logic;
      
      --Bus interface
      CYC_I       : in  std_logic;
      STB_I       : in  std_logic;
      WE_I        : in  std_logic;
      ADR_I       : in  std_logic_vector(2 downto 0);
      DAT_I       : in  std_logic_vector(7 downto 0);
      DAT_O       : out std_logic_vector(7 downto 0);
      ACK_O       : out std_logic;
      
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
      CLK_I       : in  std_logic;
      RST_I       : in  std_logic;
      
      --Bus interface
      CYC_I       : in  std_logic;
      STB_I       : in  std_logic;
      WE_I        : in  std_logic;
      ADR_I       : in  std_logic_vector(2 downto 0);
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
  end component;

  component Controller_top is
    port(
      --System clock and master reset
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      --Interrups from COMs
      INT0_IN     : in  std_logic;
      INT1_IN     : in  std_logic;
    
      CONF_AUTO_IN: in  std_logic;
      LED_OUT     : out std_logic;
    
      --Bus interface to serial com ports
      A_RD_OUT    : out  std_logic;
      A_WR_OUT    : out  std_logic;
      
      A_ADR_OUT   : out std_logic_vector(3 downto 0);
      A_DATA_OUT  : out std_logic_vector(7 downto 0);
      A_DATA_IN   : in  std_logic_vector(7 downto 0);
      
      --Bus interface to MMU and WS-driver
      B_WR_OUT    : out std_logic;
      
      B_ADR_OUT   : out std_logic_vector(3 downto 0);
      B_DATA_OUT  : out std_logic_vector(7 downto 0);
      B_DATA_IN   : in  std_logic_vector(7 downto 0) 
    );
  end component;

  component WS_Encoder_top is
    port(
      --System clock and master reset
      CLK_IN      : in  std_logic;
      RST_IN      : in  std_logic;
      
      --Bus interface
      WR_IN       : in  std_logic;
      
      ADR_IN      : in  std_logic_vector(3 downto 0);
      DATA_IN     : in  std_logic_vector(7 downto 0);
      DATA_OUT    : out std_logic_vector(7 downto 0);
      
      --LED data out
      PIXEL_OUT   : out std_logic
    );
  end component;

  --Master reset
  signal sys_reset  : std_logic;
  
  --Auto-Mode enable
  signal ena_auto   : std_logic;
  
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
  
  --WS_Controller-lines
  signal WS_wr      : std_logic;
  signal WS_adr     : std_logic_vector(3 downto 0);
  signal WS_din     : std_logic_vector(7 downto 0);
  signal WS_dout    : std_logic_vector(7 downto 0);
  
  --Sync-Registers
  signal sync_auto   : std_logic_vector(1 downto 0);
  
  -- wisbone signals
  
  -- syscon signals
  signal wb_clk     : std_logic;
  signal wb_rst     : std_logic;
  
  -- master signals
  signal wb_ma_cyc  : std_logic;
  signal wb_ma_stb  : std_logic;  
  signal wb_ma_we   : std_logic;  
  signal wb_ma_adr  : std_logic_vector(7 downto 0);  
  signal wb_ma_dat_i: std_logic_vector(7 downto 0);  
  signal wb_ma_dat_o: std_logic_vector(7 downto 0);  
  signal wb_ma_ack  : std_logic;
  
  --slave0
  signal wb_s0_cyc  : std_logic;
  signal wb_s0_stb  : std_logic;  
  signal wb_s0_we   : std_logic;  
  signal wb_s0_adr  : std_logic_vector(5 downto 0);  
  signal wb_s0_dat_i: std_logic_vector(7 downto 0);  
  signal wb_s0_dat_o: std_logic_vector(7 downto 0);  
  signal wb_s0_ack  : std_logic;
  
  --slave1
  signal wb_s1_cyc  : std_logic;
  signal wb_s1_stb  : std_logic;  
  signal wb_s1_we   : std_logic;  
  signal wb_s1_adr  : std_logic_vector(5 downto 0);  
  signal wb_s1_dat_i: std_logic_vector(7 downto 0);  
  signal wb_s1_dat_o: std_logic_vector(7 downto 0);  
  signal wb_s1_ack  : std_logic;
  
  --slave2
  signal wb_s2_cyc  : std_logic;
  signal wb_s2_stb  : std_logic;  
  signal wb_s2_we   : std_logic;  
  signal wb_s2_adr  : std_logic_vector(5 downto 0);  
  signal wb_s2_dat_i: std_logic_vector(7 downto 0);  
  signal wb_s2_dat_o: std_logic_vector(7 downto 0);  
  signal wb_s2_ack  : std_logic;
  
begin

  syscon_inst: syscon port map(
    EXT_CLK_IN    =>  CLK_IN,
    RST_BTN_N_IN  =>  RST_BTN_N_IN,
    CLK_O         =>  wb_clk,
    RST_O         =>  wb_rst
  );
  
  intercon_inst: intercon_1M_4S generic map(
    ADR_WIDTH => 8,
    DAT_WIDTH => 8
  )
  port map(
    -- from master
    CYC_I     => wb_ma_cyc,
    STB_I     => wb_ma_stb,
    WE_I      => wb_ma_we,
    ADR_I     => wb_ma_adr,
    DAT_I     => wb_ma_dat_o,

    DAT_O     => wb_ma_dat_i,
    ACK_O     => wb_ma_ack,
    
    -- to slave0
    CYC0_O    => wb_s0_cyc,
    STB0_O    => wb_s0_stb,
    WE0_O     => wb_s0_we,
    ADR0_O    => wb_s0_adr,
    DAT0_O    => wb_s0_dat_i,

    DAT0_I    => wb_s0_dat_o,
    ACK0_I    => wb_s0_ack,
    
    -- to slave1
    CYC1_O    => wb_s1_cyc,
    STB1_O    => wb_s1_stb,
    WE1_O     => wb_s1_we,
    ADR1_O    => wb_s1_adr,
    DAT1_O    => wb_s1_dat_i,

    DAT1_I    => wb_s1_dat_o,
    ACK1_I    => wb_s1_ack,
    
    -- to slave2
    CYC2_O    => wb_s2_cyc,
    STB2_O    => wb_s2_stb,
    WE2_O     => wb_s2_we,
    ADR2_O    => wb_s2_adr,
    DAT2_O    => wb_s2_dat_i,

    DAT2_I    => wb_s2_dat_o,
    ACK2_I    => wb_s2_ack,
    
    -- to slave3
    CYC3_O    => open,
    STB3_O    => open,
    WE3_O     => open,
    ADR3_O    => open,
    DAT3_O    => open,

    DAT3_I    => "--------",
    ACK3_I    => '-'
  );

  ena_auto  <=  sync_auto(1);

  sync_in: process(wb_clk)
  begin
    if rising_edge(wb_clk) then
      sync_auto   <=  sync_auto(0) & AUTO_SWITCH_IN;
    end if;
  end process;
  
  --Instatiations of submodules
  UART: UART_top port map(
    CLK_IN    =>  wb_clk,
    RST_IN    =>  wb_rst,
    
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
    CLK_IN    =>  wb_clk,
    RST_IN    =>  wb_rst,
    
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
    CLK_IN        =>  wb_clk,
    RST_IN        =>  wb_rst,
      
    INT0_IN       =>  SPI_int,
    INT1_IN       =>  UART_int,
      
    CONF_AUTO_IN  =>  ena_auto,
    LED_OUT       =>  AUTO_LED_OUT,
        
    A_RD_OUT      =>  BIUI_rd,
    A_WR_OUT      =>  BIUI_wr,
        
    A_ADR_OUT     =>  BIUI_adr,
    A_DATA_OUT    =>  BIUI_din,
    A_DATA_IN     =>  BIUI_dout,
        
    B_WR_OUT      =>  WS_wr,
        
    B_ADR_OUT     =>  WS_adr,
    B_DATA_OUT    =>  WS_din,
    B_DATA_IN     =>  WS_dout
  );

  WS_Encoder: WS_Encoder_top port map(
    CLK_IN      =>  wb_clk,
    RST_IN      =>  wb_rst,

    WR_IN       =>  WS_wr,

    ADR_IN      =>  WS_adr,
    DATA_IN     =>  WS_din,
    DATA_OUT    =>  WS_dout,

    PIXEL_OUT   =>  PIXEL_OUT
  );
end RTL;