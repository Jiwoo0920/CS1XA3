from django.urls import path
from . import views

urlpatterns = [
    path("webapp/", views.hello_world, name="webapp-hello"),
]
