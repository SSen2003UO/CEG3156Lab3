library ieee;
use ieee.std_logic_1164.all;

entity IFID is
	port(
	PCin : in std_logic_vector(7 downto 0);
	instructionin : in std_logic_vector(31 downto 0);
	IF_Flush,IFIDWrite,clk,resetBar : in std_logic;
	PCout : out std_logic_vector(7 downto 0);
	instructionout : out std_logic_vector(31 downto 0)
);
end;

architecture rtl of IFID is

signal int_instructionout : std_logic_vector(31 downto 0);
signal int_PCout : std_logic_vector(7 downto 0);

component register8bit is
port(
		i_d : in std_logic_vector(7 downto 0);
		i_clk, i_en, i_resetBar : in std_logic;
		o_q : out std_logic_vector(7 downto 0)
		);
end component;

component register32bit is
	port(
		i_d : in std_logic_vector(31 downto 0);
		i_clk, i_en, i_resetBar : in std_logic;
		o_q : out std_logic_vector(31 downto 0)
		);
end component;

begin

 PCRegUnit : register8bit port map(
 PCin,clk,IFIDWrite,(resetBar or IF_Flush),int_PCout);
 
 instructionRegUnit : register32bit port map(
 instructionin,clk,IFIDWrite,(resetBar or IF_Flush),int_instructionout);
 
 --Output Drivers
 
 instructionout <= int_instructionout;
 PCout <= int_PCout;
 end;
 
 


