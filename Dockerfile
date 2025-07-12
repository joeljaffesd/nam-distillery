# Use Ubuntu as base image for better compatibility with build tools
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    clang \
    python3 \
    python3-pip \
    python3-dev \
    python3-tk \
    wget \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic link for python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Set working directory
WORKDIR /app

# Install NAM (Neural Amp Modeler) 
RUN pip3 install neural-amp-modeler

COPY . .

# Init submodules
RUN ./init.sh

# Try to build libsndfile from the Dependencies if it exists
RUN if [ -d "NeuralAmpModelerReamping/Dependencies/libsndfile" ]; then \
        cd NeuralAmpModelerReamping/Dependencies/libsndfile && \
        mkdir -p build && cd build && \
        cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && \
        make -j$(nproc) && \
        make install && \
        ldconfig; \
    else \
        echo "libsndfile not found in Dependencies, installing system package"; \
        apt-get update && apt-get install -y libsndfile1-dev; \
    fi

# Build the project
RUN ./build.sh

# Modify learn.json if GPU is not available
RUN if ! command -v nvidia-smi >/dev/null 2>&1 || ! nvidia-smi >/dev/null 2>&1; then \
        echo "No NVIDIA GPU detected, configuring NAM for CPU training..."; \
        echo "Note: If running on Apple Silicon, you may want to manually configure for MPS acceleration"; \
        sed -i.bak 's/"accelerator": "gpu"/"accelerator": "cpu"/' nam_full_config/learn.json && rm nam_full_config/learn.json.bak; \
    else \
        echo "NVIDIA GPU detected, keeping GPU configuration"; \
    fi

# Set default command
CMD ["bash"]

# Expose any ports if needed (uncomment when we add web interface)
# EXPOSE 8080

# Create volume for input/output files
VOLUME ["/app/models", "/app/output"]