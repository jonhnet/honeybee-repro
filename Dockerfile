FROM ubuntu:noble-20250925
# System prerequisites -- pretty standard
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget curl apt-utils unzip git sudo
RUN sed -i '/%sudo/s/) ALL/) NOPASSWD:ALL/' /etc/sudoers

# AnonySys missing prerequisites -- add mentions of these to README?
RUN apt-get install -y python3.12-venv python3-dev git-lfs

# AnonySys README prerequisites
RUN apt-get install -y postgresql postgresql-contrib postgresql-server-dev-all build-essential libpq-dev

USER ubuntu

# Fetch the AnonySys repo
WORKDIR /home/ubuntu
RUN wget https://anonymous.4open.science/api/repo/VectorSearch-RBAC-7A0B/zip -O anonysys.zip
RUN unzip anonysys.zip

# Build & install pgvector
RUN git clone --branch v0.8.1 https://github.com/pgvector/pgvector.git
WORKDIR /home/ubuntu/pgvector
RUN make && sudo make install
WORKDIR /home/ubuntu
RUN rm -rf pgvector

# Setup Python Environment
RUN python3 -m venv venv
# Configure all future RUN commands to happen inside the venv
RUN echo 'source /home/ubuntu/venv/bin/activate' >> /home/ubuntu/.profile
SHELL ["/bin/bash", "-l", "-c"]
RUN pip install -r requirements.txt

# Setup embedding model
RUN python -m spacy download en_core_web_md

# Download Dataset
# This thing is sloooow because it fetches 39GB of dataset
RUN mkdir dataset
RUN cd dataset && git lfs install && git clone https://huggingface.co/datasets/Cohere/wikipedia-22-12

# (not in README) Set up database user & perms
RUN sudo service postgresql start && sudo -u postgres psql -c "CREATE USER rbac_user PASSWORD '123' SUPERUSER CREATEDB CREATEROLE;" && sudo -u postgres psql -c "CREATE DATABASE rbacdatabase_treebase;"
COPY config.json /home/ubuntu/
COPY dotpgpass /home/ubuntu/.pgpass

# Note that, henceforth, we have to prepend 'startsql' to each RUN, since
# services don't survive in docker images, only data.
RUN echo 'sudo service postgresql start' >> startsql
RUN chmod 755 startsql

# Prepare Data
RUN ./startsql && (cd basic_benchmark && python3 common_prepare_pipeline.py)
#  
#  RUN ./startsql && (cd controller && python3 initialize_main_tables.py)
#  
#  # Generate Permission
#  RUN ./startsql && (cd services/rbac_generator && python3 store_tree_based_rbac_generate_data.py)
#  
#  # Initilize partition and prepare for queries
#  RUN ./startsql && (cd basic_benchmark && python3 initialize_role_partition_tables.py)
#  # skipping "(optional)" step at author's suggestion
#  # generate queries
#  RUN ./startsql && (cd basic_benchmark && python3 generate_queries.py --num_queries 1000 --topk 10 --num_threads 4)
#  
#  # Initilize dynamic partition
#  # README: "if needed, delete parameter_hnsw.json from hnsw directory to regenerate parameters"
#  # TODO(hongbin): I think this is where we got stuck on curve_fit, and you
#  # supplied a parameter_hnsw.json to skip over it. But we should get this
#  # working so that the source code is documentation, not a magical parameter
#  # file of undocumented origin.)
#  RUN ./startsql && (cd controller/dynamic_partition/hnsw; python3 AnonySys_dynamic_partition.py --storage 2.0 --recall 0.95)
#  
#  # Run(HNSW index)
#  # NOTE: these experiment runs emit .json files in the top directory with outputs.
#  RUN ./startsql && python test_all.py --algorithm AnonySys --efs 20 && python test_all.py --algorithm RLS --efs 20
