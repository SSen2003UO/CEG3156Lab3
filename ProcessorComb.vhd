library ieee;
use ieee.std_logic_1164.all;

entity ProcessorComb is
port(
	RegDst : in std_logic;
	ALUOp : in std_logic_vector(1 downto 0);
	ALUBin,MemWrite,MemRead,MemToReg,PCSrc : in std_logic;
	o_Control : out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of ProcessorComb is

signal control : std_logic_vector(7 downto 0);

begin

	control(7) <= RegDst;
	control(6 downto 5) <= ALUOp;
	control(4) <= ALUBin;
	control(3) <= MemWrite;
	control(2) <= MemRead;
	control(1) <= MemToReg;
	control(0) <= PCSrc;
	
	--Output Drivers
	
	o_Control <= control;
end;