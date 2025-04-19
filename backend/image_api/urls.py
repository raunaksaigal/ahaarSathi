# data_api/urls.py

from django.urls import path
from .views import ImageUploadView, PredictionFeedbackView

urlpatterns = [
    path('upload/', ImageUploadView.as_view(), name='image-upload'),
    path('feedback/', PredictionFeedbackView.as_view(), name='prediction-feedback'),
]