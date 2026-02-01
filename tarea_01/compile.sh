#!/bin/bash

# Ejecutar con Docker
#   docker build -t openmp-demo .
#   docker run --rm openmp-dem
# Se puede remover tanto openmp como los flags de optimización haciendo el build 
# de la siguiente manera:
#   docker build --build-arg ENABLE_OMP=0 --build-arg ENABLE_OPTIMIZATION=0 -t openmp-demo .

# Ejecutar desde consola, requiere g++ instalado
# ./compile.sh
# Se puede remover tanto openmp como los flags de optimización haciendo el build 
# de la siguiente manera:
#   ./compile.sh --enable-omp 0 --enable-optimization 0

ENABLE_OPENMP=1
ENABLE_OPTIMIZATION=1
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -o|--enable-omp)
            ENABLE_OPENMP="$2"
            shift 2
        ;;
        -c|--enable-optimization)
            ENABLE_OPTIMIZATION="$2"
            shift 2
        ;;
        *)
        echo "Unknown option: $1"
        shift
        ;;
    esac
done

OPENMP_FLAG=-fopenmp
OPTIMIZATION_FLAG=-O2

if [ "$ENABLE_OPENMP" -eq 0 ]; then
  echo "Compiling with openmp disabled"
  OPENMP_FLAG=""
fi

if [ "$ENABLE_OPTIMIZATION" -eq 0 ]; then
  echo "Disable optimization"
  ENABLE_OPTIMIZATION=""
fi

g++ $OPTIMIZATION_FLAG -std=c++17 $OPENMP_FLAG main.cpp -o app
