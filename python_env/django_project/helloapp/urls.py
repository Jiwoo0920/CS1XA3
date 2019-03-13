from django.urls import path
from . import views #from the same directory as this file was in, import the model views

urlpatterns = [
    path('', views.hello_world , name='helloapp-hello'),
]
