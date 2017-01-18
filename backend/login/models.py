from django.db import models


class LoginData(models.Model):
    user_id = models.CharField(max_length=20)
    password = models.CharField(max_length=20)
