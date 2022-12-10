library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


entity bin12_7seg is
    generic(
        N: positive := 12
    );
    port(
        clk, reset: in std_logic := '0';
        binary_in: in std_logic_vector(N-1 downto 0);
        ssd0,ssd1,ssd2,ssd3 : OUT std_logic_vector (6 downto 0) := "0000000"
    );
end bin12_7seg ;

architecture behaviour of bin12_7seg is

    signal bcd0, bcd1, bcd2, bcd3: std_logic_vector(3 downto 0);
begin

    bcd0 <= std_logic_vector(to_unsigned( to_integer(unsigned(binary_in)) mod 10, bcd0'length));
    bcd1 <= std_logic_vector(to_unsigned( (to_integer(unsigned(binary_in)) mod 100) / 10, bcd0'length));
    bcd2 <= std_logic_vector(to_unsigned( (to_integer(unsigned(binary_in)) mod 1000) / 100, bcd0'length));
    bcd3 <= std_logic_vector(to_unsigned( to_integer(unsigned(binary_in)) / 100, bcd0'length));

    sevSeg : process (clk)
    begin
        if (rising_edge(clk)) then
            case (bcd0) is
                when "0000" => ssd0 <= "1111110";
                when "0001" => ssd0 <= "0110000";
                when "0010" => ssd0 <= "1101101";
                when "0011" => ssd0 <= "1111001";
                when "0100" => ssd0 <= "0110011";
                when "0101" => ssd0 <= "1011011";
                when "0110" => ssd0 <= "1011111";
                when "0111" => ssd0 <= "1110000";
                when "1000" => ssd0 <= "1111111";
                when "1001" => ssd0 <= "1111011";
                when others => ssd0 <= "0000000";
            end case;
            case (bcd1) is
                when "0000" => ssd1 <= "1111110";
                when "0001" => ssd1 <= "0110000";
                when "0010" => ssd1 <= "1101101";
                when "0011" => ssd1 <= "1111001";
                when "0100" => ssd1 <= "0110011";
                when "0101" => ssd1 <= "1011011";
                when "0110" => ssd1 <= "1011111";
                when "0111" => ssd1 <= "1110000";
                when "1000" => ssd1 <= "1111111";
                when "1001" => ssd1 <= "1111011";
                when others => ssd1 <= "0000000";
            end case;
            case (bcd2) is
                when "0000" => ssd2 <= "1111110";
                when "0001" => ssd2 <= "0110000";
                when "0010" => ssd2 <= "1101101";
                when "0011" => ssd2 <= "1111001";
                when "0100" => ssd2 <= "0110011";
                when "0101" => ssd2 <= "1011011";
                when "0110" => ssd2 <= "1011111";
                when "0111" => ssd2 <= "1110000";
                when "1000" => ssd2 <= "1111111";
                when "1001" => ssd2 <= "1111011";
                when others => ssd2 <= "0000000";
            end case;
            case (bcd3) is
                when "0000" => ssd3 <= "1111110";
                when "0001" => ssd3 <= "0110000";
                when "0010" => ssd3 <= "1101101";
                when "0011" => ssd3 <= "1111001";
                when "0100" => ssd3 <= "0110011";
                when "0101" => ssd3 <= "1011011";
                when "0110" => ssd3 <= "1011111";
                when "0111" => ssd3 <= "1110000";
                when "1000" => ssd3 <= "1111111";
                when "1001" => ssd3 <= "1111011";
                when others => ssd3 <= "0000000";
            end case;
            
        end if;
    end process sevSeg;

end behaviour;
