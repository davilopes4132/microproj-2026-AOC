# Projeto Referente a Disciplina DCC 301 da UFRR

Este projeto apresenta os resultados de uma comparação entre processor pipeline vs um multiciclo.

A descrição e requisitos do projeto estão disponíveis em [specs/](specs/).

Para preparar e verificar o ambiente (GHDL + GTKWave), veja [docs/ambiente.md](docs/ambiente.md).

---

Autor:
Herbert Rocha
herberthb12@gmail.com

## Testar O1 e O2

Com o GHDL no PATH, rode na raiz do projeto. No Windows, use Git Bash.

```bash
bash run_all.sh
```

O script compila as duas organizações em bibliotecas separadas, executa os testes
unitários, roda T0 e a série de tamanhos em ambas e checa os abortos TD, TE e TC
em O2. O T0 contém 36 instruções úteis e abrange a ISA obrigatória.

As métricas são gravadas em `build/validacao/metricas.csv`. Abra os arquivos
`.ghw` em `build/validacao/o1/` e `build/validacao/o2/` no GTKWave.
O período do testbench serve à simulação. Para calcular speedup em tempo
de execução, use os períodos estimados ou sintetizados de cada organização.
