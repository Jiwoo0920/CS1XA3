from django.shortcuts import render
from django.http import HttpResponse, JsonResponse
from django.contrib.auth.models import User
from django.contrib.auth import authenticate, login, logout
import json
from . models import UserInfo

#Login/Signup
def sign_up(request):
        json_req = json.loads(request.body)
        uname = json_req.get('username','')
        passw = json_req.get('password','')
        if uname != '' and passw != '':
                user = User.objects.create_user(username=uname, password=passw)
                userinfo = UserInfo.objects.create(user=user)
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


def postUserInfo(request):
	#Retrieve userinfo from request
	json_req = json.loads(request.body.decode('utf-8'))
	print("print:"+str(json_req))
	highscore = json_req.get('highscore',0)
	points = json_req.get('points',0)
	gamesPlayed = json_req.get('gamesPlayed',0)
	playerTheme = json_req.get('playerTheme','1')
	deviceTheme = json_req.get('deviceTheme','1')
	#Get user from session info
	user = request.user
	if user.is_authenticated:
		userinfo = UserInfo.objects.get(user=user)
		if highscore > userinfo.highscore:
			userinfo.highscore = highscore
		userinfo.gamesPlayed = gamesPlayed
		userinfo.points = points
		userinfo.totalPoints += points
		userinfo.playerTheme = playerTheme
		userinfo.deviceTheme = deviceTheme
		userinfo.save()
		return HttpResponse("UpdatedUserInfo")
	else:
		return HttpResponse("UserIsNotLogged")

def getUserInfo(request):
	#Get user from session info
	user = request.user
	if user.is_authenticated:
		userinfo = UserInfo.objects.get(user=user)
		userhighscore = userinfo.highscore
		respDict = {}
		respDict['highscore'] = userinfo.highscore
		respDict['points'] = userinfo.points
		if userinfo.gamesPlayed > 0:
			respDict['avgPoints'] = round((userinfo.totalPoints/userinfo.gamesPlayed),5)
		else:
			respDict['avgPoints'] = 0
		respDict['gamesPlayed'] = userinfo.gamesPlayed
		respDict['playerTheme'] = userinfo.playerTheme
		respDict['deviceTheme'] = userinfo.deviceTheme
		print(str(respDict))
		return JsonResponse(respDict)
	else:
		return HttpResponse("UserIsNotLoggedIn")

def getOverallHighscore(request):
	respDict = {'username':'', 'highscore':0}
	all_users = UserInfo.objects.all()
	for user in all_users:
		if user.highscore > respDict['highscore']:
			respDict['username']=user.user.username
			respDict['highscore']=user.highscore
	return JsonResponse(respDict)


def getLeaderBoard(request):
	top5_UserInfo = UserInfo.objects.order_by('-highscore')[:5]
	print("top5:"+str(top5_UserInfo))
	respDict = {}
	keys = ["firstPlace","secondPlace","thirdPlace","fourthPlace","fifthPlace"]
	for i in range (len(top5_UserInfo)):
		username = top5_UserInfo[i].user.username
		highscore = top5_UserInfo[i].highscore
		respDict[keys[i]] = {"username":username,"highscore":highscore}
	if len(respDict) < 5:
		for i in range (len(respDict),5):
			respDict[keys[i]] = {"username":"---------","highscore":0}
	print(str(respDict))
	return JsonResponse(respDict)
