from django.core.management.base import BaseCommand
from core.rule.tree import TreeLoader
from crawler.mysnu import crawl_taken_list
from getpass import getpass
from time import time
import pickle


class Command(BaseCommand):
    help = 'tree tester.'

    def add_arguments(self, parser):
        parser.add_argument('-f', '--file',
                            help='custom taken_list pickle file',
                            required=False)

    def handle(self, *args, **options):

        taken_list = {}
        taken_list_file = options.get('file', None)

        if taken_list_file is None:
            username = input('mySNU username: ')
            password = getpass('mySNU password: ')

            t = time()
            self.stdout.write('logging in to mysnu...')
            taken_list = crawl_taken_list(username, password)
            if not taken_list:
                self.stderr.write('error: invalid credential.')
                return
            self.stdout.write('mySNU login elasped time: ' + str(time() - t) + 's')
        else:
            f = open(taken_list_file, 'rb')
            taken_list = pickle.load(f).get('credit_info', None)

            if taken_list is None:
                self.stderr.write('file is not valid.')
                return

        rule = input('rule name: ')
        teps = input('teps: ')

        metadata = {'teps': int(teps)}

        if not teps:
            metadata = {}

        t = time()
        tree_node = TreeLoader(rule, metadata)
        self.stdout.write('TreeLoader elasped time: ' + str(time() - t) + 's')
        t = time()
        tree_node.eval_tree(taken_list)
        self.stdout.write(tree_node.tree_into_str())
        self.stdout.write('Tree evaluation elasped time: ' + str(time() - t) + 's')
