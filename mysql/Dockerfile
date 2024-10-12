# Use the official MySQL image as the base
FROM mysql:8.0

# Copy the initialization SQL script to the container
COPY init.sql /docker-entrypoint-initdb.d/

# Set environment variables
ENV MYSQL_ROOT_PASSWORD=rootpassword
ENV MYSQL_DATABASE=betting_db
ENV MYSQL_USER=nifiuser
ENV MYSQL_PASSWORD=nifipassword
