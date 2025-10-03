# Prepare Data (1/2)
# need this script to run "atomically" in Dockerfile, because
# services (postgresql) don't stay "alive" across image snapshots
sudo service postgresql start
source venv/bin/activate
sudo -u postgres psql -c "CREATE USER rbac_user PASSWORD '123' SUPERUSER CREATEDB CREATEROLE;"
sudo -u postgres psql -c "CREATE DATABASE rbacdatabase_treebase;"

(cd basic_benchmark && python3 common_prepare_pipeline.py)
