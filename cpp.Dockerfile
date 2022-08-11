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
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y --no-install-recommends tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

# Install C++ compilers
RUN apt-get update && apt-get install -y --no-install-recommends \
    apt-utils \
    sudo \
    build-essential \
    gcc \
    g++ \
    clang \
    cmake \
    make \
  && rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=

###########################################
#  Develop image 
###########################################
FROM base AS dev

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
  clangd \
  zsh \
  bash-completion \
  build-essential \
  cmake \
  gdb \
  git \
  vim \
  neovim \
  wget \
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

# Install fzf
RUN git clone https://github.com/junegunn/fzf.git ~/Dev/fzf \
      && cd ~/Dev/fzf \
      && ./install --all

# Clone workstation setup
RUN git clone https://github.com/aalbaali/workstation_setup.git ~/Dev/workstation_setup \
      && cd ~/Dev/workstation_setup \
      && sudo ./scripts/install_packages.sh

RUN cd ~/Dev/workstation_setup \
      && rm ~/.bashrc \
      && rm ~/.zshrc \
      && ./scripts/post_install_setup.sh \
          --zsh \
          --bash \
          --functions \
          --git \
          --nvim \
          --nvim-setup \
          --clang_format \
          --gdb


ENV DEBIAN_FRONTEND=

CMD ["zsh"]

