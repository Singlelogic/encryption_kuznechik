Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;

entity funcX is
  port(indata            : in std_logic_vector(127 downto 0);
       key               : in std_logic_vector(127 downto 0);
       clk, reset, start : in std_logic;
		 flagFuncXS        : out std_logic;
		 dataout           : out std_logic_vector(127 downto 0));
end funcX;

architecture funcX_arch of funcX is

  type kPi_type is array (0 to 255) of integer range 0 to 255;
  constant kPi : kPi_type := (  
    252, 238, 221, 17, 207, 110, 49, 22, 251, 196, 250, 218, 35, 197, 4, 77,
    233, 119, 240, 219, 147, 46, 153, 186, 23, 54, 241, 187, 20, 205, 95, 193,
    249, 24, 101, 90, 226, 92, 239, 33, 129, 28, 60, 66, 139, 1, 142, 79, 5,
    132, 2, 174, 227, 106, 143, 160, 6, 11, 237, 152, 127, 212, 211, 31, 235,
    52, 44, 81, 234, 200, 72, 171, 242, 42, 104, 162, 253, 58, 206, 204, 181,
    112, 14, 86, 8, 12, 118, 18, 191, 114, 19, 71, 156, 183, 93, 135, 21, 161,
    150, 41, 16, 123, 154, 199, 243, 145, 120, 111, 157, 158, 178, 177, 50, 117,
    25, 61, 255, 53, 138, 126, 109, 84, 198, 128, 195, 189, 13, 87, 223, 245,
    36, 169, 62, 168, 67, 201, 215, 121, 214, 246, 124, 34, 185, 3, 224, 15,
    236, 222, 122, 148, 176, 188, 220, 232, 40, 80, 78, 51, 10, 74, 167, 151,
    96, 115, 30, 0, 98, 68, 26, 184, 56, 130, 100, 159, 38, 65, 173, 69, 70,
    146, 39, 94, 85, 47, 140, 163, 165, 125, 105, 213, 149, 59, 7, 88, 179, 64,
    134, 172, 29, 247, 48, 55, 107, 228, 136, 217, 231, 137, 225, 27, 131, 73,
    76, 63, 248, 254, 141, 83, 170, 144, 202, 216, 133, 97, 32, 113, 103, 164,
    45, 43, 9, 91, 203, 155, 37, 208, 190, 229, 108, 82, 89, 166, 116, 210, 230,
    244, 180, 192, 209, 102, 175, 194, 57, 75, 99, 182); 

  type state_type is (idle_s, middle_s, running_s0, running_s1);
  signal state           : state_type;
  signal i               : integer range 0 to 31;
  signal prefClk         : std_logic;
  signal indata_reg      : std_logic_vector(127 downto 0);
  signal shift_reg       : std_logic_vector(7 downto 0);

begin

process(clk, reset)
begin
if reset = '1' then
    flagFuncXS      <= '0';
    dataout         <= x"00000000000000000000000000000000";
    state           <= idle_s;
    i               <= 0;
    prefClk         <= '0';
    indata_reg      <= x"00000000000000000000000000000000";
	 shift_reg       <= x"00";
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
		  flagFuncXS <= '0';
		  indata_reg      <= x"00000000000000000000000000000000";
	     i               <= 0;
	     prefClk         <= '0';
	     indata_reg      <= x"00000000000000000000000000000000";
	     shift_reg       <= x"00";
		  if start = '1' then
		    state      <= middle_s;
			 flagFuncXS <= '1';
		  else
		    state <= idle_s;
		  end if;
		
      --/* State MIDDLE */--		
		when middle_s =>
		  indata_reg <= indata xor key;
		  state <= running_s0;
		  
		--/* State RUNNING */--		
		when running_s0 =>
		  prefClk <= not prefClk;
		  if prefClk = '0' then
			 shift_reg <= conv_std_logic_vector(kPi(conv_integer(unsigned(indata_reg(127 downto 120)))), 8);
		  else
			 indata_reg <= indata_reg(119 downto 0) & shift_reg;
		    i <= i + 1;
			 if i = 15 then
			   state <= running_s1;
			 else
				state <= running_s0;
			 end if;
		  end if;
		when running_s1 =>
		  --flagFuncXS <= '0';
		  dataout <= indata_reg;
		  state <= idle_s;
		when others => null;
    end case;
  end if;
end process;

end funcX_arch;