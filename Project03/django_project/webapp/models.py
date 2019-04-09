from django.db import models
from django.contrib.auth.models import User

# Create your models here

class UserInfoManager(models.Manager):
    def create_user_info(self, username, password, highscore):
        user = User.objects.create_user(username=username, password=password)
        userinfo = self.create(user=user,highscore=highscore)
        return userinfo

class UserInfo(models.Model):
    user = models.OneToOneField(User,on_delete=models.CASCADE,primary_key=True)
    highscore = models.IntegerField(default=0)

    objects = UserInfoManager()


