from django.shortcuts import render, get_object_or_404, redirect
from django import forms
from .models import Comment
from django.http import Http404
from django.views.generic import TemplateView, DetailView
from .helpers import (
    get_top_article,
    get_three_articles,
    get_data_from_file,
    get_article_by_uuid,
    get_three_quotes
)
import logging
logger = logging.getLogger(__name__)


class HomepageView(TemplateView):
    template_name = "articles/homepage.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        content_data = get_data_from_file()

        top_article = get_top_article(content_data['results'])
        context['top_article'] = top_article

        context['other_articles'] = get_three_articles(
            content_data['results'], context['top_article'])

        return context


class CommentForm(forms.ModelForm):
    class Meta:
        model = Comment
        fields = ['author_name', 'comment']


class ArticleView(DetailView):
    model = Comment
    template_name = "articles/article_detail.html"
    context_object_name = 'article'

    def get_object(self):
        """
        This method is used to retrieve the object that the view will display. 
        In our case, it's used to get the article with a matching UUID.
        """
        try:
            all_articles = get_data_from_file()['results']
            article_uuid = str(self.kwargs['article_uuid'])
            article = get_article_by_uuid(all_articles, article_uuid)
            if article:
                return article
            else:
                logger.error(f"Article with UUID {article_uuid} not found")
                # raise Http404("Article not found")
                # print(type(article_uuid)) This was used to check why the UUID was returning None
        except Exception as e:
            logger.error(f"Error getting article: {e}")
            # raise Http404("Article not found")

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)

        # Adding comments and form to the context
        context["comments"] = Comment.objects.filter(
            article_uuid=self.object['uuid'])
        context['comment_form'] = CommentForm()

        # Adding stock quotes to the context
        context['quotes'] = get_three_quotes()

        # Adding three random articles for quotebar
        context['headlines'] = get_three_articles(
            get_data_from_file()['results'], self.object)

        return context

    def post(self, request, *args, **kwargs):
        form = CommentForm(request.POST)
        if form.is_valid():
            comment = form.save(commit=False)
            comment.article_uuid = str(self.kwargs['article_uuid'])
            comment.save()
            return redirect('article', article_uuid=comment.article_uuid)
        return self.get(request, *args, **kwargs)


"""
My plan

To use in the individual article view:

URL schema: Use the value within path
To reach go through results>path>/investing/2017/11/10/is-goldman-sachs-stock-worth-a-look.aspx

Article Page
    content_api.json:results>headline
    content_api.json:results>authors>byline
    content_api.json:results>publish_at
    content_api.json:results>promo
    content_api.json:results>body

    Stock Quotes Sidebar
        This sidebar would show a quote for the stock mentioned in the article

        var insid = content_api.json:results>instruments>instrument_id
        return stock_quote from json dump of quotes_api.json, then iterate and retrieve where instrument_id = insid
        quotes_api.json:stock_quote.ExchangeName
        quotes_api.json:stock_quote.Symbol
        quotes_api.json:stock_quote.CompanyName
        quotes_api.json:stock_quote.MarketCap (make sure is rounded to billions)
        quotes_api.json:stock_quote.PercentChange>Value (Show percentage)
        quotes_api.json:stock_quote.Change>Amount (Show in USD)
        quotes_api.json:stock_quote.CurrentPrice>Amount (Show USD)

        Button > Onclick > Shuffle the order of some of the items in the quote
"""
