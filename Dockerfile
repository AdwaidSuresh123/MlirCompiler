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
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Clone LLVM Project
# We clone the main branch to match version ~22.0.0git as requested
WORKDIR /tmp
RUN git clone --depth 1 https://github.com/llvm/llvm-project.git

# Build LLVM/MLIR
WORKDIR /tmp/llvm-project/build
RUN cmake -G Ninja ../llvm \
    -DLLVM_ENABLE_PROJECTS="mlir;clang" \
    -DLLVM_TARGETS_TO_BUILD="X86" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    && ninja \
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
    && rm -rf /var/lib/apt/lists/*

# Copy installed LLVM from the builder stage
COPY --from=llvm-builder /usr/local /usr/local

# Set up project directory
WORKDIR /app/mlir-compiler

# Copy project source code
COPY . .

# Build mlir-compiler
WORKDIR /app/mlir-compiler/build
RUN cmake -G Ninja .. \
    -DMLIR_DIR=/usr/local/lib/cmake/mlir \
    -DLLVM_DIR=/usr/local/lib/cmake/llvm \
    -DCMAKE_INSTALL_PREFIX=/opt/mlir-compiler \
    && ninja \
    && ninja install

# Set up environment variables for downstream usage
# We add the install prefix to CMAKE_PREFIX_PATH so find_package(mlir-compiler) works automatically
ENV CMAKE_PREFIX_PATH="/opt/mlir-compiler:/usr/local"
ENV PATH="/opt/mlir-compiler/bin:${PATH}"

# Default command
CMD ["/bin/bash"]
