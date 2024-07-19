library ieee;
use ieee.std_logic_1164.all;

entity comperatorbit5 is
port(
	A,B : in std_logic_vector(4 downto 0);
	equal : out std_logic
	);
end;

architecture rtl of comperatorbit5 is

signal andOp : std_logic_vector(4 downto 0);

component and5to5 is
port(
	A,B : in std_logic_vector(4 downto 0);
	C : out std_logic_vector(4 downto 0)
	);
end component;

begin

 andUnit : and5to5
 port map(A,B,andOp);
 
 --Output Drivers
 
 equal <=andOp(4) and andOp(3) and andOp(2) and andOp(1) and andOp(0);
 
end;
