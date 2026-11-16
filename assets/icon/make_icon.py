import numpy as np
from PIL import Image, ImageDraw, ImageFilter
src = Image.open('assets/icon/iconer.png').convert('RGB')
a = np.asarray(src).astype(np.float32)
r, g, b = a[..., 0], a[..., 1], a[..., 2]
w, h = src.size

# Fondo: relleno desde el borde sin cruzar el contorno blanco.
wall = Image.fromarray(((a.min(axis=2) > 150) * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(3))
fill = wall.copy()
for s in [(0, 0), (w // 2, 0), (w - 1, 0), (0, h - 1), (150, h - 1), (0, h - 250), (w - 1, h - 1)]:
    if fill.getpixel(s) == 0: ImageDraw.floodfill(fill, s, 128)
bg = fill.point(lambda v: 255 if v == 128 else 0).filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(1.2))

# "Linea" = blanco/gris neutro (contorno, ojos, nariz, dientes).
# Los reflejos del brillo son cian (verde >> rojo): esos NO son linea.
mn = a.min(axis=2)
neutral = np.clip((32 - (g - r)) / 16, 0, 1)
bright = np.clip((mn - 105) / 55, 0, 1)
line = neutral * bright
# Limpia motitas sueltas y suaviza bordes.
m = Image.fromarray((line * 255).astype(np.uint8))
m = m.filter(ImageFilter.MinFilter(3)).filter(ImageFilter.MaxFilter(3)).filter(ImageFilter.GaussianBlur(0.8))
line = np.asarray(m).astype(np.float32) / 255

# Solo se quedan las piezas grandes (contorno, ojos, nariz, dientes);
# las motitas de reflejo sueltas se descartan.
binary = Image.fromarray(((line > 0.4) * 255).astype(np.uint8))
lab = binary.copy()
keep = np.zeros(line.shape, bool)
arr = np.asarray(lab)
while True:
    pts = np.argwhere(np.asarray(lab) == 255)
    if len(pts) == 0: break
    y, x = pts[0]
    ImageDraw.floodfill(lab, (int(x), int(y)), 100)
    region = np.asarray(lab) == 100
    if region.sum() > 2500 and not region[170, 760] and not region[185, 780]: keep |= region
    ImageDraw.floodfill(lab, (int(x), int(y)), 1)
keepimg = Image.fromarray((keep * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(5)).filter(ImageFilter.GaussianBlur(1))
line = line * (np.asarray(keepimg).astype(np.float32) / 255)

yy = np.linspace(0, 1, h, dtype=np.float32)[:, None, None]

def vgrad(top, bottom):
    top = np.array(top, np.float32); bottom = np.array(bottom, np.float32)
    return np.broadcast_to(top + (bottom - top) * yy, (h, w, 3))

# Azul con degradado: claro arriba, profundo abajo.
blue = vgrad((70, 150, 255), (8, 62, 190))
# Cuerpo blanco con sombreado suave tomado del brillo original.
v = a.max(axis=2) / 255
body = (255 - (1 - v) * 30)[..., None].repeat(3, axis=2)
out = body + (blue - body) * line[..., None]

# Fondo: blanco arriba a gris perla azulado abajo.
back = vgrad((255, 255, 255), (200, 214, 232))
bgm = (np.asarray(bg).astype(np.float32) / 255)[..., None]
out = out * (1 - bgm) + back * bgm

# Brillo clasico de iOS: una gran elipse blanca que cubre la mitad de
# arriba y se corta en curva, mas fuerte arriba y suave hacia la curva.
X, Y = np.meshgrid(np.arange(w, dtype=np.float32), np.arange(h, dtype=np.float32))
cx, cy, rx, ry = w * 0.5, -h * 0.42, w * 1.05, h * 0.92
inside = ((X - cx) / rx) ** 2 + ((Y - cy) / ry) ** 2
edge = np.clip((1 - inside) / 0.012, 0, 1)          # borde de la curva nitido pero suave
alpha = (0.55 - 0.40 * np.clip(Y / (h * 0.5), 0, 1)) * edge
out = out + (255 - out) * alpha[..., None]

# Sombra interior leve en la orilla de abajo, para dar volumen.
shade = np.clip((Y - h * 0.82) / (h * 0.18), 0, 1) * 0.10
out = out * (1 - shade[..., None])

Image.fromarray(np.clip(out, 0, 255).astype(np.uint8)).save('assets/icon/iconer_white.png')
