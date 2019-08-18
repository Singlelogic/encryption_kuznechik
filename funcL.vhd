Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
--use IEEE.numeric_std.all;

entity funcL is
  port(indata            : in std_logic_vector(127 downto 0);
       clk, reset, start : in std_logic;
		 flagFuncL         : out std_logic;
		 dataout           : out std_logic_vector(127 downto 0));
end funcL;

architecture funcL_arch of funcL is

  type state_type is (idle_s, middle_s, running_s);
  signal state           : state_type;
  signal i               : integer range 0 to 31;
  signal prefClk         : std_logic;
  signal indata_reg      : std_logic_vector(127 downto 0);
  --/* FuncR */--
  signal flagfuncR       : std_logic;
  signal dataOutFuncR    : std_logic_vector(7 downto 0);
  signal startFuncR      : std_logic;
  signal indata_regFuncR : std_logic_vector(127 downto 0);
  
  component FuncR
    port(indata : in std_logic_vector(127 downto 0);
         clk, reset, start : in std_logic;
		   endFlag    : out std_logic;
		   dataout    : out std_logic_vector(7 downto 0));
  end component;
    
begin

FuncR_comp : FuncR port map (indata => indata_regFuncR, clk => clk, reset => reset, 
                 start => startFuncR, endFlag => flagfuncR, dataout => dataOutFuncR);

process(clk, reset)
begin
if reset = '1' then
    flagFuncL       <= '0';
	 dataout         <= x"00000000000000000000000000000000";
	 state           <= idle_s;
	 i               <= 0;
	 prefClk         <= '0';
	 indata_reg      <= x"00000000000000000000000000000000";
	 startFuncR      <= '0';
	 indata_regFuncR <= x"00000000000000000000000000000000";
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
        flagFuncL       <= '0';
	     i               <= 0;
	     prefClk         <= '0';
	     indata_reg      <= x"00000000000000000000000000000000";
	     startFuncR      <= '0';
	     indata_regFuncR <= x"00000000000000000000000000000000";
		  if start = '1' then
		    state      <= middle_s;
			 indata_reg <= indata;
			 flagFuncL <= '1';
		  else
		    state <= idle_s;
		  end if;
		
		--/* State RUNNING */--	
		when middle_s =>
		  if (flagfuncR = '0' and i < 16) then
		    startFuncR <= '1';
		    indata_regFuncR <= indata_reg;
			 state <= running_s;
		  else
			 startFuncR <= '0';
		  end if;
		
      --/* State RUNNING */--		
		when running_s =>
		  prefClk <= not prefClk;
		    if (flagfuncR = '0' and prefClk = '1') then
			     indata_reg <= dataOutFuncR & indata_reg(127 downto 8);
				  dataout <= dataOutFuncR & indata_reg(127 downto 8);
              i <= i + 1;
				  if i = 15 then
			       state <= idle_s;
				    startFuncR <= '0';
				  else
				    state <= middle_s;
				  end if;
		    else
			   startFuncR <= '0';
		    end if;
		when others => null;
    end case;
  end if;
end process;

end funcL_arch;