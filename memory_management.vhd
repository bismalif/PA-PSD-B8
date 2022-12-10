-- Created by Daffa Fahrizi, revised by Muhammad Rizky Utomo

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package memory_management is

    generic (
        N : positive;
        K : positive
    );
    
    type storage is array (0 to K-1) of std_logic_vector(N-1 downto 0);

    --function untuk menambahkan orang pada antrian
    function tambahAntrian(queue : storage; queue_size : positive; value : std_logic_vector(N-1 downto 0)) return storage;

    --function untuk mengambil orang pertama dari antrian
    function hapusAntrian(queue : storage; queue_size : positive) return storage;

    function cekKosong(queue : storage; queue_size : positive) return std_logic;

    function cekPenuh(queue : storage; queue_size : positive) return std_logic;

end package memory_management;

package body memory_management is

    /*
    *tambahAntrian: 
    *Fungsi ini digunakan untuk menambahkan elemen baru ke dalam antrian. 
    *Fungsi ini menerima tiga parameter, yaitu queue (antrian yang akan ditambahkan elemen barunya), queue_size (ukuran dari antrian), dan value (nilai elemen baru yang akan ditambahkan ke dalam antrian). 
    *Fungsi ini akan mengembalikan antrian yang sudah ditambahkan elemen barunya.
    */

    function tambahAntrian(queue : storage; queue_size : positive; value : std_logic_vector(N-1 downto 0)) return storage
    is
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(N-1 downto 0) := (others => '0') ;
    begin
        for i in 0 to queue_size-1 loop
            if N > 12 then queue_out(i)(N downto 12) := (others => '0'); end if; 
            if queue_out(i) = zeros then 
                queue_out(i) := value; exit;
            end if;
        end loop;
        return queue_out;
    end tambahAntrian;

    /*
    *hapusAntrian: 
    *Fungsi ini digunakan untuk menghapus elemen pertama dari antrian. 
    *Fungsi ini menerima dua parameter, yaitu queue (antrian yang akan dihapus elemennya) dan queue_size (ukuran dari antrian). 
    *Fungsi ini akan mengembalikan antrian yang sudah dihapus elemennya.
    */
    function hapusAntrian(queue : storage; queue_size : positive) return storage
    is
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(N-1 downto 0) := (others => '0') ;
    begin
        for i in 1 to queue_size-1 loop
            queue_out(i-1) := queue_out(i);
            if i = queue_size-1 then queue_out(i) := (others => '0'); end if; 
        end loop;
        return queue_out;
    end hapusAntrian;

    /*
    *cekKosong: 
    *Fungsi ini digunakan untuk memeriksa apakah antrian kosong atau tidak. 
    *Fungsi ini menerima dua parameter, yaitu queue (antrian yang akan diperiksa) dan queue_size (ukuran dari antrian). 
    *Fungsi ini akan mengembalikan nilai '1' jika antrian kosong, atau '0' jika sebaliknya.
    */

    function cekKosong(queue : storage; queue_size : positive) return std_logic
    is
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(N-1 downto 0) := (others => '0') ;
    begin
        for i in 1 to queue_size-1 loop
            if queue_out(i) /= zeros then return '1'; end if; 
        end loop;
        return '0';
    end cekKosong;

    /*
    *cekPenuh: 
    *Fungsi ini digunakan untuk memeriksa apakah antrian penuh atau tidak. 
    *Fungsi ini menerima dua parameter, yaitu queue (antrian yang akan diperiksa) dan queue_size (ukuran dari antrian). 
    *Fungsi ini akan mengembalikan nilai '1' jika antrian penuh, atau '0' jika sebaliknya.
    */

    function cekPenuh(queue : storage; queue_size : positive) return std_logic
    is
        variable ret : std_logic := '0';
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(N-1 downto 0) := (others => '0') ;
    begin
        for i in 1 to queue_size-1 loop
            if queue_out(i) = zeros then ret := '1'; exit; end if; 
        end loop;
        return ret;
    end cekPenuh;
    
end package body memory_management;