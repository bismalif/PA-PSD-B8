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

    --function untuk mengambil orang pertama dari antrian
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

    function cekKosong(queue : storage; queue_size : positive) return std_logic
    is
        variable ret : std_logic := '0';
        variable queue_out : storage := queue;
        variable zeros : std_logic_vector(N-1 downto 0) := (others => '0') ;
    begin
        for i in 1 to queue_size-1 loop
            if queue_out(i) /= zeros then ret := '1'; exit; end if; 
        end loop;
        return ret;
    end cekKosong;

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
