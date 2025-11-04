FROM pytorch/pytorch:2.4.0-cuda12.4-cudnn9-runtime
MAINTAINER Simone Riggi "simone.riggi@gmail.com"

######################################
##   DEFINE CUSTOMIZABLE ARGS/ENVS
######################################
ARG USER_ARG=caesar
ENV USER $USER_ARG

ENV PYTHONPATH_BASE ${PYTHONPATH}

#################################
###    CREATE DIRS
#################################	
# - Define env variables
ENV SOFTDIR=/opt/software
ENV CAESAR_YOLO_SRC_DIR=${SOFTDIR}/caesar-yolo
ENV CAESAR_YOLO_URL=https://github.com/SKA-INAF/caesar-yolo.git
ENV MODEL_DIR=/opt/models
	
# - Create src dir	
RUN mkdir -p ${SOFTDIR} && mkdir -p ${MODEL_DIR}

##########################################################
##     INSTALL SYS LIBS
##########################################################
# - Install OS packages
RUN apt-get update && apt-get install -y software-properties-common curl bzip2 unzip nano build-essential git fuse libgl1

# - Install OpenMPI
RUN apt-get update && apt-get install -y openmpi-bin libopenmpi-dev

# - Install python & pip
RUN apt-get install -y python3 python3-dev python3-pip
RUN pip install -U pip

##########################################################
##     CREATE USER
##########################################################
# - Create user & set permissions
RUN adduser --disabled-password --gecos "" $USER && \
    mkdir -p /home/$USER && \
    chown -R $USER:$USER /home/$USER
    
######################################
##     INSTALL RCLONE
######################################
# - Allow other non-root users to mount fuse volumes
RUN sed -i "s/#user_allow_other/user_allow_other/" /etc/fuse.conf

# - Install rclone
RUN curl https://rclone.org/install.sh | bash

######################################
##     INSTALL CAESAR-YOLO
######################################
# - Install caesar yolo dependencies
RUN pip install "numpy" "numpyencoder" "future" "astropy" "fitsio" "pandas" "scikit-image" "Pillow" "ultralytics" "matplotlib" "mpi4py"

# - Download caesar-yolo from github repo
WORKDIR ${SOFTDIR}
RUN git clone ${CAESAR_YOLO_URL}

WORKDIR ${CAESAR_YOLO_SRC_DIR}
RUN git pull origin main

# - Compile and install
WORKDIR ${CAESAR_YOLO_SRC_DIR}
RUN python setup.py build && python setup.py install

