
library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

entity tb_mem_wb is
end entity;

architecture sim of tb_mem_wb is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';

    signal valid_in, valid_out : std_logic := '0';
    signal read_data_in, read_data_out :
        std_logic_vector(31 downto 0) := (others => '0');
    signal alu_result_in, alu_result_out :
        std_logic_vector(31 downto 0) := (others => '0');
    signal write_reg_in, write_reg_out :
        std_logic_vector(4 downto 0) := (others => '0');
    signal reg_write_in, reg_write_out : std_logic := '0';
    signal mem_to_reg_in, mem_to_reg_out : std_logic := '0';
    signal halt_in, halt_out : std_logic := '0';
begin
    clk <= not clk after 5 ns;

    dut: entity work.mem_wb
        port map (
            clk => clk,
            rst => rst,
            valid_in => valid_in,
            read_data_in => read_data_in,
            alu_result_in => alu_result_in,
            write_reg_in => write_reg_in,
            reg_write_in => reg_write_in,
            mem_to_reg_in => mem_to_reg_in,
            halt_in => halt_in,
            valid_out => valid_out,
            read_data_out => read_data_out,
            alu_result_out => alu_result_out,
            write_reg_out => write_reg_out,
            reg_write_out => reg_write_out,
            mem_to_reg_out => mem_to_reg_out,
            halt_out => halt_out
        );

    process
    begin
        wait until rising_edge(clk);
        wait for 1 ns;

        assert valid_out = '0'
            report "Erro no reset" severity error;

        rst <= '0';
        valid_in <= '1';
        read_data_in <= x"00000019";
        alu_result_in <= x"00000008";
        write_reg_in <= "01010";
        reg_write_in <= '1';
        mem_to_reg_in <= '1';

        wait until rising_edge(clk);
        wait for 1 ns;

        assert valid_out = '1'
            report "Erro no valid" severity error;
        assert read_data_out = x"00000019"
            report "Erro no dado de memoria" severity error;
        assert alu_result_out = x"00000008"
            report "Erro no resultado da ULA" severity error;
        assert write_reg_out = "01010"
            report "Erro no registrador de destino" severity error;
        assert reg_write_out = '1'
            report "Erro no reg_write" severity error;
        assert mem_to_reg_out = '1'
            report "Erro no mem_to_reg" severity error;

        report "Teste MEM/WB concluido com sucesso";
        stop;
        wait;
    end process;
end architecture;
