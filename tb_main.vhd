library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.memory_management;

entity tb_main is
end entity tb_main;

architecture test of tb_main is
    -- Variable signal
    signal n   : positive := 4; -- Jumlah konter secara default adalah 4 buah, maksimal 8 buah.
    signal b   : positive := 12; -- Note: angka maksimum yang dapat dimasukkan adalah 8191 atau 12 bit.
    signal k   : positive := 250; -- Jumlah bangku default 250 buah, secara teori tidak terbatas.

    -- Input signals:
	signal request_ticket  : std_logic; -- Menaikkan counter
    signal reset           : std_logic;
	signal is_occupied     : std_logic_vector(0 to n-1); -- Apakah konter diisi orang?

	-- Output signals:
    signal queue_counter   : std_logic_vector(27 downto 0); -- Sevseg untuk urutan pelanggan
    signal queue_display   : std_logic_vector((28*n)-1 downto 0);
    
    signal queue_display_bit : std_logic_vector(b*n-1 downto 0);
    signal queue_counter_bit : std_logic_vector(b-1 downto 0);
	
    -- Clock signal:
	signal clk          : std_logic; -- Clock
    constant clk_period : time := 10 ps;
    signal i, a : integer := 0;

begin
    testmain: entity work.main
        generic map (
            n => n,
            b => b,
            k => k
        )
        port map (
            request_ticket    => request_ticket, 
            clk               => clk,
            reset             => reset,
            is_occupied       => is_occupied,
            queue_counter     => queue_counter,
            queue_counter_bin => queue_counter_bit,
            queue_display     => queue_display, 
            queue_display_bin => queue_display_bit
    );    
    
    clock: process
	begin
		clk <= '0';
		wait for clk_period;
		clk <= '1';
		wait for clk_period;

        if i < 500 then
            i <= i + 1;
        else
            wait;
        end if;
	end process;

    proc_test: process
    begin
        request_ticket <= '0';
        wait for 50 ps;
        request_ticket <= '1';
        wait for 400 ps;

        if a < 20 and a = 5 then
            reset <= '1';
            a <= a + 1;
            
        elsif a < 20 then
            a <= a + 1;
            reset <= '0';
        else
            wait;
        end if;
    end process;

end architecture;