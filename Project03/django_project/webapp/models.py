from django.db import models
from django.contrib.auth.models import User

# Create your models here

class UserInfoManager(models.Manager):
	def create_user_info(self, username, password, highscore, playerTheme, deviceTheme):
		user = User.objects.create_user(username=username, password=password)
#		userinfo = UserInfo.objects.create(user=user, highscore=highscore)
		userinfo = self.create(user=user,highscore=highscore, playerTheme=playerTheme, deviceTheme=deviceTheme)
		return userinfo

class UserInfo(models.Model):
	user = models.OneToOneField(User,on_delete=models.CASCADE,primary_key=True)
	highscore = models.IntegerField(default=0)
	playerTheme = models.CharField(max_length=10,default='1')
	deviceTheme = models.CharField(max_length=10,default='1')
	gamesPlayed = models.IntegerField(default=0)
	points = models.IntegerField(default=0)
	totalPoints = models.IntegerField(default=0)
	averagePoints = models.FloatField(default=0.0)
	objects = UserInfoManager()

	
