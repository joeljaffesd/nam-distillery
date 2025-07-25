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

# Clone project manually instead of COPY for better cross-platform compatibility
RUN git clone --recursive https://github.com/joeljaffesd/nam-distillery

# Set working directory
WORKDIR /nam-distillery

# Install NAM (Neural Amp Modeler) 
RUN pip3 install neural-amp-modeler

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

# Create a startup script that detects GPU at runtime
RUN echo '#!/bin/bash\n\
# Check GPU availability at runtime and configure accordingly\n\
if ! command -v nvidia-smi >/dev/null 2>&1 || ! nvidia-smi >/dev/null 2>&1; then\n\
    echo "No NVIDIA GPU detected, configuring NAM for CPU training..."\n\
    echo "Note: If running on Apple Silicon, you may want to manually configure for MPS acceleration"\n\
    sed -i.bak "s/\"accelerator\": \"gpu\"/\"accelerator\": \"cpu\"/" nam_full_config/learn.json && rm nam_full_config/learn.json.bak 2>/dev/null || true\n\
else\n\
    echo "NVIDIA GPU detected, ensuring GPU configuration"\n\
    sed -i.bak "s/\"accelerator\": \"cpu\"/\"accelerator\": \"gpu\"/" nam_full_config/learn.json && rm nam_full_config/learn.json.bak 2>/dev/null || true\n\
fi\n\
\n\
# Execute the original command\n\
exec "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

# Set entrypoint and default command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]

# Expose any ports if needed (uncomment when we add web interface)
# EXPOSE 8080

# Create volume for input/output files
VOLUME ["/app/models", "/app/output"]