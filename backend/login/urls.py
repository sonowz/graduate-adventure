from django.conf.urls import url
from login.views import login_page, EchoRequest

urlpatterns = [
    url(r'^$', login_page),
    url(r'^echo/', EchoRequest.as_view()),
]