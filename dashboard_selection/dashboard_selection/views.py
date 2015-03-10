from django.http import HttpResponse, JsonResponse
from django.http import Http404
from django.template.loader import get_template
from django.template import Context
import json
from django.core.files.storage import default_storage
import os


def statistics(request):
    t = get_template('main.html')
    return HttpResponse(t.render(Context({})))


def get_json(request, filename):
    with default_storage.open(os.path.join('dashboard_selection', 'data', filename), 'r') as f:
        data = json.load(f)
        return JsonResponse(data, safe=False)


def dashboard(request, student_id):
    pass