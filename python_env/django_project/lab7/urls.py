from django.urls import path
from . import views

urlpatterns = [
    path("lab7/" , views.isValid , name = "testreq-posttest"),
]

