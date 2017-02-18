from django.core.management.base import BaseCommand
from core.models import Course
from core.rule.tree import TreeLoader
from crawler.mysnu import crawl_credit
import json


class Command(BaseCommand):
    help = 'tree tester.'

    def add_arguments(self, parser):
        parser.add_argument('username')
        parser.add_argument('password')
        parser.add_argument('rule')
        parser.add_argument('meta', type=json.loads)

    def handle(self, *args, **options):
        username = options['username']
        password = options['password']
        rule = options['rule']
        metadata = options['meta']

        if metadata is None:
            metadata = {}

        self.stdout.write('logging in to mysnu...')
        taken_list = crawl_credit(username, password)
        if not taken_list:
            self.stdout.write('error: invalid credential.')
            return

        tree_node = TreeLoader(rule, metadata, Course)
        tree_node.eval_tree(taken_list)
        self.stdout.write(tree_node.tree_into_str())
