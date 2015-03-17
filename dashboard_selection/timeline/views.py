from django.template import Context
from django.shortcuts import render_to_response


def get_timeline(student_id):
    return render_to_response('timeline.html', Context({'student_id': student_id}))
