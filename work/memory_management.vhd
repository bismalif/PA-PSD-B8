library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package memory_management is

    generic (
        N : positive;
        K : positive
    );
    
    type storage is array (0 to K-1) of std_logic_vector(N-1 downto 0);

    variable queue : storage;
    variable queue_size : integer;

    --function untuk menambahkan orang pada antrian
    function tambahAntrian(queue : storage; queue_size : positive; value : std_logic_vector(N-1 downto 0)) return storage;

    --function untuk mengambil orang pertama dari antrian
    function hapusAntrian(queue : storage; queue_size : positive) return storage;

end package memory_management;

package body memory_management is

    function tambahAntrian(queue : storage; queue_size : positive; value : std_logic_vector(N-1 downto 0)) return storage
    is
    begin
        for i in 0 to queue_size-1 loop
            if queue(i) = (others => '0') then 
                queue(i) := value; exit;
            end if;
        end loop;
        return queue;
    end tambahAntrian;

    --function untuk mengambil orang pertama dari antrian
    function hapusAntrian(queue : storage; queue_size : positive) return storage
    is
    begin
        for i in 1 to queue_size-1 loop
            queue(i-1) := queue(i);
            if i = queue_size-1 then queue(i) := (others => '0'); end if; 
        end loop;
        return queue;
    end hapusAntrian;
    
end package body memory_management;
