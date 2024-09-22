FROM gitpod/workspace-full

# Re-synchronize the OS package index
RUN sudo apt-get update

# Install all needed packages for all tools
RUN sudo apt-get install -y git perl make autoconf g++ flex bison
RUN sudo rm -rf /var/lib/apt/lists/*

# Install Verilator
ENV VERILATOR_VER=v4.218
RUN git clone https://github.com/verilator/verilator.git --branch ${VERILATOR_VER} verilator \
    && unset VERILATOR_ROOT \
    && cd verilator \
    && autoconf \
    && ./configure \
    && make --silent \
    && sudo make --silent install \
    && cd .. \
    && rm -rf verilator

# Install Verible
ENV VERIBLE_VER=v0.0-3724-gdec56671
RUN wget -q https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VER}/verible-${VERIBLE_VER}-linux-static-x86_64.tar.gz -o verible.tar.gz \
    && tar xzf verible.tar.gz \
    && sudo cp -r verible-${VERIBLE_VERSION}/bin/* /usr/local/bin/ \
    && rm -rf verible-${VERIBLE_VERSION} verible.tar.gz