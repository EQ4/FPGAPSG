library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fpgapsg is
	generic (
		addr_w: integer := 8;
		data_w: integer := 32;
		gen_depth: integer := 4;
		num_channels: integer := 3);
	port (
		clk: in std_logic;
		ce_n: in std_logic; -- Pull low to use
		
		addr_in: in std_logic_vector((addr_w - 1) downto 0);
		data_in: in std_logic_vector((data_w - 1) downto 0);
		we_n: in std_logic; -- Pull low to write (precedence over read)
		re_n: in std_logic; -- Pull low to read data
		
		sample_out: out std_logic_vector(5 downto 0)
	);
end fpgapsg;

architecture behavioral of fpgapsg is

constant A_440: std_logic_vector(31 downto 0) := "00000000000000000001000111000000";

signal init_counter: std_logic_vector(7 downto 0) := "00000000";

-- All generators share clock, address, and data.
signal gen_clk: std_logic;
signal gen_addr: std_logic_vector(4 downto 0) := "00000";
signal gen_data: std_logic_vector((gen_depth - 1) downto 0) := "0000";

-- Types for controllable parameters 
type gen_amp_arr is array((num_channels - 1) downto 0) of std_logic_vector(3 downto 0);
type gen_we_arr is array ((num_channels - 1) downto 0) of std_logic;
type gen_period_arr is array ((num_channels - 1) downto 0) of std_logic_vector(31 downto 0);
type gen_out_arr is array((num_channels - 1) downto 0) of std_logic_vector((gen_depth - 1) downto 0);

-- The parameter arrays
signal gen_amp: gen_amp_arr;
signal gen_we: gen_we_arr;
signal gen_periods: gen_period_arr;
signal gen_out: gen_out_arr;

begin
	generate_gens: for i in 0 to (num_channels - 1) generate
		genx: entity work.generator(behavioral) port map (
			gen_clk, 
			gen_data, 
			gen_addr, 
			gen_we(i), 
			gen_periods(i), 
			gen_out(i)
		);
	end generate generate_gens;
	
	setup_clock: process (clk)
	begin
		gen_clk <= clk;
		sample_out <= '0' & ('0' & gen_out(0)) + ('0' & gen_out(1)) + ('0' & gen_out(2));
	end process;
	
	
	write_temp_sample: process (clk)
	begin
		if (rising_edge(clk)) then
			if (init_counter < 32) then
				gen_periods(0) <= "00000000000000000000001000111000";
				gen_periods(1) <= "00000000000000000000000111000011";
				gen_periods(2) <= "00000000000000000000000101111011";
				gen_we(0) <= '0';
				init_counter <= init_counter + 1;
				gen_addr <= gen_addr + 1;
				--gen1_data <= init_counter(4 downto 1);
				--if (init_counter = "00000" or init_counter = "00010" or init_counter > 16) then
				if (init_counter > 15) then
					gen_data <= "1111";
				else
					gen_data <= "0000";
				end if;
			else
				gen_we(0) <= '1';
			end if;
		end if;
	end process;
	

end behavioral;

