from django.http import JsonResponse
from django.template import Context
from django.shortcuts import render_to_response
from timeline.models import UserProgress


def get_timeline_json(request, student_id):
    course_id = int(request.GET.get('course'))
    timeline = UserProgress.objects.raw("""
        SELECT date, video_per_day,
               (@cum_sum_video := @cum_sum_video + video_per_day) AS video,
               problem_per_day,
               (@cum_sum_problem := @cum_sum_problem + problem_per_day) AS problem,
               1 AS active
        FROM (SELECT @cum_sum_video := 0, @cum_sum_problem := 0) init
        JOIN (
            SELECT DATE(progress_stepprogress.when_viewed) AS date,
                   SUM(IF(lessons_step.title LIKE 'T%%', 1, 0)) AS video_per_day,
                   SUM(IF(lessons_step.title LIKE 'Q%%', 1, 0)) AS problem_per_day
            FROM progress_stepprogress
               JOIN lessons_step ON progress_stepprogress.step_id = lessons_step.id
               JOIN lessons_lesson ON lessons_step.lesson_id = lessons_lesson.id
               JOIN courses_unit ON lessons_lesson.id = courses_unit.lesson_id
               JOIN courses_section ON courses_unit.section_id = courses_section.id
            WHERE courses_section.course_id = %(course)s
                AND user_id = %(user)s
                AND progress_stepprogress.when_passed is not NULL
            GROUP BY date ASC
        ) t
        """, params={'course': course_id, 'user': student_id})
    return JsonResponse({str(student_id): [{'date': r.date,
                                            'videoPerDay': float(r.video_per_day),
                                            'video': float(r.video),
                                            'problemPerDay': float(r.problem_per_day),
                                            'problem': float(r.problem),
                                            'active': r.active}
                                           for r in timeline]})


def get_timeline(student_id, data_path):
    return render_to_response('timeline.html', Context({'student_id': student_id,
                                                        'path': data_path}))
