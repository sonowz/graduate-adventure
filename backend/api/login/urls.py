from django.conf.urls import url
from api.login.views import LoginRequest

urlpatterns = [
    url(r'^(?P<option>mysnu|file)/', LoginRequest.as_view()),
]
