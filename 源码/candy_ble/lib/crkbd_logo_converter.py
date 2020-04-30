# Corne keyboard logo importer/exporter
# (c) /u/iamjoric 2019-07-07

from PIL import Image
import os

x = 0
y = 0
w = 128
h = 32
fw = 6
fh = 8

data = []
logo = []

def putchar(img, cx, cy, i):
    global x, y, data, w, h, fw, fh
    for j in range(fw):
        byte = data[i * fw + j]
        for k in range(8):
            c = (byte & 1) * 255
            img.putpixel((x+j, y+k), (c,c,c))
            byte >>= 1
    x += fw
    if x>w-fw:
        x = 0
        y += fh
        if y>h-fh:
            y = 0

def getchar(img, cx, cy, i):
    global x, y, data, w, h, fw, fh
    for j in range(fw):
        #b = data[i * fw + j]
        byte = 0
        for k in range(8):
            byte >>= 1
            bit = 1 if img.getpixel((x+j, y+k))[0] > 0 else 0
            byte |= bit << 7

        data[i * fw + j] = byte

    x += fw
    if x>w-fw:
        x = 0
        y += fh
        if y>h-fh:
            y = 0

def read_data():
    global w, h, x, y, fw,fh

    header = []
    footer = []


    print("Reading glcdfont.c...")

    for s in open('glcdfont.c').read().splitlines():
        a = s.split(',')
        if len(a)==7:
            data.extend([int(x, 16) for x in a[:-1]])
            continue
        if len(data)==0:
            header.append(s)
        else:
            footer.append(s)

    print("Reading logo_reader.c...")

    for s in open('logo_reader.c').read().splitlines():
        a = s.split(',')
        if len(a)>7:
            logo.append([int(x, 16) for x in a[:-1]])

    chars = len(data)//fw

    img = Image.new('RGB', (w, h), color = 'black')

    print("Reading logo.png...")

    omg = Image.open('logo.png')

    x = y = 0
    for s in logo:
        for i in s:
            getchar(omg, 0, 0, i)

    x = y = 0
    for s in logo:
        for i in s:
            putchar(img, 0, 0, i)

    print("Writing out.png...")

    img.save('out.png')

    i = 0
    while True:
        i += 1
        backup_fname = "glcdfont.c.%d.bak" % i
        if not os.path.exists(backup_fname):
            break

    print("Backing up glcdfont.c to %s..." % backup_fname )

    os.rename('glcdfont.c', backup_fname);

    print("Writing glcdfont.c...")

    of = open('glcdfont.c','w')

    for s in header:
        print(s, file=of)

    for i in range(0,chars*fw,fw):
        a = data[i:i+fw]
        v = ['0x%02X' % d for d in a]
        print(', '.join(v)+',', file=of)

    for s in footer:
        print(s, file=of)


if __name__=="__main__":
    read_data()

    