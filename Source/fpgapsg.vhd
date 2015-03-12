library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity fpgapsg is
	generic (
		addr_w: integer := 8;
		data_w: integer := 32;
		num_channels: integer := 1);
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

signal gen1_clk: std_logic;
signal gen1_addr: std_logic_vector(4 downto 0) := "00000";
signal gen1_data: std_logic_vector(3 downto 0);
signal gen1_we_n: std_logic;
signal gen1_count_max: std_logic_vector(31 downto 0);
signal gen1_out_data: std_logic_vector(3 downto 0);

signal init_counter: std_logic_vector(7 downto 0) := "00000000";

begin
	gen1: entity work.generator(behavioral) port map (
		gen1_clk, 
		gen1_data, 
		gen1_addr, 
		gen1_we_n, 
		gen1_count_max, 
		gen1_out_data
	);
	
	gen1_count_max <= "00000000000000000000010001110000";
	
	setup_clock: process (clk)
	begin
		gen1_clk <= clk;
		sample_out <= gen1_out_data & "00";
	end process;
	
	gen1_data <= init_counter(5 downto 2);
	
	write_temp_sample: process (clk)
	begin
		if (init_counter < 32) then
			gen1_we_n <= '0';
			init_counter <= init_counter + 1;
			gen1_addr <= gen1_addr + 1;
		else
			gen1_we_n <= '1';
		end if;
	end process;
	

end behavioral;

