----------------------------------------------------------------------------------
-- Engineer:        Florian Kiemes
--
-- Version:         0.1
--
-- Design Name:     Intercon_1M_4S
-- Module Name:     WS_ENCODER
-- Target Devices:  Spartan 6 / Artix 7
-- Tool versions:   ISE 14.7 / Vivado
-- Description:
-- Syscon with one master and four slave interfaces. Using multiplexer.
--
-- Revision:
-- Revision 0.1 File created
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Intercon_1M_4S is
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
end Intercon_1M_4S;

architecture RTL of Intercon_1M_4S is

begin

  -- Concurrent signals
  -- slave0
  STB0_O  <=  STB_I;
  WE0_O   <=  WE_I;
  ADR0_O  <=  ADR_I(ADR_WIDTH - 3 downto 0);
  DAT0_O  <=  DAT_I;
  
  -- slave1
  STB1_O  <=  STB_I;
  WE1_O   <=  WE_I;
  ADR1_O  <=  ADR_I(ADR_WIDTH - 3 downto 0);
  DAT1_O  <=  DAT_I;
  
  -- slave2
  STB2_O  <=  STB_I;
  WE2_O   <=  WE_I;
  ADR2_O  <=  ADR_I(ADR_WIDTH - 3 downto 0);
  DAT2_O  <=  DAT_I;
  
  -- slave3
  STB3_O  <=  STB_I;
  WE3_O   <=  WE_I;
  ADR3_O  <=  ADR_I(ADR_WIDTH - 3 downto 0);
  DAT3_O  <=  DAT_I;
  
  mult_log :  process(ADR_I, CYC_I, DAT0_I, ACK0_I, DAT1_I, ACK1_I, DAT2_I, ACK2_I, DAT3_I, ACK3_I)
  begin
    CYC0_O  <=  '0';
    CYC1_O  <=  '0';
    CYC2_O  <=  '0';
    CYC3_O  <=  '0';
  
    case ADR_I(ADR_WIDTH - 1 downto ADR_WIDTH - 2) is
      when "00" =>
        CYC0_O  <=  CYC_I;
        DAT_O   <=  DAT0_I;
        ACK_O   <=  ACK0_I;
        
      when "01" =>
        CYC1_O  <=  CYC_I;
        DAT_O   <=  DAT1_I;
        ACK_O   <=  ACK1_I;
        
      when "10" =>
        CYC2_O  <=  CYC_I;
        DAT_O   <=  DAT2_I;
        ACK_O   <=  ACK2_I;
        
      when others =>
        CYC3_O  <=  CYC_I;
        DAT_O   <=  DAT3_I;
        ACK_O   <=  ACK3_I;
        
    end case;
  end process;

end architecture;