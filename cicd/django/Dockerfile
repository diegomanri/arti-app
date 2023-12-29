# Stage 1: Build stage
# Use an official Python runtime as a parent image
FROM python:3.10.11-slim-buster AS builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Accept AWS credentials as build arguments
# These are coming from GitHub secrets
ARG DTEST_AWS_KEY_ID
ARG DTEST_AWS_KEY_SECRET
ARG PROD_DJANGO_KEY
ARG DTEST_DB_USER
ARG DTEST_DB_PASSWORD
#ARG DTEST_DB_HOST # I need to get this value at runtime
ARG DTEST_DB_NAME

# Set the environment variables
ENV PROD_DJANGO_SECRET_KEY=${PROD_DJANGO_KEY}
ENV AWS_ACCESS_KEY_ID=${DTEST_AWS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${DTEST_AWS_KEY_SECRET}
ENV DB_USER=${DTEST_DB_USER}
ENV DB_PASSWORD=${DTEST_DB_PASSWORD}
# ENV DB_HOST=${DTEST_DB_HOST} # I need to get this value at runtime
ENV DB_NAME=${DTEST_DB_NAME}

# Set Django settings module for production
ENV DJANGO_SETTINGS_MODULE=finarticles.settings.prod

# Set the working directory in the container
# All subsequent commands will be run from this directory
WORKDIR /app

# install python dependencies
RUN pip install --upgrade pip
RUN pip install pipenv pytest
COPY Pipfile* ./

# Generate requirements.txt from Pipfile.lock
RUN pipenv requirements > requirements.txt

# Install dependencies
RUN pip install -r requirements.txt

# Copy the current directory contents into the container
COPY . .

# Collect static files
# old - RUN pipenv run python manage.py collectstatic --noinput
RUN python manage.py collectstatic --noinput

# Stage 2: Run stage
FROM python:3.10.11-slim-buster

WORKDIR /app

# Copy only necessary files from the builder stage
COPY --from=builder /app .

# Run the application
# old - CMD ["pipenv", "run", "gunicorn", "--bind", "0.0.0.0:8001", "finarticles.wsgi:application"]
CMD ["gunicorn", "--bind", "0.0.0.0:8001", "finarticles.wsgi:application"]