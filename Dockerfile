# Stage 1: Build LLVM/MLIR from source
# We use a multi-stage build to keep the final image cleaner, though LLVM itself is huge.
FROM ubuntu:22.04 AS llvm-builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    clang \
    lld \
    git \
    python3 \
    ccache \
    zlib1g-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Clone LLVM Project
# We clone the main branch and checkout the specific commit that matches the local environment
WORKDIR /tmp
RUN git clone https://github.com/llvm/llvm-project.git
WORKDIR /tmp/llvm-project
RUN git checkout 28c9452420d51610721c6b7f7ead30e92185bcd7

# Build LLVM/MLIR
WORKDIR /tmp/llvm-project/build
RUN cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir" \
    -DLLVM_TARGETS_TO_BUILD="Native;X86;NVPTX" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DLLVM_CCACHE_BUILD=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    && ninja -j12 \
    && ninja install

# Stage 2: Build and Run mlir-compiler
FROM ubuntu:22.04

# Install runtime and build dependencies for the project
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    clang \
    lld \
    git \
    python3 \
    build-essential \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy installed LLVM from the builder stage
COPY --from=llvm-builder /usr/local /usr/local

# Set up project directory
WORKDIR /app/mlir-compiler

# Copy project source code
COPY . .

# Build mlir-compiler
WORKDIR /app/mlir-compiler/build
RUN cmake .. \
    -DMLIR_DIR=/usr/local/lib/cmake/mlir \
    -DLLVM_DIR=/usr/local/lib/cmake/llvm \
    -DCMAKE_INSTALL_PREFIX=/opt/mlir-compiler \
    && make  

# Set up environment variables for downstream usage
# We add the install prefix to CMAKE_PREFIX_PATH so find_package(mlir-compiler) works automatically
ENV CMAKE_PREFIX_PATH="/opt/mlir-compiler:/usr/local"
ENV PATH="/opt/mlir-compiler/bin:${PATH}"

# Default command
CMD ["/bin/bash"]
