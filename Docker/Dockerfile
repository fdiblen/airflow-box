FROM apache/airflow:2.2.5
USER root

# Tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget curl git

# Geant4 dependencies
RUN apt-get install -y --no-install-recommends \
    build-essential cmake automake g++ \
    libexpat1-dev libxmu-dev libmotif-dev zlib1g-dev libxerces-c-dev \
    libeigen3-dev libcoin-dev

# ROOT6 dependencies
RUN apt-get install -y --no-install-recommends \
    dpkg-dev cmake g++ gcc binutils \
    libx11-dev libxpm-dev libxft-dev libxext-dev libssl-dev libpng-dev libjpeg-dev

# Clean up
RUN apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER airflow
WORKDIR /home/airflow/

COPY ./scripts /tmp/scripts/
RUN mkdir -p /home/airflow/software
RUN cd /home/airflow/software && \
    bash /tmp/scripts/install_geant4.bash
RUN cd /home/airflow/software && \
    bash /tmp/scripts/install_root6.bash
RUN rm -rfv \
    /home/airflow/software/root/src \
    /home/airflow/software/geant4/src \
    /tmp/scripts
