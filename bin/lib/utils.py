# Copyright (c) 2018 SAP SE or an SAP affiliate company. All rights reserved. This file is licensed under the Apache Software License, v. 2 except as noted otherwise in the LICENSE file
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import re

def find_by_key_value(dict, key, value):
  for elem in dict:
    if elem[key] == value:
      return elem

def compute_image_tag(path, tag):
  if re.search(r'[0-9a-f]{5,40}', tag) != None:
    with open(path) as f:
      version = f.read().split("-")
      if len(version) > 1:
        version[1] = tag
      return "-".join(version[:2])
  else:
    return tag

def read_file(path):
  with open(path) as f:
    return f.read().rstrip()

def dict_to_tfvars(d, indent=0, inline=False):
  tab = "  "
  res = "{}{{\n".format(indent * tab if not inline else "")
  indent = indent + 1
  for k, v in d.iteritems():
      res += "{}\"{}\" = ".format(indent * tab, k)
      if isinstance(v, dict):
        res += dict_to_tfvars(v, indent=indent, inline=True)
      else:
        res += "\"{}\"\n".format(v)
  indent = indent - 1
  res += "{}}}\n".format(indent * tab)
  return res
