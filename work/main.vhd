-- Created and revised by Muhammad Rizky Utomo


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity main is
    generic (
        n   : positive := 4; -- Jumlah konter secara default adalah 4 buah, maksimal 8 buah.
        b   : positive := 12; -- Note: angka maksimum yang dapat dimasukkan adalah 8191 atau 12 bit.
        k   : positive := 250 -- Jumlah bangku default 250 buah, secara teori tidak terbatas.
    );
    port (
        request_ticket  : in std_logic; -- Menaikkan counter
        clk             : in std_logic; -- Clock
        reset           : in std_logic; -- Reset counter dan isi memori
        is_occupied     : inout std_logic_vector(0 to n-1); -- Apakah konter diisi orang?
        queue_counter_bin   : out std_logic_vector(b-1 downto 0);
        queue_counter   : out std_logic_vector(27 downto 0); -- Sevseg untuk urutan pelanggan
        queue_display_bin   : out std_logic_vector(b-1 downto 0);
        queue_display   : out std_logic_vector((28*n)-1 downto 0) -- SEVSEG untuk konter
    );
end entity main;

architecture rtl of main is

    component bin_to_bcd is
        generic(
            N: positive := 12
        );
        port(
            clk, reset: in std_logic;
            binary_in: in std_logic_vector(N-1 downto 0);
            ssd0,ssd1,ssd2,ssd3 : OUT std_logic_vector (6 downto 0)
        );
    end component;

    type states is (S0, S1, S2, S3);
        signal present_state, next_state : states := S3;

    package mem is new work.memory_management generic map (
            N => b, K => k
        );

    signal ones : std_logic_vector(b-1 downto 0) := (others => '1');
    signal restart  : std_logic_vector(b-1 downto 0) := (0 => '1', others => '0');

    signal sevseg_in        : std_logic_vector((n*b)-1 downto 0);
    signal time_counter     : integer := 0;
    signal reset_time       : std_logic := '0';
    signal queue_number     : std_logic_vector(b-1 downto 0);
    signal number_stor      : mem.storage;
    signal next_customer    : std_logic;
    
begin

    check_b : if b <= 12 generate -- Jumlah bit 12 atau kurang

        check_n : if n <= 8 generate -- Jumlah counter 8 atau kurang

            generate_counters : for i in 0 to n-1 generate 
                seven_segment_for_counters : bin_to_bcd generic map (
                    N => b
                ) port map ( -- Assignment input binary dan output seven segment display.
                    clk => clk, reset => reset, binary_in => sevseg_in(((i+1)*b)-1 downto i*b),
                    ssd3 => queue_display(27+(28*i) downto 21+(28*i)),
                    ssd2 => queue_display(20+(28*i) downto 14+(28*i)),
                    ssd1 => queue_display(13+(28*i) downto 7+(28*i)),
                    ssd0 => queue_display(6+(28*i) downto (28*i))
                );
            end generate;

        else generate -- Jumlah counter lebih dari 8, default ke 8.
            
            generate_counters : for i in 0 to n-1 generate
                seven_segment_for_counters : bin_to_bcd generic map (
                    N => b
                ) port map ( -- Assignment input binary dan output seven segment display.
                    clk => clk, reset => reset, binary_in => sevseg_in(((i+1)*b)-1 downto i*b),
                    ssd3 => queue_display(27+(28*i) downto 21+(28*i)),
                    ssd2 => queue_display(20+(28*i) downto 14+(28*i)),
                    ssd1 => queue_display(13+(28*i) downto 7+(28*i)),
                    ssd0 => queue_display(6+(28*i) downto (28*i))
                );
            end generate;
            
        end generate;

        seven_segment_for_queue : bin_to_bcd generic map ( -- Seven segment untuk penghitung urutan.
            N => b
        ) port map ( -- Assignment input binary dan output seven segment display.
            clk => clk, reset => reset, binary_in => queue_number,
            ssd3 => queue_counter(27 downto 21),
            ssd2 => queue_counter(20 downto 14),
            ssd1 => queue_counter(13 downto 7),
            ssd0 => queue_counter(6 downto 0)
        );

    else generate -- Jumlah bit lebih dari 12, default ke 12.

        check_n : if n <= 8 generate -- Jumlah counter 8 atau kurang

            generate_counters : for i in 0 to 7 generate
                seven_segment_for_counters : bin_to_bcd generic map (
                    N => 12
                ) port map ( -- Assignment input binary dan output seven segment display.
                    clk => clk, reset => reset, binary_in => sevseg_in(((i+1)*12)-1 downto i*12),
                    ssd3 => queue_display(27+(28*i) downto 21+(28*i)),
                    ssd2 => queue_display(20+(28*i) downto 14+(28*i)),
                    ssd1 => queue_display(13+(28*i) downto 7+(28*i)),
                    ssd0 => queue_display(6+(28*i) downto (28*i))
                );
            end generate;

        else generate -- Jumlah counter lebih dari 8, default ke 8.
            
            generate_counters : for i in 0 to 7 generate
                seven_segment_for_counters : bin_to_bcd generic map (
                    N => 12
                ) port map ( -- Assignment input binary dan output seven segment display.
                    clk => clk, reset => reset, binary_in => sevseg_in(((i+1)*12)-1 downto i*12),
                    ssd3 => queue_display(27+(28*i) downto 21+(28*i)),
                    ssd2 => queue_display(20+(28*i) downto 14+(28*i)),
                    ssd1 => queue_display(13+(28*i) downto 7+(28*i)),
                    ssd0 => queue_display(6+(28*i) downto (28*i))
                );
            end generate;
            
        end generate;

        seven_segment_for_queue : bin_to_bcd generic map ( -- Seven segment untuk penghitung urutan.
            N => 12
        ) port map ( -- Assignment input binary dan output seven segment display.
            clk => clk, reset => reset, binary_in => queue_number(11 downto 0),
            ssd3 => queue_counter(27 downto 21),
            ssd2 => queue_counter(20 downto 14),
            ssd1 => queue_counter(13 downto 7),
            ssd0 => queue_counter(6 downto 0)
        );
            
    end generate;

    process (clk, time_counter, reset_time) is -- Menjalankan clock
    begin
        if rising_edge(clk) then
            present_state <= next_state;
            if reset_time = '1' then time_counter <= 0;
            elsif time_counter = 3 then next_customer <= '1'; -- Cooldown untuk pemanggilan tiap customer adalah 3 clk.
            else time_counter <= time_counter + 1;
            end if;
        end if;
    end process;

    process
        variable queue_bin : std_logic_vector(b-1 downto 0) := queue_number;
        variable number_stor_var : mem.storage := number_stor;
    begin
        case present_state is
            when S0 =>
                if reset = '1' then next_state <= S3;
                elsif request_ticket = '1' then next_state <= S1;
                elsif next_customer = '1' then next_state <= S2;
                else next_state <= S0;
                end if;
            when S1 => -- Orang mengambil tiket
                if mem.cekPenuh(number_stor, k) = '1' then next_state <= S0;
                else
                    if b <= 12 then
                        if queue_number = ones then 
                            queue_bin := restart; 
                        else
                            queue_bin := std_logic_vector(unsigned(queue_number) + 1);
                        end if;
                    else 
                        if queue_bin(11 downto 0) = ones(11 downto 0) then 
                            queue_bin(11 downto 0) := (0 => '1', others => '0'); 
                        else
                            queue_bin(11 downto 0) := std_logic_vector(unsigned(queue_number(11 downto 0)) + 1);
                        end if;
                    end if;
                    number_stor <= mem.tambahAntrian(number_stor, k, queue_bin);

                    if next_customer = '1' then next_state <= S2;
                    else next_state <= S0; end if;
                    queue_number <= queue_bin;
                    queue_counter_bin <= queue_bin;
                end if;
            when S2 => -- Orang dipanggil ke konter kosong
                if mem.cekKosong(number_stor, k) = '1' then next_state <= S0;
                else
                    if b <= 12 then
                        if n <= 8 then
                            for i in 0 to n-1 loop
                                if is_occupied(i) = '0' then 
                                    sevseg_in(((i+1)*b)-1 downto i*b) <= number_stor(0);
                                    number_stor_var := mem.hapusAntrian(number_stor, k);
                                    is_occupied(i) <= '1';
                                end if;
                            end loop;
                        else
                            for i in 0 to 7 loop
                                if is_occupied(i) = '0' then 
                                    sevseg_in(((i+1)*b)-1 downto i*b) <= number_stor(0);
                                    number_stor_var := mem.hapusAntrian(number_stor, k);
                                    is_occupied(i) <= '1';
                                end if;
                            end loop;
                        end if;
                    else
                        if n <= 8 then
                            for i in 0 to n-1 loop
                                if is_occupied(i) = '0' then 
                                    sevseg_in(((i+1)*12)-1 downto i*12) <= number_stor(0)(11 downto 0);
                                    number_stor_var := mem.hapusAntrian(number_stor, k);
                                    is_occupied(i) <= '1';
                                end if;
                            end loop;  
                        else
                            for i in 0 to 7 loop
                                if is_occupied(i) = '0' then 
                                    sevseg_in(((i+1)*12)-1 downto i*12) <= number_stor(0)(11 downto 0);
                                    number_stor_var := mem.hapusAntrian(number_stor, k);
                                    is_occupied(i) <= '1';
                                end if;
                            end loop;
                        end if;      
                    end if;
                end if;
                number_stor <= number_stor_var;
                reset_time <= '1';
                next_customer <= '0';
                next_state <= S0;
            when S3 => -- Reset counter dan memori
                for i in 0 to k-1 loop
                    number_stor(i) <= (others => '0');
                end loop;
                queue_number <= (others => '0');
                sevseg_in <= (others => '0');
                next_state <= S0;
            when others =>
                next_state <= S0; --Tidak digunakan
        end case;
        wait until rising_edge(clk);
    end process;

end architecture;