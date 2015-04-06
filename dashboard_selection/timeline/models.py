from django.db import models


class UserProgress(models.Model):
    date = models.DateField(primary_key=True)
    video_per_day = models.FloatField()
    video = models.FloatField()
    problem_per_day = models.FloatField()
    problem = models.FloatField()
    active = models.IntegerField()