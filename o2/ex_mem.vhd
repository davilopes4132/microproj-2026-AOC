library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Registrador entre os estagios EX e MEM do pipeline

entity ex_mem is
  port (
    clk            : in  std_logic;
    rst            : in  std_logic;
    freeze         : in  std_logic;
    valid_in       : in  std_logic;
    valid_out      : out std_logic;
    alu_result_in  : in  std_logic_vector(31 downto 0);
    alu_result_out : out std_logic_vector(31 downto 0);
    store_data_in  : in  std_logic_vector(31 downto 0);
    store_data_out : out std_logic_vector(31 downto 0);
    dest_in        : in  std_logic_vector(4 downto 0);
    dest_out       : out std_logic_vector(4 downto 0);
    reg_write_in   : in  std_logic;
    reg_write_out  : out std_logic;
    mem_to_reg_in  : in  std_logic;
    mem_to_reg_out : out std_logic;
    mem_read_in    : in  std_logic;
    mem_read_out   : out std_logic;
    mem_write_in   : in  std_logic;
    mem_write_out  : out std_logic;
    pc_in          : in  std_logic_vector(31 downto 0);
    pc_out         : out std_logic_vector(31 downto 0);
    zero_in        : in  std_logic;
    zero_out       : out std_logic;
    branch_in      : in  std_logic;
    branch_out     : out std_logic;
    halt_in        : in  std_logic;
    halt_out       : out std_logic
  );
end entity ex_mem;

architecture comportamento of ex_mem is
begin

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        -- reset: tudo zero (uma bolha nao faz nada)
        valid_out      <= '0';
        alu_result_out <= (others => '0');
        store_data_out <= (others => '0');
        dest_out       <= (others => '0');
        reg_write_out  <= '0';
        mem_to_reg_out <= '0';
        mem_read_out   <= '0';
        mem_write_out  <= '0';
        pc_out         <= (others => '0');
        zero_out       <= '0';
        branch_out     <= '0';
        halt_out       <= '0';

      elsif freeze = '1' then
        null;  -- congelado: as saidas mantem o valor

      else
        
        valid_out      <= valid_in;
        alu_result_out <= alu_result_in;
        store_data_out <= store_data_in;
        dest_out       <= dest_in;
        reg_write_out  <= reg_write_in;
        mem_to_reg_out <= mem_to_reg_in;
        mem_read_out   <= mem_read_in;
        mem_write_out  <= mem_write_in;
        pc_out         <= pc_in;
        zero_out       <= zero_in;
        branch_out     <= branch_in;
        halt_out       <= halt_in;
      end if;
    end if;
  end process;

end architecture comportamento;