from django.conf.urls import url
from login.views import login_page, LoginRequest

urlpatterns = [
    url(r'^$', login_page),
    url(r'^(?P<option>mysnu|file)/', LoginRequest.as_view()),
]
