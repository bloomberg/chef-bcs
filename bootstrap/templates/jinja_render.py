#!/usr/bin/env python
#
# Author: Chris Jones
# Copyright 2016, Bloomberg Finance L.P.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# NOTE: You need to pass in the full paths to the file references below. The data is file should be private and it's
# not in the project. The reason is you should create a YAML file that fits how you want to configure your
# environment. For eample, you can have a small YAML data file for configuring the kickstart/ISO process and then
# maybe one for building out the missing USER and/or SYSTEM data used in the CHEF Environment files. A sample
# environment file ships with the project for vagrant called vagrant.json. However, a production.json should
# really be a jinja2 template like production.json.j2 with as much default data and with template {{ }} placeholders
# for the actual data. The output of this process should be the TRUE production.json file. Also, it's a good idea
# to name your production.json file more descriptive of the environment it actually belongs to. For example,
# prod-dc101.json or something like it.

from jinja2 import Environment, FileSystemLoader
import os
import yaml
import argparse
import sys
import json


# All three file paths must be full paths to each.
def render_template(data_file, in_file, out_file):
    #env = Environment(autoescape=False, loader=FileSystemLoader('/')), trim_blocks=True)
    env = Environment(loader=FileSystemLoader('/'))
    env.filters['jsonify'] = json.dumps

    with open(data_file) as data:
        dict =  yaml.load(data)

    # Render template and print generated config to console
    template = env.get_template(in_file)

    with open(out_file, 'w') as f:
        output = template.render(dict)
        f.write(output)


# dict is json dictionary of the values to sub
def render_string(in_string, dict):
    return Environment().from_string(in_string).render(dict)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description='Jinja2 Renderer', prog='Jinja_render')
    p.add_argument('--input_file', '-i', help='The template input file.')
    p.add_argument('--output_file', '-o', help='The rendered output file.')
    p.add_argument('--data_file', '-d', help='The YAML data file.')

    options = p.parse_args()

    if not options.input_file or not options.output_file or not options.data_file:
        p.print_help()
        sys.exit()

    render_template(options.data_file, options.input_file, options.output_file)
