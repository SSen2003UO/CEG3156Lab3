library ieee;
use ieee.std_logic_1164.all;

entity fowardingUnit is
port(
	EXMEMRegWrite, MEMWBRegWrite : in std_logic;
	EXMEMWriteReg,MEMWBWriteReg,IDEXRead1Reg,IDEXRead2Reg : in std_logic_vector(4 downto 0);
	
	ALUAin, ALUBin : out std_logic_vector(1 downto 0)
	);
end;

architecture rtl of fowardingUnit is

signal comp0,comp1,comp2,comp3,comp4,comp5,comp6,comp7 : std_logic;
signal if0,if1,if2,if3,muxOutA,muxOutB: std_logic_vector(1 downto 0);
signal zero : std_logic_vector(4 downto 0) := (others => '0');

component comperatorbit5 is
port(
	A,B : in std_logic_vector(4 downto 0);
	equal : out std_logic
	);
end component;

component mux4to1bit2 is
port(
	i_in0,i_in1,i_in2,i_in3 : in std_logic_vector(1 downto 0);
	i_sel : in std_logic_vector(1 downto 0);
	o_out : out std_logic_vector(1 downto 0)
	);
end component;
begin

 comp0Unit : comperatorbit5
 port map(EXMEMWriteReg,zero,comp0);
 
 comp1Unit : comperatorbit5
 port map(EXMEMWriteReg,IDEXRead1Reg,comp1);
 
 comp2Unit : comperatorbit5
 port map(EXMEMWriteReg,zero,comp2);
 
 comp3Unit : comperatorbit5
 port map(EXMEMWriteReg,IDEXRead2Reg,comp3);
 
 comp4Unit : comperatorbit5
 port map(MEMWBWriteReg,zero,comp4);
 
 comp5Unit : comperatorbit5
 port map(MEMWBWriteReg,IDEXRead1Reg,comp5);
 
 comp6Unit : comperatorbit5
 port map(MEMWBWriteReg,zero,comp6);
 
 comp7Unit : comperatorbit5
 port map(MEMWBWriteReg,IDEXRead2Reg,comp7);
 
 muxAin : mux4to1bit2
 port map(zero(1 downto 0),if2,if0,if0,(if0(1) & if2(0)),muxOutA);
 
 muxBin: mux4to1bit2
 port map(zero(1 downto 0),if3,if1,if1,(if1(1) & if3(0)),muxOutB);
 
 if0(1) <= (EXMEMRegWrite and not(comp0) and comp1);
 if1(1) <= (EXMEMRegWrite and not(comp2) and comp3);
 if2(0) <= (MEMWBRegWrite and not(comp4) and comp5);
 if3(0) <= (MEMWBRegWrite and not(comp6) and comp7);
 
 
 --Output Drivers
 ALUAin <= muxOutA;
 ALUBin <= muxOutB;
 
end;
