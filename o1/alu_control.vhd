library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_control is
  port (
    aluop  : in  std_logic_vector(1 downto 0);
    funct  : in  std_logic_vector(5 downto 0);
    alu_op : out std_logic_vector(2 downto 0)
  );
end entity alu_control;

architecture comportamento of alu_control is
begin
  process (aluop, funct)
  begin
    case aluop is
      when "00" => alu_op <= "000";
      when "01" => alu_op <= "001";
      when "10" =>
        case funct is
          when "100000" => alu_op <= "000"; -- add
          when "100010" => alu_op <= "001"; -- sub
          when "100100" => alu_op <= "010";   -- and
          when "100101" => alu_op <= "011";   -- or
          when "101010" => alu_op <= "100";   -- slt
          when others   => alu_op <= "000";
        end case;
      when others => alu_op <= "000";
    end case;
  end process;
end architecture comportamento;