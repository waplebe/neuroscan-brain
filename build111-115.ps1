# Build NeuroScan v111-v115
$ErrorActionPreference = 'Stop'
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$baseDir = "c:\Users\bookf\OneDrive\Desktop\brain"

function writeVer($content, $ver) {
    $dir = "$baseDir\$ver"
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir | Out-Null }
    $path = "$dir\index.html"
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
    $bytes = [System.IO.File]::ReadAllBytes($path)
    Write-Host "v$ver -> $path  |  $($bytes.Length) bytes  |  first_byte=$($bytes[0])"
}

# Read source
$src = [System.IO.File]::ReadAllText("$baseDir\110\index.html", (New-Object System.Text.UTF8Encoding $false))

# ============================================================
# V111 - TWO-LEVEL SIDEBAR NAV
# ============================================================
$v = $src

# 1. Title
$v = $v.Replace('<title>NeuroScan v110 — Performance</title>', '<title>NeuroScan v111 — Nav</title>')

# 2. CSS: replace sl-tabs rule
$v = $v.Replace('.sl-tabs{display:flex;flex-shrink:0;border-bottom:1px solid var(--b1)}', '.sl-nav{flex-shrink:0;border-bottom:1px solid var(--b1)}')

# 3. CSS: remove flex:1 from .tab
$v = $v.Replace('.tab{flex:1;padding:6px 4px;font-size:11px;', '.tab{padding:6px 4px;font-size:11px;')

# 4. CSS: insert nav CSS before .tab:hover
$newNavCss = ".sl-cats{display:flex;overflow-x:auto;gap:3px;padding:6px 8px;border-bottom:1px solid var(--b1);scrollbar-width:none}" + [char]13 + [char]10 +
".sl-cats::-webkit-scrollbar{display:none}" + [char]13 + [char]10 +
".sl-cat{flex-shrink:0;padding:4px 10px;font-size:10px;font-weight:600;letter-spacing:.05em;border-radius:16px;cursor:pointer;border:1px solid var(--b1);color:var(--dim);white-space:nowrap;transition:var(--trans);user-select:none}" + [char]13 + [char]10 +
".sl-cat:hover{background:rgba(58,184,255,.08);color:var(--text);border-color:var(--b2)}" + [char]13 + [char]10 +
".sl-cat.on{background:rgba(58,184,255,.15);color:var(--accent);border-color:var(--b2)}" + [char]13 + [char]10 +
".sl-subtabs{display:flex;flex-wrap:wrap;gap:2px;padding:5px 7px}" + [char]13 + [char]10 +
".sl-subtabs.hidden{display:none}" + [char]13 + [char]10 +
".sl-subtabs .tab{flex:0 0 auto;padding:4px 9px;font-size:10px;border-radius:4px;border-bottom:none;border:1px solid transparent;white-space:nowrap;margin:0}" + [char]13 + [char]10 +
".sl-subtabs .tab:hover{background:rgba(58,184,255,.08);border-color:var(--b1)}" + [char]13 + [char]10 +
".sl-subtabs .tab.on{border-color:currentColor;background:rgba(58,184,255,.1)}" + [char]13 + [char]10 +
".tab:hover{color:var(--text)}"

$v = $v.Replace(".tab:hover{color:var(--text)}", $newNavCss)

# 5. HTML: replace sl-tabs block with two-level nav
$oldNavHtml = '    <div class="sl-tabs">'
# Find the start position and use regex to replace the whole block
$newNavHtml = @'
    <div class="sl-nav">
      <div class="sl-cats" id="sl-cats">
        <div class="sl-cat on" data-cat="brain" onclick="selectCat('brain')">&#x1F9E0; BRAIN</div>
        <div class="sl-cat" data-cat="upload" onclick="selectCat('upload')">&#x2B06; UPLOAD</div>
        <div class="sl-cat" data-cat="exp" onclick="selectCat('exp')">&#x2726; EXPERIENCE</div>
        <div class="sl-cat" data-cat="substrate" onclick="selectCat('substrate')">&#x2B22; SUBSTRATE</div>
        <div class="sl-cat" data-cat="social" onclick="selectCat('social')">&#x229C; SOCIAL</div>
        <div class="sl-cat" data-cat="philo" onclick="selectCat('philo')">? PHILOSOPHY</div>
        <div class="sl-cat" data-cat="science" onclick="selectCat('science')">&#x1F4CA; SCIENCE</div>
        <div class="sl-cat" data-cat="personal" onclick="selectCat('personal')">&#x2605; PERSONAL</div>
        <div class="sl-cat" data-cat="finale" onclick="selectCat('finale')">&#x2B50; FINALE</div>
      </div>
      <div class="sl-subtabs" id="sl-sub-brain">
        <div class="tab on" id="tab-enc" onclick="switchTab('enc')">&#x042D;&#x041D;&#x0426;&#x0418;&#x041A;&#x041B;.</div>
        <div class="tab" id="tab-reg" onclick="switchTab('reg')">&#x0420;&#x0415;&#x0413;&#x0418;&#x041E;&#x041D;&#x042B;</div>
        <div class="tab" id="tab-net" onclick="switchTab('net')">&#x0421;&#x0415;&#x0422;&#x0418;</div>
        <div class="tab" id="tab-mtx" onclick="switchTab('mtx')">&#x041C;&#x0410;&#x0422;&#x0420;&#x0418;&#x0426;&#x0410;</div>
        <div class="tab" id="tab-sci" onclick="switchTab('sci')" style="color:var(--gold)">&#x041D;&#x0410;&#x0423;&#x041A;&#x0410;</div>
      </div>
      <div class="sl-subtabs hidden" id="sl-sub-upload">
        <div class="tab" id="tab-imm" onclick="switchTab('imm')" style="color:var(--purple)">&#x0411;&#x0415;&#x0421;&#x0421;&#x041C;.</div>
        <div class="tab" id="tab-id" onclick="switchTab('id')" style="color:var(--accent2)">ID</div>
        <div class="tab" id="tab-mem" onclick="switchTab('mem')" style="color:var(--accent)">&#x041F;&#x0410;&#x041C;&#x042F;&#x0422;&#x042C;</div>
        <div class="tab" id="tab-world" onclick="switchTab('world')" style="color:var(--gold)">&#x041C;&#x0418;&#x0420;</div>
      </div>
      <div class="sl-subtabs hidden" id="sl-sub-exp">
        <div class="tab" id="tab-qualia" onclick="switchTab('qualia')" style="color:#d070ff">&#x041A;&#x0412;&#x0410;&#x041B;&#x0418;&#x0410;</div>
        <div class="tab" id="tab-dream" onclick="switchTab('dream')" style="color:#0dd">&#x0421;&#x041E;&#x041D;</div>
        <div class="tab" id="tab-bci" onclick="switchTab('bci')" style="color:#ff9030">BCI</div>
        <div class="tab" id="tab-fork" onclick="switchTab('fork')" style="color:#00ff88">&#x0424;&#x041E;&#x0420;&#x041A;&#x0418;</div>
        <div class="tab" id="tab-emotion" onclick="switchTab('emotion')" style="color:#ff6eb4">&#x042D;&#x041C;&#x041E;&#x0426;&#x0418;&#x0418;</div>
        <div class="tab" id="tab-creative" onclick="switchTab('creative')" style="color:#ff40ff">&#x0422;&#x0412;&#x041E;&#x0420;&#x0427;&#x0415;&#x0421;&#x0422;&#x0412;&#x041E;</div>
      </div>
      <div class="sl-subtabs hidden" id="sl-sub-substrate">
        <div class="tab" id="tab-substrate" onclick="switchTab('substrate')" style="color:#aabbcc">&#x0421;&#x0423;&#x0411;&#x0421;&#x0422;&#x0420;&#x0410;&#x0422;</div>
        <div class="tab" id="tab-quantum" onclick="switchTab('quantum')" style="color:#00ccdd">&#x041A;&#x0412;&#x0410;&#x041D;&#x0422;&#x0423;&#x041C;</div>
        <div class="tab" id="tab-aging" onclick="switchTab('aging')" style="color:#ffaa44">&#x0421;&#x0422;&#x0410;&#x0420;&#x0415;&#x041D;&#x0418;&#x0415;</div>
        <div class="tab" id="tab-backup" onclick="switchTab('backup')" style="color:#6699ff">&#x0411;&#x042D;&#x041A;&#x0410;&#x041F;</div>
        <div class="tab" id="tab-body" onclick="switchTab('body')" style="color:#00ee44">&#x0422;&#x0415;&#x041B;&#x041E;</div>
        <div class="tab" id="tab-plasticity" onclick="switchTab('plasticity')" style="color:#a8ff50">&#x041F;&#x041B;&#x0410;&#x0421;&#x0422;&#x0418;&#x041A;&#x0410;</div>
        <div class="tab" id="tab-skills" onclick="switchTab('skills')" style="color:var(--gold)">&#x041D;&#x0410;&#x0412;&#x042B;&#x041A;&#x0418;</div>
        <div class="tab" id="tab-knowledge" onclick="switchTab('knowledge')" style="color:#c084fc">&#x0417;&#x041D;&#x0410;&#x041D;&#x0418;&#x042F;</div>
      </div>
      <div class="sl-subtabs hidden" id="sl-sub-social">
        <div class="tab" id="tab-copies" onclick="switchTab('copies')" style="color:#b060ff">&#x041A;&#x041E;&#x041F;&#x0418;&#x0418;</div>
        <div class="tab" id="tab-merge" onclick="switchTab('merge')" style="color:#ff8040">&#x0421;&#x041B;&#x0418;&#x042F;&#x041D;&#x0418;&#x0415;</div>
        <div class="tab" id="tab-society" onclick="switchTab('society')" style="color:#40e8d0">&#x041E;&#x0411;&#x0429;&#x0415;&#x0421;&#x0422;&#x0412;&#x041E;</div>
        <div class="tab" id="tab-telepathy" onclick="switchTab('telepathy')" style="color:#80c8ff">&#x0422;&#x0415;&#x041B;&#x0415;&#x041F;&#x0410;&#x0422;&#x0418;&#x042F;</div>
        <div class="tab" id="tab-hive" onclick="switchTab('hive')" style="color:#ffb830">&#x0420;&#x041E;&#x0419;</div>
      </div>
      <div class="sl-subtabs hidden" id="sl-sub-philo">
        <div class="tab" id="tab-hardproblem" onclick="switchTab('hardproblem')" style="color:#c084fc">&#x041F;&#x0420;&#x041E;&#x0411;&#x041B;&#x0415;&#x041C;&#x0410;</div>
        <div class="tab" id="tab-zombie" onclick="switchTab('zombie')" style="color:#aaaaaa">&#x0417;&#x041E;&#x041C;&#x0411;&#x0418;</div>
        <div class="tab" id="tab-chinese" onclick="switchTab('chinese')" style="color:#ffcc50">&#x041A;&#x041E;&#x041C;&#x041D;&#x0410;&#x0422;&#x0410;</div>
        <div class="tab" id="tab-machine" onclick="switchTab('machine')" style="color:#ff40dd">&#x041C;&#x0410;&#x0428;&#x0418;&#x041D;&#x0410;</div>
        <div class="tab" id="tab-vote" onclick="switchTab('vote')" style="color:#00e8ff">&#x0413;&#x041E;&#x041B;&#x041E;&#x0421;</div>
      </div>
      <div class="sl-subtabs hidden" id="sl-sub-science">
        <div class="tab" id="tab-si" onclick="switchTab('si')" style="color:#fff070">&#x0418;&#x041D;&#x0422;&#x0415;&#x041B;&#x041B;&#x0415;&#x041A;&#x0422;</div>
        <div class="tab" id="tab-simulation" onclick="switchTab('simulation')" style="color:#00e840">&#x0421;&#x0418;&#x041C;&#x0423;&#x041B;&#x042F;&#x0426;&#x0418;&#x042F;</div>
        <div class="tab" id="tab-posthuman" onclick="switchTab('posthuman')" style="color:#aac0ff">&#x041F;&#x041E;&#x0421;&#x0422;-&#x0427;&#x0415;&#x041B;&#x041E;&#x0412;&#x0415;&#x041A;</div>
        <div class="tab" id="tab-topo" onclick="switchTab('topo')" style="color:#6090ff">&#x0422;&#x041E;&#x041F;&#x041E;&#x041B;&#x041E;&#x0413;&#x0418;&#x042F;</div>
        <div class="tab" id="tab-evolution" onclick="switchTab('evolution')" style="color:#80e840">&#x042D;&#x0412;&#x041E;&#x041B;&#x042E;&#x0426;&#x0418;&#x042F;</div>
        <div class="tab" id="tab-realdata" onclick="switchTab('realdata')" style="color:#3ab8ff">&#x0414;&#x0410;&#x041D;&#x041D;&#x042B;&#x0415;</div>
        <div class="tab" id="tab-timeline87" onclick="switchTab('timeline87')" style="color:#ffcc50">&#x0425;&#x0420;&#x041E;&#x041D;&#x041E;&#x041B;&#x041E;&#x0413;&#x0418;&#x042F;</div>
        <div class="tab" id="tab-cryo88" onclick="switchTab('cryo88')" style="color:#88ccff">&#x041A;&#x0420;&#x0418;&#x041E;&#x041D;&#x0418;&#x041A;&#x0410;</div>
        <div class="tab" id="tab-emscan89" onclick="switchTab('emscan89')" style="color:#ffa030">&#x0421;&#x041A;&#x0410;&#x041D;&#x0418;&#x0420;&#x041E;&#x0412;&#x0410;&#x041D;&#x0418;&#x0415;</div>
        <div class="tab" id="tab-compute90" onclick="switchTab('compute90')" style="color:#c0c8e0">&#x0412;&#x042B;&#x0427;&#x0418;&#x0421;&#x041B;&#x0415;&#x041D;&#x0418;&#x042F;</div>
      </div>
      <div class="sl-subtabs hidden" id="sl-sub-personal">
        <div class="tab" id="tab-mypath" onclick="switchTab('mypath')" style="color:#ffcc50">&#x041C;&#x041E;&#x0419; &#x041F;&#x0423;&#x0422;&#x042C;</div>
        <div class="tab" id="tab-readiness" onclick="switchTab('readiness')" style="color:#00ccdd">&#x0413;&#x041E;&#x0422;&#x041E;&#x0412;&#x041D;&#x041E;&#x0421;&#x0422;&#x042C;</div>
        <div class="tab" id="tab-ethics" onclick="switchTab('ethics')" style="color:#ffaa30">&#x042D;&#x0422;&#x0418;&#x041A;&#x0410;</div>
        <div class="tab" id="tab-will" onclick="switchTab('will')" style="color:#ccaa60">&#x0417;&#x0410;&#x0412;&#x0415;&#x0429;&#x0410;&#x041D;&#x0418;&#x0415;</div>
        <div class="tab" id="tab-letter" onclick="switchTab('letter')" style="color:#60c898">&#x041F;&#x0418;&#x0421;&#x042C;&#x041C;&#x041E;</div>
      </div>
      <div class="sl-subtabs hidden" id="sl-sub-finale">
        <div class="tab" id="tab-dashboard" onclick="switchTab('dashboard')" style="color:#a0a8ff">&#x041F;&#x0410;&#x041D;&#x0415;&#x041B;&#x042C;</div>
        <div class="tab" id="tab-tour" onclick="switchTab('tour')" style="color:#30ff80">&#x0422;&#x0423;&#x0420;</div>
        <div class="tab" id="tab-doc" onclick="switchTab('doc')" style="color:#ffcc50">&#x0414;&#x041E;&#x041A;&#x0423;&#x041C;&#x0415;&#x041D;&#x0422;&#x0410;&#x041B;&#x042C;&#x041D;&#x042B;&#x0419;</div>
        <div class="tab" id="tab-choice" onclick="switchTab('choice')" style="color:#ff6080">&#x0412;&#x042B;&#x0411;&#x041E;&#x0420;</div>
        <div class="tab" id="tab-apotheosis" onclick="switchTab('apotheosis')" style="color:#ffcc50;font-weight:700">&#x0410;&#x041F;&#x041E;&#x0424;&#x0415;&#x041E;&#x0417;</div>
      </div>
    </div>
'@

# Replace the entire sl-tabs block using regex
$v = [regex]::Replace($v, '(?s)<div class="sl-tabs">.*?АПОФЕОЗ</div>\s*</div>', $newNavHtml.TrimEnd())

# 6. JS: Add TAB_TO_CAT, selectCat, and switchTab patch before </body>
$navJs = @'
<script>
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
</script>
'@

$v = $v.Replace('<div id="perf-panel" class="perf-panel"></div>' + [char]13 + [char]10 + '</body>', '<div id="perf-panel" class="perf-panel"></div>' + [char]13 + [char]10 + $navJs + '</body>')

writeVer $v 111

# ============================================================
# V112 - DARK/LIGHT THEME POLISH
# ============================================================
$v = $v.Replace('<title>NeuroScan v111 — Nav</title>', '<title>NeuroScan v112 — Themes</title>')

# Replace body.light CSS block
$oldLight = [regex]::Match($v, '(?s)body\.light\{[^}]+\}').Value
$newLight = 'body.light{' + [char]13 + [char]10 +
'  --bg:#f0f4fa; --panel:#e4eaf5; --panel2:#d8e2f0;' + [char]13 + [char]10 +
'  --b1:rgba(40,80,200,.15); --b2:rgba(40,80,200,.3);' + [char]13 + [char]10 +
'  --accent:#1a5fd4; --accent2:#1a9e60;' + [char]13 + [char]10 +
'  --text:#1a2440; --dim:rgba(20,40,100,.5);' + [char]13 + [char]10 +
'  --gold:#9a6400; --red:#cc1122; --purple:#6020b0;' + [char]13 + [char]10 +
'}'

$v = $v.Replace($oldLight, $newLight)

# Add light theme extra rules after body.light block
$lightExtras = [char]13 + [char]10 +
'body.light .hdr{box-shadow:0 2px 16px rgba(0,0,0,.15)}' + [char]13 + [char]10 +
'body.light .cw{background:#eef2fa}' + [char]13 + [char]10 +
'body.light .cw::before{background:linear-gradient(rgba(40,80,200,.018) 1px,transparent 1px),linear-gradient(90deg,rgba(40,80,200,.018) 1px,transparent 1px);background-size:40px 40px}' + [char]13 + [char]10 +
'body.light .digi-panel{background:rgba(230,238,252,.92)}' + [char]13 + [char]10 +
'body.light .tt{background:rgba(240,244,252,.96)}' + [char]13 + [char]10 +
'body.light .lbl{background:rgba(240,244,252,.9);color:rgba(20,40,100,.8)}' + [char]13 + [char]10 +
'body.light .feat-bar{background:var(--panel2)}' + [char]13 + [char]10 +
'body.light .sl-cat.on{background:rgba(40,80,200,.12)}' + [char]13 + [char]10 +
'body{transition:background-color .3s, color .3s}' + [char]13 + [char]10 +
'.hdr,.sl,.sr,.sbar,.layer-row,.feat-bar{transition:background .3s, border-color .3s}'

$v = $v.Replace('body.light .layer-row{background:rgba(200,210,230,.95)}', 'body.light .layer-row{background:rgba(200,210,230,.95)}' + $lightExtras)

writeVer $v 112

# ============================================================
# V113 - KEYBOARD SHORTCUTS PANEL
# ============================================================
$v = $v.Replace('<title>NeuroScan v112 — Themes</title>', '<title>NeuroScan v113 — Shortcuts</title>')

# Add shortcuts CSS before closing </style>
$shortcutsCSS = '.shortcuts-panel{position:fixed;top:50%;left:50%;transform:translate(-50%,-50%);width:min(480px,90vw);background:rgba(6,10,22,.97);backdrop-filter:blur(20px);border:1px solid var(--b2);border-radius:12px;padding:20px;z-index:400;display:none;box-shadow:var(--shadow)}' + [char]13 + [char]10 +
'.shortcuts-panel.vis{display:block}' + [char]13 + [char]10 +
'.shortcuts-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;padding-bottom:10px;border-bottom:1px solid var(--b1)}' + [char]13 + [char]10 +
'.shortcuts-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px}' + [char]13 + [char]10 +
'.sc-item{display:flex;align-items:center;gap:10px;padding:5px 0}' + [char]13 + [char]10 +
'kbd{background:rgba(58,184,255,.1);border:1px solid var(--b2);border-radius:4px;padding:2px 8px;font-size:11px;font-family:var(--font-mono);color:var(--accent);flex-shrink:0;min-width:32px;text-align:center}' + [char]13 + [char]10 +
'.sc-item span{font-size:12px;color:var(--dim)}'

$v = $v.Replace('</style>', $shortcutsCSS + [char]13 + [char]10 + '</style>')

# Add ? button in header (before the ⌘K button)
$v = $v.Replace('<div class="hb" onclick="openCmdPalette()" title="Command Palette (Ctrl+K)"', '<div class="hb" onclick="toggleShortcutsPanel()" title="Keyboard Shortcuts (?)">?</div>' + [char]13 + [char]10 + '    <div class="hb" onclick="openCmdPalette()" title="Command Palette (Ctrl+K)"')

# Add shortcuts panel HTML before perf-panel
$shortcutsHTML = '<div id="shortcuts-panel" class="shortcuts-panel">' + [char]13 + [char]10 +
'  <div class="shortcuts-header">' + [char]13 + [char]10 +
'    <span style="font-size:13px;font-weight:700;color:var(--accent)">Keyboard Shortcuts</span>' + [char]13 + [char]10 +
'    <span onclick="toggleShortcutsPanel()" style="cursor:pointer;font-size:16px;color:var(--dim)">&#215;</span>' + [char]13 + [char]10 +
'  </div>' + [char]13 + [char]10 +
'  <div class="shortcuts-grid">' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>Ctrl+K</kbd><span>Command Palette</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>Space</kbd><span>Toggle Rotation</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>F</kbd><span>Toggle fMRI</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>W</kbd><span>Toggle Wireframe</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>L</kbd><span>Toggle Labels</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>R</kbd><span>Reset View</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>1</kbd><span>Awake State</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>2</kbd><span>Sleep State</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>3</kbd><span>Meditate State</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>4</kbd><span>Stress State</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>U</kbd><span>Upload Mind</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>T</kbd><span>Digital Twin</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>?</kbd><span>This Panel</span></div>' + [char]13 + [char]10 +
'    <div class="sc-item"><kbd>Esc</kbd><span>Close Panels</span></div>' + [char]13 + [char]10 +
'  </div>' + [char]13 + [char]10 +
'</div>' + [char]13 + [char]10

$v = $v.Replace('<div id="perf-panel" class="perf-panel"></div>', $shortcutsHTML + '<div id="perf-panel" class="perf-panel"></div>')

# Add shortcuts JS before closing nav script block
$shortcutsJS = @'
<script>
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
      if(typeof PERF !== 'undefined' && PERF.perfPanelOpen && typeof togglePerfPanel === 'function') togglePerfPanel();
      break;
  }
});
</script>
'@

$v = $v.Replace('</body>', $shortcutsJS + '</body>')

writeVer $v 113

# ============================================================
# V114 - TOOLTIP SYSTEM UPGRADE
# ============================================================
$v = $v.Replace('<title>NeuroScan v113 — Shortcuts</title>', '<title>NeuroScan v114 — Tooltips</title>')

# Replace .tt CSS
$oldTT = '.tt{position:fixed;background:rgba(4,9,20,.94);border:1px solid var(--b2);padding:4px 9px;font-size:8.5px;color:var(--text);pointer-events:none;z-index:200;display:none;white-space:nowrap;backdrop-filter:blur(12px);border-radius:6px}'
$newTT = '.tt{position:fixed;background:rgba(4,9,20,.96);backdrop-filter:blur(12px);border:1px solid var(--b2);padding:8px 12px;font-size:12px;color:var(--text);pointer-events:none;z-index:200;display:none;border-radius:8px;box-shadow:var(--shadow);max-width:220px;line-height:1.5}' + [char]13 + [char]10 +
'.tt-title{font-size:12px;font-weight:700;color:var(--accent);margin-bottom:3px}' + [char]13 + [char]10 +
'.tt-body{font-size:11px;color:var(--dim);line-height:1.5}' + [char]13 + [char]10 +
'.tt-tag{display:inline-block;font-size:9px;padding:1px 6px;border-radius:8px;border:1px solid var(--b1);color:var(--dim);margin-top:4px}'

$v = $v.Replace($oldTT, $newTT)

# Add rich tooltips JS before </body>
$tooltipJS = @'
<script>
var RICH_TOOLTIPS = {
  bUpload: {title:'Upload Mind', body:'Simulate the 7-stage consciousness transfer process. Scanning, digitization, and awakening.', tag:'Core Feature'},
  bTwin: {title:'Digital Twin', body:'Activate a digital copy of the biological brain that runs in parallel and accumulates divergence.', tag:'Identity'},
  bAccel: {title:'Time Acceleration', body:'Run digital consciousness at 2x, 10x, 100x, or 1000x real time. Explore subjective time.', tag:'Consciousness'},
  bFmri: {title:'fMRI Mode', body:'Simulate functional MRI — color brain regions by activity level using BOLD signal simulation.', tag:'Imaging'},
  bApotheosis: {title:'Apotheosis', body:'The 8-phase grand finale sequence. Combines all visual effects. A meditation on digital transcendence.', tag:'Experience'}
};
document.addEventListener('mouseover', function(e){
  var el = e.target.closest('[id]');
  if(!el || !RICH_TOOLTIPS[el.id]) return;
  var rt = RICH_TOOLTIPS[el.id];
  var tt = document.getElementById('tt');
  if(!tt) return;
  tt.innerHTML = '<div class="tt-title">'+rt.title+'</div><div class="tt-body">'+rt.body+'</div><span class="tt-tag">'+rt.tag+'</span>';
  tt.style.display = 'block';
});
</script>
'@

$v = $v.Replace('</body>', $tooltipJS + '</body>')

writeVer $v 114

# ============================================================
# V115 - NOTIFICATION SYSTEM
# ============================================================
$v = $v.Replace('<title>NeuroScan v114 — Tooltips</title>', '<title>NeuroScan v115 — Notifications</title>')

# Add toast container after <body>
$v = $v.Replace('<body>', '<body>' + [char]13 + [char]10 + '<div id="toast-container" class="toast-container"></div>')

# Add toast CSS before </style>
$toastCSS = '.toast-container{position:fixed;bottom:52px;right:14px;display:flex;flex-direction:column;gap:8px;z-index:600;pointer-events:none}' + [char]13 + [char]10 +
'.toast{background:rgba(6,12,26,.96);backdrop-filter:blur(16px);border:1px solid var(--b1);border-radius:8px;padding:10px 14px;font-size:12px;color:var(--text);display:flex;align-items:flex-start;gap:10px;min-width:240px;max-width:320px;box-shadow:var(--shadow);animation:toastIn .2s ease;transition:opacity .3s, transform .3s;pointer-events:all}' + [char]13 + [char]10 +
'.toast.removing{opacity:0;transform:translateX(20px)}' + [char]13 + [char]10 +
'@keyframes toastIn{from{opacity:0;transform:translateX(20px)}to{opacity:1;transform:none}}' + [char]13 + [char]10 +
'.toast-icon{font-size:16px;flex-shrink:0;margin-top:1px}' + [char]13 + [char]10 +
'.toast-body{flex:1}' + [char]13 + [char]10 +
'.toast-title{font-size:12px;font-weight:600;color:var(--text);margin-bottom:2px}' + [char]13 + [char]10 +
'.toast-msg{font-size:11px;color:var(--dim);line-height:1.5}' + [char]13 + [char]10 +
'.toast-close{font-size:14px;color:var(--dim);cursor:pointer;flex-shrink:0;pointer-events:all;margin-top:-2px;transition:color .15s}' + [char]13 + [char]10 +
'.toast-close:hover{color:var(--text)}' + [char]13 + [char]10 +
'.toast.success{border-color:rgba(80,232,160,.35);background:rgba(4,20,16,.96)}' + [char]13 + [char]10 +
'.toast.warning{border-color:rgba(255,200,74,.35);background:rgba(20,14,4,.96)}' + [char]13 + [char]10 +
'.toast.error{border-color:rgba(255,85,104,.35);background:rgba(20,4,8,.96)}' + [char]13 + [char]10 +
'.toast.info{border-color:var(--b2)}'

$v = $v.Replace('</style>', $toastCSS + [char]13 + [char]10 + '</style>')

# Add toast JS before </body>
$toastJS = @'
<script>
var _toastId = 0;
function showToast(msg, opts){
  opts = opts || {};
  var type = opts.type || 'info';
  var title = opts.title || '';
  var duration = opts.duration !== undefined ? opts.duration : 3500;
  var icon = opts.icon || (type==='success'?'&#10003;':type==='warning'?'&#9888;':type==='error'?'&#10007;':'&#8505;');
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
    '<span class="toast-close" onclick="removeToast(\''+id+'\')">&#215;</span>';
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
  showToast('Welcome to NeuroScan v115', {title:'Platform Ready', type:'success', icon:'&#x1F9E0;', duration:4000});
}, 800);
</script>
'@

$v = $v.Replace('</body>', $toastJS + '</body>')

writeVer $v 115

Write-Host "All versions built successfully."
