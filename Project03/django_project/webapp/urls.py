from django.urls import path
from . import views

urlpatterns = [
    path('gethighscore/', views.get_highscore, name='webapp-get_highscore'),
    path('viewhighscore/', views.view_highscore, name='webapp-view_highscore'),
    path('viewoverallhighscore/', views.view_overall_highscore, name='webapp-view_overall_highscore'),
    path('signup/', views.sign_up, name='webapp-sign_up'),
    path('loginuser/', views.login_user, name='webapp-login_user'),
    path('logoutuser/',views.logout_user, name='webapp-logout_user'),
]
