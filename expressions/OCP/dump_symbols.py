import lief
import sys
from path import Path

prefix = sys.argv[1]

prefix_linux = Path(prefix).expand()
libs = prefix_linux.glob('**/libTK*.so.7.7.0')

exported_symbols = []

for lib in libs:
    p = lief.parse(lib)
    for s in p.exported_symbols:
        exported_symbols.append(f'{s.name}\n')

with open(f'symbols_mangled_linux.dat','w') as f:
    f.writelines(exported_symbols)
