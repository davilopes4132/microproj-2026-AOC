library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu is
    port (
        a    : in std_logic_vector(31 downto 0);
        b    : in std_logic_vector(31 downto 0);
        alu_op    :  in  std_logic_vector(2 downto 0);
        result    : out std_logic_vector(31 downto 0);
        zero    : out std_logic
    );
end entity alu;
 
architecture comportamento of alu is
    signal res : std_logic_vector(31 downto 0);
begin

    process (a, b , alu_op)
    begin
        case alu_op is
            when "000" => res <= std_logic_vector(signed(a) + signed(b));
            when "001" => res <= std_logic_vector(signed(a) - signed(b));
            when "010" => res <= a and b;
            when "011" => res <= a or b;
            when "100" =>
             if signed(a) < signed(b) then
                res <= x"00000001";
             else
                res <= x"00000000";
            end if;
           when others => res <= (others => '0');
          end case;
        end process;

        result <= res;
        zero   <= '1' when res = x"00000000" else '0';

end architecture comportamento;
