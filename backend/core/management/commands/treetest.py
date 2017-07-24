from django.core.management.base import BaseCommand
from core.rule.tree import TreeLoader
from crawler.mysnu import crawl_credit
from getpass import getpass
from time import time


class Command(BaseCommand):
    help = 'tree tester.'

    def handle(self, *args, **options):
        username = input('mySNU username: ')
        password = getpass('mySNU password: ')

        t = time()
        self.stdout.write('logging in to mysnu...')
        taken_list = crawl_credit(username, password)
        if not taken_list:
            self.stdout.write('error: invalid credential.')
            return
        self.stdout.write('mySNU login elasped time: ' + str(time() - t) + 's')

        rule = input('rule name: ')
        teps = input('teps: ')

        metadata = {teps: teps}

        if not teps:
            metadata = {}

        t = time()
        tree_node = TreeLoader(rule, metadata)
        tree_node.eval_tree(taken_list)
        self.stdout.write(tree_node.tree_into_str())
        self.stdout.write('TreeLoader elasped time: ' + str(time() - t) + 's')
