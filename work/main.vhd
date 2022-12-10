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
        clk             : in std_logic; -- Clock
        reset           : in std_logic; -- Reset counter dan isi memori
        request_ticket  : in std_logic; -- Menaikkan counter
        is_occupied     : inout std_logic_vector(0 to n-1); -- Apakah konter diisi orang?
        queue_counter_bin   : out std_logic_vector(b-1 downto 0);
        queue_counter   : out std_logic_vector(27 downto 0); -- Sevseg untuk urutan pelanggan
        queue_display_bin   : out std_logic_vector((n*b)-1 downto 0);
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

    --package mem is new work.memory_management generic map (
    --    N => b, K => k
    --);

    type storage is array (0 to k-1) of std_logic_vector(b-1 downto 0);

    function tambahAntrian(queue : storage; queue_size : positive; value : std_logic_vector(b-1 downto 0)) return storage
    is
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(b-1 downto 0) := (others => '0') ;
    begin
        for i in 0 to queue_size-1 loop
            if N > 12 then queue_out(i)(b downto 12) := (others => '0'); end if; 
            if queue_out(i) = zeros then 
                queue_out(i) := value; exit;
            end if;
        end loop;
        return queue_out;
    end tambahAntrian;

    --function untuk mengambil orang pertama dari antrian
    function hapusAntrian(queue : storage; queue_size : positive) return storage
    is
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(b-1 downto 0) := (others => '0') ;
    begin
        for i in 1 to queue_size-1 loop
            queue_out(i-1) := queue_out(i);
            if i = queue_size-1 then queue_out(i) := (others => '0'); end if; 
        end loop;
        return queue_out;
    end hapusAntrian;

    function cekKosong(queue : storage; queue_size : positive) return std_logic
    is
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(b-1 downto 0) := (others => '0') ;
    begin
        for i in 1 to queue_size-1 loop
            if queue_out(i) /= zeros then return '1'; end if; 
        end loop;
        return '0';
    end cekKosong;

    function cekPenuh(queue : storage; queue_size : positive) return std_logic
    is
        variable ret : std_logic := '0';
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(b-1 downto 0) := (others => '0') ;
    begin
        for i in 1 to queue_size-1 loop
            if queue_out(i) = zeros then ret := '1'; exit; end if; 
        end loop;
        return ret;
    end cekPenuh;

    signal ones : std_logic_vector(b-1 downto 0) := (others => '1');
    signal restart  : std_logic_vector(b-1 downto 0) := (0 => '1', others => '0');

    signal sevseg_in        : std_logic_vector((n*b)-1 downto 0);
    signal queue_number     : std_logic_vector(b-1 downto 0);
    signal number_stor      : storage;
    
begin

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

    seven_segment_for_queue : bin_to_bcd generic map ( -- Seven segment untuk penghitung urutan.
        N => b
    ) port map ( -- Assignment input binary dan output seven segment display.
        clk => clk, reset => reset, binary_in => queue_number,
        ssd3 => queue_counter(27 downto 21),
        ssd2 => queue_counter(20 downto 14),
        ssd1 => queue_counter(13 downto 7),
        ssd0 => queue_counter(6 downto 0)
    );

    queue_counter_bin <= queue_number;
    queue_display_bin <= sevseg_in;

    --process (clk) is -- Menjalankan clock
    --begin
    --    if rising_edge(clk) then
    --        present_state <= next_state;
    --    end if;
    --end process;

    process (clk, queue_number, sevseg_in, reset, request_ticket)
        variable sevseg_in_var : std_logic_vector((n*b)-1 downto 0);
        variable queue_number_var : std_logic_vector(b - 1 downto 0);
        variable number_stor_var : storage;
        variable kosong : std_logic;
        variable penuh : std_logic;
    begin
        kosong := cekKosong(number_stor_var, k);
        penuh := cekPenuh(number_stor_var, k);
        if rising_edge(clk) then
            case present_state is
                when S0 =>
                    if reset = '1' then next_state <= S3;
                    else next_state <= S1;
                    end if;
                when S1 => -- Orang mengambil tiket
                    if request_ticket = '1' then
                        if penuh = '1' then
                            if b <= 12 then
                                if queue_number_var = ones then 
                                    queue_number_var := restart; 
                                else
                                    queue_number_var := std_logic_vector(unsigned(queue_number_var) + 1);
                                end if;
                            else 
                                if queue_number_var(11 downto 0) = ones(11 downto 0) then 
                                    queue_number_var(11 downto 0) := restart(11 downto 0); 
                                else
                                    queue_number_var(11 downto 0) := std_logic_vector(unsigned(queue_number_var(11 downto 0)) + 1);
                                end if;
                            end if;
                            number_stor_var := tambahAntrian(number_stor_var, k, queue_number_var);
                        end if;
                    end if;
                    next_state <= S2;
                when S2 => -- Orang dipanggil ke konter kosong
                    if kosong = '1' then
                        for i in 0 to n-1 loop
                            if is_occupied(i) = '0' then 
                                sevseg_in_var(((i+1)*b)-1 downto i*b) := number_stor_var(0);
                                number_stor_var := hapusAntrian(number_stor_var, k);
                                is_occupied(i) <= '1';
                                exit;
                            end if;
                        end loop;
                    end if;
                    next_state <= S0;
                when S3 => -- Reset counter dan memori
                    for i in 0 to k-1 loop
                        number_stor_var(i) := (others => '0');
                    end loop;
                    queue_number_var := (others => '0');
                    sevseg_in_var := (others => '0');
                    next_state <= S0;
                when others =>
                    next_state <= S0; --Tidak digunakan
            end case;
        end if;
        number_stor <= number_stor_var;
        sevseg_in <= sevseg_in_var;
        queue_number <= queue_number_var;
        present_state <= next_state;
    end process;

end architecture;