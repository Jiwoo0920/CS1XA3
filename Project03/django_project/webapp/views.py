#from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
import json
from . models import UserInfo

# Create your views here.
#def session_incr(request):
#	i = request.session.get('counter',0)
#	request.session['counter'] = i+1
#	return HttpResponse("Counter = " + str(request.session['counter']))

#def session_get(request):
#	return HttpResponse("Counter = " + str(request.session['counter']))


def get_highscore(request):
	json_req = json.loads(request.body) #takes the request and turn to dictionary 
	username = json_req.get('username','')
	highscore = json_req.get('highscore',0)	
	user = User.objects.get(username=username)
	userinfo = UserInfo.objects.get(user=user)
	if highscore > userinfo.highscore:
		userinfo.highscore = highscore
	userinfo.save()

def view_highscore(request):
	reqDict = json.loads(request.body)
	username = reqDict.get('username','')
	user = User.objects.get(username=username)
	userinfo = UserInfo.objects.get(user=user)
	userhighscore = userinfo.highscore
#	return JsonResponse({'highscore':userhighscore})

def sign_up(request):
	json_req = json.loads(request.body)
	uname = json_req.get('username','')
	passw = json_req.get('password','')
	if uname != '':
		user = User.objects.create_user(username=uname, password=passw)
		login(request,user)
		return HttpResponse('SignupSuccess')
	else:
		return HttpResponse('SignupFail')

def login_user(request):
	print("Printing body " + str(request.body))
	json_req = json.loads(request.body)
	uname = json_req.get('username','')
	passw = json_req.get('password','')
	user = authenticate(request,username=uname,password=passw)
	if user is not None:
		login(request,user)
		return HttpResponse('LoggedIn')
	else:
		return HttpResponse('LoginFailed')

def logout_user(request):
	logout(request)
	return HttpResponse('LoggedOut')
