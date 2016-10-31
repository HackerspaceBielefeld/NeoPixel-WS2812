----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:     WS2812_TOP
-- Module Name:     BYTE_TRANSFER
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
--    This is the byte transfer layer. It feeds the bit transfer layer with the
--		single bits to transmit.
--
-- Revision:
-- Revision 0.1	File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rgb_send is
  Port( 
		CLK_IN    		:	in	std_logic;	--Main clock
		RST_IN    		:	in	std_logic;	--Main reset
		
		START_IN      : in  std_logic;  --Starts encoding
		
    SEQ_STP_IN    : in  std_logic_vector(7 downto 0); --amount of steps for one bit sequence
		STP_0H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 0-bit
		STP_1H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 1-bit
		
		RGB_DATA_IN		:	in	std_logic_vector(23 downto 0); --RGB data
		
		DAT_OUT   		:	out	std_logic;	--LED data line
		BSY_OUT				:	out	std_logic;	--High, if transfer is in progress
		NB_OUT				:	out std_logic
	);
end rgb_send;

architecture RTL of rgb_send is

	component bit_send is
		Port( 
			CLK_IN    		:	in	std_logic;	--Main clock
			RST_IN    		:	in	std_logic;	--Main reset
					
			START_IN			:	in	std_logic;
			
			SEQ_STP_IN    : in  std_logic_vector(7 downto 0); --amount of steps for one bit sequence
			STP_0H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 0-bit
			STP_1H_IN     : in  std_logic_vector( 7 downto 0);  --high time in steps for 1-bit
	
			BIT_IN        : in  std_logic;  --the actual bit to encode
	
			DAT_OUT       : out std_logic;  --LED data line
			BSY_OUT       : out std_logic;  --High, if encoding in Progress.
			NB_OUT        : out std_logic   --Load Next Bit output. If it's gone high during transmission,
		);
	end component;
	
	type RGB_SEND_FSM_T is (IDLE_S, NEXTBIT_S, NEXT_BYTE_S);
	signal cState, nState		:	RGB_SEND_FSM_T;
	
	signal cBitCnt, nBitCnt		:	unsigned(2 downto 0);
	signal cByteCnt, nByteCnt	:	unsigned(1 downto 0);
	
	signal bitStart			:	std_logic;
	signal bitVal 			:	std_logic;
	signal bitBsy				:	std_logic;
	signal bitNb				:	std_logic;

begin

	bit_send_inst:	bit_send
		port map(
			CLK_IN			=>	CLK_IN,
			RST_IN			=>	RST_IN,

			START_IN		=>	bitStart,
			
			SEQ_STP_IN	=>	SEQ_STP_IN,
			STP_0H_IN		=>	STP_0H_IN,
			STP_1H_IN		=>	STP_1H_IN,
			
			BIT_IN			=>	bitVal,
			
			DAT_OUT			=>	DAT_OUT,
			BSY_OUT			=>	bitBsy,
			NB_OUT			=>	bitNb
		);

	fsm:	process(cState, cBitCnt, cByteCnt, START_IN)
	begin
		BSY_OUT		<=	'1';
		NB_OUT		<=  '0';
		
    bitStart  <=  '0';
    bitVal    <=  '0';
		
		nState		<=	cState;
		nBitCnt		<=	cBitCnt - 1;
		nByteCnt	<=	cByteCnt - 1;
		
		case cState is
			when IDLE_S =>
        BSY_OUT   <=  '0';
				if START_IN = '1' then
					nState	  <=	NEXTBIT_S;
				end if;
			
			when NEXTBIT_S =>
			
			when NEXT_BYTE_S =>
			
		end case;
	end process;
	
	regs:	process(CLK_IN) is
	begin
		if rising_edge(CLK_IN) then
			if RST_IN = '1' then
				cState		<=	IDLE_S;
				
			else
				cState 		<=	nState;
				cBitCnt		<=	nBitCnt;
				cByteCnt	<=	nByteCnt;
			end if;
		end if;
	end process;
end RTL;