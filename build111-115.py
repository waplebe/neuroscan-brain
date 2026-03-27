import re, os, sys

base = r"c:\Users\bookf\OneDrive\Desktop\brain"

def write_ver(content, ver):
    d = os.path.join(base, str(ver))
    os.makedirs(d, exist_ok=True)
    p = os.path.join(d, "index.html")
    with open(p, 'w', encoding='utf-8') as f:
        f.write(content)
    with open(p, 'rb') as f:
        first = f.read(1)[0]
    sz = os.path.getsize(p)
    print(f"v{ver}: {sz} bytes, first_byte={first}")

src = open(os.path.join(base, "110", "index.html"), encoding='utf-8').read()

# ===== V111 =====
v = src
v = v.replace('<title>NeuroScan v110 \u2014 Performance</title>', '<title>NeuroScan v111 \u2014 Nav</title>')
v = v.replace('.sl-tabs{display:flex;flex-shrink:0;border-bottom:1px solid var(--b1)}', '.sl-nav{flex-shrink:0;border-bottom:1px solid var(--b1)}')
v = v.replace('.tab{flex:1;padding:6px 4px;font-size:11px;', '.tab{padding:6px 4px;font-size:11px;')

nav_css = (
    '.sl-cats{display:flex;overflow-x:auto;gap:3px;padding:6px 8px;border-bottom:1px solid var(--b1);scrollbar-width:none}\n'
    '.sl-cats::-webkit-scrollbar{display:none}\n'
    '.sl-cat{flex-shrink:0;padding:4px 10px;font-size:10px;font-weight:600;letter-spacing:.05em;border-radius:16px;cursor:pointer;border:1px solid var(--b1);color:var(--dim);white-space:nowrap;transition:var(--trans);user-select:none}\n'
    '.sl-cat:hover{background:rgba(58,184,255,.08);color:var(--text);border-color:var(--b2)}\n'
    '.sl-cat.on{background:rgba(58,184,255,.15);color:var(--accent);border-color:var(--b2)}\n'
    '.sl-subtabs{display:flex;flex-wrap:wrap;gap:2px;padding:5px 7px}\n'
    '.sl-subtabs.hidden{display:none}\n'
    '.sl-subtabs .tab{flex:0 0 auto;padding:4px 9px;font-size:10px;border-radius:4px;border-bottom:none;border:1px solid transparent;white-space:nowrap;margin:0}\n'
    '.sl-subtabs .tab:hover{background:rgba(58,184,255,.08);border-color:var(--b1)}\n'
    '.sl-subtabs .tab.on{border-color:currentColor;background:rgba(58,184,255,.1)}\n'
    '.tab:hover{color:var(--text)}'
)
v = v.replace('.tab:hover{color:var(--text)}', nav_css)

# Extract tab divs from source
m = re.search(r'<div class="sl-tabs">(.*?)</div>\s*<!-- V60', src, re.DOTALL)
tabs_block = m.group(1)
tab_divs = re.findall(r'(<div class="tab[^>]*id="tab-([^"]+)"[^>]*>.*?</div>)', tabs_block)

tab_cats = {
    'enc':'brain','reg':'brain','net':'brain','mtx':'brain','sci':'brain',
    'imm':'upload','id':'upload','mem':'upload','world':'upload',
    'qualia':'exp','dream':'exp','bci':'exp','fork':'exp','emotion':'exp','creative':'exp',
    'substrate':'substrate','quantum':'substrate','aging':'substrate','backup':'substrate',
    'body':'substrate','plasticity':'substrate','skills':'substrate','knowledge':'substrate',
    'copies':'social','merge':'social','society':'social','telepathy':'social','hive':'social',
    'hardproblem':'philo','zombie':'philo','chinese':'philo','machine':'philo','vote':'philo',
    'si':'science','simulation':'science','posthuman':'science','topo':'science','evolution':'science',
    'realdata':'science','timeline87':'science','cryo88':'science','emscan89':'science','compute90':'science',
    'mypath':'personal','readiness':'personal','ethics':'personal','will':'personal','letter':'personal',
    'dashboard':'finale','tour':'finale','doc':'finale','choice':'finale','apotheosis':'finale',
}
cat_order = ['brain','upload','exp','substrate','social','philo','science','personal','finale']
cat_icons = {
    'brain':'\U0001f9e0 BRAIN','upload':'\u2b06 UPLOAD','exp':'\u2726 EXPERIENCE',
    'substrate':'\u2b22 SUBSTRATE','social':'\u229c SOCIAL','philo':'? PHILOSOPHY',
    'science':'\U0001f4ca SCIENCE','personal':'\u2605 PERSONAL','finale':'\u2b50 FINALE'
}
cat_tabs = {c: [] for c in cat_order}
for full_div, tid in tab_divs:
    cat = tab_cats.get(tid, 'brain')
    cat_tabs[cat].append(full_div.strip())

lines = ['    <div class="sl-nav">']
lines.append('      <div class="sl-cats" id="sl-cats">')
for cat in cat_order:
    on_cls = ' on' if cat == 'brain' else ''
    lines.append(f'        <div class="sl-cat{on_cls}" data-cat="{cat}" onclick="selectCat(\'{cat}\')">{cat_icons[cat]}</div>')
lines.append('      </div>')
for cat in cat_order:
    hidden = '' if cat == 'brain' else ' hidden'
    lines.append(f'      <div class="sl-subtabs{hidden}" id="sl-sub-{cat}">')
    for td in cat_tabs[cat]:
        lines.append(f'        {td}')
    lines.append('      </div>')
lines.append('    </div>')
new_nav_html = '\n'.join(lines)

v = re.sub(r'(?s)<div class="sl-tabs">.*?АПОФЕОЗ</div>\s*</div>', new_nav_html, v)

nav_js = '''<script>
var TAB_TO_CAT = {
  enc:'brain',reg:'brain',net:'brain',mtx:'brain',sci:'brain',
  imm:'upload',id:'upload',mem:'upload',world:'upload',
  qualia:'exp',dream:'exp',bci:'exp',fork:'exp',emotion:'exp',creative:'exp',
  substrate:'substrate',quantum:'substrate',aging:'substrate',backup:'substrate',body:'substrate',plasticity:'substrate',skills:'substrate',knowledge:'substrate',
  copies:'social',merge:'social',society:'social',telepathy:'social',hive:'social',
  hardproblem:'philo',zombie:'philo',chinese:'philo',machine:'philo',vote:'philo',
  si:'science',simulation:'science',posthuman:'science',topo:'science',evolution:'science',realdata:'science',timeline87:'science',cryo88:'science',emscan89:'science',compute90:'science',
  mypath:'personal',readiness:'personal',ethics:'personal',will:'personal',letter:'personal',
  dashboard:'finale',tour:'finale',doc:'finale',choice:'finale',apotheosis:'finale'
};
var currentCat = 'brain';
function selectCat(cat){
  if(cat===currentCat) return;
  currentCat = cat;
  document.querySelectorAll('.sl-subtabs').forEach(function(el){el.classList.add('hidden')});
  var sub = document.getElementById('sl-sub-'+cat);
  if(sub) sub.classList.remove('hidden');
  document.querySelectorAll('.sl-cat').forEach(function(el){el.classList.remove('on')});
  var pill = document.querySelector('[data-cat="'+cat+'"]');
  if(pill) pill.classList.add('on');
}
var _origST = switchTab;
switchTab = function(t){
  _origST(t);
  var cat = TAB_TO_CAT[t];
  if(cat && cat!==currentCat) selectCat(cat);
  document.querySelectorAll('.sl-subtabs .tab').forEach(function(el){el.classList.remove('on')});
  var at = document.getElementById('tab-'+t);
  if(at) at.classList.add('on');
};
</script>'''

v = v.replace('</body>', nav_js + '\n</body>')
write_ver(v, 111)

# ===== V112 =====
v = v.replace('<title>NeuroScan v111 \u2014 Nav</title>', '<title>NeuroScan v112 \u2014 Themes</title>')

old_light = re.search(r'(?s)body\.light\{[^}]+\}', v).group(0)
new_light = ('body.light{\n'
    '  --bg:#f0f4fa; --panel:#e4eaf5; --panel2:#d8e2f0;\n'
    '  --b1:rgba(40,80,200,.15); --b2:rgba(40,80,200,.3);\n'
    '  --accent:#1a5fd4; --accent2:#1a9e60;\n'
    '  --text:#1a2440; --dim:rgba(20,40,100,.5);\n'
    '  --gold:#9a6400; --red:#cc1122; --purple:#6020b0;\n'
    '}')
v = v.replace(old_light, new_light)

light_extras = (
    '\nbody.light .hdr{box-shadow:0 2px 16px rgba(0,0,0,.15)}'
    '\nbody.light .cw{background:#eef2fa}'
    '\nbody.light .cw::before{background:linear-gradient(rgba(40,80,200,.018) 1px,transparent 1px),linear-gradient(90deg,rgba(40,80,200,.018) 1px,transparent 1px);background-size:40px 40px}'
    '\nbody.light .digi-panel{background:rgba(230,238,252,.92)}'
    '\nbody.light .tt{background:rgba(240,244,252,.96)}'
    '\nbody.light .lbl{background:rgba(240,244,252,.9);color:rgba(20,40,100,.8)}'
    '\nbody.light .feat-bar{background:var(--panel2)}'
    '\nbody.light .sl-cat.on{background:rgba(40,80,200,.12)}'
    '\nbody{transition:background-color .3s, color .3s}'
    '\n.hdr,.sl,.sr,.sbar,.layer-row,.feat-bar{transition:background .3s, border-color .3s}'
)
v = v.replace('body.light .layer-row{background:rgba(200,210,230,.95)}',
              'body.light .layer-row{background:rgba(200,210,230,.95)}' + light_extras)
write_ver(v, 112)

# ===== V113 =====
v = v.replace('<title>NeuroScan v112 \u2014 Themes</title>', '<title>NeuroScan v113 \u2014 Shortcuts</title>')

sc_css = (
    '.shortcuts-panel{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);width:min(480px,90vw);background:rgba(6,10,22,.97);backdrop-filter:blur(20px);border:1px solid var(--b2);border-radius:12px;padding:20px;z-index:400;display:none;box-shadow:var(--shadow)}\n'
    '.shortcuts-panel.vis{display:block}\n'
    '.shortcuts-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;padding-bottom:10px;border-bottom:1px solid var(--b1)}\n'
    '.shortcuts-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px}\n'
    '.sc-item{display:flex;align-items:center;gap:10px;padding:5px 0}\n'
    'kbd{background:rgba(58,184,255,.1);border:1px solid var(--b2);border-radius:4px;padding:2px 8px;font-size:11px;font-family:var(--font-mono);color:var(--accent);flex-shrink:0;min-width:32px;text-align:center}\n'
    '.sc-item span{font-size:12px;color:var(--dim)}\n'
)
v = v.replace('</style>', sc_css + '</style>', 1)

v = v.replace(
    '<div class="hb" onclick="openCmdPalette()" title="Command Palette (Ctrl+K)"',
    '<div class="hb" onclick="toggleShortcutsPanel()" title="Keyboard Shortcuts (?)">?</div>\n    <div class="hb" onclick="openCmdPalette()" title="Command Palette (Ctrl+K)"'
)

sc_html = (
    '<div id="shortcuts-panel" class="shortcuts-panel">\n'
    '  <div class="shortcuts-header">\n'
    '    <span style="font-size:13px;font-weight:700;color:var(--accent)">Keyboard Shortcuts</span>\n'
    '    <span onclick="toggleShortcutsPanel()" style="cursor:pointer;font-size:16px;color:var(--dim)">\u00d7</span>\n'
    '  </div>\n'
    '  <div class="shortcuts-grid">\n'
    '    <div class="sc-item"><kbd>Ctrl+K</kbd><span>Command Palette</span></div>\n'
    '    <div class="sc-item"><kbd>Space</kbd><span>Toggle Rotation</span></div>\n'
    '    <div class="sc-item"><kbd>F</kbd><span>Toggle fMRI</span></div>\n'
    '    <div class="sc-item"><kbd>W</kbd><span>Toggle Wireframe</span></div>\n'
    '    <div class="sc-item"><kbd>L</kbd><span>Toggle Labels</span></div>\n'
    '    <div class="sc-item"><kbd>R</kbd><span>Reset View</span></div>\n'
    '    <div class="sc-item"><kbd>1</kbd><span>Awake State</span></div>\n'
    '    <div class="sc-item"><kbd>2</kbd><span>Sleep State</span></div>\n'
    '    <div class="sc-item"><kbd>3</kbd><span>Meditate State</span></div>\n'
    '    <div class="sc-item"><kbd>4</kbd><span>Stress State</span></div>\n'
    '    <div class="sc-item"><kbd>U</kbd><span>Upload Mind</span></div>\n'
    '    <div class="sc-item"><kbd>T</kbd><span>Digital Twin</span></div>\n'
    '    <div class="sc-item"><kbd>?</kbd><span>This Panel</span></div>\n'
    '    <div class="sc-item"><kbd>Esc</kbd><span>Close Panels</span></div>\n'
    '  </div>\n'
    '</div>\n'
)
v = v.replace('<div id="perf-panel" class="perf-panel"></div>', sc_html + '<div id="perf-panel" class="perf-panel"></div>', 1)

sc_js = '''<script>
var shortcutsOpen = false;
function toggleShortcutsPanel(){
  shortcutsOpen = !shortcutsOpen;
  var p = document.getElementById('shortcuts-panel');
  if(p) p.classList.toggle('vis', shortcutsOpen);
}
document.addEventListener('keydown', function(e){
  if(typeof cmdOpen !== 'undefined' && cmdOpen) return;
  if(e.ctrlKey || e.metaKey || e.altKey) return;
  var tag = (e.target||{}).tagName||'';
  if(tag==='INPUT'||tag==='TEXTAREA') return;
  switch(e.key){
    case ' ': e.preventDefault(); var br=document.getElementById('bRot');if(br)br.click(); break;
    case 'f': case 'F': var bf=document.getElementById('bFmri');if(bf)bf.click(); break;
    case 'w': case 'W': var bw=document.getElementById('bWire');if(bw)bw.click(); break;
    case 'l': case 'L': var bl=document.getElementById('bLbl');if(bl)bl.click(); break;
    case 'r': case 'R': var brr=document.getElementById('bReset');if(brr)brr.click(); break;
    case '1': if(typeof setBrainState==='function') setBrainState('awake'); break;
    case '2': if(typeof setBrainState==='function') setBrainState('sleep'); break;
    case '3': if(typeof setBrainState==='function') setBrainState('meditate'); break;
    case '4': if(typeof setBrainState==='function') setBrainState('stress'); break;
    case 'u': case 'U': var bu=document.getElementById('bUpload');if(bu)bu.click(); break;
    case 't': case 'T': var bt=document.getElementById('bTwin');if(bt)bt.click(); break;
    case '?': case '/': toggleShortcutsPanel(); break;
    case 'Escape':
      if(shortcutsOpen) toggleShortcutsPanel();
      if(typeof PERF!=='undefined' && PERF.perfPanelOpen && typeof togglePerfPanel==='function') togglePerfPanel();
      break;
  }
});
</script>'''
v = v.replace('</body>', sc_js + '\n</body>')
write_ver(v, 113)

# ===== V114 =====
v = v.replace('<title>NeuroScan v113 \u2014 Shortcuts</title>', '<title>NeuroScan v114 \u2014 Tooltips</title>')

old_tt = '.tt{position:fixed;background:rgba(4,9,20,.94);border:1px solid var(--b2);padding:4px 9px;font-size:8.5px;color:var(--text);pointer-events:none;z-index:200;display:none;white-space:nowrap;backdrop-filter:blur(12px);border-radius:6px}'
new_tt = (
    '.tt{position:fixed;background:rgba(4,9,20,.96);backdrop-filter:blur(12px);border:1px solid var(--b2);padding:8px 12px;font-size:12px;color:var(--text);pointer-events:none;z-index:200;display:none;border-radius:8px;box-shadow:var(--shadow);max-width:220px;line-height:1.5}\n'
    '.tt-title{font-size:12px;font-weight:700;color:var(--accent);margin-bottom:3px}\n'
    '.tt-body{font-size:11px;color:var(--dim);line-height:1.5}\n'
    '.tt-tag{display:inline-block;font-size:9px;padding:1px 6px;border-radius:8px;border:1px solid var(--b1);color:var(--dim);margin-top:4px}'
)
v = v.replace(old_tt, new_tt)

tt_js = '''<script>
var RICH_TOOLTIPS = {
  bUpload: {title:'Upload Mind', body:'Simulate the 7-stage consciousness transfer process. Scanning, digitization, and awakening.', tag:'Core Feature'},
  bTwin: {title:'Digital Twin', body:'Activate a digital copy of the biological brain that runs in parallel and accumulates divergence.', tag:'Identity'},
  bAccel: {title:'Time Acceleration', body:'Run digital consciousness at 2x, 10x, 100x, or 1000x real time. Explore subjective time.', tag:'Consciousness'},
  bFmri: {title:'fMRI Mode', body:'Simulate functional MRI \u2014 color brain regions by activity level using BOLD signal simulation.', tag:'Imaging'},
  bApotheosis: {title:'Apotheosis', body:'The 8-phase grand finale sequence. Combines all visual effects. A meditation on digital transcendence.', tag:'Experience'}
};
document.addEventListener('mouseover', function(e){
  var el = e.target.closest('[id]');
  if(!el || !RICH_TOOLTIPS[el.id]) return;
  var rt = RICH_TOOLTIPS[el.id];
  var ttEl = document.getElementById('tt');
  if(!ttEl) return;
  ttEl.innerHTML = '<div class="tt-title">'+rt.title+'</div><div class="tt-body">'+rt.body+'</div><span class="tt-tag">'+rt.tag+'</span>';
  ttEl.style.display = 'block';
});
</script>'''
v = v.replace('</body>', tt_js + '\n</body>')
write_ver(v, 114)

# ===== V115 =====
v = v.replace('<title>NeuroScan v114 \u2014 Tooltips</title>', '<title>NeuroScan v115 \u2014 Notifications</title>')

v = v.replace('<body>', '<body>\n<div id="toast-container" class="toast-container"></div>', 1)

toast_css = (
    '.toast-container{position:fixed;bottom:52px;right:14px;display:flex;flex-direction:column;gap:8px;z-index:600;pointer-events:none}\n'
    '.toast{background:rgba(6,12,26,.96);backdrop-filter:blur(16px);border:1px solid var(--b1);border-radius:8px;padding:10px 14px;font-size:12px;color:var(--text);display:flex;align-items:flex-start;gap:10px;min-width:240px;max-width:320px;box-shadow:var(--shadow);animation:toastIn .2s ease;transition:opacity .3s, transform .3s;pointer-events:all}\n'
    '.toast.removing{opacity:0;transform:translateX(20px)}\n'
    '@keyframes toastIn{from{opacity:0;transform:translateX(20px)}to{opacity:1;transform:none}}\n'
    '.toast-icon{font-size:16px;flex-shrink:0;margin-top:1px}\n'
    '.toast-body{flex:1}\n'
    '.toast-title{font-size:12px;font-weight:600;color:var(--text);margin-bottom:2px}\n'
    '.toast-msg{font-size:11px;color:var(--dim);line-height:1.5}\n'
    '.toast-close{font-size:14px;color:var(--dim);cursor:pointer;flex-shrink:0;pointer-events:all;margin-top:-2px;transition:color .15s}\n'
    '.toast-close:hover{color:var(--text)}\n'
    '.toast.success{border-color:rgba(80,232,160,.35);background:rgba(4,20,16,.96)}\n'
    '.toast.warning{border-color:rgba(255,200,74,.35);background:rgba(20,14,4,.96)}\n'
    '.toast.error{border-color:rgba(255,85,104,.35);background:rgba(20,4,8,.96)}\n'
    '.toast.info{border-color:var(--b2)}\n'
)
v = v.replace('</style>', toast_css + '</style>', 1)

toast_js = '''<script>
var _toastId = 0;
function showToast(msg, opts){
  opts = opts || {};
  var type = opts.type || 'info';
  var title = opts.title || '';
  var duration = opts.duration !== undefined ? opts.duration : 3500;
  var icon = opts.icon || (type==='success'?'\u2713':type==='warning'?'\u26a0':type==='error'?'\u2717':'\u2139');
  var id = 'toast-'+(++_toastId);
  var container = document.getElementById('toast-container');
  if(!container) return;
  var el = document.createElement('div');
  el.className = 'toast ' + type;
  el.id = id;
  el.innerHTML = '<span class="toast-icon">'+icon+'</span>'+
    '<div class="toast-body">'+
    (title?'<div class="toast-title">'+title+'</div>':'')+
    '<div class="toast-msg">'+msg+'</div>'+
    '</div>'+
    '<span class="toast-close" onclick="removeToast(\\\''+id+'\\\')">&#215;</span>';
  container.appendChild(el);
  if(duration > 0){
    setTimeout(function(){ removeToast(id); }, duration);
  }
}
function removeToast(id){
  var el = document.getElementById(id);
  if(!el) return;
  el.classList.add('removing');
  setTimeout(function(){ if(el.parentNode) el.parentNode.removeChild(el); }, 350);
}
setTimeout(function(){
  showToast('Welcome to NeuroScan v115', {title:'Platform Ready', type:'success', icon:'\U0001f9e0', duration:4000});
}, 800);
</script>'''
v = v.replace('</body>', toast_js + '\n</body>')
write_ver(v, 115)

print("Done!")