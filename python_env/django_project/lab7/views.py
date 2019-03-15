from django.shortcuts import render
from django.http import HttpResponse
# Create your views here.

def isValid(request):
    user = request.POST.get("user","")
    password = request.POST.get("password","")
    if user == "Jimmy" and password == "Hendrix":
        return HttpResponse("Cool")
    return HttpResponse("Bad User Name")

    return HttpResp
