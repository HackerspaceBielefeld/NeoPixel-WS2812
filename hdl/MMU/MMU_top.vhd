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

library work;
use work.ram_pkg.all;

entity MMU_top is
  port(
    CLK_IN      : in  std_logic;
    RST_IN      : in  std_logic;
    
    ADR_RST_IN  : in  std_logic;
    
    WR_IN       : in  std_logic;
    
    ADR_IN      : in  std_logic_vector(1 downto 0);
    DATA_IN     : in  std_logic_vector(7 downto 0);
    DATA_OUT    : out std_logic_vector(7 downto 0);
    
    M_ADR_IN    : in  std_logic_vector(8 downto 0);
    M_DATA_OUT  : out std_logic_vector(23 downto 0) 
  );
end MMU_top;

architecture RTL of MMU_top is
  
  component MMU_vram is
    port(
      CLK_IN      : in  std_logic;

      WR_A_IN     : in  std_logic;

      ADR_A_IN    : in  std_logic_vector( 8 downto 0);
      DATA_A_IN   : in  std_logic_vector(23 downto 0);

      ADR_B_IN    : in  std_logic_vector( 8 downto 0);
      DATA_B_OUT  : out std_logic_vector(23 downto 0) 
    );
  end component;
  
  component MMU_pram is
    port(
      CLK_IN    : in  std_logic;
      
      WR_IN     : in  std_logic;
      
      ADR_IN    : in  std_logic_vector( 7 downto 0);
      DATA_IN   : in  std_logic_vector(23 downto 0);
      DATA_OUT  : out std_logic_vector(23 downto 0) 
    );
  end component;
  
  type DREG_ARRAY_T is array (0 to 2) of std_logic_vector(7 downto 0);
  signal cDIR, nDIR   : DREG_ARRAY_T; -- Data Input Register
  
  signal cCSR, nCSR   : std_logic_vector(7 downto 0); -- Control Status Register
  
  signal cAdrCntr, nAdrCntr : unsigned(8 downto 0);
  signal cByteSel, nByteSel : natural range 0 to 2;
  
  signal vram_wr      : std_logic;
  signal vram_din     : std_logic_vector(23 downto 0);
  
  signal pram_wr      : std_logic;
  signal pram_adr     : std_logic_vector(7 downto 0);
  signal pram_din     : std_logic_vector(23 downto 0);
  signal pram_dout    : std_logic_vector(23 downto 0);
  
begin
  
  logic: process(cAdrCntr, cDIR, cCSR, ADR_IN, WR_IN, cByteSel, DATA_IN)
  begin
    nAdrCntr  <=  cAdrCntr;
    nByteSel  <=  cByteSel;
    
    nDIR      <=  cDIR;
    nCSR      <=  cCSR;

    
    case ADR_IN is
      -- Data Input Register
      when "00" =>
        DATA_OUT  <=  cDIR(cByteSel);
        if WR_IN = '1' then
          nDIR(cByteSel)  <=  DATA_IN;
          
          case cCsr(1 downto 0) is
            when "00" =>  -- 24-Bit mode
              nByteSel        <=  cByteSel + 1;
              if cByteSel = 2 then
                nByteSel  <=  0;
                nAdrCntr  <=  cAdrCntr + 1;
              end if;
              
						when others =>
          end case;
        end if;
    
      when "01" =>
        DATA_OUT  <=  cCSR;
        if WR_IN = '1' then
          nCSR  <=  DATA_IN;
        end if;
      
      -- Adress Register Low
      when "10" =>
        DATA_OUT  <=  std_logic_vector(cAdrCntr(7 downto 0));
        if WR_IN = '1' then
          nAdrCntr(7 downto 0)  <=  unsigned(DATA_IN);
          nByteSel              <=  0;
        end if;
        
      -- Adress Register High
      when "11" =>
        DATA_OUT  <=  "0000000" & cAdrCntr(8);
        if WR_IN = '1' then
          nAdrCntr(8) <=  DATA_IN(0);
          nByteSel    <=  0;
        end if;
      
      when others=>
    end case;
  end process;

  register_p: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if RST_IN = '1' then
        cCSR      <=  (others=>'0');
        cAdrCntr  <=  (others=>'0');
      else
        cDIR      <=  nDIR;
        cCSR      <=  nCSR;
        cAdrCntr  <=  nAdrCntr;
      end if;
    end if;
  end process;
  
  adr_cnt_p: process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if ADR_RST_IN = '1' then
        cByteSel  <=  0;
      else
        cByteSel  <=  nByteSel;
      end if;
    end if;
  end process;
  
  pram_inst: MMU_pram port map(
    CLK_IN    =>  CLK_IN,
    
    WR_IN     =>  pram_wr,
    
    ADR_IN    =>  pram_adr,
    DATA_IN   =>  pram_din,
    DATA_OUT  =>  pram_dout
  );
  
  vram_inst: MMU_vram port map(
    CLK_IN      =>  CLK_IN,

    WR_A_IN     =>  vram_wr,

    ADR_A_IN    =>  std_logic_vector(cAdrCntr),
    DATA_A_IN   =>  vram_din,

    ADR_B_IN    =>  M_ADR_IN,
    DATA_B_OUT  =>  M_DATA_OUT
  );

end RTL;