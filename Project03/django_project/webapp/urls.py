from django.urls import path
from . import views

urlpatterns = [
    path("webapp/", views.user_highscore, name="webapp_bug"),
]
