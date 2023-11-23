# Use an official Python runtime as a parent image
FROM python:3.10.11-slim-buster

# Set the working directory in the container
WORKDIR /app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Copy the Pipfile and Pipfile.lock into the container at /app
COPY Pipfile Pipfile.lock /app/

# Install Pipenv and project dependencies
RUN pip install pipenv && pipenv install --deploy --ignore-pipfile

# Copy the current directory contents into the container at /app
COPY . /app

# Uncomment below line for debugging purpose
# CMD ["tail", "-f", "/dev/null"]

# Copy entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh

# Set script as entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Run the application - Will be running this from entrypoint.sh
# CMD ["pipenv", "run", "gunicorn", "--bind", "0.0.0.0:8000", "finarticles.wsgi:application"]
