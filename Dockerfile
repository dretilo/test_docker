FROM ubuntu:focal
# initial packages install
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y \
  software-properties-common \
  tzdata locales \
  python3 python3-dev python3-pip python3-venv \
  gcc make git openssh-server curl \
  && rm -rf /var/lib/apt/lists/*
# replace SH with BASH
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
# Locales gen
RUN ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime \
  && dpkg-reconfigure --frontend noninteractive tzdata \
  && export LC_ALL="fr_FR.UTF-8" \
  && export LC_CTYPE="fr_FR.UTF-8" \
  && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
  && echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen \
  && locale-gen \
  && dpkg-reconfigure --frontend noninteractive locales
# SSH run folder
RUN mkdir -p /run/sshd
# create python venv
RUN mkdir -p /venv \
  && python3 -m venv /venv/
# Install jupyterlab and its plotly extension
RUN /venv/bin/pip3 install --upgrade pip --no-cache-dir \
    jupyterlab \
    ipywidgets>=7.5 \
    ipython \
    ipykernel \
    xeus-python \
    ptvsd \
    plotly \
  && curl -sL https://deb.nodesource.com/setup_15.x | bash \
  && export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y nodejs \
  && rm -rf /var/lib/apt/lists/* \
  && /venv/bin/jupyter labextension install jupyterlab-plotly@4.14.3 @jupyter-widgets/jupyterlab-manager plotlywidget@4.14.3 --no-build \
  && /venv/bin/jupyter labextension install @jupyterlab/debugger --no-build \
  && /venv/bin/jupyter lab build \
  && /venv/bin/jupyter lab clean \
  && /venv/bin/jlpm cache clean \
  && npm cache clean --force \
  && rm -rf $HOME/.node-gyp \
  && rm -rf $HOME/.local
# install all other required python packages
RUN /venv/bin/pip3 install --no-cache-dir \
    pandas \
    xlrd \
    numpy \
    scipy \
    matplotlib \
    scikit-learn \
    openpyxl \
    beautifulsoup4 \
    Pillow \
    graphviz \
    lxml \
    python-dateutil \
    pylint \
    requests_html \
    dash \
    dash_daq \
    dash-bootstrap-components \
    gunicorn \
    SQLAlchemy \
    alembic \
    dpkt \
    gpsd-py3 \
    h5py  
# Install Miniconda et création environnement pour inférence imagettes
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  && chmod +x Miniconda3-latest-Linux-x86_64.sh \  
  && bash Miniconda3-latest-Linux-x86_64.sh -p /root/conda -b \
  && rm -rf Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/root/conda/bin:${PATH}
ADD env_ia_full.yml ./env_ia.yml
RUN conda create --name env_ia --file env_ia.yml \
  && rm -rf env_ia.yml \
  && conda clean --all -y
