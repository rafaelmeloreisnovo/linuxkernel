# ASM-first build profile (no external deps, sem quebrar)

Este perfil **não converte o kernel inteiro para ASM** (inviável sem quebrar ABI, drivers e subsistemas),
mas aplica o limite seguro possível para:

- priorizar caminhos nativos/baixo nível;
- reduzir fricção de toolchain;
- manter build reprodutível;
- não enfraquecer a trilha oficial de release.

## O que este perfil faz

O helper `scripts/asm-first-build.sh`:

1. seleciona uma `defconfig` explícita da arquitetura alvo;
2. desliga módulos (`CONFIG_MODULES=n`) para reduzir superfície dinâmica;
3. desliga BPF JIT (`CONFIG_BPF_JIT=n`) para reduzir caminho JIT/runtime;
4. desliga tracing/uprobes (`CONFIG_FTRACE=n`, `CONFIG_UPROBES=n`) para reduzir camadas de instrumentação;
5. mantém a build oficial do kernel (sem hacks de unsigned/release bypass);
6. executa `olddefconfig` para consistência e build com `vmlinux`.

## Uso

### x86_64 (padrão)

```bash
scripts/asm-first-build.sh
```

### arm64

```bash
ARCH=arm64 scripts/asm-first-build.sh
```

### Dry-run (sem compilar)

```bash
DRY_RUN=1 scripts/asm-first-build.sh
```

## Escopo e limite

- Este perfil é incremental e reversível.
- A fonte de verdade continua sendo Kconfig/Makefile oficial.
- Objetivo: **empurrar o sistema para o limite ASM/baixo nível possível sem quebrar**,
  em vez de forçar reescrita total insegura.
