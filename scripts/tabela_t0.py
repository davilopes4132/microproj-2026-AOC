"""Tabela do traço: endereço, instrução, registradores lidos e escritos e
distância até o produtor mais próximo (em instruções, na ordem executada).

Uso: python scripts/tabela_t0.py tracos/t0.asm

Supõe execução sequencial (o beq do T0 não é tomado). Leituras e escritas em
$zero não criam dependência. Na O2, distância 1 ou 2 é conflito de dados.
"""
import re
import sys

R = {"add", "sub", "and", "or", "slt"}


def regs(instr):
    op, *resto = instr.replace(",", " ").split()
    a = [x for x in resto]
    num = lambda r: int(r.strip("$")) if r.strip("$").isdigit() else 0  # $zero -> 0
    if op in R:
        return op, [num(a[1]), num(a[2])], [num(a[0])]
    if op == "addi":
        return op, [num(a[1])], [num(a[0])]
    if op in ("lw", "sw"):
        base = num(re.search(r"\((.*)\)", a[1]).group(1))
        return op, ([base] if op == "lw" else [base, num(a[0])]), ([num(a[0])] if op == "lw" else [])
    if op == "beq":
        return op, [num(a[0]), num(a[1])], []
    return op, [], []


def main():
    lista = []
    for l in open(sys.argv[1], encoding="utf-8"):
        l = l.split("#")[0].strip()
        if not l or l.startswith("."):
            continue
        if ":" in l:
            l = l.split(":", 1)[1].strip()
            if not l:
                continue
        lista.append(re.sub(r"\s+", " ", l))
    ultimo = {}
    executa = True
    print("Endereço;Instrução;Lê;Escreve;Distância ao produtor")
    for k, ins in enumerate(lista):
        op, le, escreve = regs(ins)
        le = [r for r in le if r != 0]
        escreve = [r for r in escreve if r != 0]
        dist = [k - ultimo[r] for r in le if r in ultimo]
        d = str(min(dist)) if dist and executa else "—"
        fmt = lambda rs: ", ".join(f"${r}" for r in rs) or "—"
        nota = "" if executa else " (não executada)"
        print(f"0x{4*k:02X};{ins}{nota};{fmt(le)};{fmt(escreve)};{d}")
        if executa:
            for r in escreve:
                ultimo[r] = k
        if op == "break":
            executa = False


if __name__ == "__main__":
    main()
