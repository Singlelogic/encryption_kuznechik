Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;

entity funcKey is
  port(key               : in std_logic_vector(255 downto 0);
       clk, reset, start : in std_logic;
		 --startRead         : in std_logic; --New
		 --ReadKey           : in integer range 0 to 15; --New
		 flagFuncKey       : out std_logic;
		 --regKeyOne         : out std_logic_vector(127 downto 0);
                 --regKeyTwo         : out std_logic_vector(127 downto 0);
                 --regKeyThree       : out std_logic_vector(127 downto 0);
                 --regKeyFour        : out std_logic_vector(127 downto 0);
                 --regKeyFive        : out std_logic_vector(127 downto 0);
                 --regKeySix         : out std_logic_vector(127 downto 0);
                 --regKeySeven       : out std_logic_vector(127 downto 0);
                 --regKeyEight       : out std_logic_vector(127 downto 0);
                 --regKeyNine        : out std_logic_vector(127 downto 0);
                 --regKeyTen         : out std_logic_vector(127 downto 0));
                 regKeyOne         : out bit_vector(127 downto 0);
                 regKeyTwo         : out bit_vector(127 downto 0);
                 regKeyThree       : out bit_vector(127 downto 0);
                 regKeyFour        : out bit_vector(127 downto 0);
                 regKeyFive        : out bit_vector(127 downto 0);
                 regKeySix         : out bit_vector(127 downto 0);
                 regKeySeven       : out bit_vector(127 downto 0);
                 regKeyEight       : out bit_vector(127 downto 0);
                 regKeyNine        : out bit_vector(127 downto 0);
                 regKeyTen         : out bit_vector(127 downto 0));
		 --outKey            : out std_logic_vector(127 downto 0));
end funcKey;

architecture funcKey_arch of funcKey is

  --type state_type is (idle_s, read_s, running_funcL, middle_funcL, running_funcXSRL, ending_s);
  type state_type is (idle_s, running_funcL, middle_funcL, running_funcXSRL, ending_s);
  signal state           : state_type;
  signal i               : integer range 0 to 63;
  signal c               : std_logic_vector(127 downto 0);
  signal K1              : std_logic_vector(127 downto 0);
  signal K2              : std_logic_vector(127 downto 0);
  --signal regKeyOne       : std_logic_vector(127 downto 0);
  --signal regKeyTwo       : std_logic_vector(127 downto 0);
  --signal regKeyThree     : std_logic_vector(127 downto 0);
  --signal regKeyFour      : std_logic_vector(127 downto 0);
  --signal regKeyFive      : std_logic_vector(127 downto 0);
  --signal regKeySix       : std_logic_vector(127 downto 0);
  --signal regKeySeven     : std_logic_vector(127 downto 0);
  --signal regKeyEight     : std_logic_vector(127 downto 0);
  --signal regKeyNine      : std_logic_vector(127 downto 0);
  --signal regKeyTen       : std_logic_vector(127 downto 0);
  --/* funcXSRL */--
  --signal indataFuncXSRL  : std_logic_vector(127 downto 0);
  signal startFuncXSRL   : std_logic;
  signal flagFuncXSRL    : std_logic;
  signal dataoutFuncXSRL : std_logic_vector(127 downto 0);
  --/* funcL */--
  signal indataFuncL    : std_logic_vector(127 downto 0);
  signal startFuncL     : std_logic;
  signal flagFuncL      : std_logic;
  signal dataoutFuncL   : std_logic_vector(127 downto 0);

  component funcL
    port(indata            : in std_logic_vector(127 downto 0);
         clk, reset, start : in std_logic;
		   flagFuncL         : out std_logic;
		   dataout           : out std_logic_vector(127 downto 0));
  end component funcL;
  
  component funcXSRL
    port(indata            : in std_logic_vector(127 downto 0);
         key               : in std_logic_vector(127 downto 0);
         clk, reset, start : in std_logic;
		   flagFuncXSRL      : out std_logic;
		   dataout           : out std_logic_vector(127 downto 0));
  end component funcXSRL;
 
begin

funcL_comp : funcL port map (indataFuncL, clk, reset, startFuncL,
                             flagFuncL, dataoutFuncL);

funcXSRL_comp : funcXSRL port map (c, K1, clk, reset, startFuncXSRL,
                                   flagFuncXSRL, dataoutFuncXSRL);

process(clk, reset)

  function conv_bit_vector (x : std_logic_vector) return bit_vector is
    variable result : bit_vector(127 downto 0);
	 begin
	   for i in result'range loop
		  case x(i) is
		    when '0' => result(i) := '0';
			 when '1' => result(i) := '1';
			 when others =>
			   null;
			end case;
		end loop;
	 return result;
  end conv_bit_vector; 
  
    function conv_bit_vector2 (x : std_logic_vector) return bit_vector is
    variable result : bit_vector(255 downto 128);
	 begin
	   for i in result'range loop
		  case x(i) is
		    when '0' => result(i) := '0';
			 when '1' => result(i) := '1';
			 when others =>
			   null;
			end case;
		end loop;
	 return result;
  end conv_bit_vector2;

begin  
  
  if reset = '1' then
	 flagFuncKey     <= '0';
	 --outKey          <= x"00000000000000000000000000000000";
	 state           <= idle_s;
	 i               <= 0;
	 c               <= x"00000000000000000000000000000000";
	 K1              <= x"00000000000000000000000000000000";
	 K2              <= x"00000000000000000000000000000000";
	 regKeyOne       <= x"00000000000000000000000000000000";
    regKeyTwo       <= x"00000000000000000000000000000000";
    regKeyThree     <= x"00000000000000000000000000000000";
    regKeyFour      <= x"00000000000000000000000000000000";
    regKeyFive      <= x"00000000000000000000000000000000";
    regKeySix       <= x"00000000000000000000000000000000";
    regKeySeven     <= x"00000000000000000000000000000000";
    regKeyEight     <= x"00000000000000000000000000000000";
    regKeyNine      <= x"00000000000000000000000000000000";
    regKeyTen       <= x"00000000000000000000000000000000";
	 startFuncXSRL   <= '0';
	 indataFuncL     <= x"00000000000000000000000000000000";
	 startFuncL      <= '0';
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
		  flagFuncKey <= '0';
		  i               <= 0;
	          c               <= x"00000000000000000000000000000000";
	          K1              <= x"00000000000000000000000000000000";
	          K2              <= x"00000000000000000000000000000000";
	          startFuncXSRL   <= '0';
	          indataFuncL     <= x"00000000000000000000000000000000";
	          startFuncL      <= '0';
		  --if startRead = '1' then --New
		    --state <= read_s; --New
		  if start = '1' then
		    state        <= running_funcL;
			 flagFuncKey  <= '1';
			 regKeyOne    <= conv_bit_vector2(key(255 downto 128));
			 regKeyTwo    <= conv_bit_vector(key(127 downto 0));
			 K1           <= key(255 downto 128);
			 K2           <= key(127 downto 0);
			 i            <= i + 1;
		  else
		    state <= idle_s;
			 i <= 0;
		  end if;
		  
		--/* State RUNNING_funcL */--		
		when running_funcL =>
        indataFuncL <= conv_std_logic_vector(i, 128);
		  startFuncL  <= '1';
		  if flagFuncL = '1' then
		    state <= middle_funcL;
			 startFuncL  <= '0';
		  else
		    state <= running_funcL;
		  end if;
		
		--/* State MIDDLE_funcL */--	
      when middle_funcL =>
        if flagFuncL = '0' then
		    c <= dataoutFuncL;
	       startFuncXSRL <= '1';
	       if flagFuncXSRL = '1' then
	         state <= running_funcXSRL;
	         startFuncXSRL <= '0';
	       end if;
        end if;		 

		--/* State RUNNING_funcXSRL */--
		when running_funcXSRL =>
		  if flagFuncXSRL = '0' then
		    K1 <= dataoutFuncXSRL xor K2;
			 K2 <= K1;
			 i <= i + 1;
			 state <= ending_s;
		  else
		    state <= running_funcXSRL;
		  end if;

		--/* State ENDING_s */--	 
		when ending_s =>
		  if i = 33 then
		    state <= idle_s;
		  else
		    state <= running_funcL;
		  end if;
		  case i is
			 when 9 =>
				regKeyThree <= conv_bit_vector(K1);
				regKeyFour <= conv_bit_vector(K2);
		    when 17 =>
				regKeyFive <= conv_bit_vector(K1);
				regKeySix <= conv_bit_vector(K2);
			 when 25 =>
				regKeySeven <= conv_bit_vector(K1);
				regKeyEight <= conv_bit_vector(K2);
			 when 33 =>
				regKeyNine <= conv_bit_vector(K1);
				regKeyTen <= conv_bit_vector(K2);
			 when others =>
				null;
		  end case;
		  
		when others =>
		  null;
		  
		--/* State READ_s */--	 
		--when read_s =>
		  --if startRead = '1' then
          --case ReadKey is
		      --when 1 =>
		        --outKey <= regKeyOne;
		      --when 2 =>
		        --outKey <= regKeyTwo;	 
            --when 3 =>
		        --outKey <= regKeyThree;
			   --when 4 =>
			     --outKey <= regKeyFour;
			   --when 5 =>
			     --outKey <= regKeyFive;
			   --when 6 =>
			     --outKey <= regKeySix;
		      --when 7 =>
		        --outKey <= regKeySeven;
			   --when 8 =>
			     --outKey <= regKeyEight;
			   --when 9 =>
			     --outKey <= regKeyNine;
			   --when 10 =>
			     --outKey <= regKeyTen;	
            --when others =>
              --outKey <= x"00000000000000000000000000000000";			 
		    --end case;
		  --else
		    --state <= idle_s;
		  --end if;
		--when others => null;
    end case;
  end if;
end process;

end funcKey_arch;