Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;

entity ReverseFuncS is
  port(indataReverseFuncS  : in std_logic_vector(127 downto 0);
       clk, reset          : in std_logic;
		 startReverseFuncS   : in std_logic;
		 flagReverseFuncS    : out std_logic;
		 dataoutReverseFuncS : out std_logic_vector(127 downto 0));
end ReverseFuncS;

architecture ReverseFuncS_arch of ReverseFuncS is

  type kReversePi_type is array (0 to 255) of std_logic_vector(7 downto 0);
  constant kReversePi : kReversePi_type := (  
    x"a5", x"2d", x"32", x"8f", x"0e", x"30", x"38", x"c0", x"54", x"e6", x"9e", x"39",
    x"55", x"7e", x"52", x"91", x"64", x"03", x"57", x"5a", x"1c", x"60", x"07", x"18",
    x"21", x"72", x"a8", x"d1", x"29", x"c6", x"a4", x"3f", x"e0", x"27", x"8d", x"0c",
    x"82", x"ea", x"ae", x"b4", x"9a", x"63", x"49", x"e5", x"42", x"e4", x"15", x"b7",
    x"c8", x"06", x"70", x"9d", x"41", x"75", x"19", x"c9", x"aa", x"fc", x"4d", x"bf",
    x"2a", x"73", x"84", x"d5", x"c3", x"af", x"2b", x"86", x"a7", x"b1", x"b2", x"5b",
    x"46", x"d3", x"9f", x"fd", x"d4", x"0f", x"9c", x"2f", x"9b", x"43", x"ef", x"d9",
    x"79", x"b6", x"53", x"7f", x"c1", x"f0", x"23", x"e7", x"25", x"5e", x"b5", x"1e",
    x"a2", x"df", x"a6", x"fe", x"ac", x"22", x"f9", x"e2", x"4a", x"bc", x"35", x"ca",
    x"ee", x"78", x"05", x"6b", x"51", x"e1", x"59", x"a3", x"f2", x"71", x"56", x"11",
    x"6a", x"89", x"94", x"65", x"8c", x"bb", x"77", x"3c", x"7b", x"28", x"ab", x"d2",
    x"31", x"de", x"c4", x"5f", x"cc", x"cf", x"76", x"2c", x"b8", x"d8", x"2e", x"36",
    x"db", x"69", x"b3", x"14", x"95", x"be", x"62", x"a1", x"3b", x"16", x"66", x"e9",
    x"5c", x"6c", x"6d", x"ad", x"37", x"61", x"4b", x"b9", x"e3", x"ba", x"f1", x"a0",
    x"85", x"83", x"da", x"47", x"c5", x"b0", x"33", x"fa", x"96", x"6f", x"6e", x"c2",
    x"f6", x"50", x"ff", x"5d", x"a9", x"8e", x"17", x"1b", x"97", x"7d", x"ec", x"58",
    x"f7", x"1f", x"fb", x"7c", x"09", x"0d", x"7a", x"67", x"45", x"87", x"dc", x"e8",
    x"4f", x"1d", x"4e", x"04", x"eb", x"f8", x"f3", x"3e", x"3d", x"bd", x"8a", x"88",
    x"dd", x"cd", x"0b", x"13", x"98", x"02", x"93", x"80", x"90", x"d0", x"24", x"34",
    x"cb", x"ed", x"f4", x"ce", x"99", x"10", x"44", x"40", x"92", x"3a", x"01", x"26",
    x"12", x"1a", x"48", x"68", x"f5", x"81", x"8b", x"c7", x"d6", x"20", x"0a", x"08",
    x"00", x"4c", x"d7", x"74");
 

  type state_type is (idle_s, running_s, middle_s);
  signal state           : state_type;
  signal i               : integer range 0 to 31;
  signal prefClk         : std_logic;
  signal indata_reg      : std_logic_vector(127 downto 0);
  signal shift_reg       : std_logic_vector(7 downto 0);

begin

process(clk, reset)
begin
  if reset = '1' then
	 flagReverseFuncS     <= '0';
	 dataoutReverseFuncS  <= x"00000000000000000000000000000000";
    state                <= idle_s;
	 i                    <= 0;
	 prefClk              <= '0';
    indata_reg           <= x"00000000000000000000000000000000";
	 shift_reg            <= x"00";	 
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
		  flagReverseFuncS <= '0';
	     i                <= 0;
	     prefClk          <= '0';
		  indata_reg       <= x"00000000000000000000000000000000";
		  shift_reg        <= x"00";	  
		  if startReverseFuncS = '1' then
		    state            <= running_s;
			 flagReverseFuncS <= '1';
			 indata_reg       <= indataReverseFuncS;
		  else
		    state <= idle_s;
		  end if;
		  
		--/* State RUNNING */--		
		when running_s =>
		  prefClk <= not prefClk;
		  if prefClk = '0' then
			 shift_reg <= kReversePi(conv_integer(unsigned(indata_reg(127 downto 120))));
		  else
			 indata_reg <= indata_reg(119 downto 0) & shift_reg;
		    i <= i + 1;
			 if i = 15 then
			   state <= middle_s;
			 else
				state <= running_s;
			 end if;
		  end if;
		
      --/* State MIDDLE */--			
		when middle_s =>
		  flagReverseFuncS    <= '0';
		  dataoutReverseFuncS <= indata_reg;
		  state <= idle_s;
		  
		when others => null;
    end case;
  end if;
end process;

end ReverseFuncS_arch;