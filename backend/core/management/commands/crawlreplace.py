from django.core.management.base import BaseCommand
from django.core.exceptions import ValidationError
from django.db import IntegrityError
from getpass import getpass
from core.models import Replace
from crawler import mysnu
import logging.config
from django.conf import settings

logging.config.dictConfig(settings.LOGGING)
logger = logging.getLogger('crawlreplace')


class Command(BaseCommand):
    help = 'Replace course crawler'

    def handle(self, *args, **options):
        self.stdout.write('starting replace course crawler...')

        username = input('mySNU username: ')
        password = getpass('mySNU password: ')
        replaces = mysnu.crawl_replace_course(username, password)
        if replaces is None:
            self.stdout.write('mySNU login failed. Nothing changed.')
            return

        new_count, already_exists_count, error_count = 0, 0, 0

        for replace in replaces:
            new_replace = Replace(**replace)
            try:
                new_replace.save()
                new_count += 1
            except (ValidationError, IntegrityError):
                already_exists_count += 1
            except Exception as err:
                logger.exception(err, err.args)
                error_count += 1

        self.stdout.write('\nreplace course crawling process Done!')
        self.stdout.write('\t* newly added - {0}\n\t* already_exists - {1}\n\t* error - {2}'.format(
            new_count, already_exists_count, error_count
        ))
