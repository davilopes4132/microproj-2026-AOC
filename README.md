# Projeto Referente a Disciplina DCC 301 da UFRR

O projeto compara o processador monociclo O1 com o processador pipeline O2 de cinco estágios.

A descrição e requisitos do projeto estão disponíveis em [specs/](specs/).

Para preparar e verificar o ambiente (GHDL + GTKWave), veja [docs/ambiente.md](docs/ambiente.md).

## Simulação

Execute `bash run_all.sh` com GHDL 6.0.0. O script testa O1 e O2 com T0 e a série S, verifica os abortos TD, TE e TC na O2 e grava métricas e formas de onda em `build/validacao`. Use `bash run_all.sh --o1-only` para executar apenas a O1.

A O2 resolve a condição do `beq` em MEM. Quando há instruções posteriores em andamento, o aborto de controle congela o PC e prevalece sobre o destino do desvio. Um `BREAK` válido chegando a WB ativa `done` e congela o processador. A escrita de WB usa a borda de descida, e o ID/EX captura os operandos na subida seguinte.

Os arquivos `.hex` foram montados com MARS 4.5. Para reproduzir o dump de um traço, substitua `t0` pelo nome correspondente neste comando.

```sh
java -jar Mars4_5.jar nc a ae1 dump .text HexText tracos/t0.hex tracos/t0.asm
```

## Tabelas auxiliares do relatório

Com Python 3, depois de `bash run_all.sh`:

```sh
# Tabela do traço T0: registradores lidos e escritos e distância ao produtor
python scripts/tabela_t0.py tracos/t0.asm
# Diagrama instrução × ciclo (10 primeiras e 3 últimas instruções)
cd build/validacao
ghdl --elab-run --std=08 --workdir=o2 tb_cpu -gORG_NOME=O2 -gNUM_SLOTS=5 \
  -gPROG_FILE=../../tracos/t0.hex -gESPERADO_FILE=../../tracos/t0_esperado.txt \
  -gMETRICAS_FILE=/dev/null --vcd=o2/t0.vcd
cd ../..
python scripts/instr_ciclo.py o2 build/validacao/o2/t0.vcd tracos/t0.asm
```

Para a O1, troque `o2` por `o1` e `-gNUM_SLOTS=5` por `-gNUM_SLOTS=1`.

## Modelo de tempo

`metricas.csv` registra a contagem de ciclos, CPI, IPC e ocupação média e por estágio. `tempos_estimados.csv` aplica o mesmo modelo de atrasos por componente às duas organizações. O clock de 10 ns do testbench é o estímulo da simulação funcional.

O modelo usa os atrasos ilustrativos do capítulo 4 de Patterson e Hennessy, com 200 ps para memória ou ULA e 100 ps para leitura ou escrita no banco. A O1 usa o caminho do `lw` como referência (800 ps) mais 20 ps do registrador PC, totalizando 820 ps. O mesmo overhead de 20 ps por transferência entre registradores vale para a O2. O maior estágio completo usa 220 ps e o orçamento de 120 ps por meio ciclo para WB e leitura em ID eleva o período estimado para 240 ps. O modelo abstrai os atrasos da lógica de controle, dos multiplexadores e do roteamento. São estimativas para comparação, sem síntese ou caracterização física. [Tabela de referência](https://www.dcc.fc.up.pt/~ricroc/aulas/2021/ac/apontamentos/T07_mips_implementation.pdf)


---

Autor:
Herbert Rocha
herberthb12@gmail.com
