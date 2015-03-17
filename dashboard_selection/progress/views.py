from django.template import Context
from django.shortcuts import render_to_response


def get_progress(student_id):
    return render_to_response('progress.html', Context({'student_id': student_id}))
