from django.urls import path
from .views import UserDetailView, UserProfileView

urlpatterns = [
    path('me/', UserDetailView.as_view(), name='user-detail'),
    path('profile/', UserProfileView.as_view(), name='user-profile'),
]