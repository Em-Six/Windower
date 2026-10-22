-- DirectInput keyboard codes (US QWERTY text entry). Non-US layouts may differ.
local K = {}
local normal, shifted = {}, {}
local function pair(code, plain, shift) normal[code] = plain; shifted[code] = shift or plain:upper() end
local letters = { [0x10]='q',[0x11]='w',[0x12]='e',[0x13]='r',[0x14]='t',[0x15]='y',[0x16]='u',[0x17]='i',[0x18]='o',[0x19]='p',
 [0x1E]='a',[0x1F]='s',[0x20]='d',[0x21]='f',[0x22]='g',[0x23]='h',[0x24]='j',[0x25]='k',[0x26]='l',
 [0x2C]='z',[0x2D]='x',[0x2E]='c',[0x2F]='v',[0x30]='b',[0x31]='n',[0x32]='m'}
for code, char in pairs(letters) do pair(code, char) end
for i, chars in ipairs({'1!','2@','3#','4$','5%','6^','7&','8*','9(','0)'}) do pair(i + 1, chars:sub(1,1), chars:sub(2,2)) end
for code, chars in pairs({[0x0C]='-_',[0x0D]='=+',[0x1A]='[{',[0x1B]=']}',[0x27]=';:',[0x28]="'\"",[0x29]='`~',[0x2B]='\\|',[0x33]=',<',[0x34]='.>',[0x35]='/?'}) do
 pair(code, chars:sub(1,1), chars:sub(2,2))
end
pair(0x39,' ',' ')
for code, char in pairs({[0x47]='7',[0x48]='8',[0x49]='9',[0x4B]='4',[0x4C]='5',[0x4D]='6',[0x4F]='1',[0x50]='2',[0x51]='3',[0x52]='0',[0x53]='.',[0xB5]='/',[0x37]='*',[0x4A]='-',[0x4E]='+'}) do pair(code, char, char) end
local bind_keys = {}
for code, char in pairs(letters) do bind_keys[code] = char end
for i=1,10 do bind_keys[i+1] = tostring(i%10) end
for code, key in pairs({[0x0C]='-',[0x0D]='=',[0x1A]='[',[0x1B]=']',[0x29]='`',[0x39]='space',[0x0F]='tab',[0x0E]='backspace',[0x1C]='enter',[0x53]='delete',[0xC8]='up',[0xD0]='down',[0xCB]='left',[0xCD]='right'}) do bind_keys[code]=key end
for i=1,12 do bind_keys[0x3A+i] = 'F'..i end
local uk_normal, uk_shifted = {}, {}
for code, char in pairs(normal) do uk_normal[code]=char end
for code, char in pairs(shifted) do uk_shifted[code]=char end
uk_shifted[0x03]='\"' -- UK Shift+2
uk_shifted[0x04]='£' -- UK Shift+3 (FFXI text rendering may not support Unicode)
uk_shifted[0x28]='@' -- UK Shift+apostrophe
uk_normal[0x2B]='#'; uk_shifted[0x2B]='~'
uk_normal[0x56]='\\'; uk_shifted[0x56]='|'
K.normal, K.shifted, K.bind = normal, shifted, bind_keys
K.modifier = {[0x2A]='shift',[0x36]='shift',[0x1D]='ctrl',[0x9D]='ctrl',[0x38]='alt',[0xB8]='alt'}
function K.character(dik, shift, layout)
    if layout=='UK' then return (shift and uk_shifted or uk_normal)[dik] end
    return (shift and shifted or normal)[dik]
end
function K.binding(dik, shift, ctrl, alt)
 local key = bind_keys[dik]
 if not key then return nil end
 return (ctrl and '^' or '') .. (alt and '!' or '') .. (shift and '~' or '') .. key
end
return K
