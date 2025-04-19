"""
URL configuration for backend project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include
<<<<<<< HEAD
from django.conf.urls.static import static
from django.conf import settings
=======
>>>>>>> c3b0ca754a528a9e820d4f649f61ab5e23a47895

urlpatterns = [
    path('admin/', admin.site.urls),
    path('image/', include("image_api.urls")),
    path('data/', include("data_api.urls")),
]
<<<<<<< HEAD
urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
=======
>>>>>>> c3b0ca754a528a9e820d4f649f61ab5e23a47895
