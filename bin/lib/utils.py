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
