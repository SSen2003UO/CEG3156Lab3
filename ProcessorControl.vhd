library ieee;
use ieee.std_logic_1164.all;

entity ProcessorControl is
port(
	opcode: in std_logic_vector(5 downto 0);
	clk : in std_logic;
	Jump,Branch : out std_logic;
	controlOut: out std_logic_vector(7 downto 0) --Logic
	);
end;

architecture rtl of ProcessorControl is
-- 35 Load, 43 Store, 4 Branch, 2 Jump, 0 Rtype

signal ALUOp : std_logic_vector(1 downto 0);
signal RegDst,MemRead,MemToReg,MemWrite,ALUBin,RegWrite : std_logic;
signal dec35,dec43,dec0,dec4,dec2 : std_logic;
signal control : std_logic_vector(7 downto 0);

component ProcessorComb is
port(
	RegDst : in std_logic;
	ALUOp : in std_logic_vector(1 downto 0);
	ALUBin,MemWrite,MemRead,MemToReg,PCSrc : in std_logic;
	o_Control : out std_logic_vector(7 downto 0)
	);
end component;

begin
	
	dec35 <= opcode(5) and opcode(1) and opcode(0) and not(opcode(4) or opcode(3) or opcode(2)); --Load Word
	dec43 <= opcode(5) and opcode(3) and opcode(1) and opcode(0) and not(opcode(4) or opcode(2)); --Store Word
	dec0 <= not(opcode(0) or opcode(1) or opcode(2) or opcode(3) or opcode(4) or opcode(5)); --R type
	dec4 <= not(opcode(0) or opcode(1) or opcode(3) or opcode(4) or opcode(5)) and opcode(2); --Branch
	dec2 <= not(opcode(0) or opcode(2) or opcode(3) or opcode(4) or opcode(5)) and opcode(1); -- Jump
	
	
	
	RegDst <= dec0;
	ALUBin <= dec35 or dec43 or dec4 or dec2;
	MemToReg <= dec35;
	MemRead <= dec35;
	MemWrite <= dec43;
	RegWrite <= dec35 or dec0;
	ALUOp(0) <= dec4;
	ALUOp(1) <= dec0;
	
	SigComb : ProcessorComb
	port map(RegDst,ALUOp,ALUBin,MemWrite,MemRead,MemToReg,RegWrite,control);
	
	--Output Drivers;
	Branch <= dec4;
	Jump <= dec2;
	controlOut <= control;

end;
	