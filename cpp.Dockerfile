##############################################
# C++ development docker file
##############################################

###########################################
# Base image 
###########################################
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install language
RUN apt-get update && apt-get install -y --no-install-recommends \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/EST /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

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

ARG USERNAME=cpp
ARG USER_UID=1000
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
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
  && echo "if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc

# Set user to non-root user
USER $USERNAME

# Create a development directory
RUN mkdir -p ~/Dev

# Install latest stable eigen release
RUN git config --global http.sslverify false \
    && git clone https://gitlab.com/libeigen/eigen.git ~/Dev/external/eigen \
    && cd ~/Dev/external/eigen \
    && mkdir build && cd build \
    && cmake .. \
    && sudo make install \
    && git config --global http.sslverify false 

ENV DEBIAN_FRONTEND=

###########################################
#  Develop image 
###########################################
FROM base AS dev

ARG USERNAME
ARG USER_UID
ARG USER_GID

ENV DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get update \
  && sudo apt-get install -y --no-install-recommends \
  clangd \
  zsh \
  bash-completion \
  build-essential \
  cmake \
  gdb \
  vim \
  neovim \
  wget \
  python3-pip \
  && sudo rm -rf /var/lib/apt/lists/* 

# Install fzf
RUN git clone https://github.com/junegunn/fzf.git ~/Dev/external/fzf \
      && cd ~/Dev/external/fzf \
      && ./install --all

# Clone workstation setup
RUN git clone https://github.com/aalbaali/workstation_setup.git ~/Dev/workstation_setup \
      && cd ~/Dev/workstation_setup \
      && ./scripts/install_packages.sh

RUN cd ~/Dev/workstation_setup \
      && rm ~/.bashrc >/dev/null \
      && rm ~/.zshrc >/dev/null \
      && rm ~/.gitconfig >/dev/null \
      && ./scripts/post_install_setup.sh \
          --zsh \
          --bash \
          --functions \
          --git \
          --nvim \
          --nvim-setup \
          --clang_format \
          --gdb \
          --tmux \
          --tmux-setup

ENV DEBIAN_FRONTEND=

CMD ["zsh"]
###########################################
#  opencv layer
###########################################
from dev AS opencv

ARG USERNAME
ARG USER_UID
ARG USER_GID

ENV DEBIAN_FRONTEND=noninteractive

RUN sudo apt-get update \
  && sudo apt-get install -y \
    libopencv-dev \
    python3-opencv \
  && sudo rm -rf /var/lib/apt/lists/* 

ENV DEBIAN_FRONTEND=

CMD ["zsh"]
