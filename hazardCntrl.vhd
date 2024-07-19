library ieee;
use ieee.std_logic_1164.all;

entity hazardCntrl is
port(
	IDEXMemRead : in std_logic;
	IDEXRead2Reg,IFIDRead1Reg,IFIDRead2Reg : in std_logic_vector(4 downto 0);
	
	outSig : out std_logic
	);
end;

architecture rtl of hazardCntrl is
signal int_and,int_1and : std_logic;

component comperatorbit5 is
port(
	A,B : in std_logic_vector(4 downto 0);
	equal : out std_logic
	);
end component;

begin

	comp1 : comperatorbit5
	port map(IDEXRead2Reg,IFIDRead1Reg,int_and);
	
	comp2 : comperatorbit5
	port map(IDEXRead2Reg,IFIDRead2Reg,int_1and);
	
	--Output Drivers
	
	outSig <= (IDEXMemRead and (int_and or int_1and));

end;