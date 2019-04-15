from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
import json
from . models import UserInfo


def get_highscore(request):
	json_req = json.loads(request.body) #takes the request and turn to dictionary
	username = json_req.get('username','')
	highscore = json_req.get('highscore',0)
	print("username:"+str(username)+" / "+"highscore:"+str(highscore))
	user = User.objects.get(username=username)
	userinfo = UserInfo.objects.get(user=user)
	if highscore > userinfo.highscore:
		userinfo.highscore = highscore
		userinfo.save()
		return HttpResponse('UpdatedNewHighscore')
	else:
		return HttpResponse('NotAHighscore')

def view_highscore(request):
	reqDict = json.loads(request.body)
	username = reqDict.get('username','')
	user = User.objects.get(username=username)
	userinfo = UserInfo.objects.get(user=user)
	userhighscore = userinfo.highscore
	respDict = {}
	respDict['username'] = user.username
	respDict['highscore'] = userhighscore
	return JsonResponse(respDict)

def view_overall_highscore(request):
	recordHolder = {'username':'','highscore':0}
	all_users = UserInfo.objects.all()
	for user in all_users:
		if user.highscore > recordHolder['highscore']:
			recordHolder['username'] = user.user.username
			recordHolder['highscore'] = user.highscore
	return JsonResponse(recordHolder)

def leaderboard(request):
	pass

def update_settings(request):
	json_req = json.loads(request.body.decode('utf-8'))
	print("print:"+str(json_req))
	uname = json_req.get('username','')
	playerTheme = json_req.get('playerTheme',1)
	deviceTheme = json_req.get('deviceTheme',1)
	user = User.objects.get(username=uname)
	userinfo = UserInfo.objects.get(user=user)
	userinfo.playerTheme = playerTheme
	userinfo.deviceTheme = deviceTheme
	userinfo.save()
	user.save()
	return HttpResponse('UpdateSettingsSuccess')

def sign_up(request):
	json_req = json.loads(request.body)
	uname = json_req.get('username','')
	passw = json_req.get('password','')
	if uname != '' and passw != '':
		user = User.objects.create_user(username=uname, password=passw)
		userinfo = UserInfo.objects.create(user=user,highscore=0,playerTheme='1',deviceTheme='1')
		user.save()
		userinfo.save()
		login(request,user)
		return HttpResponse('SignupSuccess')
	else:
		return HttpResponse('SignupFail')

def login_user(request):
	json_req = json.loads(request.body.decode('utf-8'))
	print("print:" + str(json_req))
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
