# image_api/views.py

from rest_framework import status, generics
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from .models import ImageUpload, PredictionFeedback
from .serializers import ImageUploadSerializer, PredictionFeedbackSerializer
from .prediction import predict_image_content
import os

class ImageUploadView(generics.CreateAPIView):
    serializer_class = ImageUploadSerializer
    parser_classes = (MultiPartParser, FormParser)

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        instance = serializer.save()

        image_path = instance.image.path

        prediction_result = predict_image_content(image_path)

        instance.prediction = prediction_result['class']
        instance.save()

        response_serializer = self.get_serializer(instance)
        response_data = response_serializer.data
        response_data.update({
            'prediction_detail': prediction_result
        })
        
        return Response(response_data, status=status.HTTP_201_CREATED)

class PredictionFeedbackView(generics.CreateAPIView):
    """API endpoint for submitting feedback on predictions"""
    serializer_class = PredictionFeedbackSerializer
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)