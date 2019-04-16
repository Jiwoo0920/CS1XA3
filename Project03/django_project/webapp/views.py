from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
import json
from . models import UserInfo

#def session_incr(request):
#	i = request.session.get('counter',0)
#	request.session['counter'] = i+1
#	return HttpResponse("Counter = " + str(request.session['counter']))

#def session_get(request):
#    return HttpResponse("Counter = " + str(request.session['counter']))

def post_user_highscore(request):
	json_req = json.loads(request.body) #takes the request and turn to dictionary
	#username = json_req.get('username','')
	highscore = json_req.get('highscore',0)
	user = request.user #User.objects.get(username=username)
	if not user.is_anonymous:
		userinfo = UserInfo.objects.get(user=user)
	else:
		return HttpResponse('Error: Must be logged in to submit high score')
	if user.is_authenticated:
		if highscore > userinfo.highscore:
			userinfo.highscore = highscore
			userinfo.save()
			return HttpResponse('UpdatedNewHighscore')
		else:
			return HttpResponse('NotAHighscore')
	else:
		return HttpResponse('Error: Please login again.')

def view_highscore(request):
#	reqDict = json.loads(request.body)
#	username = reqDict.get('username','')
#	user = User.objects.get(username=username)
	user = request.user
	if user.is_authenticated:
		userinfo = UserInfo.objects.get(user=user)
		userhighscore = userinfo.highscore
		respDict = {}
		respDict['username'] = user.username
		respDict['highscore'] = userhighscore
		return JsonResponse(respDict)
	else:
		return HttpResponse('Error: Please login again.')

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
#	uname = json_req.get('username','')
	playerTheme = json_req.get('playerTheme','1')
	deviceTheme = json_req.get('deviceTheme','1')
	user = request.user
	if user.is_authenticated:
#	user = User.objects.get(username=uname)
		userinfo = UserInfo.objects.get(user=user)
		userinfo.playerTheme = playerTheme
		userinfo.deviceTheme = deviceTheme
		userinfo.save()
		user.save()
		return HttpResponse('UpdateSettingsSuccess')
	else:
		return HttpResponse('Error: Please login again')

def get_settings(request):
	json_req = json.loads(request.body.decode('utf-8'))
	print("print:"+str(json_req))
#	uname = json_req.get('username','')
	user = request.user #User.objects.get(username=uname)
	if user.is_authenticated:
		userinfo = UserInfo.objects.get(user=user)
		playerTheme = userinfo.playerTheme
		deviceTheme = userinfo.deviceTheme
		respDict = {}
		respDict['username'] = user.username
		respDict['playerTheme'] = playerTheme
		respDict['deviceTheme'] = deviceTheme
		print(str(respDict))
		return JsonResponse(respDict)
	else:
		return HttpResponse("Error: Please login again")

def sign_up(request):
	json_req = json.loads(request.body)
	uname = json_req.get('username','')
	passw = json_req.get('password','')
	if uname != '' and passw != '':
		user = User.objects.create_user(username=uname, password=passw)
		userinfo = UserInfo.objects.create(user=user,highscore=0,playerTheme='1',deviceTheme='1',gamesPlayed=0)
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
