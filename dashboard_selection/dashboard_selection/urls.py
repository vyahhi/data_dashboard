from django.conf.urls import patterns, include, url
from django.contrib import admin
from dashboard_selection.views import statistics, get_json, dashboard

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'dashboard_selection.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    url(r'^$', statistics),
    url(r'^data/([a-z_.]+)$', get_json),
    url(r'^student/(\d+)$', dashboard)
)
