from .base import *
import dj_database_url
# import boto3
from articles.helpers import get_secret, get_parameter


# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get('PROD_DJANGO_SECRET_KEY')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = False

# Using a wildcard for now, until I can get a domain name
ALLOWED_HOSTS = ['*']

# Serving static files from S3
STATICFILES_STORAGE = 'storages.backends.s3boto3.S3Boto3Storage'
AWS_STORAGE_BUCKET_NAME = 'artiapp-staticfiles-bucket'
AWS_S3_REGION_NAME = 'us-east-1'

# Fetching database credentials
db_username = get_parameter('rds_username')
db_password = get_secret('rds_password')
db_host = get_parameter('rds_host')
db_name = get_parameter('rds_db_name')

# Configure DATABASES setting
DATABASES = {
    'default': dj_database_url.config(default=f'postgres://{db_username}:{db_password}@{db_host}/{db_name}')
}

# Media files
# MEDIA_ROOT = os.path.join(BASE_DIR, 'media')
# MEDIA_URL = '/media/'

# Email settings
# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# EMAIL_HOST = os.environ.get('EMAIL_HOST')
# EMAIL_PORT = os.environ.get('EMAIL_PORT')
# EMAIL_USE_TLS = True
# EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER')
# EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD')
# DEFAULT_FROM_EMAIL = os.environ.get('DEFAULT_FROM_EMAIL')
