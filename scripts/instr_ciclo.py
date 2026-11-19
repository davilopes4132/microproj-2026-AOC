"""Diagrama instrução × ciclo a partir de um VCD do tb_cpu (GHDL --vcd).

Uso: python scripts/instr_ciclo.py <o1|o2> <arquivo.vcd> <traco.asm> [primeiras] [ultimas]

Amostra os sinais na descida de clk, como o testbench, do ciclo 1 (primeiro após
o reset) até o ciclo em que done = 1, inclusive. Na O2, o estágio WB herda o PC
que estava em MEM no ciclo anterior, porque o MEM/WB não carrega o PC.
"""
import re
import sys


def ler_vcd(caminho, nomes):
    ids, escopo, valores, amostras = {}, [], {}, []
    with open(caminho, encoding="utf-8") as f:
        linhas = f.read().split("\n")
    i = 0
    for i, l in enumerate(linhas):
        if l.startswith("$scope"):
            escopo.append(l.split()[2])
        elif l.startswith("$upscope"):
            escopo.pop()
        elif l.startswith("$var"):
            p = l.split()
            nome = ".".join(escopo + [p[4].split("[")[0]])
            if nome in nomes:
                ids[p[3]] = nome
        elif l.startswith("$enddefinitions"):
            break
    clk_ant = None
    for l in linhas[i + 1:]:
        if not l or l[0] == "$":
            continue
        if l[0] == "#":
            continue
        if l[0] == "b":
            v, ident = l[1:].split()
        else:
            v, ident = l[0], l[1:]
        if ident not in ids:
            continue
        nome = ids[ident]
        valores[nome] = v
        if nome == "tb_cpu.clk":
            if clk_ant == "1" and v == "0" and valores.get("tb_cpu.rst") == "0":
                amostras.append(dict(valores))  # descida de clk
            clk_ant = v
    return amostras


def instrucoes(asm):
    lista = []
    for l in open(asm, encoding="utf-8"):
        l = l.split("#")[0].strip()
        if not l or l.startswith("."):
            continue
        if ":" in l:
            l = l.split(":", 1)[1].strip()
            if not l:
                continue
        lista.append(re.sub(r"\s+", " ", l))
    return {4 * k: s for k, s in enumerate(lista)}


def hexa(v):
    return int(v, 2) if set(v) <= {"0", "1"} else None


def main():
    org, vcd, asm = sys.argv[1:4]
    primeiras = int(sys.argv[4]) if len(sys.argv) > 4 else 10
    ultimas = int(sys.argv[5]) if len(sys.argv) > 5 else 3
    d = "tb_cpu.dut."
    if org == "o1":
        nomes = {"tb_cpu.clk", "tb_cpu.rst", "tb_cpu.done", d + "pc"}
    else:
        nomes = {"tb_cpu.clk", "tb_cpu.rst", "tb_cpu.done"} | {d + s for s in (
            "pc_if", "pc_id", "pc_ex", "pc_mem", "valid_if", "valid_id", "valid_ex", "valid_mem", "valid_wb")}
    amostras = ler_vcd(vcd, nomes)
    fim = next(k for k, a in enumerate(amostras) if a.get("tb_cpu.done") == "1")
    amostras = amostras[:fim + 1]
    texto = instrucoes(asm)
    tabela = {}  # pc -> {ciclo: estágio}
    ordem = []
    def marca(pc, ciclo, est):
        if pc not in tabela:
            tabela[pc] = {}
            ordem.append(pc)
        tabela[pc][ciclo] = est
    mem_ant = None
    for c, a in enumerate(amostras, start=1):
        if org == "o1":
            marca(hexa(a[d + "pc"]), c, "IF-WB")
            continue
        for est, s in (("IF", "if"), ("ID", "id"), ("EX", "ex"), ("MEM", "mem")):
            if a.get(d + "valid_" + s) == "1":
                marca(hexa(a[d + "pc_" + s]), c, est)
        if a.get(d + "valid_wb") == "1" and mem_ant is not None:
            marca(mem_ant, c, "WB")
        mem_ant = hexa(a[d + "pc_mem"]) if a.get(d + "valid_mem") == "1" else None
    escolhidas = ordem[:primeiras] + (["..."] if len(ordem) > primeiras + ultimas else []) + ordem[-ultimas:]
    if len(ordem) <= primeiras + ultimas:
        escolhidas = ordem
    ciclos = sorted({c for pc in escolhidas if pc != "..." for c in tabela[pc]})
    print(f"# {org.upper()}: {len(ordem)} instruções, {len(amostras)} ciclos (done no ciclo {len(amostras)})")
    print("PC;Instrução;" + ";".join(f"C{c}" for c in ciclos))
    for pc in escolhidas:
        if pc == "...":
            print("...;...;" + ";".join("" for _ in ciclos))
            continue
        print(f"0x{pc:02X};{texto.get(pc, '?')};" + ";".join(tabela[pc].get(c, "") for c in ciclos))


if __name__ == "__main__":
    main()
