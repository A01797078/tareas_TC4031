#!/usr/bin/env bash
set -e

# =========================================================
# Valores por defecto
# =========================================================
DISK="disk_debian.qcow2"
DISK_SIZE="15G"
ISO=""
MEMORY="4G"
CPUS="4"
SSH_PORT="2222"
HTTP_PORT="8080"

ACTION="$1"
shift || true

# =========================================================
# Argumentos
# =========================================================
while [[ $# -gt 0 ]]; do
  case "$1" in
    --disk)
      DISK="$2"
      shift 2
      ;;
    --disk-size)
      DISK_SIZE="$2"
      shift 2
      ;;
    --iso)
      ISO="$2"
      shift 2
      ;;
    --memory)
      MEMORY="$2"
      shift 2
      ;;
    --cpus)
      CPUS="$2"
      shift 2
      ;;
    --ssh-port)
      SSH_PORT="$2"
      shift 2
      ;;
    --http-port)
      HTTP_PORT="$2"
      shift 2
      ;;
    --help)
      echo "Uso:"
      echo "  $0 create --disk DISK --disk-size SIZE --iso ISO [--memory MEM --cpus N]"
      echo "  $0 run    --disk DISK [--memory MEM --cpus N]"
      exit 0
      ;;
    *)
      echo "Opción desconocida: $1"
      exit 1
      ;;
  esac
done

# =========================================================
# Validación básica
# =========================================================
if [[ -z "$ACTION" ]]; then
  echo "Debes especificar una acción: create | run"
  exit 1
fi


# =========================================================
# CREATE: crear disco + instalar desde ISO
# =========================================================
if [[ "$ACTION" == "create" ]]; then
  if [[ -z "$ISO" ]]; then
    echo "Error: debes especificar una ISO con --iso"
    exit 1
  fi

  echo "Creando disco virtual $DISK ($DISK_SIZE)"
  qemu-img create \
    -f qcow2 \
    "$DISK" \
    "$DISK_SIZE"

  echo "Iniciando instalación del sistema operativo"
  qemu-system-x86_64 \
    -enable-kvm \
    -m "$MEMORY" \
    -smp "$CPUS" \
    -hda "$DISK" \
    -cdrom "$ISO" \
    -boot d

  exit 0
fi

# =========================================================
# RUN: ejecutar VM ya instalada con soporte de red
# =========================================================
if [[ "$ACTION" == "run" ]]; then
  if [[ ! -f "$DISK" ]]; then
    echo "Error: el disco $DISK no existe"
    exit 1
  fi

  echo "Ejecutando máquina virtual"
  qemu-system-x86_64 \
    -enable-kvm \
    -m "$MEMORY" \
    -smp "$CPUS" \
    -hda "$DISK" \
    -netdev user,id=net0,hostfwd=tcp::${SSH_PORT}-:22,hostfwd=tcp::${HTTP_PORT}-:80 \
    -device virtio-net-pci,netdev=net0

  exit 0
fi

echo "Acción inválida: $ACTION"
exit 1
