Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;

entity encription is
  port(indata            : in std_logic_vector(127 downto 0);
       key               : in std_logic_vector(255 downto 0);
       clk, reset        : in std_logic;
		 startEncription   : in std_logic;
		 startDeciphering  : in std_logic;
		 startKey          : in std_logic;
		 flagShifr         : out std_logic;
		 flagDeciphering   : out std_logic;
		 flagKey           : out std_logic;
		 dataout           : out std_logic_vector(127 downto 0));
end encription;

architecture encription_arch of encription is

  type state_type is (idle_s, running_funcKey, middle_funcKey, running_funcShifr, 
                      running_funcXSRL, middle_funcXSRL, running_funcX,
							 running_ReverseFuncSLX,middle_ReverseFuncSLX);
  signal state                 : state_type;
  signal regDataShifr          : std_logic_vector(127 downto 0);
  signal regKey                : std_logic_vector(127 downto 0);
  signal i                     : integer range 0 to 15;
  signal regflagShifr          : std_logic;
  signal regflagDeciphering    : std_logic;
  --/* funcKey */--
  signal startFuncKey          : std_logic;
  signal flagFuncKey           : std_logic;
  signal regKeyOne             : bit_vector(127 downto 0);
  signal regKeyTwo             : bit_vector(127 downto 0);
  signal regKeyThree           : bit_vector(127 downto 0);
  signal regKeyFour            : bit_vector(127 downto 0);
  signal regKeyFive            : bit_vector(127 downto 0);
  signal regKeySix             : bit_vector(127 downto 0);
  signal regKeySeven           : bit_vector(127 downto 0);
  signal regKeyEight           : bit_vector(127 downto 0);
  signal regKeyNine            : bit_vector(127 downto 0);
  signal regKeyTen             : bit_vector(127 downto 0);
  --/* funcXSRL */--
  signal indataFuncXSRL        : std_logic_vector(127 downto 0);
  signal startFuncXSRL         : std_logic;
  signal flagFuncXSRL          : std_logic;
  signal dataoutFuncXSRL       : std_logic_vector(127 downto 0);
  --/* ReverseFuncSLX */--
  signal indataReverseFuncSLX  : std_logic_vector(127 downto 0);
  --signal keyReverseFuncSLX     : std_logic_vector(127 downto 0);
  signal startReverseFuncSLX   : std_logic;
  signal flagReverseFuncSLX    : std_logic;
  signal dataoutReverseFuncSLX : std_logic_vector(127 downto 0);
   
  component funcKey
    port(key               : in std_logic_vector(255 downto 0);
         clk, reset, start : in std_logic;
		   flagFuncKey       : out std_logic;
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
  end component funcKey;
  
  component funcXSRL
    port(indata            : in std_logic_vector(127 downto 0);
         key               : in std_logic_vector(127 downto 0);
         clk, reset, start : in std_logic;
		   flagFuncXSRL      : out std_logic;
		   dataout           : out std_logic_vector(127 downto 0));
  end component funcXSRL;
  
  component ReverseFuncSLX
    port(indata              : in std_logic_vector(127 downto 0);
         key                 : in std_logic_vector(127 downto 0);
         clk, reset, start   : in std_logic;
		   flagReverseFuncSLX  : out std_logic;
		   dataout             : out std_logic_vector(127 downto 0));  
  end component ReverseFuncSLX;
  
begin

funcKey_comp : funcKey port map (key, clk, reset, startFuncKey, flagFuncKey, regKeyOne, regKeyTwo,
                                 regKeyThree, regKeyFour, regKeyFive, regKeySix, regKeySeven,
											regKeyEight, regKeyNine, regKeyTen);
										
funcXSRL_comp : funcXSRL port map (indataFuncXSRL, regKey, clk, reset, startFuncXSRL,
                                   flagFuncXSRL, dataoutFuncXSRL);

ReverseFuncSLX_comp : ReverseFuncSLX port map (indataReverseFuncSLX, regKey, clk, reset, 
                                               startReverseFuncSLX,flagReverseFuncSLX, dataoutReverseFuncSLX);										  
											  
process(clk, reset)

  function conv_stdLogicVector (x : bit_vector) return std_logic_vector is
    variable result : std_logic_vector(127 downto 0);
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
  end conv_stdLogicVector;
  
begin  

  if reset = '1' then
	 flagShifr            <= '0';
	 flagDeciphering      <= '0';
	 flagKey              <= '0';
	 dataout              <= x"00000000000000000000000000000000";
	 state                <= idle_s;
	 regDataShifr         <= x"00000000000000000000000000000000";
	 regKey               <= x"00000000000000000000000000000000";
	 i                    <= 0;
	 regflagShifr         <= '0';
	 regflagDeciphering   <= '0';
	 startFuncKey         <= '0';
    indataFuncXSRL       <= x"00000000000000000000000000000000";
    startFuncXSRL        <= '0';
	 indataReverseFuncSLX <= x"00000000000000000000000000000000";
	 startReverseFuncSLX  <= '0';
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
	     flagShifr        <= '0';
		  flagDeciphering  <= '0';
	     flagKey          <= '0';
	     state            <= idle_s;
	     regDataShifr     <= x"00000000000000000000000000000000";
	     regKey           <= x"00000000000000000000000000000000";
	     i                <= 0;
	     regflagShifr         <= '0';
	     regflagDeciphering   <= '0';		  
	     startFuncKey     <= '0';
        indataFuncXSRL   <= x"00000000000000000000000000000000";
        startFuncXSRL    <= '0';
		  indataReverseFuncSLX <= x"00000000000000000000000000000000";
	     startReverseFuncSLX  <= '0';
		  if startKey = '1' then
		    state       <= running_funcKey;
			 flagKey     <= '1';
		  elsif startEncription = '1' then
			 state       <= running_funcShifr;
			 flagShifr   <= '1';
			 regflagShifr  <= '1';
	       regDataShifr  <= indata;
        elsif startDeciphering = '1' then	
	       state       <= running_funcShifr;
			 flagDeciphering  <= '1';
			 regflagDeciphering <= '1';
			 regDataShifr <= indata;
			 i                <= 9;
		  else
		    state <= idle_s;
		  end if;
		  
		--/* State RUNNING_funcKey */--		
		when running_funcKey =>
        startFuncKey <= '1';
		  if flagFuncKey = '1' then
		    state <= middle_funcKey;
			 startFuncKey <= '0';
		  else
		    state <= running_funcKey;
		  end if;
		  
		--/* State MIDDLE_funcKey */--		
		when middle_funcKey =>
		  if flagFuncKey = '0' then
			 state <= idle_s;
		  else
		    state <= middle_funcKey;
		  end if;
				
		--/* State RUNNING_funcShifr */--
		when running_funcShifr =>
        case i is
		    when 0 =>
		      regKey <= conv_stdLogicVector(regKeyOne);
	       when 1 =>
		      regKey <= conv_stdLogicVector(regKeyTwo);
		    when 2 =>
		      regKey <= conv_stdLogicVector(regKeyThree);
		    when 3 =>		
			   regKey <= conv_stdLogicVector(regKeyFour);
			 when 4 =>		
			   regKey <= conv_stdLogicVector(regKeyFive);
			 when 5 =>		
			   regKey <= conv_stdLogicVector(regKeySix);
			 when 6 =>		
			   regKey <= conv_stdLogicVector(regKeySeven);	
			 when 7 =>		
			   regKey <= conv_stdLogicVector(regKeyEight);
			 when 8 =>		
			   regKey <= conv_stdLogicVector(regKeyNine);
			 when 9 =>		
			   regKey <= conv_stdLogicVector(regKeyTen);
			 when others =>
			   null;
		  end case;
		  
		  if ((i = 9 and regflagShifr = '1') or (i = 0 and regflagDeciphering = '1')) then
		    state <= running_funcX;
		  else
		    if regflagShifr = '1' then
		      state <= running_funcXSRL;
			 elsif regflagDeciphering = '1' then
			   state <= running_ReverseFuncSLX;
			 else
			   state <= idle_s;
			 end if;
		  end if;
		
--------------------------------------------------------------------------------------------------		
		--/* State RUNNING_funcXSRL */--
		when running_funcXSRL =>
		  startFuncXSRL <= '1';
		  indataFuncXSRL <= regDataShifr;
		  if flagFuncXSRL = '1' then
			 startFuncXSRL <= '0';
		    state <= middle_funcXSRL;
		  else
			 state <= running_funcXSRL;
		  end if;
			 
		--/* State MIDDLE_funcXSRL */--	 
		when middle_funcXSRL =>	
	     if flagFuncXSRL = '0' then
		    regDataShifr <= dataoutFuncXSRL;
			 i <= i + 1;
			 state <= running_funcShifr;
		  else
		    state <= middle_funcXSRL;
		  end if;
--------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------
		--/* State RUNNING_ReverseFuncSLX */--
		when running_ReverseFuncSLX =>
		  startReverseFuncSLX <= '1';
		  indataReverseFuncSLX <= regDataShifr;
		  if flagReverseFuncSLX = '1' then
			 startReverseFuncSLX <= '0';
		    state <= middle_ReverseFuncSLX;
		  else
			 state <= running_ReverseFuncSLX;
		  end if;
		  
		--/* State MIDDLE_ReverseFuncSLX */--	 
		when middle_ReverseFuncSLX =>	
	     if flagReverseFuncSLX = '0' then
		    regDataShifr <= dataoutReverseFuncSLX;
			 i <= i - 1;
			 state <= running_funcShifr;
		  else
		    state <= middle_ReverseFuncSLX;
		  end if;
--------------------------------------------------------------------------------------------------		  
			
		--/* State RUNNING_funcX */--
		when running_funcX =>
		  dataout <= regDataShifr xor regKey;
		  state <= idle_s;
	
		when others => null;
    end case;
  end if;
end process;

end encription_arch;