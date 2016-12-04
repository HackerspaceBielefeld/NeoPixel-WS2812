----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     WS2812_TOP
-- Module Name:     WS2812_TOP
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
--    This is an interface for LEDs with WS2812 controller integrated. It is wishbone
--    compatible. The registers can be accessed via I/O instructions, the LED data
--    is transmitted via MMIO.
--
--    Register map:
--    ADR     R/W     DESC
--     0      R/W     Control/Status register.
--     1      R/W     T1H cnt.
--     2      R/W     T1L cnt.
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
-- Dependencies:
--    pic
--
-- Revision:
-- Revision 0.1 File created
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.ram_pkg.all;
use work.pic_pkg.all;

entity ws2812_top is
  Port( 
  -- Wishbone-interface
    CLK_I     : in  std_logic;
    RST_I     : in  std_logic;
    
    CYC_I     : in  std_logic;
    STB_I     : in  std_logic;
    
    WE_I      : in  std_logic;
    
    ADR_I     : in  std_logic_vector(11 downto 0);
    
    DAT_I     : in  std_logic_vector(7 downto 0);
    DAT_O     : out std_logic_vector(7 downto 0);
    
    ACK_O     : out std_logic;
    
    -- Serial lines
    LED_OUT   : out STD_LOGIC
  );
end ws2812_top;

architecture RTL of ws2812_top is

  -- Constants for timing with 32 MHz clock
  constant  C32_T0L   : std_logic_vector(7 downto 0)  := x"1B"; --27
  constant  C32_T0H   : std_logic_vector(7 downto 0)  := x"0C"; --12
  constant  C32_T1L   : std_logic_vector(7 downto 0)  := x"0F"; --15
  constant  C32_T1H   : std_logic_vector(7 downto 0)  := x"19"; --25
  
  constant  C32_RST   : std_logic_vector(15 downto 0) := x"06A4"; --1700
  constant  LED_CNT   : std_logic_vector(15 downto 0) := x"012C"; --300
  
  -- counter registers for timing of the different signal phases
  signal c_t0l_cnt, n_t0l_cnt   : std_logic_vector(7 downto 0);
  signal c_t0h_cnt, n_t0h_cnt   : std_logic_vector(7 downto 0);
  signal c_t1l_cnt, n_t1l_cnt   : std_logic_vector(7 downto 0);
  signal c_t1h_cnt, n_t1h_cnt   : std_logic_vector(7 downto 0);

  signal c_rst_cnt, n_rst_cnt   : std_logic_vector(15 downto 0);
  signal c_led_cnt, n_led_cnt   : std_logic_vector(15 downto 0); --For 30 fps don't use more than 1100 LEDs
  
  -- Control-/Statusregister
  signal c_ctrl_reg, n_ctrl_reg : std_logic_vector(7 downto 0);
  
  -- Memory acknowledge, one tick delayed for mem read.
  signal c_mem_ack, n_mem_ack   : std_logic;
  
--RAM signals
  --external interface
  signal we_r       : std_logic;
  signal we_g       : std_logic;
  signal we_b       : std_logic;
    
  signal dat_r      : std_logic_vector(7 downto 0);
  signal dat_g      : std_logic_vector(7 downto 0);
  signal dat_b      : std_logic_vector(7 downto 0);
  
  --internal interface
  signal pixel_adr  : std_logic_vector(9 downto 0);
  signal pixel_dat  : std_logic_vector(23 downto 0);
  
  --fsm states
  type FSM_STATES is (IDLE, T0L, T0H, T1L, T1H, RESET);
  --fsm registers
  signal c_state, n_state     : FSM_STATES;
  signal c_padr, n_padr       : unsigned(9 downto 0);
  signal c_bit_cnt, n_bit_cnt : natural range 0 to 23;
  
  --pic signals
  signal pic_en   : std_logic;
  signal pic_tick : std_logic;
  signal pic_ld   : std_logic_vector(15 downto 0);

begin

  pixel_adr <=  std_logic_vector(c_padr);
  
  ramb_r  : ram_dual_port
    generic map(
      DATA_WIDTH  =>  8,
      RAM_DEPTH   =>  1024
    )
    port map(
      CLK_A_IN    =>  CLK_I,
      WE_A_IN     =>  we_r,
      ADR_A_IN    =>  ADR_I(11 downto 2),
      DAT_A_IN    =>  DAT_I,
      DAT_A_OUT   =>  dat_r,
        
      CLK_B_IN    =>  CLK_I,
      WE_B_IN     =>  '0',
      ADR_B_IN    =>  pixel_adr,
      DAT_B_IN    =>  "--------",
      DAT_B_OUT   =>  pixel_dat(15 downto 8)
    );
    
    ramb_g  : ram_dual_port
    generic map(
      DATA_WIDTH  =>  8,
      RAM_DEPTH   =>  1024
    )
    port map(
      CLK_A_IN    =>  CLK_I,
      WE_A_IN     =>  we_g,
      ADR_A_IN    =>  ADR_I(11 downto 2),
      DAT_A_IN    =>  DAT_I,
      DAT_A_OUT   =>  dat_g,
        
      CLK_B_IN    =>  CLK_I,
      WE_B_IN     =>  '0',
      ADR_B_IN    =>  pixel_adr,
      DAT_B_IN    =>  "--------",
      DAT_B_OUT   =>  pixel_dat(23 downto 16)
    );
    
    ramb_b  : ram_dual_port
    generic map(
      DATA_WIDTH  =>  8,
      RAM_DEPTH   =>  1024
    )
    port map(
      CLK_A_IN    =>  CLK_I,
      WE_A_IN     =>  we_b,
      ADR_A_IN    =>  ADR_I(11 downto 2),
      DAT_A_IN    =>  DAT_I,
      DAT_A_OUT   =>  dat_b,
        
      CLK_B_IN    =>  CLK_I,
      WE_B_IN     =>  '0',
      ADR_B_IN    =>  pixel_adr,
      DAT_B_IN    =>  "--------",
      DAT_B_OUT   =>  pixel_dat(7 downto 0)
    );
    
    pic_inst: pic
    generic map(
      CNT_WIDTH =>  16
    )
    port map(
      CLK_IN    =>  CLK_I,
      CNT_EN_IN =>  pic_en,
      LOAD_IN   =>  pic_ld,
      TICK_OUT  =>  pic_tick
    );
    
  bus_iface_l:  process(CYC_I, STB_I, ADR_I, TAG_I, WE_I, DAT_I, c_led_cnt, 
                        c_rst_cnt, dat_r, dat_g, dat_b, c_ctrl_reg, c_mem_ack,
                        c_t0h_cnt, c_t0l_cnt, c_t1h_cnt, c_t1l_cnt)
  begin
    DAT_O       <=  "--------";
    ACK_O       <=  '0';
    
    we_r        <=  '0';
    we_g        <=  '0';
    we_b        <=  '0';
    
    n_t0l_cnt   <=  c_t0l_cnt;
    n_t0h_cnt   <=  c_t0h_cnt;
    n_t1l_cnt   <=  c_t1l_cnt;
    n_t1h_cnt   <=  c_t1h_cnt;
    
    n_rst_cnt   <=  c_rst_cnt;
    n_led_cnt   <=  c_led_cnt;
    
    n_ctrl_reg  <=  c_ctrl_reg;
    
    n_mem_ack   <=  '0';
    
    if CYC_I = '1' and STB_I = '1' then
      if TAG_I(0) = '1' then  --register access
        case ADR_I(3 downto 0) is
          when "0000" =>
            DAT_O   <=  c_ctrl_reg;
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_ctrl_reg  <=  c_ctrl_reg(7 downto 1) & DAT_I(0);
            end if;
            
          when "0010" =>
            DAT_O   <=  c_t1h_cnt;
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_t1h_cnt <=  DAT_I;
            end if;
            
          when "0011" =>
            DAT_O   <=  c_t0h_cnt;
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_t0h_cnt <=  DAT_I;
            end if;
            
          when "0100" =>
            DAT_O   <=  c_t1l_cnt;
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_t1l_cnt <=  DAT_I;
            end if;
            
          when "0101" =>
            DAT_O   <=  c_t0l_cnt;
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_t0l_cnt <=  DAT_I;
            end if;
            
          when "0110" =>
            DAT_O   <=  c_rst_cnt(7 downto 0);
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_rst_cnt(7 downto 0) <=  DAT_I;
            end if;
            
          when "0111" =>
            DAT_O   <=  c_rst_cnt(15 downto 8);
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_rst_cnt(15 downto 8)  <=  DAT_I;
            end if;
            
          when "1000" =>
            DAT_O   <=  c_led_cnt(7 downto 0);
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_led_cnt(7 downto 0) <=  DAT_I;
            end if;
            
          when "1001" =>
            DAT_O   <=  c_led_cnt(15 downto 8);
            ACK_O   <=  '1';
            if WE_I = '1' then
              n_led_cnt(15 downto 8)  <=  DAT_I;
            end if;
            
          when others =>
        end case;
      
      else                    --memory access
        case ADR_I(1 downto 0) is
          when "00"   =>
            DAT_O     <=  dat_r;
            
            if WE_I = '1' then
              we_r      <=  '1';
              ACK_O     <=  '1';
            else
              --READ DELAY FOR BRAM--
              n_mem_ack <=  '1';
                if c_mem_ack = '1' then
                n_mem_ack <=  '0';
                ACK_O     <=  '1';
              end if;
              -----------------------
            end if;
          
          when "01"   =>
            DAT_O     <=  dat_g;
            
            if WE_I = '1' then
              we_g      <=  '1';
              ACK_O     <=  '1';
            else
              --READ DELAY FOR BRAM--
              n_mem_ack <=  '1';
                if c_mem_ack = '1' then
                n_mem_ack <=  '0';
                ACK_O     <=  '1';
              end if;
              -----------------------
            end if;
            
          when "10"   =>
            DAT_O     <=  dat_b;
            
            if WE_I = '1' then
              we_b      <=  '1';
              ACK_O     <=  '1';
            else
              --READ DELAY FOR BRAM--
              n_mem_ack <=  '1';
                if c_mem_ack = '1' then
                n_mem_ack <=  '0';
                ACK_O     <=  '1';
              end if;
              -----------------------
            end if;
            
          when others =>
        end case;
      end if;
    end if;
  end process;

  bus_iface_r:  process(CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        c_t0l_cnt   <=  C32_T0L;
        c_t0h_cnt   <=  C32_T0H;
        c_t1l_cnt   <=  C32_T1L;
        c_t1h_cnt   <=  C32_T1H;
        
        c_rst_cnt   <=  C32_RST;
        c_led_cnt   <=  LED_CNT;
        
        c_ctrl_reg  <=  (others=>'0');
        c_mem_ack   <=  '0';
        
      else
        c_t0l_cnt   <=  n_t0l_cnt;
        c_t0h_cnt   <=  n_t0h_cnt;
        c_t1l_cnt   <=  n_t1l_cnt;
        c_t1h_cnt   <=  n_t1h_cnt;
        
        c_rst_cnt   <=  n_rst_cnt;
        c_led_cnt   <=  n_led_cnt;
        
        c_ctrl_reg  <=  n_ctrl_reg;
        c_mem_ack   <=  n_mem_ack;
      end if;
    end if;
  end process;

  ws_fsm: process(c_state, c_bit_cnt, c_ctrl_reg, pixel_dat, pic_tick)
  begin
    n_state   <=  c_state;
    n_bit_cnt <=  c_bit_cnt;
    
    pic_en    <=  '1':
    pic_ld    <=  (others=>'-');
    
    LED_OUT   <=  '0';

    case c_state is
      when IDLE =>
        pic_en  <=  '0';
        
        if c_ctrl_reg(0) = '1' then -- enable
          
          if pixel_dat(c_bit_cnt) = '0' then
            n_state <=  T0H;
            
          else
            n_state <=  T1H;
            pic_ld  <=  c_t1h_cnt;
          end if;
        end if;
      
      when T0H =>
        LED_OUT   <=  '1';
        pic_ld    <=  c_t0h_cnt;
        
        if pic_tick = '1' then
          n_state   <=  T0L;
          pic_ld    <=  c_t0l_cnt;
          n_bit_cnt <=  c_bit_cnt - 1;
          if c_bit_cnt = 0 then
            n_bit_cnt   <=  23;
            n_padr      <=  c_padr + 1;
        end if;
        
      when T0L =>   
        if pic_tick = '1' then
          if c_padr = unsigned(c_led_cnt(9 downto 0)) then
            if c_bit_cnt = 23 then
              n_state   <=  RESET;
          else
              
            end if;
          end if;
        end if;
        
    end case;
  end process;
  
  ws_regs:  process(CLK_I)
  begin
    if rising_edge(CLK_I) then
      if RST_I = '1' then
        c_padr    <=  (others=>'0');
        c_state   <=  IDLE;
        c_bit_cnt <=  23;
      else
        c_padr    <=  n_padr;
        c_state   <=  n_state;
        c_bit_cnt <=  n_bit_cnt;
      end if;
    end if;
  end process;
  
end RTL;