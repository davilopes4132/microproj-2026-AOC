library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Registrador entre os estagios ID e EX do pipeline

entity id_ex is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    freeze    : in  std_logic;
    valid_in  : in  std_logic;
    valid_out : out std_logic;
    pc_in     : in  std_logic_vector(31 downto 0);
    pc_out    : out std_logic_vector(31 downto 0);
    rs_val_in : in  std_logic_vector(31 downto 0);
    rs_val_out: out std_logic_vector(31 downto 0);
    rt_val_in : in  std_logic_vector(31 downto 0);
    rt_val_out: out std_logic_vector(31 downto 0);
    imm_in    : in  std_logic_vector(31 downto 0);
    imm_out   : out std_logic_vector(31 downto 0);
    dest_in   : in  std_logic_vector(4 downto 0);
    dest_out  : out std_logic_vector(4 downto 0);
    aluop_in  : in  std_logic_vector(1 downto 0);
    aluop_out : out std_logic_vector(1 downto 0);
    reg_write_in  : in  std_logic;
    reg_write_out : out std_logic;
    mem_to_reg_in : in  std_logic;
    mem_to_reg_out: out std_logic;
    mem_read_in   : in  std_logic;
    mem_read_out  : out std_logic;
    mem_write_in  : in  std_logic;
    mem_write_out : out std_logic;
    branch_in : in std_logic;
    branch_out: out std_logic;
    alu_src_in: in std_logic;
    alu_src_out:  out std_logic;
    halt_in   : in std_logic;
    halt_out  : out std_logic
  );

end entity id_ex;

architecture comportamento of id_ex is
begin

  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        -- reset: tudo zero (uma bolha nao faz nada)
        valid_out <= '0';
        pc_out    <= (others => '0');
        rs_val_out    <= (others => '0');
        rt_val_out    <= (others => '0');
        imm_out    <= (others => '0');
        dest_out    <= (others => '0');
        aluop_out    <= (others => '0');
        reg_write_out <= '0';
        mem_to_reg_out <= '0';
        mem_read_out <= '0';
        mem_write_out <= '0';
        branch_out <= '0';
        alu_src_out <= '0';
        halt_out <= '0';
      

      elsif freeze = '1' then
        null;  -- congelado: as saidas mantem o valor

      else
        -- caso normal: copia as entradas para as saidas
        valid_out <= valid_in;
        pc_out <= pc_in;
        rs_val_out    <= rs_val_in;
        rt_val_out    <= rt_val_in;
        imm_out    <= imm_in;
        dest_out    <= dest_in;
        aluop_out    <= aluop_in;
        reg_write_out    <= reg_write_in;
        mem_to_reg_out    <= mem_to_reg_in;
        mem_read_out    <= mem_read_in;
        mem_write_out    <= mem_write_in;
        branch_out    <= branch_in;
        alu_src_out    <= alu_src_in;
        halt_out    <= halt_in;
        
      end if;
    end if;
  end process;

end architecture comportamento;