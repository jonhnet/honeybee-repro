# Initilize dynamic partition
# re-awaken postgresql for next docker build stage
sudo service postgresql start
source venv/bin/activate
# initilize dynamic
# if needed, delete parameter_hnsw.json from hnsw directory to regenerate parameters
# TODO(hongbin): I think this is where we got stuck on curve_fit, and you
# supplied a parameter_hnsw.json to skip over it. But we should get this
# working so that the source code is documentation, not a magical parameter
# file of undocumented origin.)
(cd controller/dynamic_partition/hnsw; python3 AnonySys_dynamic_partition.py --storage 2.0 --recall 0.95)
