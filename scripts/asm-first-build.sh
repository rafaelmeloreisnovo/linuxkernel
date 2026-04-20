#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

ARCH_NAME="${ARCH:-x86_64}"
JOBS="${JOBS:-$(nproc)}"
DRY_RUN="${DRY_RUN:-0}"

case "$ARCH_NAME" in
  x86_64) DEFCONFIG="x86_64_defconfig" ;;
  arm64|aarch64) ARCH_NAME="arm64"; DEFCONFIG="defconfig" ;;
  riscv|riscv64) ARCH_NAME="riscv"; DEFCONFIG="defconfig" ;;
  *)
    echo "[asm-first] ARCH '$ARCH_NAME' não suportada por este helper" >&2
    exit 2
    ;;
esac

run() {
  echo "+ $*"
  if [[ "$DRY_RUN" != "1" ]]; then
    "$@"
  fi
}

cat > .config.asm-first.fragment <<'CFG'
CONFIG_MODULES=n
CONFIG_BPF_JIT=n
CONFIG_FTRACE=n
CONFIG_UPROBES=n
CFG

echo "[asm-first] ARCH=$ARCH_NAME DEFCONFIG=$DEFCONFIG JOBS=$JOBS DRY_RUN=$DRY_RUN"

run make ARCH="$ARCH_NAME" "$DEFCONFIG"
run ./scripts/kconfig/merge_config.sh -m .config .config.asm-first.fragment
run make ARCH="$ARCH_NAME" olddefconfig
run make -j"$JOBS" ARCH="$ARCH_NAME" vmlinux

echo "[asm-first] build concluída"
