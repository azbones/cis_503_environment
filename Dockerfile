# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
ARG BASE_CONTAINER=jupyter/scipy-notebook
FROM $BASE_CONTAINER

LABEL maintainer="Jupyter Project <jupyter@googlegroups.com>"

USER root

# R pre-requisites
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc && \
    rm -rf /var/lib/apt/lists/*

# Fix for devtools https://github.com/conda-forge/r-devtools-feedstock/issues/4
RUN ln -s /bin/tar /bin/gtar

USER $NB_UID

RUN cd /home/jovyan && \
    git clone https://github.com/azbones/cis503_data_science_tools.git && \
    git clone https://github.com/azbones/cis503_machine_learning.git

# R packages
RUN conda install --quiet --yes \
    'r-base=3.5.1' \
    'r-tidyverse=1.2*' \
    'tensorflow' \
    'r-caret=6.0*' \
    'r-e1071' \
    'pandas' \
    'scikit-learn' \
    'matplotlib' \
    'seaborn'

# only installs from conda forge
RUN conda install --quiet --yes -c conda-forge 'r-pracma'

RUN conda install --quiet --yes -c conda-forge 'r-scatterplot3d'

RUN conda install --quiet --yes 'r-irkernel=0.8*'

# setting R kernel manually
RUN R -e 'IRkernel::installspec()'

RUN conda clean --all -f -y #this is on own line

RUN fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER
