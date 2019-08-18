Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;

entity ReverseFuncL is
  port(indata            : in std_logic_vector(127 downto 0);
       clk, reset, start : in std_logic;
		 flagFuncL         : out std_logic;
		 dataout           : out std_logic_vector(127 downto 0));
end ReverseFuncL;

architecture ReverseFuncL_arch of ReverseFuncL is

  type state_type is (idle_s, running_funcR, middle_funcR);
  signal state           : state_type;
  signal i               : integer range 0 to 31;
  signal indata_reg      : std_logic_vector(127 downto 0);
  --/* FuncR */--
  signal flagfuncR       : std_logic;
  signal dataOutFuncR    : std_logic_vector(127 downto 0);
  signal startFuncR      : std_logic;
  
  component ReverseFuncR
    port(indata : in std_logic_vector(127 downto 0);
         clk, reset, start : in std_logic;
		   endFlag    : out std_logic;
		   dataout    : out std_logic_vector(127 downto 0));
  end component;
    
begin

ReverseFuncR_comp : ReverseFuncR port map (indata => indata_reg, clk => clk, reset => reset, start => startFuncR, 
                                           endFlag => flagfuncR, dataout => dataOutFuncR);

process(clk, reset)
begin
if reset = '1' then
	 flagFuncL <= '0';
	 dataout         <= x"00000000000000000000000000000000";
    state           <= idle_s;
	 i               <= 0;	 
    indata_reg      <= x"00000000000000000000000000000000";
	 startFuncR      <= '0';
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
        flagFuncL  <= '0';
		  i          <= 0;
		  indata_reg <= x"00000000000000000000000000000000";
		  startFuncR      <= '0';  
		  if start = '1' then
		    state      <= running_funcR;
			 indata_reg <= indata;
			 flagFuncL <= '1';
		  else
		    state <= idle_s;
		  end if;
		
		--/* State RUNNING_funcR */--	
		when running_funcR =>
		  startFuncR <= '1';
		    if flagfuncR = '1' then
		      startFuncR <= '0';
			   state <= middle_funcR;
		    else
			   state <= running_funcR;
		    end if;
		
      --/* State MIDDLE_funcR */--		
		when middle_funcR =>
		  if flagfuncR = '0' then
		    indata_reg <= dataOutFuncR;
			 i <= i + 1;
			 if i = 15 then
			   state <= idle_s;
				dataout <= dataOutFuncR;
		    else
				state <= running_funcR;
		    end if;
		  end if;
			 
		when others => null;
    end case;
  end if;
end process;

end ReverseFuncL_arch;