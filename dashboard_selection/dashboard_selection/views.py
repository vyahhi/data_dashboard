from django.http import HttpResponse, JsonResponse
from django.http import Http404
from django.template.loader import get_template
from django.template import Context
from django.core.files.storage import default_storage
import os
from timeline.views import get_timeline
from progress.views import get_progress
from leaderboard.views import get_leaderboard
import json
from leaderboard.views import get_leaderboard_json
from timeline.views import get_timeline_json
from dashboard_selection.models import GradesCoursegrade


def home(request):
    t = get_template('main.html')
    students = list(GradesCoursegrade.objects.all().filter(course=67).values('user_id'))
    return HttpResponse(t.render(Context({'student_ids': students,
                                          'curr_student_id': "null"})))


def get_json(request, filename):
    with default_storage.open(os.path.join('dashboard_selection', 'data', filename), 'r') as f:
        data = json.load(f)
        return JsonResponse(data, safe=False)


def dashboard(request, student_id):
    t = get_template('student.html')
    # timeline = get_timeline(student_id, request.path + "/timeline.json?course=67")
    timeline = get_timeline(student_id, get_timeline_json(request, student_id))
    progress = get_progress(student_id)
    # leaderboard = get_leaderboard(student_id, request.path + "/leaderboard.json?course=67")
    leaderboard = get_leaderboard(student_id, get_leaderboard_json(request, student_id))
    students = list(GradesCoursegrade.objects.all().filter(course=67).values('user_id'))
    return HttpResponse(t.render(Context({'student_ids': students,
                                          'curr_student_id': student_id,
                                          'timeline': timeline.content,
                                          'progress': progress.content,
                                          'leaderboard': leaderboard.content})))


def get_leaderboard_data(request, student_id):
    return get_leaderboard_json(request, student_id)


def get_timeline_data(request, student_id):
    return get_timeline_json(request, student_id)