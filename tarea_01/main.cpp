#include <iostream>
#include <vector>
#include <cstdlib>
#include <algorithm>
#include <chrono>

#ifdef _OPENMP
  // include omp library to get max number of threads if enabled
  #include <omp.h>
#endif

static std::size_t parse_size(const char* s, std::size_t def) {
    if (!s) return def;
    try { return static_cast<std::size_t>(std::stoull(s)); }
    catch (...) { return def; }
}

static int parse_int(const char* s, int def) {
    if (!s) return def;
    try { return std::stoi(s); }
    catch (...) { return def; }
}

static double now_sec() {
#ifdef _OPENMP
    // use omp time functions
    return omp_get_wtime();
#else
    // use standard library functions to calculate time
    using clock = std::chrono::steady_clock;
    return std::chrono::duration<double>(clock::now().time_since_epoch()).count();
#endif
}

void print_debug_information() {
// prints iformation about running mode (if supports openmp or not)
// and some other data related to openm when enabled
#ifdef _OPENMP
    std::cout << "mode=openmp" << std::endl;
    const char* omp_env_var = std::getenv("OMP_NUM_THREADS");
    if (omp_env_var != nullptr) {
        std::cout << "OMP_NUM_THREADS is set to: " << omp_env_var << std::endl;
    } else {
        std::cout << "OMP_NUM_THREADS is not set. Using default" << std::endl;
    }
#else
    std::cout << "mode=serial" << std::endl;
#endif
}

void print_first_elements(const std::vector<float>& a,
                          const std::vector<float>& b,
                          const std::vector<float>& c,
                          std::size_t max_elems = 10) {
    const std::size_t n = std::min({a.size(), b.size(), c.size(), max_elems});

    std::cout << "i\t a[i]\t\t b[i]\t\t c[i] = a[i] + b[i]\n";
    for (std::size_t i = 0; i < n; ++i) {
        std::cout << i << "\t "
                  << a[i] << "\t "
                  << b[i] << "\t "
                  << c[i] << "\n";
    }
}

int main(int argc, char** argv) {
    // Uso:
    //   ./app [N] [chunk]
    //  
    // NOTA: el número de threads puede configurarse con OMP_NUM_THREADS si se compila con -fopenmp
    //
    // Ejemplos:
    //   ./app 10000000 1024 # crea 10M elementos y divide en chunks de 1024 elementos
    //   ./app 5000 100      # crea 5K elementos y divide en chunks of 100 elementos
    //
    // Valores por defecto:
    // N     = 10,000,000
    // chunk = 128
    // threads = si OMP_NUM_THREADS no es definida como variable de entorno
    //          utiliza todos los hilos disponibles.
    //          - https://hpc-wiki.info/hpc/How_to_Use_OpenMP#:~:text=an%20OpenMP%20Application-,Setting%20OMP_NUM_THREADS,value:%20$%20export%20OMP_NUM_THREADS=24

    const std::size_t N = parse_size(argc > 1 ? argv[1] : nullptr, 10'000'000);
    const int chunk     = parse_int(argc > 2 ? argv[2] : nullptr, 128);

    if (N <= 0) {
        std::cerr << "N debe ser mayor a 0" << std::endl;
        return 1;
    }
    if (chunk <= 0) {
        std::cerr << "chunk debe ser mayor a 0" << std::endl;
    }

    std::vector<float> a(N), b(N), c(N);

    for (std::size_t i = 0; i < N; ++i) {
        a[i] = 0.001f * static_cast<float>(i % 1000);
        b[i] = 0.002f * static_cast<float>((i * 7) % 1000);
    }

    const double t0 = now_sec();
    constexpr int ITER = 200;

    #pragma omp parallel for schedule(static, chunk)
    for (std::size_t i = 0; i < N; ++i) {

        // trabajo artificial, para ver el poder de openmp
        // el problema original de solo sumar se llega a ver limitado por el acceso
        // a memoria (memory-bound) por lo que se agrega un for extra para que
        // quede un tiempo en el procesador.
        // NOTA: se ejecuta solo cuando se compila sin optimización
        for (int k = 0; k < ITER; ++k) {
        }

        c[i] = a[i] + b[i];
    }

    const double t1 = now_sec();

    print_debug_information();

    std::cout << "N=" << N << " chunk=" << chunk << " time_sec=" << (t1 - t0) << "\n";

    print_first_elements(a, b, c);

    return 0;
}