# Generated by Django 2.1.7 on 2019-04-21 21:51

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('webapp', '0011_auto_20190417_2331'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='userinfo',
            name='points',
        ),
    ]