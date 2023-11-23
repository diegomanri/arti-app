#!/bin/bash

# Exit in case of error
set -e

# adding to ensure we are using the correct settings file
export DJANGO_SETTINGS_MODULE=finarticles.settings.dev

# Check for Python 3 and Pip installation
if ! command -v python3 &>/dev/null; then
    echo "Python 3 could not be found. Please install it."
    exit 1
fi

if ! command -v pip &>/dev/null; then
    echo "pip could not be found. Please install it."
    exit 1
fi

# Install pipenv using pip
echo "Installing pipenv..."
pip install --user pipenv

# Navigate to the project directory where the Pipfile exists
cd "$(dirname "$0")"

# Install project dependencies from Pipfile.lock
echo "Installing dependencies from Pipfile.lock..."
pipenv sync

# Enter the pipenv environment
echo "Spawning a shell within the pipenv environment..."
pipenv shell

# Apply migrations
echo "Applying database migrations..."
pipenv run python manage.py migrate

# Collect static files
echo "Collecting static files..."
pipenv run python manage.py collectstatic --noinput

# Create a superuser for the Django admin (optional)
# Uncomment the following line if you want to create a superuser interactively
# pipenv run python manage.py createsuperuser

echo "Setup completed successfully. You can now run the development server."
