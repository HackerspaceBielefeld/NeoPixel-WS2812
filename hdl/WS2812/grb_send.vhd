----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     WS2812_TOP
-- Module Name:     BYTE_TRANSFER
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
--    This is the byte transfer layer. It feeds the bit transfer layer with the
--    single bits to transmit.
--
-- Revision:
-- Revision 0.1 File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity grb_send is
  Port( 
    CLK_IN        : in  std_logic;  --Main clock
    RST_IN        : in  std_logic;  --Main reset
    
    START_IN      : in  std_logic;  --Starts encoding
    
    SEQ_STP_IN    : in  std_logic_vector(7 downto 0); --amount of steps for one bit sequence
    STP_0H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 0-bit
    STP_1H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 1-bit
    
    GRB_DATA_IN   : in  std_logic_vector(23 downto 0); --RGB data
    
    DAT_OUT       : out std_logic;  --LED data line
    BSY_OUT       : out std_logic;  --High, if transfer is in progress
    NB_OUT        : out std_logic
  );
end grb_send;

architecture RTL of grb_send is

  component bit_send is
    Port( 
      CLK_IN        : in  std_logic;  --Main clock
      RST_IN        : in  std_logic;  --Main reset
          
      START_IN      : in  std_logic;
      
      SEQ_STP_IN    : in  std_logic_vector(7 downto 0); --amount of steps for one bit sequence
      STP_0H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 0-bit
      STP_1H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 1-bit
  
      BIT_IN        : in  std_logic;  --the actual bit to encode
  
      DAT_OUT       : out std_logic;  --LED data line
      BSY_OUT       : out std_logic;  --High, if encoding in Progress.
      NB_OUT        : out std_logic   --Load Next Bit output. If it's gone high during transmission,
    );
  end component;
  
  type GRB_SEND_FSM_T is (IDLE_S, NEXTBIT_S);
  signal cState, nState   : GRB_SEND_FSM_T;
  
  signal cBitCnt, nBitCnt   : natural range 0 to 23;
  
  signal bitStart     : std_logic;
  signal bitVal       : std_logic;
  signal bitBsy       : std_logic;
  signal bitNb        : std_logic;

begin

  bit_send_inst:  bit_send
    port map(
      CLK_IN      =>  CLK_IN,
      RST_IN      =>  RST_IN,

      START_IN    =>  bitStart,
      
      SEQ_STP_IN  =>  SEQ_STP_IN,
      STP_0H_IN   =>  STP_0H_IN,
      STP_1H_IN   =>  STP_1H_IN,
      
      BIT_IN      =>  bitVal,
      
      DAT_OUT     =>  DAT_OUT,
      BSY_OUT     =>  bitBsy,
      NB_OUT      =>  bitNb
    );

  bitVal    <=  GRB_DATA_IN(cBitCnt); 
  
  fsm:  process(cState, cBitCnt, bitNb, START_IN, bitBsy)
    variable decBitCnt  : natural range 0 to 23 ;
  begin
    BSY_OUT   <=  '1';
    NB_OUT    <=  '0';
    
    bitStart  <=  '0';
    
    nState    <=  cState;
    nBitCnt   <=  cBitCnt;
    decBitCnt :=  cBitCnt - 1;
    
    case cState is
      when IDLE_S =>
        BSY_OUT   <=  '0';
        nBitCnt   <=  23;
        
        if START_IN = '1' then
          nState    <=  NEXTBIT_S;
          bitStart  <=  '1';
        end if;
      
      when NEXTBIT_S =>
        bitStart  <= '1';
        
        if bitNb = '1' then
          nBitCnt <= decBitCnt;
          
          if cBitCnt = 0 then
            nBitCnt   <= 23;
            NB_OUT    <= '1';
            if START_IN = '0' then
              bitStart  <= '0';
              nState  <= IDLE_S;
            end if;
          end if;
        end if;

    end case;
  end process;
  
  regs: process(CLK_IN) is
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        cState    <=  IDLE_S;
        
      else
        cState    <=  nState;
        cBitCnt   <=  nBitCnt;
      end if;
    end if;
  end process;
end RTL;