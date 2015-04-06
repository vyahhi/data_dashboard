from django.db import models


class UsersUser(models.Model):
    id = models.IntegerField(primary_key=True)
    password = models.CharField(max_length=128)
    last_login = models.DateTimeField()
    is_superuser = models.IntegerField()
    email = models.CharField(unique=True, max_length=254)
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)
    is_confirmed = models.IntegerField()
    is_staff = models.IntegerField()
    is_active = models.IntegerField()
    date_joined = models.DateTimeField()
    language = models.CharField(max_length=7)
    details = models.TextField()
    is_creator = models.IntegerField()
    subscribed_for_mail = models.IntegerField()
    unsubscribe_key = models.CharField(unique=True, max_length=40)
    is_guest = models.IntegerField()
    user_agent = models.TextField()
    date_registered = models.DateTimeField(blank=True, null=True)
    calendar_key = models.CharField(unique=True, max_length=40)
    is_private = models.IntegerField()
    notification_email_delay = models.IntegerField()
    subscribed_for_news_en = models.IntegerField()
    subscribed_for_news_ru = models.IntegerField()
    bit_field = models.BigIntegerField()
    level = models.IntegerField()

    class Meta:
        managed = False
        db_table = 'users_user'


class LessonsLesson(models.Model):
    id = models.IntegerField(primary_key=True)
    deleted_at = models.DateTimeField(blank=True, null=True)
    title = models.CharField(max_length=64)
    owner = models.ForeignKey('UsersUser', blank=True, null=True)
    language = models.CharField(max_length=7)
    is_featured = models.IntegerField()
    can_anyone_learn = models.IntegerField()
    version = models.BigIntegerField()
    lti_consumer_key = models.CharField(max_length=256)
    lti_secret_key = models.CharField(max_length=256)
    is_prime = models.IntegerField()
    create_date = models.DateTimeField(blank=True, null=True)
    update_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'lessons_lesson'


class VideosVideo(models.Model):
    id = models.IntegerField(primary_key=True)
    user = models.ForeignKey(UsersUser)
    source = models.CharField(max_length=100)
    status = models.IntegerField()
    vimeo_id = models.CharField(max_length=31)
    thumbnail = models.CharField(max_length=127)
    urls = models.TextField()
    create_date = models.DateTimeField()
    upload_date = models.DateTimeField(blank=True, null=True)
    available_date = models.DateTimeField(blank=True, null=True)
    ready_date = models.DateTimeField(blank=True, null=True)
    lesson = models.ForeignKey(LessonsLesson)

    class Meta:
        managed = False
        db_table = 'videos_video'


class ExercisesBlock(models.Model):
    id = models.IntegerField(primary_key=True)
    name = models.CharField(max_length=64)
    text = models.TextField()
    video = models.ForeignKey('VideosVideo', unique=True, blank=True, null=True)
    source = models.TextField()
    options = models.TextField()
    subtitles = models.TextField()
    animation = models.TextField(blank=True)

    class Meta:
        managed = False
        db_table = 'exercises_block'


class CoursesCourse(models.Model):
    id = models.IntegerField(primary_key=True)
    deleted_at = models.DateTimeField(blank=True, null=True)
    title = models.CharField(max_length=64)
    owner = models.ForeignKey('UsersUser', blank=True, null=True)
    language = models.CharField(max_length=7)
    is_featured = models.IntegerField()
    can_anyone_learn = models.IntegerField()
    begin_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)
    soft_deadline = models.DateTimeField(blank=True, null=True)
    hard_deadline = models.DateTimeField(blank=True, null=True)
    grading_policy = models.IntegerField(blank=True, null=True)
    summary = models.TextField()
    cover = models.CharField(max_length=100, blank=True)
    lti_consumer_key = models.CharField(max_length=256)
    lti_secret_key = models.CharField(max_length=256)
    workload = models.CharField(max_length=64)
    intro = models.CharField(max_length=200)
    course_format = models.TextField()
    target_audience = models.TextField()
    instructors = models.TextField()
    requirements = models.TextField()
    description = models.TextField()
    certificate = models.CharField(max_length=256)
    is_spoc = models.IntegerField()
    certificate_footer = models.CharField(max_length=100, blank=True)
    certificate_regular_threshold = models.IntegerField(blank=True, null=True)
    certificate_distinction_threshold = models.IntegerField(blank=True, null=True)
    certificate_cover_org = models.CharField(max_length=100, blank=True)
    create_date = models.DateTimeField(blank=True, null=True)
    update_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'courses_course'


class CoursesSection(models.Model):
    id = models.IntegerField(primary_key=True)
    deleted_at = models.DateTimeField(blank=True, null=True)
    title = models.CharField(max_length=64)
    begin_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)
    soft_deadline = models.DateTimeField(blank=True, null=True)
    hard_deadline = models.DateTimeField(blank=True, null=True)
    grading_policy = models.IntegerField(blank=True, null=True)
    course = models.ForeignKey(CoursesCourse)
    position = models.IntegerField()
    requirements = models.TextField()
    create_date = models.DateTimeField(blank=True, null=True)
    update_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'courses_section'


class CoursesUnit(models.Model):
    id = models.IntegerField(primary_key=True)
    deleted_at = models.DateTimeField(blank=True, null=True)
    begin_date = models.DateTimeField(blank=True, null=True)
    end_date = models.DateTimeField(blank=True, null=True)
    soft_deadline = models.DateTimeField(blank=True, null=True)
    hard_deadline = models.DateTimeField(blank=True, null=True)
    grading_policy = models.IntegerField(blank=True, null=True)
    section = models.ForeignKey(CoursesSection)
    lesson = models.ForeignKey(LessonsLesson)
    position = models.IntegerField()
    create_date = models.DateTimeField(blank=True, null=True)
    update_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'courses_unit'


class GradesCoursegrade(models.Model):
    id = models.IntegerField(primary_key=True)
    course = models.ForeignKey(CoursesCourse)
    user = models.ForeignKey(UsersUser)
    score = models.FloatField()
    is_teacher = models.IntegerField()
    update_date = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'grades_coursegrade'


class LessonsStep(models.Model):
    id = models.IntegerField(primary_key=True)
    deleted_at = models.DateTimeField(blank=True, null=True)
    lesson = models.ForeignKey(LessonsLesson)
    title = models.CharField(max_length=4)
    position = models.IntegerField()
    status = models.IntegerField()
    reason_of_failure = models.TextField()
    block = models.ForeignKey(ExercisesBlock, unique=True)
    cost = models.IntegerField()
    create_date = models.DateTimeField(blank=True, null=True)
    update_date = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'lessons_step'


class ProgressStepprogress(models.Model):
    id = models.IntegerField(primary_key=True)
    user = models.ForeignKey(UsersUser)
    step = models.ForeignKey(LessonsStep)
    is_creator = models.IntegerField()
    is_updater = models.IntegerField()
    when_viewed = models.DateTimeField(blank=True, null=True)
    last_viewed = models.DateTimeField(blank=True, null=True)
    when_passed = models.DateTimeField(blank=True, null=True)
    total_views = models.IntegerField()
    total_successes = models.IntegerField()
    total_failures = models.IntegerField()
    total_comments = models.IntegerField()
    best_score = models.FloatField()
    when_gave_reviews = models.DateTimeField(blank=True, null=True)
    when_took_reviews = models.DateTimeField(blank=True, null=True)
    when_finished_review = models.DateTimeField(blank=True, null=True)
    review_score = models.FloatField()

    class Meta:
        managed = False
        db_table = 'progress_stepprogress'

