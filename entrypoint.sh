#!/bin/bash

# Wait for database to be ready (optional, useful in some cases)
# wait-for-it db:5432 --timeout=30

# Apply database migrations
echo "Applying database migrations..."
pipenv run python manage.py migrate --noinput

# Collect static files
echo "Collecting static files..."
pipenv run python manage.py collectstatic --noinput --clear

# Start Gunicorn server
pipenv run gunicorn finarticles.wsgi:application --bind 0.0.0.0:8000