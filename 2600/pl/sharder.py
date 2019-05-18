import re
import json


page = dict()
for i in range(0, 256):
    page["{:08b}".format(i)] = '#0'


def format_shard(shard):
    res = '#%{:02b}{:02b}'.format(shard[0], shard[1])
    # print(shard, res)
    return res

gemslice = None
file = open("results_a.txt")
for line in file:
    if re.match(r"gems:", line):
        gems = line[11:34]
        gemslice = gems[4:-4]
    if re.match(r"shard:", line):
        shard = json.loads(line[6:])
        if shard[0] != 0 or shard[1] != 0:
            hash = gemslice.replace('g', '').replace(',', '')
            if page[hash] != '#0' and page[hash] != format_shard(shard):
                print('; conflict:', hash, format_shard(shard), page[hash])
            page[hash] = format_shard(shard)

print("\talign 256")
for i in range(0, 256):
    print('.shard_{}: .byte'.format(i), page["{0:08b}".format(i)])
