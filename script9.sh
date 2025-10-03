# Initilize dynamic partition
# re-awaken postgresql for next docker build stage
sudo service postgresql start
source venv/bin/activate

# Run(HNSW index)
# emits .json files in the top directory with outputs.
python test_all.py --algorithm AnonySys --efs 20

python test_all.py --algorithm RLS --efs 20
