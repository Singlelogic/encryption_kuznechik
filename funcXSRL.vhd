Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;

entity funcXSRL is
  port(indata            : in std_logic_vector(127 downto 0);
       key               : in std_logic_vector(127 downto 0);
       clk, reset, start : in std_logic;
		 flagFuncXSRL      : out std_logic;
		 dataout           : out std_logic_vector(127 downto 0));
end funcXSRL;

architecture funcXSRL_arch of funcXSRL is

  type state_type is (idle_s, running_funcXS, running_funcRL, ending_s);
  signal state           : state_type;
  signal reg_funcLSX     : std_logic_vector(127 downto 0);
  --signal reg_funcXS      : std_logic_vector(127 downto 0);
  --signal reg_funcRL      : std_logic_vector(127 downto 0);
  --/* funcXS */--
  --signal indataFuncXS    : std_logic_vector(127 downto 0);
  signal dataoutFuncXS   : std_logic_vector(127 downto 0);
  signal startFuncXS     : std_logic;
  signal flagFuncXS      : std_logic;
  --/* funcRL */--
  --signal indataFuncRL    : std_logic_vector(127 downto 0);
  signal dataoutFuncRL   : std_logic_vector(127 downto 0);
  signal startFuncRL     : std_logic;
  signal flagFuncRL      : std_logic;
  --signal prefClk         : std_logic; --New
   
  component funcX
    port(indata            : in std_logic_vector(127 downto 0);
         key               : in std_logic_vector(127 downto 0);
         clk, reset, start : in std_logic;
		   flagFuncXS        : out std_logic;
		   dataout           : out std_logic_vector(127 downto 0));
  end component funcX;
  
  component funcL
    port(indata            : in std_logic_vector(127 downto 0);
         clk, reset, start : in std_logic;
		   flagFuncL         : out std_logic;
		   dataout           : out std_logic_vector(127 downto 0));
  end component funcL;
  
begin

funcX_comp : funcX port map (indata, key, clk, reset, startFuncXS,
                               flagFuncXS, dataoutFuncXS);
										
funcL_comp : funcL port map (reg_funcLSX, clk, reset, startFuncRL,
                             flagFuncRL, dataoutFuncRL);

process(clk, reset)
begin
  if reset = '1' then
	 flagFuncXSRL    <= '0';
	 dataout         <= x"00000000000000000000000000000000";
	 reg_funcLSX     <= x"00000000000000000000000000000000";
	 state           <= idle_s;
	 startFuncXS     <= '0';
	 startFuncRL     <= '0';
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
		  flagFuncXSRL <= '0';
		  reg_funcLSX     <= x"00000000000000000000000000000000";
		  startFuncXS     <= '0';
	          startFuncRL     <= '0';
		  if start = '1' then
		    state      <= running_funcXS;
			 flagFuncXSRL <= '1';
		  else
		    state <= idle_s;
		  end if;
		  
		--/* State RUNNING_funcXS */--		
		when running_funcXS =>
        startFuncXS <= '1';
		  if flagFuncXS = '1' then
		    state <= running_funcRL;
			 startFuncXS <= '0';
		  else
		    state <= running_funcXS;
		  end if;
		
		--/* State RUNNING_funcRL */--
		when running_funcRL =>
		  if flagFuncXS = '0' then
		    reg_funcLSX <= dataoutFuncXS; 
		    startFuncRL <= '1';
			 if flagFuncRL = '1' then
			   state <= ending_s;
				startFuncRL <= '0';
			 else
			   state <= running_funcRL;
		    end if;
		  end if;
		
      --/* State MIDDLE_s */--		
		--when middle_s =>
		  --if flagFuncRL = '0' then
			 --startFuncRL <= '0';
			 --state <= ending_s;
		  --else
		    --state <= middle_s;
		  --end if;
      
		--/* State ENDING_s */--
		when ending_s =>
		  if flagFuncRL = '0' then
		    state <= idle_s;
		    dataout <= dataoutFuncRL;
		  else
		    state <= ending_s;
		  end if;
		  
		when others => null;
    end case;
  end if;
end process;

end funcXSRL_arch;