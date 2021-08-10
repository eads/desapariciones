import click
import csv

from jinja2 import Template
from slugify import slugify

TEMPLATE = """
comment on column processed.cenapi.{{nombre_variable}} is '{{descripción}}';
"""


@click.command()
@click.argument('input', type=click.File('r', encoding='utf-8-sig'))
@click.argument('output', type=click.File('w'))
def generate(input, output):
    """Generate comments from a csv."""
    t = Template(TEMPLATE)
    reader = csv.DictReader(input)

    for row in reader:
        comment = t.render(**row)
        output.write(comment)

if __name__ == '__main__':
    generate()
