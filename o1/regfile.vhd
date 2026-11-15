library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    reg_write : in  std_logic;
    ra1       : in  std_logic_vector(4 downto 0);
    ra2       : in  std_logic_vector(4 downto 0);
    wa        : in  std_logic_vector(4 downto 0);
    wd        : in  std_logic_vector(31 downto 0);
    rd1       : out std_logic_vector(31 downto 0);
    rd2       : out std_logic_vector(31 downto 0);
    dbg_addr  : in  std_logic_vector(4 downto 0);
    dbg_data  : out std_logic_vector(31 downto 0)
  );
end entity regfile;

architecture comportamento of regfile is
-- 32 registradores de 32 bits (indices de 0 ate 31)
  type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
  signal regs : reg_array := (others => (others => '0'));
begin

  -- leituras (sem relogio)
  rd1 <= regs(to_integer(unsigned(ra1)));
  rd2 <= regs(to_integer(unsigned(ra2)));
  dbg_data <= regs(to_integer(unsigned(dbg_addr)));

  -- escrita (na borda de subida do relogio)
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        regs <= (others => (others => '0'));
      elsif reg_write = '1' and wa /= "00000" then
        regs(to_integer(unsigned(wa))) <= wd;
      end if;
    end if;
  end process;

end architecture comportamento;