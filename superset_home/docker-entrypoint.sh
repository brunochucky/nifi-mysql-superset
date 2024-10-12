#!/bin/bash
# Custom entrypoint script for Superset

# Function to detect Windows environment and use winpty if necessary
use_winpty() {
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    echo "Running on Windows environment, using winpty for compatibility..."
    winpty "$@"
  else
    "$@"
  fi
}

# Wait for MySQL service to be ready using Netcat with a timeout of 60 seconds
echo "Waiting for MySQL to be ready..."
timeout=60
elapsed=0
while ! nc -z mysql 3306; do
  echo "Waiting for MySQL on host 'mysql' and port 3306... ($elapsed/$timeout)"
  sleep 2
  elapsed=$((elapsed + 2))
  if [ $elapsed -ge $timeout ]; then
    echo "MySQL service did not start in time. Exiting..."
    exit 1
  fi
done
echo "MySQL is ready."

# Run Superset database migrations and setup
echo "Running Superset database migrations..."
use_winpty superset db upgrade

# Create default roles and permissions
echo "Initializing Superset roles and permissions..."
use_winpty superset init

# Create an admin user (modify username and password as needed)
if [ "$SUPERSET_ADMIN_USER" ] && [ "$SUPERSET_ADMIN_PASSWORD" ]; then
  echo "Creating admin user..."
  use_winpty superset fab create-admin \
      --username "$SUPERSET_ADMIN_USER" \
      --firstname Superset \
      --lastname Admin \
      --email "$SUPERSET_ADMIN_EMAIL" \
      --password "$SUPERSET_ADMIN_PASSWORD" || true
else
  echo "Admin credentials are not set. Skipping admin user creation."
fi

# Start the Superset server
echo "Starting Superset..."
superset run -h 0.0.0.0 -p 8088 --with-threads --reload --debugger
