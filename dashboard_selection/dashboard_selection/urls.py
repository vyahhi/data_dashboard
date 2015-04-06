from django.conf.urls import patterns, url
from dashboard_selection.views import *

urlpatterns = patterns('',
    url(r'^$', home),
    url(r'^data/([a-z_.]+)$', get_json),
    url(r'^student/(\d+)$', dashboard),
    url(r'^student/(\d+)/leaderboard\.json$', get_leaderboard_data),
    url(r'^student/(\d+)/timeline\.json$', get_timeline_data)
)
