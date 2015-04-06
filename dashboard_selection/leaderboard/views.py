from django.http import JsonResponse
from django.template import Context
from django.shortcuts import render_to_response
from leaderboard.models import CourseStats


def get_leaderboard_json(request, student_id):
    course_id = request.GET.get('course')
    rating = CourseStats.objects.raw("""
        SELECT position, user_id AS user, first_name, last_name, score AS total_score
        FROM
        (
            SELECT ROW_NUMBER() AS position, user_id, first_name, last_name, score, when_last_passed
            FROM
            (
                SELECT t.user_id AS user_id, first_name, last_name,
                       grades_coursegrade.score AS score, when_last_passed
                FROM
                (
                    SELECT progress_stepprogress.user_id AS user_id,
                           MAX(progress_stepprogress.when_passed) AS when_last_passed
                    FROM progress_stepprogress
                       JOIN lessons_step ON progress_stepprogress.step_id = lessons_step.id
                       JOIN lessons_lesson ON lessons_step.lesson_id = lessons_lesson.id
                       JOIN courses_unit ON lessons_lesson.id = courses_unit.lesson_id
                       JOIN courses_section ON courses_unit.section_id = courses_section.id
                    WHERE courses_section.course_id = %(course)s
                    GROUP BY progress_stepprogress.user_id
                ) as t
                JOIN grades_coursegrade ON t.user_id = grades_coursegrade.user_id
                JOIN users_user ON t.user_id = users_user.id
                WHERE grades_coursegrade.course_id = %(course)s
                ORDER BY score DESC, when_last_passed ASC
            ) AS t2
        ) AS rating_t
        WHERE position <= 3 OR 3 >= abs(position - (SELECT rating_t.position FROM (
                    SELECT ROW_NUMBER() AS position, user_id, score
                    FROM
                    (
                        SELECT t.user_id AS user_id, grades_coursegrade.score AS score
                        FROM
                        (
                            SELECT progress_stepprogress.user_id AS user_id,
                                   MAX(progress_stepprogress.when_passed) AS when_last_passed
                            FROM progress_stepprogress
                               JOIN lessons_step ON progress_stepprogress.step_id = lessons_step.id
                               JOIN lessons_lesson ON lessons_step.lesson_id = lessons_lesson.id
                               JOIN courses_unit ON lessons_lesson.id = courses_unit.lesson_id
                               JOIN courses_section ON courses_unit.section_id = courses_section.id
                            WHERE courses_section.course_id = %(course)s
                            GROUP BY progress_stepprogress.user_id
                        ) as t
                        JOIN grades_coursegrade ON t.user_id = grades_coursegrade.user_id
                        WHERE grades_coursegrade.course_id = %(course)s
                        ORDER BY score DESC, when_last_passed ASC
                    ) AS t2
                ) AS rating_t WHERE user_id = %(user)s))
        """, params={'course': course_id, 'user': student_id})
    return JsonResponse(dict(score_rating=[{'rating': r.position,
                                            'user': r.user,
                                            'first_name': r.first_name,
                                            'last_name': r.last_name,
                                            'value': r.total_score}
                                           for r in rating]))


def get_leaderboard(student_id, data_path):
    return render_to_response('leaderboard.html', Context({'student_id': student_id,
                                                           'path': data_path}))
