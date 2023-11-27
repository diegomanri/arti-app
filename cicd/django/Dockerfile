# Use an official Python runtime as a parent image
FROM python:3.10.11-slim-buster

# Set the working directory in the container
WORKDIR /app

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Copy the Pipfile and Pipfile.lock into the container at /app
COPY Pipfile Pipfile.lock /app/

# Install Pipenv and project dependencies
RUN pip install pipenv && pipenv install --deploy --ignore-pipfile

# Copy the current directory contents into the container at /app
COPY . /app

# Collect static files
RUN pipenv run python manage.py collectstatic --noinput

# Run the application
CMD ["pipenv", "run", "gunicorn", "--bind", "0.0.0.0:8001", "finarticles.wsgi:application"]
