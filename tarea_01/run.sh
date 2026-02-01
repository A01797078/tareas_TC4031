#!/bin/bash

# Ejecuta el archivo compilado de main.cpp generado con compile.sh
# el ejecutable se llama `app`
# Se puede invocar con varios parametros:
#   --elems-in-array configura dinámicamente la cantidad de elementos
#     de los arreglo que se van a sumar
#   --chunks partes del arreglo que le tocarán sumar a cada hilo
#   --threads cantidad de hilos a usar (si se compilo con soporte de openmp)
#     opcionalmente puede usarse la variable de entorno: OMP_NUM_THREADS
# Ejemplo:
#  Genera arreglos de 10,000 elementos, habra dos hilos ejecutando 
#  en secciones de 10 en 10
#    ./run.sh --elems-in-array 10000 --chunks 10 --threads 2

ELEMS_IN_ARRAY=10000000
CHUNKS=128

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -n|--elems-in-array)
            ELEMS_IN_ARRAY="$2"
            shift 2
        ;;
        -c|--chunks)
            CHUNKS="$2"
            shift 2
        ;;
        -t|--threads)
            THREADS="$2"
            shift 2
        ;;
        *)
        echo "Unknown option: $1"
        shift
        ;;
    esac
done

if [ ! -z "$THREADS" ]; then
    export OMP_NUM_THREADS=$THREADS
    echo "setting specific number of threads"
fi

./app $ELEMS_IN_ARRAY $CHUNKS
