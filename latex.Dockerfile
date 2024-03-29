##############################################
# LaTeX container for development
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

# Set time zone
ENV TZ="Canada/Eastern"
RUN date

# Install texlive
RUN apt-get update && apt-get install -y --no-install-recommends \
    texlive \
    latexmk \
    git \
    make \
    ssh \
  && rm -rf /var/lib/apt/lists/*

# Set user name
ARG USERNAME=latex
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
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc

# Create a development directory
RUN mkdir -p ~/Dev

ENV DEBIAN_FRONTEND=

###########################################
#  Full latexmk image
###########################################
FROM base AS full

ARG USERNAME
ARG USER_UID
ARG USER_GID

ENV DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get update \
  && sudo apt-get install -y --no-install-recommends \
     zathura      \
     okular       \
     mupdf        \
     xdotool      \
     wget         \
     texlive-full \
  && sudo rm -rf /var/lib/apt/lists/* 

ENV DEBIAN_FRONTEND=

###########################################
#  Develop image 
###########################################
FROM full AS dev

ARG USERNAME
ARG USER_UID
ARG USER_GID

ENV DEBIAN_FRONTEND=noninteractive
RUN sudo apt-get update \
  && sudo apt-get install -y --no-install-recommends \
  zsh \
  build-essential \
  gdb \
  neovim \
  python3-pip \
  && sudo rm -rf /var/lib/apt/lists/* 

# Install fzf
RUN git clone https://github.com/junegunn/fzf.git ~/Dev/external/fzf \
      && cd ~/Dev/external/fzf \
      && ./install --all

# Clone custom workstation setup and setup packages
RUN git clone https://github.com/aalbaali/workstation_setup.git ~/Dev/workstation_setup \
      && cd ~/Dev/workstation_setup \
      && sudo ./scripts/install_packages.sh \
      && rm ~/.bashrc \
      && rm ~/.zshrc \
      && if [ -f ~/.gitconfig ]; then rm ~/.gitconfig; fi \
      && ./scripts/post_install_setup.sh \
          --zsh \
          --zsh-setup \
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
