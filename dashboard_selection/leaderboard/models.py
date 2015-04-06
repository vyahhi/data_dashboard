from django.db import models


class CourseStats(models.Model):
    user = models.IntegerField(primary_key=True)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    position = models.IntegerField()
    total_score = models.FloatField()

