# Generated by Django 2.1.7 on 2019-04-17 23:26

import datetime
from django.db import migrations, models
from django.utils.timezone import utc


class Migration(migrations.Migration):

    dependencies = [
        ('webapp', '0009_userinfo_updatedtime'),
    ]

    operations = [
        migrations.AlterField(
            model_name='userinfo',
            name='updatedTime',
            field=models.DateTimeField(default=datetime.datetime(2019, 4, 17, 23, 26, 32, 448334, tzinfo=utc)),
        ),
    ]