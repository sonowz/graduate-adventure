from django.db import models


class Course(models.Model):
    year = models.CharField(max_length=4)
    semester = models.CharField(max_length=2)
    code = models.CharField(max_length=30)
    number = models.SmallIntegerField(null=True)
    title = models.CharField(max_length=40)
    credit = models.SmallIntegerField()
    category = models.CharField(max_length=10)
    language = models.SmallIntegerField()
    area = models.CharField(max_length=30)
    subarea = models.CharField(max_length=30)
    collage = models.CharField(max_length=20)
    dept = models.CharField(max_length=20)
