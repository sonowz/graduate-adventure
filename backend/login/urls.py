from django.conf.urls import url
from login.views import login_page, LoginRequest, test

urlpatterns = [
    url(r'^$', login_page),
    url(r'^mysnu/', LoginRequest.as_view()),
    url(r'^test/', test)
]
