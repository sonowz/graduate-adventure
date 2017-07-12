# Copyright (c) 2016, Shin DongJin. See the LICENSE file
# at the top-level directory of this distribution and at
# https://github.com/LastOne817/graduate-adventure/blob/master/LICENSE
#
# Licensed under the MIT license <http://opensource.org/licenses/MIT>.
# This file may not be copied, modified, or distributed except according
# to those terms.

from django.conf.urls import url, include
from django.contrib import admin
from django.conf import settings
from django.conf.urls.static import static
import api.urls

urlpatterns = [
    url(r'^admin/', include(admin.site.urls)),
    url(r'^api/', include(api.urls.urlpatterns)),
] + static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
