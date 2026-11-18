#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

if (( $# > 1 )) || [[ ${1:-} != "" && ${1:-} != "--o1-only" ]]; then
  printf 'Uso: bash run_all.sh [--o1-only]\n' >&2
  exit 2
fi

somente_o1=false
if [[ ${1:-} == --o1-only ]]; then
  somente_o1=true
elif [[ ! -s o2/cpu_top_o2.vhd || ! -s o2/mem_wb.vhd ]]; then
  printf 'A simulação da O2 requer cpu_top_o2.vhd e mem_wb.vhd. Use --o1-only para testar a O1.\n' >&2
  exit 1
fi

ghdl="${GHDL:-ghdl}"
saida=build/validacao
o1="$saida/o1"
o2="$saida/o2"
metricas="$saida/metricas.csv"
mkdir -p "$o1" "$o2"
printf 'org;programa;ciclos;instrucoes;CPI;IPC;ocupacao;erros\n' > "$metricas"

# Ambas as organizações declaram cpu_top e usam bibliotecas separadas.
bash compilar_o1.sh "$o1"
"$ghdl" -a --std=08 --workdir="$o1" tb/{tb_cpu,tb_dmem,tb_pc,tb_sign_extend}.vhd
if ! "$somente_o1"; then
  "$ghdl" -a --std=08 --workdir="$o2" \
    o1/{alu,alu_control,control,dmem,imem,pc,regfile,sign_extend}.vhd \
    o2/{if_id,id_ex,ex_mem,mem_wb,hazard_unit,cpu_top_o2}.vhd tb/tb_cpu.vhd
fi

cd "$saida"
for unidade in dmem pc sign_extend; do
  "$ghdl" --elab-run --std=08 --workdir=o1 "tb_$unidade" --assert-level=error --stop-time=1us
done

simular() {
  local biblioteca="$1" org="$2" slots="$3" traco="$4"
  shift 4
  "$ghdl" --elab-run --std=08 --workdir="$biblioteca" tb_cpu \
    "-gORG_NOME=$org" "-gNUM_SLOTS=$slots" "-gPROG_FILE=../../tracos/$traco.hex" \
    "--wave=$biblioteca/$traco.ghw" \
    --assert-level=error --ieee-asserts=disable-at-0 "$@"
}

for tamanho in 36 5 10 20 50 100 200; do
  traco="s$tamanho"
  if [[ "$tamanho" == 36 ]]; then traco=t0; fi
  esperado="-gESPERADO_FILE=../../tracos/${traco}_esperado.txt"
  simular o1 O1 1 "$traco" "$esperado" \
    "-gINSTRUCOES_ESPERADAS=$tamanho" "-gCICLOS_ESPERADOS=$((tamanho + 1))"
  if ! "$somente_o1"; then
    simular o2 O2 5 "$traco" "$esperado" \
      "-gINSTRUCOES_ESPERADAS=$tamanho"
  fi
done

if ! "$somente_o1"; then
  simular o2 O2 5 td -gESPERA_ABORTO=true -gTIPO_ESPERADO=1 -gPC_ESPERADO=4
  simular o2 O2 5 te -gESPERA_ABORTO=true -gTIPO_ESPERADO=2 -gPC_ESPERADO=12 -gMEM_UNIFICADA=true
  simular o2 O2 5 tc -gESPERA_ABORTO=true -gTIPO_ESPERADO=3 -gPC_ESPERADO=0
fi

printf 'Métricas em %s e formas de onda em %s.\n' "$metricas" "$saida"
