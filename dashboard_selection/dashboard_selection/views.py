from django.http import HttpResponse, JsonResponse
from django.http import Http404
from django.template.loader import get_template
from django.template import Context
import json
from django.core.files.storage import default_storage
import os
from timeline.views import get_timeline
from progress.views import get_progress
from leaderboard.views import get_leaderboard


def home(request):
    t = get_template('main.html')
    return HttpResponse(t.render(Context({})))


def get_json(request, filename):
    with default_storage.open(os.path.join('dashboard_selection', 'data', filename), 'r') as f:
        data = json.load(f)
        return JsonResponse(data, safe=False)


def dashboard(request, student_id):
    t = get_template('student.html')
    timeline = get_timeline(student_id)
    progress = get_progress(student_id)
    leaderboard = get_leaderboard(student_id)
    return HttpResponse(t.render(Context({'student_id': student_id,
                                          'timeline': timeline.content,
                                          'progress': progress.content,
                                          'leaderboard': leaderboard.content})))
