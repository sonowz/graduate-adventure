from django.http.response import HttpResponse
from django.shortcuts import render
from rest_framework import serializers
from rest_framework.generics import GenericAPIView, mixins
from login.models import LoginData


def login_page(request):
    return HttpResponse("Hello World!")


class LoginSerializer(serializers.ModelSerializer):
    class Meta:
        model = LoginData
        fields = ('user_id', 'password')


class EchoRequest(GenericAPIView, mixins.ListModelMixin):
    queryset = LoginData.objects.all()
    serializer_class = LoginSerializer

    def get(self, request, *args, **kwargs):
        LoginData.objects.create(user_id='dummy', password='1234')
        return self.list(self, request, *args, **kwargs)
