# Generate Permission
# re-awaken postgresql for next docker build stage
sudo service postgresql start
source venv/bin/activate
# note README points out we're selecting "treebased" here, not other rbac shapes.
(cd services/rbac_generator && python3 store_tree_based_rbac_generate_data.py)
