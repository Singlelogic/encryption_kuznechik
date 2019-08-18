Library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use work.table_h_package.all;
--use IEEE.numeric_std.all;

entity ReverseFuncR is
  port(indata : in std_logic_vector(127 downto 0);
       clk, reset, start : in std_logic;
		 endFlag    : out std_logic;
		 dataout    : out std_logic_vector(127 downto 0));
end ReverseFuncR;

architecture ReverseFuncR_arch of ReverseFuncR is

  type state_type is (idle_s, running_shift, running_FuncR, ending_s);
  signal state      : state_type;
  signal i          : integer range 0 to 31;
  signal prefClk    : std_logic;
  signal sum        : std_logic_vector(7 downto 0);
  signal sumtable   : std_logic_vector(7 downto 0);
  signal indata_reg : std_logic_vector(127 downto 0);
  
  type kB_type is array (0 to 15) of integer range 0 to 255;
constant kB : kB_type := (148, 32, 133, 16, 194, 192, 1, 251,
                          1, 192, 194, 16, 133, 32, 148, 1);

begin

process(clk, reset)
begin
  if reset = '1' then
    endFlag   <= '0';
	 dataout   <= x"00000000000000000000000000000000";
    state <= idle_s;
	 i          <= 0;
	 prefClk    <= '0';
	 sum        <= x"00";	 
	 sumtable   <= x"00";	 
    indata_reg <= x"00000000000000000000000000000000";
  elsif rising_edge(clk) then
    case state is
	 
	   --/* State IDLE */--
	   when idle_s =>
	     endFlag    <= '0';	
		  i          <= 0;
		  prefClk    <= '0';
		  sum        <= x"00";	 
	     sumtable   <= x"00";
		  --indata_reg <= x"00000000000000000000000000000000";
		  if start = '1' then
		    state <= running_shift;
			 indata_reg <= indata;
			 endFlag <= '1';
		  else
		    state <= idle_s;
		  end if;
		
		--/* State RUNNING_shift */--		
		when running_shift =>
		  indata_reg <= indata_reg(119 downto 0) & indata_reg(127 downto 120);
		  state <= RUNNING_FuncR;
		
      --/* State RUNNING_funcR */--		
		when running_FuncR =>
		  prefClk <= not prefClk;
		  if prefClk = '0' then
		    sumtable <= table(conv_integer(unsigned(indata_reg(127 downto 120))) * 256 + kB(i));
		  else
		    sum <= sum xor sumtable;
			 indata_reg <= indata_reg(119 downto 0) & indata_reg(127 downto 120);
			 i <= i + 1;
			 --dataout <= sum;
			 if i = 15 then
			   --dataout <= indata_reg(127 downto 8) & sum;
			   state <= ending_s;
				--endFlag <= '0';
		    end if;
		  end if;
		
      --/* State ending_s */--		
		when ending_s =>
        dataout <= indata_reg(127 downto 8) & sum;  		
		  state <= idle_s;
		  
		when others => null;
    end case;
  end if;
end process;

end ReverseFuncR_arch;

 
