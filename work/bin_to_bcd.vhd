-- Created and revised by Bisma Alif

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity bin_to_bcd is
    generic(
        N: positive := 12
    );
    port(
        clk, reset: in std_logic;
        binary_in: in std_logic_vector(N-1 downto 0);
        ssd0,ssd1,ssd2,ssd3 : OUT std_logic_vector (6 downto 0)
    );
end bin_to_bcd ;

architecture behave of bin_to_bcd is
    type states is (start, shift, done);
    signal state, state_next: states;

    signal binary, binary_next: std_logic_vector(N-1 downto 0);
    signal bcds, bcds_reg, bcds_next: std_logic_vector(15 downto 0);
    --output register keep output constant during conversion
    signal bcds_out_reg, bcds_out_reg_next: std_logic_vector(15 downto 0);
    --need to keep track of shifts
    signal shift_counter, shift_counter_next: natural range 0 to N;
    signal bcd0, bcd1, bcd2, bcd3: std_logic_vector(3 downto 0);
begin

    process(clk, reset)
    begin
        if reset = '1' then
            binary <= (others => '0');
            bcds <= (others => '0');
            state <= start;
            bcds_out_reg <= (others => '0');
            shift_counter <= 0;
        elsif falling_edge(clk) then
            binary <= binary_next;
            bcds <= bcds_next;
            state <= state_next;
            shift_counter <= shift_counter_next;
        end if;
    end process;

    convert:
    process(state, binary, binary_in, bcds, bcds_reg, shift_counter)
    begin
        state_next <= state;
        bcds_next <= bcds;
        binary_next <= binary;
        shift_counter_next <= shift_counter;

        case state is
            when start =>
                state_next <= shift;
                binary_next <= binary_in;
                bcds_next <= (others => '0');
                shift_counter_next <= 0;
            when shift =>
                if shift_counter = N then
                    state_next <= done;
                else
                    binary_next <= binary(N-2 downto 0) & 'L';
                    bcds_next <= bcds_reg(14 downto 0) & binary(N-1);
                    shift_counter_next <= shift_counter + 1;
                end if;
            when done =>
                state_next <= start;
        end case;
    end process;

    bcds_reg(15 downto 12) <= bcds(15 downto 12) + 3 
        when bcds(15 downto 12) > 4 
        else bcds(15 downto 12);
    bcds_reg(11 downto 8) <= bcds(11 downto 8) + 3 
        when bcds(11 downto 8) > 4 
        else bcds(11 downto 8);
    bcds_reg(7 downto 4) <= bcds(7 downto 4) + 3 
        when bcds(7 downto 4) > 4 
        else bcds(7 downto 4);
    bcds_reg(3 downto 0) <= bcds(3 downto 0) + 3 
        when bcds(3 downto 0) > 4 
        else bcds(3 downto 0);

    bcds_out_reg_next <= bcds
        when state = done 
        else bcds_out_reg;

    bcd3 <= bcds_out_reg_next(15 downto 12);
    bcd2 <= bcds_out_reg_next(11 downto 8);
    bcd1 <= bcds_out_reg_next(7 downto 4);
    bcd0 <= bcds_out_reg_next(3 downto 0);

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

end behave;
