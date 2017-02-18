from django.conf.urls import url, include
import api.login.urls
import api.main.urls

urlpatterns = [
    url(r'^login/', include(api.login.urls.urlpatterns)),
    url(r'^main/', include(api.main.urls.urlpatterns)),
]
