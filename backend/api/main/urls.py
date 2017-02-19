from django.conf.urls import url
from api.main.views import main_data, SearchModal

urlpatterns = [
    url(r'^$', main_data),
    url(r'^search/', SearchModal.as_view()),
]
