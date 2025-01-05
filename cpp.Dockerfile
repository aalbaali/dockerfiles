##############################################
# C++ development docker file
##############################################

###########################################
# Base image 
###########################################
FROM ubuntu:22.04 AS base

ARG DEBIAN_FRONTEND=noninteractive

# Set timezone
ENV TZ="America/New_York"

# Install timezone
RUN export DEBIAN_FRONTEND=noninteractive \
 && apt-get update \
 && apt-get install -y --no-install-recommends tzdata \
 && dpkg-reconfigure --frontend noninteractive tzdata \
 && rm -rf /var/lib/apt/lists/* \
 && ln -fs /usr/share/zoneinfo/EST /etc/localtime 

# Install language
RUN apt-get update && apt-get install -y --no-install-recommends \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# Install C++ compilers
RUN apt-get update && apt-get install -y --no-install-recommends \
    dialog \
    ssh \
    apt-utils \
    sudo \
    build-essential \
    gcc \
    g++ \
    clang \
    cmake \
    make \
    git \
  && rm -rf /var/lib/apt/lists/*

ARG USERNAME="dev"
ENV USERNAME=$USERNAME
ENV USER=$USERNAME

ARG USER_UID=1001
ARG USER_GID=$USER_UID

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # [Optional] Add sudo support for the non-root user
  && apt-get update \
  && apt-get install -y --no-install-recommends sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  # Cleanup
  && rm -rf /var/lib/apt/lists/* \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc

# Set user to non-root user
USER $USERNAME

# Create a development directory
RUN mkdir -p ~/Dev

# Install latest stable eigen release
ARG EIGEN_VERSION=3.4.0
RUN git config --global http.sslverify false \
    && git clone https://gitlab.com/libeigen/eigen.git -b $EIGEN_VERSION ~/Dev/external/eigen \
    && cd ~/Dev/external/eigen \
    && mkdir build && cd build \
    && cmake .. \
    && sudo make install \
    && git config --global http.sslverify false 

###########################################
#  Develop image 
###########################################
FROM base AS dev

ARG USERNAME
ARG USER_UID
ARG USER_GID

RUN sudo apt-get update \
  && sudo apt-get install -y --no-install-recommends \
  clangd \
  zsh \
  bash-completion \
  build-essential \
  cmake \
  gdb \
  vim \
  wget \
  python3-pip \
  curl \
  ca-certificates \
  && sudo rm -rf /var/lib/apt/lists/* 

# Install fzf
RUN git clone https://github.com/junegunn/fzf.git ~/Dev/external/fzf \
      && cd ~/Dev/external/fzf \
      && ./install --all

# Install my workstation setup
RUN curl -sS https://raw.githubusercontent.com/aalbaali/workstation_setup/master/clone_and_run_dev_playbook | bash -

# Run zsh to initialize
USER $USERNAME

CMD ["zsh"]

###########################################
#  opencv layer
###########################################
from dev AS opencv

ARG USERNAME
ARG USER_UID
ARG USER_GID

RUN sudo apt-get update \
  && sudo apt-get install -y \
    libopencv-dev \
    python3-opencv \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
  && sudo rm -rf /var/lib/apt/lists/* 

CMD zsh
