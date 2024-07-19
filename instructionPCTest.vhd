library ieee;
use ieee.std_logic_1164.all;

entity instructionPCTest is
	port(
		clk,resetbar : in std_LOGIC;
		PC,newPC : out std_logic_vector(31 downto 0)
		--instruct : out std_logic_vector(31 downto 0)
		);
end;

architecture rtl of instructionPCTest is

signal int_PC,int_newPC : std_logic_vector(31 downto 0);
signal int_instruct : std_logic_vector(31 downto 0);

component ROM1Port is
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

component PCAdd4 is
port(
	A : in std_logic_vector(31 downto 0);
	O : out std_logic_vector(31 downto 0)
	);
end component;

component register32bit is
	port(
		i_d : in std_logic_vector(31 downto 0);
		i_clk, i_en, i_resetBar : in std_logic;
		o_q : out std_logic_vector(31 downto 0)
		);
end component;

component register8bit is
	port(
		i_d : in std_logic_vector(7 downto 0);
		i_clk, i_en, i_resetBar : in std_logic;
		o_q : out std_logic_vector(7 downto 0)
		);
end component;

begin

PCReg : register32bit
port map(int_newPC,clk,clk,resetbar,int_PC);

--Mem : ROM1Port
--port map(int_PC(7 downto 0),clk,int_instruct);

PCAdder : PCAdd4
port map(int_PC,int_newPC);

--Output Drivers

	PC <= int_PC;
	newPC <= int_newPC;
	--instruct <= int_instruct;

end;