library ieee;
use ieee.std_logic_1164.all;

entity IDEX is
port (
	ReadData1in, ReadData2in : in std_logic_vector(7 downto 0);
	signExtend : in std_logic_vector(31 downto 0);
	ReadReg1in,ReadReg2in,WriteRegIn : in std_logic_vector(4 downto 0);
	WB : in std_logic_vector(1 downto 0);
	MEM: in std_logic_vector(1 downto 0);
	EX : in std_logic_vector(3 downto 0);
	clk,resetBar : in std_logic;
	
	o_WB : out std_logic_vector(1 downto 0);
	o_MEM : out std_logic_vector(1 downto 0);
	
	
	ALUBin,RegDst : out std_logic;
	ALUOp : out std_logic_vector(1 downto 0);
	ReadData1out,ReadData2out : out std_logic_vector(7 downto 0);
	ReadReg1out,ReadReg2out,WriteRegOut : out std_logic_vector(4 downto 0);
	signExtendOut : out std_logic_vector(31 downto 0)
	);

end;

architecture rtl of IDEX is

signal int_Read1Data,int_Read2Data : std_logic_vector(7 downto 0);
signal int_Read1Reg,int_Read2Reg,int_WriteReg : std_logic_vector(4 downto 0);
signal int_EX : std_logic_vector(3 downto 0);
signal int_WB,int_MEM : std_logic_vector(1 downto 0);
signal int_signExtend : std_logic_vector(31 downto 0);

component registerNbit is
generic(
n : positive
);
	port(
		i_d : in std_logic_vector(n-1 downto 0);
		i_clk, i_en, i_resetBar : in std_logic;
		o_q : out std_logic_vector(n-1 downto 0)
		);
end component;

begin

	ReadData1Unit : registerNbit
	generic map(
	n => 8)
	port map(
	ReadData1in,clk,'1',resetBar,int_Read1Data);
	
	ReadData2Unit : registerNbit
	generic map(
	n => 8)
	port map(
	ReadData2in,clk,'1',resetBar,int_Read2Data);
	
	ReadReg1Unit : registerNbit
	generic map(
	n => 5)
	port map(
	ReadReg1in,clk,'1',resetBar,int_Read1Reg);
	
	ReadReg2Unit : registerNbit
	generic map(
	n => 5)
	port map(
	ReadReg2in,clk,'1',resetBar,int_Read2Reg);
	
	WriteRegUnit : registerNbit
	generic map(
	n => 5)
	port map(
	WriteRegIn,clk,'1',resetBar,int_WriteReg);
	
	MemUnit : registerNbit
	generic map(
	n => 2)
	port map(
	MEM,clk,'1',resetBar,int_MEM);
	
	WBUnit : registerNbit
	generic map(
	n => 2)
	port map(
	WB,clk,'1',resetBar,int_WB);
	
	EXUnit : registerNbit
	generic map(
	n => 4)
	port map(
	EX,clk,'1',resetBar,int_EX);
	
	signExtendUnit : registerNbit
	generic map(
	n => 32)
	port map(
	signExtend,clk,'1',resetBar,int_signExtend);
	
	--Output Drivers
	
	RegDst <= int_EX(3);
	ALUOp <= int_EX(2 downto 1);
	ALUBin <= int_EX(0);
	
	o_WB <= int_WB;
	o_MEM <= int_MEM;
	
	ReadData1out <= int_Read1Data;
	ReadData2out <= int_Read2Data;
	ReadReg1out <= int_Read1Reg;
	ReadReg2out <= int_Read2Reg;
	WriteRegOut <= int_WriteReg;
	signExtendOut <= int_signExtend;

end;
	
	