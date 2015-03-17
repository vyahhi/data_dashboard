from django.template import Context
from django.shortcuts import render_to_response


def get_leaderboard(student_id):
    return render_to_response('leaderboard.html', Context({'student_id': student_id}))
