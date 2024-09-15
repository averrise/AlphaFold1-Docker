# Use an official Python runtime as a parent image
FROM ubuntu:20.04

# Set environment variables to noninteractive to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install required system dependencies
RUN apt-get update && apt-get install -y \
    python3.8 python3.8-dev python3-pip \
    git cmake make gcc g++ \
    wget tar octave liboctave-dev \
    && apt-get clean

# Install Python packages
RUN pip3 install --upgrade pip && \
    pip3 install torch>=1.3 numpy scipy argparse

# Clone and build HH-suite
RUN git clone https://github.com/soedinglab/hh-suite.git \
    && mkdir -p hh-suite/build && cd hh-suite/build \
    && cmake -DCMAKE_INSTALL_PREFIX=. .. \
    && make -j 4 && make install \
    && export PATH="$(pwd)/bin:$(pwd)/scripts:$PATH"

# Clone plmDCA_asymmetric_v3 and setup
RUN git clone https://github.com/mskwark/plmDCA_asymmetric_v3.git \
    && cd plmDCA_asymmetric_v3 \
    && octave --eval "mexAll"

# Copy the required files into the container
COPY ./alphafold.py /plmDCA_asymmetric_v3/
COPY ./alphafold.sh /plmDCA_asymmetric_v3/
COPY ./dataset.py /plmDCA_asymmetric_v3/
COPY ./feature.py /plmDCA_asymmetric_v3/
COPY ./feature.sh /plmDCA_asymmetric_v3/
COPY ./network.py /plmDCA_asymmetric_v3/
COPY ./plmDCA.m /plmDCA_asymmetric_v3/
COPY ./README.md /plmDCA_asymmetric_v3/
COPY ./utils.py /plmDCA_asymmetric_v3/
COPY ./utils.py /plmDCA_asymmetric_v3/
COPY ./model /plmDCA_asymmetric_v3/model
COPY ./test_data /plmDCA_asymmetric_v3/test_data
COPY ./test_out /plmDCA_asymmetric_v3/test_out
# Set the working dictory
WORKDIR /plmDCA_asymmetric_v3

# Set the PATH for HH-suite
ENV PATH="/hh-suite/build/bin:/hh-suite/build/scripts:${PATH}"

# Default command
CMD ["/bin/bash"]
