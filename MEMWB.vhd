library ieee;
use ieee.std_logic_1164.all;

entity MEMWB is
port(
	WB : in std_logic_vector(1 downto 0);
	ReadMem, ALUResult : in std_logic_vector(7 downto 0);
	WriteReg : in std_logic_vector(4 downto 0);
	clk,resetBar : in std_logic;
	
	RegWrite,MemToReg : out std_logic;
	o_WriteReg : out std_logic_vector(4 downto 0);
	o_ReadMem, o_ALUResult : out std_logic_vector(7 downto 0)
	);
end;

architecture rtl of MEMWB is

signal int_ReadMem,int_ALUResult : std_logic_vector(7 downto 0);
signal int_WriteREg : std_logic_vector(4 downto 0);
signal int_WB : std_logic_vector(1 downto 0);

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

	ReadMemUnit : registerNbit
	generic map(
	n => 8)
	port map(
	ReadMem,clk,'1',resetBar,int_ReadMem);
	
	ALUResultUnit : registerNbit
	generic map(
	n => 8)
	port map(
	ALUResult,clk,'1',resetBar,int_ALUResult);
	
	WriteRegUnit : registerNbit
	generic map(
	n => 5)
	port map(
	WriteReg,clk,'1',resetBar,int_WriteReg);
	
	WBUnit : registerNbit
	generic map(
	n => 2)
	port map(
	WB,clk,'1',resetBar,int_WB);
	
	--Output Drivers
	
	MemToReg <= int_WB(1);
	RegWrite <= int_WB(0);
	o_ReadMem <= int_ReadMem;
	o_ALUResult <= int_ALUResult;
	o_WriteReg <= int_WriteReg;
	
end;