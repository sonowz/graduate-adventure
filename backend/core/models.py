from django.db import models


class Course(models.Model):
    year = models.CharField(max_length=4)
    semester = models.CharField(max_length=2)
    code = models.CharField(max_length=30)
    number = models.SmallIntegerField(null=True)
    title = models.CharField(max_length=40)
    credit = models.SmallIntegerField()
    category = models.CharField(max_length=10)
    language = models.CharField(max_length=20)
    area = models.CharField(max_length=30)
    subarea = models.CharField(max_length=30)
    collage = models.CharField(max_length=20)
    dept = models.CharField(max_length=20)

    class Meta:
        unique_together = (('year', 'semester', 'code', 'number'),)

    def __str__(self):
        return '{code} {title} - {number} ({year}) / {area}-{subarea}'.format(
            code=self.code,
            title=self.title,
            number=self.number,
            year=self.year,
            area=self.area,
            subarea=self.subarea,
        )


class Replace(models.Model):
    from_code = models.CharField(max_length=30)
    to_code = models.CharField(max_length=30)

    class Meta:
        unique_together = (('from_code', 'to_code'),)

    def __str__(self):
        return '{from_code} -> {to_code}'.format(
            from_code=self.from_code,
            to_code=self.to_code
        )
