from django.shortcuts import render

# Create your views here.
from django.shortcuts import render
from django.http import HttpResponse

def hello_world(request):
     hello = "<html><body>Hello World</body></html>"
     return HttpResponse(hello)
