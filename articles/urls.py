from articles import views
from django.urls import path

urlpatterns = [
    path('', views.HomepageView.as_view(), name='homepage'),
    path('article/<uuid:article_uuid>',
         views.ArticleView.as_view(), name='article'),
]
