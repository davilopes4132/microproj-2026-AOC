# Ambiente de desenvolvimento

Requisito R7 do enunciado ([specs/MicroProj.pdf](../specs/MicroProj.pdf)): VHDL-2008, simulado em GHDL e visualizado no GTKWave.

## Versões testadas

| Ferramenta | Versão | Backend / observação |
|---|---|---|
| SO | Fedora 43 | |
| GHDL | 5.1.1 | backend GCC 15.2.1 |
| GTKWave | 3.3.125 | |

## Instalação

```bash
# Fedora
sudo dnf install ghdl gtkwave

# Ubuntu / Debian
sudo apt install ghdl gtkwave
```

## Verificação do ambiente

```bash
bash scripts/verifica_ambiente.sh
```

O script:

1. confere se o `ghdl` está no PATH e mostra a versão;
2. analisa, elabora e roda [scripts/smoke/smoke_tb.vhd](../scripts/smoke/smoke_tb.vhd), que usa recursos exclusivos do VHDL-2008 (`to_string`, `to_hstring`, `std.env.stop`);
3. faz isso separadamente em `build/o1` e em `build/o2`;
4. avisa se o `gtkwave` não estiver instalado.

Sai com código 0 se tudo estiver certo.

## Uma workdir por organização

As organizações O1 e O2 definem a mesma entidade de topo, `cpu_top`, para que um único testbench sirva às duas (R3). Por isso cada uma é compilada em sua própria biblioteca `work`:

| Organização | Fontes | Workdir |
|---|---|---|
| O1 | `o1/*.vhd` | `build/validacao/o1` |
| O2 | `o2/*.vhd` e componentes compartilhados em `o1/` | `build/validacao/o2` |

Para compilar e executar todos os traços em ambas as organizações, rode na raiz:

```bash
bash run_all.sh
gtkwave build/validacao/o2/td.ghw
```

O script salva as métricas em `build/validacao/metricas.csv`.

## Estrutura do repositório

| Pasta | Conteúdo |
|---|---|
| `o1/` | VHDL da organização O1 (sem pipeline) |
| `o2/` | VHDL da organização O2 (pipeline de 5 estágios) |
| `tb/` | testbench compartilhado `tb_cpu.vhd` e testes unitários |
| `tracos/` | traços: fonte assembly, `.hex` e arquivo esperado |
| `scripts/` | scripts auxiliares de verificação do ambiente |
| `build/` | gerada; não versionada (ver `.gitignore`) |
