library ieee;
use ieee.std_logic_1164.all;

entity mux2to1 is
port(
	A,B : in std_logic_vector(7 downto 0);
	sel : in std_logic;
	O : out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of mux2to1 is

signal int_A,int_B : std_logic_vector(7 downto 0);

component and1to7 is
port(
	i_in1 : in std_logic_vector(7 downto 0);
	i_in2 : in std_logic;
	o_out : out std_logic_vector(7 downto 0)
	);
end component;

begin

	muxA : and1to7
	port map(A,not(sel),int_A);
	
	muxB : and1to7
	port map(B,sel,int_B);
	
	--Output Drivers
	
	O <= int_A or int_B;

end;
