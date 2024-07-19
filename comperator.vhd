library ieee;
use ieee.std_logic_1164.all;

entity comperator is
port(
	A,B : in std_logic_vector(7 downto 0);
	equal : out std_logic
	);
end;

architecture rtl of comperator is

signal andOp : std_logic_vector(7 downto 0);

component and8to8 is
port(
	A,B : in std_logic_vector(7 downto 0);
	C : out std_logic_vector(7 downto 0)
	);
end component;

begin

 andUnit : and8to8
 port map(A,B,andOp);
 
 --Output Drivers
 
 equal <= andOp(7) and andOp(6) and andOp(5) and andOp(4) and andOp(3) and andOp(2) and andOp(1) and andOp(0);
 
end;
