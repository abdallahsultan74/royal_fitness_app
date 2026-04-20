from PIL import Image
src=r'C:\\Users\\HD\\.cursor\\projects\\c-Users-HD-royal-fitness-app\\assets\\c__Users_HD_AppData_Roaming_Cursor_User_workspaceStorage_a639502b1c06d1bf622ec3f2ff35b6f0_images_cc24fcf8-2caf-4268-a980-2caa01fb05f0-d9724030-3bc6-4790-9f18-3d274830e436.png'
out_icon=r'C:\\Users\\HD\\royal_fitness_app\\assets\\branding\\app_icon.png'
out_splash=r'C:\\Users\\HD\\royal_fitness_app\\assets\\branding\\splash_logo.png'
BG=(1,34,23)
im=Image.open(src).convert('RGBA')
px=im.load(); w,h=im.size
coords=[(x,y) for y in range(h) for x in range(w) if not (px[x,y][0]>235 and px[x,y][1]>235 and px[x,y][2]>235)]
xs=[c[0] for c in coords]; ys=[c[1] for c in coords]
cr=im.crop((min(xs),min(ys),max(xs)+1,max(ys)+1))
def mk(size,path):
    out=cr.resize((size,size), Image.Resampling.LANCZOS).convert('RGB')
    p=out.load()
    for y in range(size):
        for x in range(size):
            r,g,b = p[x,y]
            mx=max(r,g,b); mn=min(r,g,b); avg=(r+g+b)//3
            isWhite=(r>220 and g>220 and b>220)
            isGrayBright=((mx-mn)<25 and avg>110)
            if isWhite or isGrayBright:
                p[x,y]=BG
    t=max(6, size//170)
    for y in range(size):
        for x in range(size):
            if x<t or y<t or x>=size-t or y>=size-t:
                p[x,y]=BG
    out.save(path, format='PNG', optimize=True)
mk(1024,out_icon)
mk(512,out_splash)
print('updated', out_icon)
print('updated', out_splash)
