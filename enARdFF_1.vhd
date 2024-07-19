library ieee;
use ieee.std_logic_1164.all;

entity enARdFF_1 is
	port(
	i_d, i_en, clk, i_resetBar: in std_logic;
	o_q : out std_logic);
end enARdFF_1;

architecture rtl of enARdFF_1 is
 SIGNAL int_q, int_qBar : STD_LOGIC;
 SIGNAL int_sSignal, int_rSignal : STD_LOGIC;
 BEGIN
 -- Concurrent Signal Assignment
-- int_sSignal <= i_d and i_en and clk;
 --int_rSignal <= (not(i_d) and i_en and clk);
 --int_q <= not(not(i_d) and i_en and (clk or int_qBar)) and i_resetBar;
 --int_qBar <= not((int_q or i_d) and i_en and clk) or not(i_resetBar);
   onebitregister : process (i_resetBar, clk) is
  begin

    if (i_resetBar = '0') then
      int_q <= '0';
    elsif (clk'EVENT and clk = '1') then
      if (i_en = '1') then
        int_q <= i_d;
      end if;
    end if;

  end process onebitregister;
 
 --Output Drivers

 o_q <= int_q;
 
 end rtl;