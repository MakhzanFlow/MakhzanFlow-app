from PIL import Image, ImageDraw
import os

SIZE = 1024
img = Image.new("RGBA", (SIZE, SIZE), (0,0,0,0))

rect_size = 720
rx = 160
x0 = (SIZE - rect_size)//2
y0 = (SIZE - rect_size)//2
x1 = x0 + rect_size
y1 = y0 + rect_size

# mask for rounded rect
mask = Image.new("L", (SIZE,SIZE), 0)
ImageDraw.Draw(mask).rounded_rectangle([x0,y0,x1,y1], radius=rx, fill=255)

# gradient: deep indigo #1E293B -> #4F46E5 -> amber accent #F59E0B diagonal
grad = Image.new("RGBA", (SIZE,SIZE), (0,0,0,0))
gd = ImageDraw.Draw(grad)
for y in range(y0, y1):
    t = (y - y0)/rect_size
    # interpolate indigo 30,41,59 -> 79,70,229 -> 245,158,11 at bottom blend
    if t < 0.6:
        tt = t/0.6
        r = int(30 + (79-30)*tt)
        g = int(41 + (70-41)*tt)
        b = int(59 + (229-59)*tt)
    else:
        tt = (t-0.6)/0.4
        r = int(79 + (245-79)*tt)
        g = int(70 + (158-70)*tt)
        b = int(229 + (11-229)*tt*0.35)  # keep bluish, not full amber
        # actually keep indigo dominant, amber as accent not full background
        # blend slightly to warmer
        r = int(79 + (120-79)*tt)
        g = int(70 + (90-70)*tt)
        b = int(229 + (180-229)*tt)
    gd.line([(x0,y),(x1,y)], fill=(r,g,b,255))

img = Image.composite(grad, img, mask)
draw = ImageDraw.Draw(img)

# inner highlight
hl = Image.new("RGBA", (SIZE,SIZE), (0,0,0,0))
ImageDraw.Draw(hl).rounded_rectangle([x0+22,y0+22,x1-22,y0+150], radius=22, fill=(255,255,255,26))
img = Image.alpha_composite(img, hl)
draw = ImageDraw.Draw(img)

cx, cy = SIZE//2, SIZE//2 - 20

# Draw warehouse / boxes icon - flat minimal
# Two stacked boxes: bottom box and top box, isometric-like flat

# Box dimensions
bw, bh = 220, 130
gap = 14

# bottom box centered at cy+70
bx0 = cx - bw//2
by0 = cy + 40
bx1 = bx0 + bw
by1 = by0 + bh

# top box slightly smaller, sits on bottom
tw, th = 180, 110
tx0 = cx - tw//2
ty0 = by0 - th - gap + 18
tx1 = tx0 + tw
ty1 = tx0 + th + (ty0 - tx0)  # keep
ty1 = ty0 + th

# Colors: boxes white with amber tape
box_fill = (255,255,255,245)
box_outline = (255,255,255,255)
tape = (245,158,11,255)  # amber
tape_dark = (217,119,6,255)

# Helper to draw box with tape
def draw_box(x0,y0,x1,y1, show_tape=True):
    # main rect with rounded corners 18
    draw.rounded_rectangle([x0,y0,x1,y1], radius=18, fill=box_fill, outline=(255,255,255,0))
    # vertical tape stripe center
    if show_tape:
        tx = (x0+x1)//2 - 14
        draw.rectangle([tx, y0, tx+28, y1], fill=tape)
        # horizontal tape line
        ty = (y0+y1)//2 - 6
        draw.rectangle([x0, ty, x1, ty+12], fill=tape)
        # overlap darker center
        draw.rectangle([tx, ty, tx+28, ty+12], fill=tape_dark)
    # subtle shadow inner
    draw.rounded_rectangle([x0,y0,x1,y1], radius=18, outline=(0,0,0,18), width=2)

draw_box(bx0, by0, bx1, by1, True)
draw_box(tx0, ty0, tx1, ty1, True)

# Flow arrow wrapping around boxes - circular flowing arrow on top-right
# Draw minimal circular arrow (open circle with arrowhead) in white
arrow_cx, arrow_cy = cx + 155, cy - 105
arrow_r = 62
# arc: 270 degrees
draw.arc([arrow_cx-arrow_r, arrow_cy-arrow_r, arrow_cx+arrow_r, arrow_cy+arrow_r], start= -90, end=210, fill=(255,255,255,235), width=14)
# arrowhead
import math
# end angle 210 deg -> position
ang = math.radians(210)
ax = arrow_cx + arrow_r*math.cos(ang)
ay = arrow_cy + arrow_r*math.sin(ang)
# direction tangent (+90 deg)
tang = math.radians(210+90)
# arrowhead triangle
ah_len = 26
ah_w = 18
# tip at ax,ay, base opposite tangent
base_x = ax - ah_len*math.cos(tang)
base_y = ay - ah_len*math.sin(tang)
perp = tang + math.radians(90)
bx1h = base_x + ah_w*math.cos(perp)/2
by1h = base_y + ah_w*math.sin(perp)/2
bx2h = base_x - ah_w*math.cos(perp)/2
by2h = base_y - ah_w*math.sin(perp)/2
draw.polygon([(ax,ay),(bx1h,by1h),(bx2h,by2h)], fill=(255,255,255,235))

# Small shelf line under bottom box to ground
draw.line([(bx0-22, by1+18),(bx1+22, by1+18)], fill=(255,255,255,70), width=4)
# Two small dots under shelf indicating distribution points
for i, dx in enumerate([cx-70, cx, cx+70]):
    r = 11 if i==1 else 8
    alpha = 220 if i==1 else 140
    draw.ellipse([dx-r, by1+38-r, dx+r, by1+38+r], fill=(255,255,255,alpha))
draw.line([(cx-70, by1+38),(cx+70, by1+38)], fill=(255,255,255,75), width=2)

# Bottom text area spacer but no text (icon should be textless)

# Save
os.makedirs("assets/icon", exist_ok=True)
os.makedirs("assets/images", exist_ok=True)
out_main = "assets/icon/icon.png"
out_images = "assets/images/logo.png"
# 1024 main (transparent background outside rounded rect, icon itself is the rounded rect)
img.save(out_main, "PNG")
img.save(out_images, "PNG")
# Also save original size for reference
img.save("assets/icon-1024-makhzan.png", "PNG")

# Android adaptive: scale 66% centered (for flutter_launcher_icons adaptive foreground inset 16 handles safe area, but we also provide scaled)
android = Image.new("RGBA", (SIZE,SIZE), (0,0,0,0))
scaled_sz = int(SIZE*0.66)
scaled = img.resize((scaled_sz, scaled_sz), Image.LANCZOS)
ax0 = (SIZE-scaled_sz)//2
ay0 = (SIZE-scaled_sz)//2
android.paste(scaled, (ax0,ay0), scaled)
android.save("assets/icon/foreground.png", "PNG")
android.save("assets/android-icon-66.png", "PNG")

print(f"Saved {out_main} {img.size}")
print(f"Saved foreground {scaled_sz}")
print("Done")
