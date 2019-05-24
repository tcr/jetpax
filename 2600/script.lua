json = dofile("/Users/trim/tcr/stella/src/macos/json.lua")

regs = cpu()
print('registers:', json.encode(regs));
print('Gems:',
    string.format('%x', peek(label('DO_GEMS_A')+0)),
    string.format('%x', peek(label('DO_GEMS_B')+0)),
    string.format('%x', peek(label('DO_GEMS_A')+1)),
    string.format('%x', peek(label('DO_GEMS_B')+1)),
    string.format('%x', peek(label('DO_GEMS_A')+2)),
    string.format('%x', peek(label('DO_GEMS_B')+2)),
    string.format('%x', peek(label('DO_GEMS_A')+3)),
    string.format('%x', peek(label('DO_GEMS_B')+3)),
    string.format('%x', peek(label('DO_GEMS_A')+4)),
    string.format('%x', peek(label('DO_GEMS_B')+4)),
    string.format('%x', peek(label('DO_GEMS_A')+5)),
    string.format('%x', peek(label('DO_GEMS_B')+5)))
-- print('registers:', string.format("%x", regs))
