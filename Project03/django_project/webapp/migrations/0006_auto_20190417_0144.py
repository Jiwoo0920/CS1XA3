# Generated by Django 2.1.7 on 2019-04-17 01:44

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('webapp', '0005_auto_20190417_0139'),
    ]

    operations = [
        migrations.AlterField(
            model_name='userinfo',
            name='gamesPlayed',
            field=models.IntegerField(default=0),
        ),
        migrations.AlterField(
            model_name='userinfo',
            name='playerTheme',
            field=models.CharField(default='1', max_length=10),
        ),
    ]