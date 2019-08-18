Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;

entity ReverseFuncSLX is
  port(indata              : in std_logic_vector(127 downto 0);
       key                 : in std_logic_vector(127 downto 0);
       clk, reset, start   : in std_logic;
		 flagReverseFuncSLX  : out std_logic;
		 dataout             : out std_logic_vector(127 downto 0));
end ReverseFuncSLX;

architecture ReverseFuncSLX_arch of ReverseFuncSLX is

  type state_type is (idle_s, running_ReversefuncX, running_ReverseFuncL, running_ReverseFuncS);
  signal state                 : state_type;
  signal reg_ReverseFuncSLX    : std_logic_vector(127 downto 0);
  --/* ReserveFuncL */--
  --signal indataFuncXS    : std_logic_vector(127 downto 0);
  signal startReverseFuncL     : std_logic;
  signal flagReverseFuncL      : std_logic;
  signal dataoutReverseFuncL   : std_logic_vector(127 downto 0);
  --/* ReverseFuncS */--
  --signal indataFuncRL    : std_logic_vector(127 downto 0);
  signal startReverseFuncS     : std_logic;
  signal flagReverseFuncS      : std_logic;
  signal dataoutReverseFuncS   : std_logic_vector(127 downto 0);

   
  component ReverseFuncL
    port(indata            : in std_logic_vector(127 downto 0);
         clk, reset, start : in std_logic;
		   flagFuncL         : out std_logic;
		   dataout           : out std_logic_vector(127 downto 0));
  end component ReverseFuncL;
  
  component ReverseFuncS
    port(indataReverseFuncS  : in std_logic_vector(127 downto 0);
         clk, reset          : in std_logic;
		   startReverseFuncS   : in std_logic;
		   flagReverseFuncS    : out std_logic;
		   dataoutReverseFuncS : out std_logic_vector(127 downto 0));
  end component ReverseFuncS;
  
begin

ReverseFuncL_comp : ReverseFuncL port map (reg_ReverseFuncSLX, clk, reset, startReverseFuncL,
                                           flagReverseFuncL, dataoutReverseFuncL);
										
ReverseFuncS_comp : ReverseFuncS port map (reg_ReverseFuncSLX, clk, reset, startReverseFuncS,
                             flagReverseFuncS, dataoutReverseFuncS);

process(clk, reset)
begin
  if reset = '1' then
	 flagReverseFuncSLX <= '0';
	 dataout            <= x"00000000000000000000000000000000";
    state              <= idle_s;	 
	 reg_ReverseFuncSLX <= x"00000000000000000000000000000000";
	 startReverseFuncL  <= '0';
	 startReverseFuncS  <= '0';
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
		  flagReverseFuncSLX <= '0';
		  reg_ReverseFuncSLX <= x"00000000000000000000000000000000";		  
		  startReverseFuncL  <= '0';
	     startReverseFuncS  <= '0';
		  if start = '1' then
		    state              <= running_ReversefuncX;
			 flagReverseFuncSLX <= '1';
		  else
		    state <= idle_s;
		  end if;
		  
		--/* State running_ReversefuncX */--		
		when running_ReversefuncX =>
        reg_ReverseFuncSLX <= indata xor key;
		  startReverseFuncL <= '1';
		  if flagReverseFuncL = '1' then
		    startReverseFuncL <= '0';
			 state <= running_ReverseFuncL;
		  else
		    state <= running_ReversefuncX;
		  end if;
			 
		--/* State running_ReverseFuncL */--
		when running_ReverseFuncL =>
		  if flagReverseFuncL = '0' then
		    reg_ReverseFuncSLX <= dataoutReverseFuncL;
			 startReverseFuncS <= '1';
			 if flagReverseFuncS = '1' then
			   startReverseFuncS <= '0';
				state <= running_ReverseFuncS;
			 else
			   state <= running_ReverseFuncL;
			 end if;
		  else
		    state <= running_ReverseFuncL;
		  end if;
				
		--/* State running_ReverseFuncS */--
		when running_ReverseFuncS =>
		  if flagReverseFuncS = '0' then
		    dataout <= dataoutReverseFuncS;
		    state <= idle_s;
		  else
			 state <= running_ReverseFuncL;
		  end if; 	 
		  
		when others => null;
    end case;
  end if;
end process;

end ReverseFuncSLX_arch;