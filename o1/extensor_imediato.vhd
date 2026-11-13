
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity extensor_imediato is
    port (
        imediato_16 : in std_logic_vector(15 downto 0);
        imediato_32 : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of extensor_imediato is
begin

   imediato_32 <= std_logic_vector(resize(signed(imediato_16), 32));

end architecture;
