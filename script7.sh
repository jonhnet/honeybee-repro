# Initilize partition and prepare for queries
# re-awaken postgresql for next docker build stage
sudo service postgresql start
source venv/bin/activate

# initialize role partition
(cd basic_benchmark && python3 initialize_role_partition_tables.py)

# skipping "(optional)" step at author's suggestion

# generate queries
(cd basic_benchmark && python3 generate_queries.py --num_queries 1000 --topk 10 --num_threads 4)
