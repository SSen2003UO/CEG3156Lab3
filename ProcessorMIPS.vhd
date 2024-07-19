library ieee;
use ieee.std_logic_1164.all;

entity ProcessorMIPS is
port(
	ValueSelect : in std_logic_vector(2 downto 0);
	GClock, GResetBar : in std_logic;
	MuxOut : out std_logic_vector(7 downto 0);
	InstructionOut : out std_logic_vector(31 downto 0);
	BranchOut,ZeroOut,MemWriteOut,RegWriteOut : out std_logic
	);
end;

architecture rtl of ProcessorMIPS is

signal instruction,instructionBuff,PC,PC4Added,BranchAddress,JumpAddress,BranchOffset,BranchMux,PCBufferOut,signExtend,signExtendOut: std_logic_vector(31 downto 0) := (others => '0');

signal newPC : std_LOGIC_VECTOR(31 downto 0) := (others => '0');
	
signal ReadReg1,ReadReg1Buff,ReadReg2,ReadReg2Buff,WriteReg,int_WriteReg,WriteRegBuff,WriteRegEXMEM  : std_logic_vector(4 downto 0) := (others => '0');

signal ALUControlSig,int_EX : std_logic_vector(3 downto 0) := (others => '0');

signal Read1Data,Read1DataBuff,Read2Data,Read2DataBuff, ALUResult,int_ALUResult,ALUResultBuff,WriteData,MemData,MemDataBuff,ALUBin,ALUAin,FinalData,int_OutMux,ProcessorCntrlOut,BufferSig: std_logic_vector(7 downto 0):= (others => '0');

signal ALUOp,ALUSrcA,ALUSrcB,int_1MEM,int_2MEM,int_1WB,int_2WB,int_3WB : std_logic_vector(1 downto 0):= (others => '0');

signal zero,zeroALU,RegDst,Jump,Branch,MemRead,MemToReg,MemWrite,ALUSrc,RegWrite,int_CoutBranch,IF_Flush,IFIDWrite,stallCntrl,PCSrc : std_logic := '0';

component RAM1Port is
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
END component;

component ROM1Port is
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END component;

component JumpShiftCombPC is
port(
	Jump : in std_logic_vector(25 downto 0);
	PC : in std_logic_vector(3 downto 0);
	O : out std_logic_vector(31 downto 0)
);
end component;

component ALU is
port(
	i_a,i_b : in std_logic_vector(7 downto 0);
	i_ControlSig : in std_logic_vector(3 downto 0); -- 1bit 1 = AU, 1bit 0 = LU
	o_zero : out std_logic;
	o_ALUResult : out std_logic_vector(7 downto 0)
	);
end component;

component ALUControl is
port(
	ALUOp : in std_logic_vector(1 downto 0);
	funct : in std_logic_vector(5 downto 0);
	ALUControl : out std_logic_vector(3 downto 0)
	);
end component;

component mux2to1bit32 is
port(
	A,B : in std_logic_vector(31 downto 0);
	sel : in std_logic;
	O : out std_logic_vector(31 downto 0)
	);
end component;

component mux4to1 is
port(
	i_in0,i_in1,i_in2,i_in3 : in std_logic_vector(7 downto 0);
	i_sel : in std_logic_vector(1 downto 0);
	o_out : out std_logic_vector(7 downto 0)
	);
end component;

component mux2to1 is
port(
	A,B : in std_logic_vector(7 downto 0);
	sel : in std_logic;
	O : out std_logic_vector(7 downto 0)
	);
end component;

component mux2to1bit5 is
port(
	A,B : in std_logic_vector(4 downto 0);
	sel : in std_logic;
	O : out std_logic_vector(4 downto 0)
	);
end component;

component mux8to1 is
port(
	i_sel : in std_logic_vector(2 downto 0);
	i_0in,i_1in,i_2in,i_3in,i_4in,i_5in,i_6in,i_7in : in std_logic_vector(7 downto 0);
	o_out : out std_logic_vector(7 downto 0)
	);
end component;

component PCAdd4 is
port(
	A : in std_logic_vector(31 downto 0);
	O : out std_logic_vector(31 downto 0)
	);
end component;

component ProcessorControl is
port(
	opcode: in std_logic_vector(5 downto 0);
	clk : in std_logic;
	Jump,Branch : out std_logic;
	controlOut: out std_logic_vector(7 downto 0) --Logic
	);
end component;

component registerFile is
	port(
		clk, RegWrite, i_resetBar : in std_logic;
		i_readReg1, i_readReg2, i_writeReg : in std_logic_vector(2 downto 0);
		i_writeData : in std_logic_vector(7 downto 0);
		o_readData1, o_readData2 : out std_logic_vector(7 downto 0)
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

component extend32leftshift2 is
port(
	i_in : in std_logic_vector(15 downto 0);
	o_out : out std_logic_vector(31 downto 0)
	);
end component;

component fullAdder32bit is
port(
	A,B : in std_logic_vector(31 downto 0);
	C : in std_logic;
	S : out std_logic_vector(31 downto 0);
	Cout : out std_logic
	);
end component;

component combineData is
port(
	RegDst,Jump,MemRead,MemToReg,ALUSrc : in std_logic;
	ALUOp : in std_logic_vector(1 downto 0);
	O : out std_logic_vector(7 downto 0)
	);
end component;

component comperator is
port(
	A,B : in std_logic_vector(7 downto 0);
	equal : out std_logic
	);
end component;

component IFID is
	port(
	PCin : in std_logic_vector(7 downto 0);
	instructionin : in std_logic_vector(31 downto 0);
	IF_Flush,IFIDWrite,clk,resetBar : in std_logic;
	PCout : out std_logic_vector(7 downto 0);
	instructionout : out std_logic_vector(31 downto 0)
);
end component;

component IDEX is
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
end component;

component EXMEM is
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
end component;

component MEMWB is
port(
	WB : in std_logic_vector(1 downto 0);
	ReadMem, ALUResult : in std_logic_vector(7 downto 0);
	WriteReg : in std_logic_vector(4 downto 0);
	clk,resetBar : in std_logic;
	
	RegWrite,MemToReg : out std_logic;
	o_WriteReg : out std_logic_vector(4 downto 0);
	o_ReadMem, o_ALUResult : out std_logic_vector(7 downto 0)
	);
end component;

component extend32bit is
port(
	i_in : in std_logic_vector(15 downto 0);
	o_out : out std_logic_vector(31 downto 0)
	);
end component;

component fowardingUnit is
port(
	EXMEMRegWrite, MEMWBRegWrite : in std_logic;
	EXMEMWriteReg,MEMWBWriteReg,IDEXRead1Reg,IDEXRead2Reg : in std_logic_vector(4 downto 0);
	
	ALUAin, ALUBin : out std_logic_vector(1 downto 0)
	);
end component;

component hazardCntrl is
port(
	IDEXMemRead : in std_logic;
	IDEXRead2Reg,IFIDRead1Reg,IFIDRead2Reg : in std_logic_vector(4 downto 0);
	
	outSig : out std_logic
	);
end component;

begin

-- Instruction Memory/PC
 PCReg : register8bit
 port map(newPC(7 downto 0),GClock,not(IFIDWrite),GResetBar,PC(7 downto 0));
 
 InstructMem : ROM1Port
 port map(PC(7 downto 0),GClock,instructionBuff);
 
 PCNorm : PCAdd4
 port map(PC,PC4Added);
 
 JumpBlock : JumpShiftCombPC
 port map(instruction(25 downto 0),PC4Added(31 downto 28),JumpAddress);

--Register File
 muxWriteReg : mux2to1bit5
 port map(ReadReg2Buff,WriteRegBuff,RegDst,WriteRegEXMEM);
 
 RegFile : RegisterFile
 port map(GClock,RegWrite,GResetBar,instruction(23 downto 21),instruction(18 downto 16),WriteReg(2 downto 0),WriteData,Read1DataBuff,Read2DataBuff);
 
 --ALU 
 muxALUB : mux4to1
 port map(Read2Data,signExtendOut(7 downto 0),ALUResult,WriteData,ALUSrcB,ALUBin);
 
 muxALUA : mux4to1
 port map(Read1Data,"00000000",ALUResult,WriteData,ALUSrcA,ALUAin);
 
 ALUCom : ALU
 port map(ALUAin,ALUBin,ALUControlSig,zeroALU,ALUResultBuff);
 
 ALUCon : ALUControl
 port map(ALUOp,instruction(5 downto 0),ALUControlSig);
 
 --Processor Control
 ProcessorCntrl : ProcessorControl
 port map(instruction(31 downto 26),GClock,Jump,Branch,ProcessorCntrlOut);
 
 --Memory Unit
 RAM : RAM1Port
 port map(ALUResult,GClock,Read2Data,MemWrite,MemDataBuff);
 
 muxMem : mux2to1
 port map(int_ALUResult,MemData,MemToReg,WriteData);
 
 --Branch/Jump to PC
 
 extenderAddr : extend32leftshift2
 port map(instruction(15 downto 0),BranchOffset);
 
 extendBit : extend32bit
 port map(instruction(15 downto 0),signExtend);
 
 BranchCalc : fullAdder32bit
 port map(PCBufferOut,BranchOffset,'0',BranchAddress,int_CoutBranch);
 
 BranchMulti : mux2to1bit32
 port map(PCBufferOut,BranchAddress,(Branch and zero),BranchMux);
 
 JumpMux : mux2to1bit32
 port map(BranchMux,JumpAddress,Jump,newPC);
 
 --Pipeline Buffers
 controlMux : mux2to1
 port map(ProcessorCntrlOut,"00000000",stallCntrl,BufferSig);
 int_EX <= BufferSig(7 downto 4);
 int_1MEM <= BufferSig(3 downto 2);
 int_1WB <= BufferSig(1 downto 0);
 
 IFIDBuffer : IFID
 port map(PC4Added(7 downto 0),instructionBuff,(Branch and zero),not(IFIDWrite),GClock,GResetBar,PCBufferOut(7 downto 0),instruction);
 
 IDEXBuffer : IDEX
 port map(Read1DataBuff,Read2DataBuff,signExtend,instruction(25 downto 21),instruction(20 downto 16),instruction(15 downto 11),int_1WB,int_1MEM,int_EX,GClock,GResetBar,int_2WB,int_2MEM,ALUSrc,RegDst,ALUOp,Read1Data,Read2Data,ReadReg1Buff,ReadReg2Buff,WriteRegBuff,signExtendOut);
 
 EXMEMBuffer : EXMEM
 port map(ALUResultBuff,WriteRegEXMEM,int_2MEM,int_2WB,GClock,GResetBar,MemRead,MemWrite,int_3WB,ALUResult,int_WriteReg);
 
 MEMWBBuffer : MEMWB
 port map(int_3WB,MemDataBuff,ALUResult,int_WriteReg,GClock,GResetBar,RegWrite,MemToReg,WriteReg,MemData,int_ALUResult);
 
 comperatorUnit : comperator
 port map(Read1Data,Read2Data,zero);
 
 fowardUnit : fowardingUnit
 port map(int_3WB(0),RegWrite,int_WriteReg,WriteReg,ReadReg1Buff,ReadReg2Buff,ALUSrcA,ALUSrcB);
 
 hazardUnit : hazardCntrl
 port map(int_1MEM(0),ReadReg2,instruction(25 downto 21),instruction(20 downto 16),IFIDWrite);
 
 --Top Level
 
 OutMix : combineData
 port map(RegDst,Jump,MemRead,MemToReg,ALUSrc,ALUOp,FinalData);
 
 OutputMux : mux8to1
 port map(ValueSelect,PC(7 downto 0),ALUResult,Read1Data,Read2Data,WriteData,FinalData,FinalData,FinalData,int_OutMux);
 
 --Output Drivers
 
 MuxOut <= int_OutMux;
 InstructionOut <= instruction;
 BranchOut <= Branch;
 ZeroOut <= zero;
 MemWriteOut <= MemWrite;
 RegWriteOut <= RegWrite;
 
end rtl;

