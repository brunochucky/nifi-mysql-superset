# Use the official Apache Superset image as the base
FROM apache/superset:latest

# Install netcat using the correct package name
USER root
RUN apt-get update && apt-get install -y netcat-openbsd

# Set environment variables for Superset
ENV SUPERSET_DB_URI=mysql://nifiuser:nifipassword@mysql:3306/betting_db
ENV SECRET_KEY='U2FsdGVkX1/zRH9FkkcPvZT9d8bx3BjbjEvHP8S0XtLdVsKzPu4='

# Copy the custom Superset configuration file
COPY superset_config.py /app/pythonpath/superset_config.py

# Set the Superset configuration path
ENV SUPERSET_CONFIG_PATH /app/pythonpath/superset_config.py

# Use the custom entrypoint script
ENTRYPOINT ["/app/superset_home/docker-entrypoint.sh"]
