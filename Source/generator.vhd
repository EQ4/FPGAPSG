library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity generator is
	generic (
		sample_addr_bits: integer := 5;
		sample_data_bits: integer := 2
	);
	port (
		clk: in std_logic;
		data_in: in std_logic_vector(((2**sample_data_bits)-1) downto 0);
		addr_in: in std_logic_vector((sample_addr_bits-1) downto 0);
		we_n: in std_logic; -- Low to write data
		
		count_max: in std_logic_vector(31 downto 0);
		out_data: out std_logic_vector(((2**sample_data_bits)-1) downto 0)
	);
end generator;

architecture behavioral of generator is

constant U32_ZERO: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";

subtype sample_entry is std_logic_vector(((2**sample_data_bits) - 1) downto 0);
type sample_mem is array (((2**sample_addr_bits) - 1) downto 0) of sample_entry;

signal sample: sample_mem;
signal count: std_logic_vector(31 downto 0) := U32_ZERO;
signal idx: std_logic_vector((sample_addr_bits - 1) downto 0);

begin
	-- Increment counter, and sample index if counter max is met
	count_proc: process (clk)
	begin
		if (rising_edge(clk)) then
			if (count >= count_max) then
				count <= U32_ZERO;
				if (idx = (2**sample_addr_bits) - 1) then
					idx <= (others => '0');
				else
					idx <= idx + 1;
				end if;
			else
				count <= count + 1;
			end if;
		end if;
	end process;
	
	-- Put sample data at idx on output bus
	output_proc: process (clk)
	begin
		if (rising_edge(clk)) then
		
		--	if (idx = 0) then
		--		out_data <= "1111";
		--	elsif (idx = 2) then
		--		out_data <= "1111";
		--	elsif (idx > 16) then
		--		out_data <= "1111";
		--	else
		--		out_data <= (others => '0');
		--	end if;
			out_data <= sample(to_integer(unsigned(idx)));
		end if;	
	end process;
	
	-- Define sample data
	sample_write: process (clk)
	begin
		if (rising_edge(clk)) then
			if (we_n = '0') then
				sample(to_integer(unsigned(addr_in))) <= data_in;
			end if;
		end if;
	end process;
end behavioral;