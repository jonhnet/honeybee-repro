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

RUN python3 -m venv venv

COPY script1.sh /home/ubuntu/
RUN bash script1.sh

COPY script2.sh /home/ubuntu/
RUN bash script2.sh

# This step fetches 39GB of dataset from huggingface.co; let's try to keep
# changes *after* this point in the Dockerfile :vD
# (Or maybe we should move this step up to the beginning.)
# Getting here is about 11 minutes on my machine.
COPY script3.sh /home/ubuntu/
RUN bash script3.sh

COPY config.json /home/ubuntu/
COPY dotpgpass /home/ubuntu/.pgpass

COPY script4.sh /home/ubuntu/
RUN bash script4.sh

COPY script5.sh /home/ubuntu/
RUN bash script5.sh

COPY script6.sh /home/ubuntu/
RUN bash script6.sh

COPY script7.sh /home/ubuntu/
RUN bash script7.sh

COPY script8.sh /home/ubuntu/
RUN bash script8.sh

COPY script9.sh /home/ubuntu/
RUN bash script9.sh
