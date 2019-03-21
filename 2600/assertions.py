import re

with open('bin/jetpack.lst') as fp:
    with open('bin/jetpack.script', 'w') as out:
        for line in fp.readlines():
            m = re.search(r'^\s+ASSERT:\s*(.*)', line)
            if m:
                out.write(m[1])
                out.write('\n')
        out.write('run\n')
