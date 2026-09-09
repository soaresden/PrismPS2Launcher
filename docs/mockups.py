import os, re, importlib.util
from PIL import Image, ImageDraw, ImageFont, ImageFilter
M="/sessions/bold-nifty-hawking/mnt/PrismPS2Launcher/To Transfer on USB or Exfat/Prism/System/Medias"
PSX="/sessions/bold-nifty-hawking/mnt/psx"; OUT="/sessions/bold-nifty-hawking/mnt/outputs"; PADS="/tmp/ui/pads"
s=importlib.util.spec_from_file_location("p","/sessions/bold-nifty-hawking/mnt/PrismPS2Launcher/HelperScripts/PS1toPOPS.py"); P=importlib.util.module_from_spec(s); s.loader.exec_module(P)
ART=P.load_gamelist(PSX)
W,H=640,448
F=lambda s,b=False: ImageFont.truetype(f"/usr/share/fonts/truetype/dejavu/DejaVuSans{'-Bold' if b else ''}.ttf", s)
WHITE=(240,243,248); DIM=(150,160,178); BLUE=(47,123,255); CYAN=(63,208,255); YEL=(255,205,0); RED=(235,80,80)
SYSTEMS=["Recent","Favorites","—","Atari 2600","Atari Lynx","ColecoVision","Game Boy","Game Boy Color","Game Boy Advance","Master System","Game Gear","SG-1000","Megadrive","NES","SNES","Neo Geo Pocket","WonderSwan","MSX","PlayStation","PlayStation 2"]
def fond():
    im=Image.new("RGB",(W,H)); px=im.load()
    for y in range(H):
        for x in range(W):
            t=x/W*0.45+y/H*0.55; px[x,y]=(int(28-20*t),int(44-30*t),int(74-50*t))
    return im
def panel(base,box,a=120):
    base.paste(Image.new("RGB",(box[2]-box[0],box[3]-box[1]),(6,10,20)),(box[0],box[1]),Image.new("L",(box[2]-box[0],box[3]-box[1]),a))
def btn(base,d,x,y,name,label,h=16):
    im=Image.open(f"{PADS}/ps-{name}.png").convert("RGBA"); im=im.resize((int(im.width*h/im.height),h),Image.LANCZOS)
    base.paste(im,(int(x),int(y)),im); x+=im.width+5
    d.text((int(x),int(y)+2),label,font=F(9),fill=WHITE); return x+d.textlength(label,font=F(9))+14
def helpbar(base,d,items):
    panel(base,(0,H-24,W,H),170); x=12
    for n,l in items: x=btn(base,d,x,H-20,n,l)
def topbar(d,left,right): d.text((124,8),left,font=F(9),fill=DIM); d.text((W-12,8),right,font=F(9),fill=DIM,anchor="ra")
def column(base,d,selected):
    panel(base,(0,0,110,H),150); y=12
    for s in SYSTEMS:
        if s=="—": y+=6; continue
        col=WHITE
        if s in ("Recent","Favorites"): col=YEL
        if s=="PlayStation 2": col=CYAN
        if s==selected: d.rounded_rectangle([4,y-3,106,y+13],radius=3,fill=BLUE); col=WHITE
        d.text((12,y),s,font=F(10,s==selected),fill=col); y+=18
def art(stem,k): return ART.get(stem,{}).get(k)
def wrap(d,x,y,txt,font,fill,width,lh):
    line=""
    for w in txt.split():
        if d.textlength(line+" "+w,font=font)>width: d.text((x,y),line,font=font,fill=fill); line=w; y+=lh
        else: line=(line+" "+w).strip()
    d.text((x,y),line,font=font,fill=fill); return y+lh
