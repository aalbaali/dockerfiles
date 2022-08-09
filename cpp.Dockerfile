##############################################
# C++ development docker file
##############################################

###########################################
# Base image 
###########################################
FROM ubuntu:22.04 AS base

ENV DEBIAN_FRONTEND=noninteractive

# Install language
RUN apt-get update && apt-get install -y \
  locales \
  && locale-gen en_US.UTF-8 \
  && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
  && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.UTF-8

# Install timezone
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y tzdata \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && rm -rf /var/lib/apt/lists/*

# Install C++ compilers
RUN apt-get update && apt-get install -y \
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
# RUN apt-get update && apt-get install -y \
#   bash-completion \
#   build-essential \
#   cmake \
#   gdb \
#   git \
#   pylint3 \
#   python3-argcomplete \
#   python3-colcon-common-extensions \
#   python3-pip \
#   python3-rosdep \
#   python3-vcstool \
#   vim \
#   wget \
#   # Install ros distro testing packages
#   ros-foxy-ament-lint \
#   ros-foxy-launch-testing \
#   ros-foxy-launch-testing-ament-cmake \
#   ros-foxy-launch-testing-ros \
#   python3-autopep8 \
#   && rm -rf /var/lib/apt/lists/* \
#   && rosdep init || echo "rosdep already initialized" \
#   # Update pydocstyle
#   && pip install --upgrade pydocstyle

ARG USERNAME=cpp
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create a non-root user
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  # [Optional] Add sudo support for the non-root user
  && apt-get update \
  && apt-get install -y sudo \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  # Cleanup
  && rm -rf /var/lib/apt/lists/* \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
  && echo "if [ -f /opt/ros/${ROS_DISTRO}/setup.bash ]; then source /opt/ros/${ROS_DISTRO}/setup.bash; fi" >> /home/$USERNAME/.bashrc
USER $USERNAME

ENV DEBIAN_FRONTEND=

###########################################
#  Full image 
###########################################
#FROM dev AS full

#ENV DEBIAN_FRONTEND=noninteractive
## Install the full release
#RUN apt-get update && apt-get install -y \
#  ros-foxy-desktop \
#  && rm -rf /var/lib/apt/lists/*
#ENV DEBIAN_FRONTEND=

############################################
##  Full+Gazebo image 
############################################
#FROM full AS gazebo

#ENV DEBIAN_FRONTEND=noninteractive
## Install gazebo
#RUN apt-get update && apt-get install -y \
#  ros-foxy-gazebo* \
#  && rm -rf /var/lib/apt/lists/*
#ENV DEBIAN_FRONTEND=

############################################
##  Full+Gazebo+Nvidia image 
############################################

#FROM gazebo AS gazebo-nvidia

#################
## Expose the nvidia driver to allow opengl 
## Dependencies for glvnd and X11.
#################
#RUN apt-get update \
# && apt-get install -y -qq --no-install-recommends \
#  libglvnd0 \
#  libgl1 \
#  libglx0 \
#  libegl1 \
#  libxext6 \
#  libx11-6

## Env vars for the nvidia-container-runtime.
#ENV NVIDIA_VISIBLE_DEVICES all
#ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute
#ENV QT_X11_NO_MITSHM 1
