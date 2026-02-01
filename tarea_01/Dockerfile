FROM gcc:14

ARG ENABLE_OMP=1
ARG ENABLE_OPTIMIZATION=1

WORKDIR /app
COPY main.cpp /app/main.cpp
COPY compile.sh /app/compile.sh
COPY run.sh /app/run.sh

RUN chmod +x /app/compile.sh
RUN chmod +x /app/run.sh

RUN /app/compile.sh --enable-omp ${ENABLE_OMP} --enable-optimization ${ENABLE_OPTIMIZATION}
