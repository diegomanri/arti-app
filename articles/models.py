from django.db import models


class Comment(models.Model):
    article_uuid = models.UUIDField()  # Linking to the uuid of the article
    comment = models.TextField(max_length=250, blank=False)
    created_at = models.DateTimeField(auto_now_add=True)
    # author = models.ForeignKey('auth.User', on_delete=models.CASCADE)
    author_name = models.CharField(max_length=100, blank=False)

    def __str__(self):
        return f"Comment by {self.author_name} on Article {self.article_uuid}"
