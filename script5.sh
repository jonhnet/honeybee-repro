# Prepare Data (2/2)
# re-awaken postgresql for next docker build stage
sudo service postgresql start
source venv/bin/activate
(cd controller && python3 initialize_main_tables.py)

