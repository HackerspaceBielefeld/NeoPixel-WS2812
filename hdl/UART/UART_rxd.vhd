----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Design Name:			RECEIVER
-- Module Name:     UART_TOP
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7
-- Description:
--    This is the receiver of a fifo buffered uart with wishbone interface.
--    If a byte is received, is is stored in the fifo and the flags to the
--		top entity are set accordingly.
--
--    Funktion:
--		Once enabled, the receiver is waiting for a falling edge on RXD_IN,
--		which is the start bit. Then it waites for half a bit time to sample
--		RXD_IN in the middle of the bit. If it reads as low, the receiver reads
--		all the other bits in, if it is high, the falling edge was maybe a
--		distortion and the FSM goes back to idle. 
--		The bit time is given by a Programmable Intervall Counter, loaded by
--		PIC_LOAD_IN.
--		FIFO_USED_OUT gives back the amount of currently used bytes in the fifo.
--		The fifo is a first word fall through type.
--
-- Dependencies:
--		fifo
--		pic
--
-- Revision:
-- Revision 0.5   Synthesizes fine, not yet simulated.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.pic_pkg.all;

------------
-- Entity --
------------
entity UART_rxd is
	port(
		CLK_IN				: in 	std_logic;
		RESET_IN			: in 	std_logic;
		RX_ENABLE_IN	:	in	std_logic;
		
		PIC_LOAD_IN		:	in	std_logic_vector(15 downto 0);
		
		RXD_IN				:	in	std_logic;
		DATA_RD_IN		:	in	std_logic;		
		DATA_OUT			: out	std_logic_vector(7 downto 0);

		RX_BUSY_OUT		: out std_logic
	);
end UART_rxd;

architecture RTL of UART_rxd is
-------------
--Constants--
-------------

	constant PIC_CNT_WIDTH		:	positive	:=	16;
	
	type RxD_Type is(IDLE, START, RECEIVE, STOP);
	signal c_rx_state, n_rx_state		: RxD_Type;
	
	signal c_rx_dta, n_rx_dta				:	std_logic_vector(7 downto 0);
	signal c_edge_reg, n_edge_reg		:	std_logic_vector(5 downto 0);
	signal c_cnt, n_cnt							:	unsigned(2 downto 0);
	
	signal pic_en						: std_logic;
	signal pic_tick					:	std_logic;
	signal pic_cnt					:	std_logic_vector(15 downto 0);
	
	signal rxd_falling			:	std_logic;
  
begin
	
	pic_inst  : PIC
		generic map(
			CNT_WIDTH			=>	PIC_CNT_WIDTH
		)
		port map(
			CLK_IN				=> 	CLK_IN,
			CNT_EN_IN			=>	pic_en,
			LOAD_IN				=>	pic_cnt,
			TICK_OUT			=>	pic_tick
		);
		
	rxd_edge_det_l	:	process(c_edge_reg, RXD_IN)
	begin		
		n_edge_reg		<= c_edge_reg(4 downto 0) & RXD_IN;
		rxd_falling		<= '0';
		
		if c_edge_reg = "110000" then
			rxd_falling		<=	'1';
		end if;
	end process;
	
	rxd_edge_det_r	:	process
	begin		
		wait until rising_edge(CLK_IN);
		c_edge_reg		<=	n_edge_reg;
	end process;
  
	receive_fsm : process(c_rx_state, c_rx_dta, rxd_falling, pic_tick, 
												c_cnt, fifo_full, PIC_LOAD_IN, RXD_IN)
	begin
		fifo_wr					<=	'0';
		pic_en					<=	'1';
		pic_cnt					<=	PIC_LOAD_IN;
		n_cnt						<=	c_cnt;
		n_rx_dta				<=	c_rx_dta;
		n_rx_state			<=	c_rx_state;
		RX_BUSY_OUT			<=	'1';
		
		case c_rx_state is
			when IDLE	=>
				RX_BUSY_OUT	<=	'0';
				pic_en			<= '0';
				pic_cnt			<= '0' & PIC_LOAD_IN(15 downto 1);
				
				if rxd_falling = '1' then
					n_rx_state		<=	START;
				end if;
				
			when START =>
				if pic_tick = '1' then
					if RXD_IN	= '0' then
						n_rx_state	<= RECEIVE;
					else
						n_rx_state	<= IDLE;
					end if;
				end if;
				
			when RECEIVE =>
				if pic_tick = '1' then
					n_rx_dta	<= RXD_IN & c_rx_dta(7 downto 1);
					n_cnt			<= c_cnt - 1;
					
					if c_cnt = 0 then
						n_cnt				<= "111";
						n_rx_state	<= STOP;
					end if;
				end if;
				
			when STOP =>
				if pic_tick = '1' then
					n_rx_state	<= IDLE;
					
					if RXD_IN = '1' and fifo_full = '0' then
						fifo_wr	<= '1';
					end if;
				end if;

		end case;
	end process receive_fsm;
	
	receive_fsm_reg : process (CLK_IN)
	begin	
		if (rising_edge(CLK_IN)) then
			if RESET_IN = '1' then
				c_rx_state	<=	IDLE;
				c_rx_dta		<= 	"--------";
				c_cnt				<= 	"111";
				
			elsif RX_ENABLE_IN = '1' then
				c_rx_state	<=	n_rx_state;
				c_rx_dta		<=	n_rx_dta;
				c_cnt				<=	n_cnt;
			end if;
		end if;
	end process receive_fsm_reg;
	
end rtl;