ARG BASE_IMAGE="ubuntu:22.04"
FROM --platform=$TARGETPLATFORM condaforge/mambaforge:latest as build

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
RUN printf "I'm building for TARGETPLATFORM=${TARGETPLATFORM}" \
    && printf ", TARGETARCH=${TARGETARCH}" \
    && printf ", TARGETVARIANT=${TARGETVARIANT} \n" \
    && printf "With uname -s : " && uname -s \
    && printf "and  uname -m : " && uname -m

# Install conda-pack in base environment
RUN mamba install -c conda-forge conda-pack -y

# Create environment with build dependencies (NOT the entwine package itself)
RUN mamba create -n entwine -c conda-forge \
    libpdal-core compilers cmake ninja \
    xz curl openssl -y

ENV CONDA_ENV_NAME="entwine"
ENV CONDAENV="/opt/conda/envs/${CONDA_ENV_NAME}"

# Copy source code from the build context (the repository)
COPY . /src

# Build entwine from source
SHELL ["conda", "run", "-n", "entwine", "/bin/bash", "-c"]

RUN cd /src && mkdir build && cd build && \
    cmake .. \
        -G Ninja \
        -DCMAKE_PREFIX_PATH=${CONDAENV} \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX=${CONDAENV} \
        -DWITH_TESTS=OFF && \
    ninja install

# Package the environment with conda-pack
SHELL ["conda", "run", "-n", "base", "/bin/bash", "-c"]

RUN conda-pack -n ${CONDA_ENV_NAME} --dest-prefix=/var/task -o /tmp/env.tar && \
     mkdir /venv && cd /venv && tar xf /tmp/env.tar  && \
     rm /tmp/env.tar

FROM --platform=$TARGETPLATFORM ${BASE_IMAGE:?} as al2

ARG BASE_IMAGE
ARG TARGETPLATFORM
ARG TARGETARCH

ENV CONDAENV "/var/task"
ENV CONDA_PREFIX "/var/task"
ENV TARGETPLATFORM "${TARGETPLATFORM}"
COPY --from=build /venv ${CONDAENV}


ENV PROJ_LIB ${CONDAENV}/share/proj
ENV PROJ_NETWORK=TRUE
ENV PATH $PATH:${CONDAENV}/bin
ENV LD_LIBRARY_PATH=${CONDAENV}/lib

SHELL [ "/bin/bash", "--login", "-c" ]

ENTRYPOINT ["entwine"]
