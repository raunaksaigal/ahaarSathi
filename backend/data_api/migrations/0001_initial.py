# Generated by Django 5.2 on 2025-04-19 22:23

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='DataEntry',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('timestamp', models.DateTimeField(auto_now_add=True)),
                ('protein', models.DecimalField(decimal_places=3, max_digits=7)),
                ('carbs', models.DecimalField(decimal_places=3, max_digits=7)),
                ('fat', models.DecimalField(decimal_places=3, max_digits=7)),
                ('vitamins', models.DecimalField(decimal_places=3, max_digits=7)),
                ('minerals', models.DecimalField(decimal_places=3, max_digits=7)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='data_entries', to=settings.AUTH_USER_MODEL)),
            ],
        ),
    ]
