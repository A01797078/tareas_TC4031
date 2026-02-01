# Tarea 1. Programación de una solución paralela

El presente proyecto contiene código para ejemplificar el uso de paralelismo por medio de openmp

- `main.cpp`: contiene el código para sumar dos arreglos de manera paralela (si se compila con soporte de openmp)
- `Dockerfile`: es un archivo para generar un contenedor que compila el archivo para posteriormente ejecutarse con docker.
- `compile.sh`: permite compilar el archivo de manera manual si se tiene el compilador `g++`.
- `run.sh`: permite ejecutar el archivo compilado, y facilitar el paso de diversos argumentos.

## Compilación

### Desde Docker
```bash
docker build -t openmp-demo .
```

Se puede remover tanto openmp como los flags de optimización haciendo el build de la siguiente manera:

```bash
docker build --build-arg ENABLE_OMP=0 --build-arg ENABLE_OPTIMIZATION=0 -t openmp-demo .
```

### Desde consola, requiere g++ instalado
```bash
./compile.sh
```
Se puede remover tanto openmp como los flags de optimización haciendo el build de la siguiente manera:
```bash
./compile.sh --enable-omp 0 --enable-optimization 0
```
## Ejecución

### Desde Docker
Si se creo desde un contenedor
```bash
docker run --rm openmp-demo /app/run.sh --threads 4 --chunks 1024 --elems-in-array 1000000
```

### Desde consola
Si se compilo usando la consola:
```bash
./app/run.sh --threads 4 --chunks 1024 --elems-in-array 1000000
```