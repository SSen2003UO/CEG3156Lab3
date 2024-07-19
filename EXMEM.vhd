library ieee;
use ieee.std_logic_1164.all;

entity EXMEM is
port( 
	ALUResult : in std_logic_vector(7 downto 0);
	WriteReg : in std_logic_vector(4 downto 0);
	MEM : in std_logic_vector(1 downto 0);
	WB : in std_logic_vector(1 downto 0);
	clk,resetBar : in std_logic;
	
	MemRead,MemWrite : out std_logic;
	o_WB : out std_logic_vector(1 downto 0);
	o_ALUResult : out std_logic_vector(7 downto 0);
	o_WriteReg : out std_logic_vector(4 downto 0)
	);
end;

architecture rtl of EXMEM is

signal int_ALUResult : std_logic_vector(7 downto 0);
signal int_WriteReg : std_logic_vector(4 downto 0);
signal int_MEM,int_WB : std_logic_vector(1 downto 0);

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
	
	MEMUnit : registerNbit
	generic map(
	n => 2)
	port map(
	MEM,clk,'1',resetBar,int_MEM);
	
	WBUnit : registerNbit
	generic map(
	n => 2)
	port map(
	WB,clk,'1',resetBar,int_WB);
	
	--Output Drivers
	
	MemWrite <= int_MEM(1);
	MemRead <= int_MEM(0);
	
	o_WB <= int_WB;
	o_WriteReg <= int_WriteReg;
	o_ALUResult <= int_ALUResult;
	
end;
