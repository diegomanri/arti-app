import json
import os
import random
import logging
import datetime
from django.utils.timezone import make_aware
logger = logging.getLogger(__name__)


def load_json_file(filename):
    """
    This function takes a filename as input and returns the contents of the file as a JSON object.
    """
    with open(filename, 'r') as file:
        data = json.load(file)
    return data


def get_article_by_uuid(articles, uuid_to_search):
    """
    This function takes a list of articles and a UUID as inputs and returns the article with the matching UUID.

    Args:
        articles (list): A list of article dictionaries.
        uuid_to_search (str): The UUID of the article to search for.

    Returns:
        dict: The article with the matching UUID or None if no match is found.
    """
    for article in articles:
        if article.get('uuid') == uuid_to_search:
            return article
    return None


def get_top_article(articles):
    """
    This function takes a list of articles as input and returns the first article 
    that has a tag with the slug '10-promise'.
    """
    return next(
        (item for item in articles
         if isinstance(item, dict)
         and item.get('tags')
         and '10-promise' in [tag['slug'] for tag in item['tags']]),
        None
    )


def get_three_articles(articles, excluded_article, num_articles=3):
    """
    Returns a new list of three articles that excludes the top article.

    Args:
        articles (list): A list of articles.
        excluded_article (str): The article to exclude from the list.
        num_articles (int, optional): Number of articles to return. Default is 3.


    Returns:
        list: A list of three random articles from the input list, excluding the selected article. If the input list has less than three articles, it returns the entire list.

    """
    articles__minus_excluded = [
        item for item in articles
        if item != excluded_article
    ]

    three_random_articles = random.sample(articles__minus_excluded, num_articles) if len(
        articles__minus_excluded) > 2 else articles__minus_excluded

    return three_random_articles


def format_percentage(value):
    """Helper function to format a decimal as a percentage."""
    if value is not None:
        return f"{value * 100:.3f}%"
    return ""


def get_three_quotes():
    """
    Returns three random quotes from quotes_api.json.
    """
    all_quotes = get_data_from_file('quotes_api.json')

    # Format the percentage for display
    for quote in all_quotes:
        if 'PercentChange' in quote and 'Value' in quote['PercentChange']:
            quote['FormattedPercentChange'] = format_percentage(
                quote['PercentChange']['Value'])

    # Select three random quotes if there are enough
    if len(all_quotes) >= 3:
        return random.sample(all_quotes, 3)
    else:
        # If there are fewer than three quotes, return all of them.
        return all_quotes


def get_data_from_file(filename='content_api.json'):
    """
    This function returns the contents of a JSON file located in the 'app_data' directory
     relative to the current file.
    """
    try:
        base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        content_file = os.path.join(base_dir, 'app_data', filename)
        data = load_json_file(content_file)

        # Process each article in the results
        if 'results' in data:
            for article in data['results']:
                # Convert the publish_at string to a datetime object
                publish_at_naive = datetime.datetime.strptime(
                    article["publish_at"], "%Y-%m-%dT%H:%M:%SZ")
                # Make it timezone aware (the 'Z' indicates UTC)
                article["publish_at"] = make_aware(publish_at_naive)

        return data
    except Exception as e:
        logger.error(f"Error getting data from {filename}: {e}")
        return {}
