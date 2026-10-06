import math
P,PD,PL,AC,SF,INK,MU,CR,BD='#0A6F82','#065666','#DCEFF2','#E06F2C','#F5F8F8','#16323A','#6C7F85','#0A8A6A','#E3EBED'
F='Inter, Helvetica, Arial, sans-serif'
W,H=402,874

# 24x24 icon paths (simplified Material-style)
ICON={
 'phone':'<rect x="7" y="2.5" width="10" height="19" rx="2" fill="none" stroke="{c}" stroke-width="2"/><circle cx="12" cy="18" r="1" fill="{c}"/>',
 'bolt':'<path d="M13 2L5 13h6l-1 9 8-11h-6z" fill="{c}"/>',
 'swap':'<path d="M7 7h12M15 3l4 4-4 4M17 17H5M9 13l-4 4 4 4" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>',
 'gift':'<rect x="3" y="9" width="18" height="12" rx="1" fill="none" stroke="{c}" stroke-width="2"/><path d="M3 13h18M12 9v12M12 9c-3-5-6-1-3 0M12 9c3-5 6-1 3 0" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round"/>',
 'wifi':'<path d="M3 9a14 14 0 0 1 18 0M6 13a9 9 0 0 1 12 0M9.5 16.5a4 4 0 0 1 5 0" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round"/><circle cx="12" cy="20" r="1.3" fill="{c}"/>',
 'water':'<path d="M12 3c4 5 6 8 6 11a6 6 0 0 1-12 0c0-3 2-6 6-11z" fill="{c}"/>',
 'gas':'<path d="M12 2c1 4 6 6 6 12a6 6 0 0 1-12 0c0-3 2-4 3-7 1 2 2 2 3-5z" fill="{c}"/>',
 'heart':'<path d="M12 21C4 14 3 10 3 8a5 5 0 0 1 9-3 5 5 0 0 1 9 3c0 2-1 6-9 13z" fill="{c}"/>',
 'send':'<path d="M3 11l18-8-8 18-2-8z" fill="{c}"/>',
 'receipt':'<path d="M6 3h12v18l-3-2-3 2-3-2-3 2z" fill="none" stroke="{c}" stroke-width="2" stroke-linejoin="round"/><path d="M9 8h6M9 12h6" stroke="{c}" stroke-width="2"/>',
 'grid':'<rect x="4" y="4" width="7" height="7" rx="1.5" fill="{c}"/><rect x="13" y="4" width="7" height="7" rx="1.5" fill="{c}"/><rect x="4" y="13" width="7" height="7" rx="1.5" fill="{c}"/><rect x="13" y="13" width="7" height="7" rx="1.5" fill="{c}"/>',
 'bell':'<path d="M6 17V11a6 6 0 0 1 12 0v6l2 2H4zM10 21h4" fill="none" stroke="{c}" stroke-width="2" stroke-linejoin="round" stroke-linecap="round"/>',
 'person':'<circle cx="12" cy="8" r="4" fill="none" stroke="{c}" stroke-width="2"/><path d="M4 21c0-4 4-6 8-6s8 2 8 6" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round"/>',
 'shield':'<path d="M12 2l8 3v6c0 5-3.5 9-8 11-4.500-2-8-6-8-11V5z" fill="none" stroke="{c}" stroke-width="2" stroke-linejoin="round"/>',
 'devices':'<rect x="3" y="5" width="14" height="10" rx="1.5" fill="none" stroke="{c}" stroke-width="2"/><rect x="14" y="10" width="7" height="11" rx="1.5" fill="none" stroke="{c}" stroke-width="2"/>',
 'help':'<circle cx="12" cy="12" r="9" fill="none" stroke="{c}" stroke-width="2"/><path d="M9.500 9.500a2.500 2.500 0 1 1 3.500 2.300c-.7.400-1 .900-1 1.700M12 17v.5" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round"/>',
 'info':'<circle cx="12" cy="12" r="9" fill="none" stroke="{c}" stroke-width="2"/><path d="M12 11v6M12 7.500v.5" stroke="{c}" stroke-width="2" stroke-linecap="round"/>',
 'home':'<path d="M4 11l8-7 8 7v9H4z" fill="{c}"/>',
 'home_o':'<path d="M4 11l8-7 8 7v9H4z" fill="none" stroke="{c}" stroke-width="2" stroke-linejoin="round"/>',
 'pay':'<rect x="3" y="6" width="18" height="12" rx="2" fill="{c}"/><circle cx="12" cy="12" r="3" fill="#fff"/>',
 'pay_o':'<rect x="3" y="6" width="18" height="12" rx="2" fill="none" stroke="{c}" stroke-width="2"/><circle cx="12" cy="12" r="2.500" fill="none" stroke="{c}" stroke-width="2"/>',
 'person_f':'<circle cx="12" cy="8" r="4.500" fill="{c}"/><path d="M3.500 21c0-4.500 4-6.500 8.500-6.500s8.500 2 8.500 6.500z" fill="{c}"/>',
 'chev':'<path d="M9 5l7 7-7 7" fill="none" stroke="{c}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>',
 'wallet':'<rect x="3" y="6" width="18" height="13" rx="2" fill="none" stroke="{c}" stroke-width="2"/><path d="M15 12h6v3h-6z" fill="{c}"/>',
}
def icon(name,x,y,size,c): return f'<g transform="translate({x},{y}) scale({size/24})">{ICON[name].format(c=c)}</g>'
def text(x,y,s,size=14,w=400,c=INK,anchor='start',ls=None):
    l=f' letter-spacing="{ls}"' if ls else ''
    return f'<text x="{x}" y="{y}" font-family="{F}" font-size="{size}" font-weight="{w}" fill="{c}" text-anchor="{anchor}"{l}>{s}</text>'
def rect(x,y,w,h,r=0,fill='#fff',stroke=None,extra=''):
    s=f' stroke="{stroke}"' if stroke else ''
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{r}" fill="{fill}"{s} {extra}/>'
def card(x,y,w,h,r=16): return rect(x,y,w,h,r,'#fff',BD,'filter="url(#sh)"')
def chip(cx,cy,r,fill,name,c,isz=20): return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}"/>'+icon(name,cx-isz/2,cy-isz/2,isz,c)

def defs():
    return f'''<defs>
<linearGradient id="hdr" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="{P}"/><stop offset="0.6" stop-color="#3A9DAE"/><stop offset="1" stop-color="{SF}"/></linearGradient>
<filter id="sh" x="-10%" y="-10%" width="120%" height="130%"><feDropShadow dx="0" dy="4" stdDeviation="6" flood-color="{P}" flood-opacity="0.07"/></filter>
<filter id="shn" x="-10%" y="-20%" width="120%" height="160%"><feDropShadow dx="0" dy="6" stdDeviation="9" flood-color="{P}" flood-opacity="0.16"/></filter></defs>'''

def status(light):
    c='#fff' if light else INK
    return text(32,34,'9:41',16,600,c)+f'<rect x="318" y="24" width="26" height="12" rx="3" fill="none" stroke="{c}" opacity=".5"/><rect x="320" y="26" width="19" height="8" rx="2" fill="{c}"/><circle cx="302" cy="30" r="4" fill="{c}"/>'

def contours():
    out=[]
    for i in range(5):
        pts=' '.join(f'{x},{30+i*26+math.sin(x/55+i)*14:.1f}' for x in range(0,W+1,8))
        out.append(f'<polyline points="{pts}" fill="none" stroke="#fff" stroke-opacity=".12" stroke-width="1.2"/>')
    return ''.join(out)

def nav(active):
    items=[('home','home_o','Home'),('pay','pay_o','Payments'),('person_f','person','Profile')]
    o=rect(16,790,370,68,34,'#fff',None,'filter="url(#shn)"')
    for i,(a,b,l) in enumerate(items):
        cx=16+370/6*(1+2*i); on=i==active; c=P if on else MU
        o+=icon(a if on else b,cx-12,803,24,c)+text(cx,842,l,12,700 if on else 500,c,'middle')
    return o

def wrap(name,body,bg=SF):
    svg=f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">{defs()}{rect(0,0,W,H,0,bg)}{body}</svg>'
    open(f'{name}.svg','w').write(svg)

TX=[('Vodafone Recharge','5 Oct, 9:30 PM','- EGP 150.00','phone',0),('Electricity Bill','4 Oct, 1:15 PM','- EGP 620.00','bolt',0),
    ('Money Transfer','3 Oct, 5:00 PM','- EGP 1,250.00','swap',0),('Cashback','2 Oct, 12:00 PM','+ EGP 75.00','gift',1)]
def tx_rows(y0):
    o=''
    for i,(t,d,a,ic,cr) in enumerate(TX):
        cy=y0+30+i*60
        o+=chip(46,cy,20,('#DDF1EB' if cr else PL),ic,CR if cr else P)
        o+=text(78,cy-3,t,15,600)+text(78,cy+14,d,12,400,MU)+text(370,cy+5,a,14,700,CR if cr else INK,'end')
        if i<len(TX)-1: o+=f'<line x1="32" x2="370" y1="{cy+30}" y2="{cy+30}" stroke="{BD}"/>'
    return o

# HOME
b=f'<rect width="{W}" height="260" fill="url(#hdr)"/>{contours()}{status(True)}'
b+=f'<circle cx="38" cy="96" r="22" fill="#fff"/>'+icon('bell',26,84,24,P)
b+=text(72,90,'Good evening',13,400,'#fff')+text(72,115,'Ahmed',22,700,'#fff')
b+=f'<circle cx="364" cy="96" r="22" fill="#fff"/>'+text(364,103,'A',18,800,P,'middle')
b+=card(16,150,370,142,18)+text(36,184,'Available Balance',13,400,MU)
b+=rect(290,166,80,26,13,PL)+text(330,184,'•••• 4821',12,600,P,'middle')
b+=text(36,232,'EGP 12,450.00',32,800,P,ls='-0.5')+icon('wallet',36,250,15,MU)+text(56,262,'AmanFlow Wallet',12,400,MU)
b+=rect(16,308,370,52,14,AC)+text(190,340,'Pay a Bill',16,600,'#fff','middle')+f'<path d="M232 334h12M238 328v12" stroke="#fff" stroke-width="2" stroke-linecap="round"/>'
for i,(ic,l) in enumerate([('send','Send Money'),('receipt','Pay Bills'),('phone','Mobile Recharge'),('grid','More')]):
    cx=16+28+i*(370-56)/3
    b+=rect(cx-28,386,56,56,16,'#fff',BD,'filter="url(#sh)"')+icon(ic,cx-12,402,24,P)+text(cx,462,l,12,400,INK,'middle')
b+=text(16,510,'Recent Transactions',17,800,P)+text(370,510,'View All',14,500,P,'end')
b+=card(16,526,370,244)+tx_rows(526)+nav(0)
wrap('home',b)

# PAYMENTS
SV=[('phone','Mobile Recharge','Top up any mobile line'),('bolt','Electricity','Pay your electricity bill'),('wifi','Internet','Home internet and DSL'),
    ('water','Water','Pay your water bill'),('gas','Gas','Natural gas bills'),('heart','Donations','Support a registered charity')]
def payments_body():
    b=status(False)+text(16,90,'Payments',22,700,P)
    for i,(ic,n,d) in enumerate(SV):
        x=16+(i%2)*(177+16); y=112+(i//2)*(142+12)
        b+=card(x,y,177,142)+rect(x+16,y+16,38,38,10,PL)+icon(ic,x+25,y+25,20,P)
        b+=text(x+16,y+100,n,15,600)+text(x+16,y+120,d if len(d)<24 else d[:22]+'…',11.5,400,MU)
    b+=text(16,614,'Recent Payments',17,800,P)+card(16,630,370,70)
    b+=chip(46,665,20,PL,'phone',P)+text(78,662,'Mobile Recharge',15,600)+text(78,679,'01012345678 · 6 Oct, 9:41 PM',12,400,MU)+text(370,670,'EGP 150.00',14,700,INK,'end')
    return b
wrap('payments',payments_body()+nav(1))
# PAYMENT SHEET
s=payments_body()+nav(1)+rect(0,0,W,H,0,'#000','','fill-opacity="0.45"')
s+=rect(0,500,W,374,28,'#F4F6F8')+rect(181,512,40,4,2,'#79868A')
s+=text(20,562,'Pay Mobile Recharge',22,700,P)
for y,l in ((586,'Phone / account number'),(654,'Amount (EGP)')):
    s+=rect(20,y,362,56,4,'none',MU)+text(36,y+33,l,15,400,MU)
s+=rect(20,730,362,52,14,P)+text(201,762,'Pay now',16,600,'#fff','middle')
wrap('payment-sheet',s)

# PROFILE
ROWS=[('person','Personal Information','Name, phone, address'),('shield','Security','Security settings'),('devices','Devices','Devices using your account'),
      ('bell','Notifications','Alerts and reminders'),('help','Help &amp; Support','FAQs and contact'),('info','About','AmanFlow demo v0.1.0')]
b=status(False)+text(16,90,'Profile',22,700,P)+card(16,112,370,106,20)
b+=f'<circle cx="64" cy="165" r="30" fill="{P}"/>'+text(64,175,'A',24,700,'#fff','middle')
b+=text(110,157,'Ahmed Hassan',22,700,P)+text(110,178,'+20 10 *** **67',14,400,INK)+text(110,198,'Customer ID: AF-102938',12,400,MU)
b+=card(16,242,370,6*64)
for i,(ic,t,s_) in enumerate(ROWS):
    y=242+i*64
    b+=icon(ic,34,y+20,24,P)+text(74,y+30,t,15,600)+text(74,y+48,s_,12,400,MU)+icon('chev',340,y+20,24,INK)
    if i<5: b+=f'<line x1="16" x2="386" y1="{y+64}" y2="{y+64}" stroke="{BD}"/>'
wrap('profile',b+nav(2))
print('ok')
