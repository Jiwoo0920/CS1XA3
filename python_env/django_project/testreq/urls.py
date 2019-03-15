from django.urls import path
from . import views

urlpatterns = [
    path("post/" , views.posttest , name = "testreq-posttest"),
    path("get/" , views.gettest , name = "testreq-gettest" ),
    path("", views.hello, name = "testreq-hello") ,
]

