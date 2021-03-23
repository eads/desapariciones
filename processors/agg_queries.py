
import click
import itertools
import os

from jinja2 import Template
from slugify import slugify

SQL_TEMPLATE = """
    {% for gender, status in fields %}count(*) filter (where c.sexo = '{{gender.value}}' and c.vivo_o_muerto = '{{status.value}}') as {{gender.slug}}_{{status.slug}}{{ ',' if not loop.last }}
    {% endfor %}
"""

STATUSES = ['AUN SIN LOCALIZAR', 'VIVO', 'MUERTO']
GENDERS = ['FEMENINO', 'MASCULINO']

@click.command()
@click.argument('output', type=click.File('w'))
def generate(output):
    """Generate a schema"""
    combinations = itertools.product(GENDERS, STATUSES)
    
    template_rows = []
    for row in combinations:
        newrow = []
        for value in row:
            slug = slugify(value, separator='_')
            newrow.append({'value': value, 'slug': slug})
        template_rows.append(newrow)

    t = Template(SQL_TEMPLATE)
    sql = t.render(fields=template_rows)
    output.write(sql)

if __name__ == '__main__':
    generate()