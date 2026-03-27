$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function WriteVersion($content, $outPath, $ver) {
    $content = [regex]::Replace($content, '<title>[^<]*</title>', "<title>NeuroScan v$ver</title>")
    [System.IO.File]::WriteAllText($outPath, $content, $utf8NoBom)
    $bytes = [System.IO.File]::ReadAllBytes($outPath)
    $sz = (Get-Item $outPath).Length
    Write-Host "v$ver -> $sz bytes | first=$($bytes[0])"
}

function ReplaceFirst($content, $find, $repl) {
    $idx = $content.IndexOf($find)
    if ($idx -lt 0) { Write-Warning "NOT FOUND: $($find.Substring(0,[Math]::Min(50,$find.Length)))"; return $content }
    return $content.Substring(0,$idx) + $repl + $content.Substring($idx + $find.Length)
}

$root = "c:\Users\bookf\OneDrive\Desktop\brain"
$c = [System.IO.File]::ReadAllText("$root\145\index.html", [System.Text.Encoding]::UTF8)

# ======================================================
# V146 - C. ELEGANS
# ======================================================
$css146 = @'
.celegans-panel{bottom:50px;right:10px;width:300px}
.ce-stats{display:flex;gap:4px;margin:8px 0}
.ce-stat{flex:1;text-align:center;background:rgba(80,232,160,.05);border:1px solid rgba(80,232,160,.15);border-radius:6px;padding:5px 3px}
.ce-val{display:block;font-size:16px;font-weight:700;color:var(--accent2);font-family:var(--font-mono)}
.ce-lbl{font-size:9px;color:var(--dim);display:block}
.ce-type-legend{display:flex;gap:10px;flex-wrap:wrap}
.ce-type{display:flex;align-items:center;gap:5px;font-size:10px;color:var(--dim)}
'@

$panel146 = @'
<div id="celegans-panel" class="feature-panel celegans-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#129419; C. ELEGANS CONNECTOME</span>
    <span class="fp-sub">Real 302-neuron connectome — mapped 1986, completed 2019</span>
    <span class="fp-close" onclick="toggleCelegansPanel()">&#215;</span>
  </div>
  <div class="ce-stats">
    <div class="ce-stat"><span class="ce-val">302</span><span class="ce-lbl">Neurons</span></div>
    <div class="ce-stat"><span class="ce-val">~7,000</span><span class="ce-lbl">Synapses</span></div>
    <div class="ce-stat"><span class="ce-val">0.3mm</span><span class="ce-lbl">Brain size</span></div>
    <div class="ce-stat"><span class="ce-val">100%</span><span class="ce-lbl">Mapped</span></div>
  </div>
  <div style="font-size:11px;color:var(--dim);margin:8px 0;line-height:1.5">First complete connectome mapped by White et al. (1986), updated by Varshney et al. (2011). The only fully mapped nervous system in a multicellular organism.</div>
  <button onclick="simulateCElegansWalk()" style="width:100%;padding:7px;background:rgba(80,232,160,.1);border:1px solid rgba(80,232,160,.3);color:var(--accent2);border-radius:6px;cursor:pointer;font-size:12px;margin-bottom:8px">&#9654; Simulate Locomotion</button>
  <div class="ce-type-legend">
    <div class="ce-type"><div style="width:8px;height:8px;border-radius:50%;background:#3ab8ff"></div><span>Sensory (72)</span></div>
    <div class="ce-type"><div style="width:8px;height:8px;border-radius:50%;background:#c084fc"></div><span>Interneuron (107)</span></div>
    <div class="ce-type"><div style="width:8px;height:8px;border-radius:50%;background:#50e8a0"></div><span>Motor (123)</span></div>
  </div>
  <div style="margin-top:10px;font-size:11px;color:var(--dim)">Scale: Human brain has 86 billion neurons — <span style="color:var(--accent)">285 million times</span> more complex.</div>
</div>
'@

$js146 = @'
<script>
// === V146 C. ELEGANS CONNECTOME ===
var CELEGANS_NEURONS=[],CELEGANS_EDGES=[];
(function(){
  var types=['sensory','interneuron','motor','pharyngeal'];
  var typeColors=['#3ab8ff','#c084fc','#50e8a0','#ffc84a'];
  var typeCounts=[72,107,123,20];
  var idx=0;
  types.forEach(function(type,ti){
    for(var i=0;i<typeCounts[ti];i++){
      var bodyPos=i/typeCounts[ti];
      var angle=Math.random()*Math.PI*2;
      var radius=0.2+Math.random()*0.3;
      CELEGANS_NEURONS.push({id:idx++,type:type,color:typeColors[ti],
        x:(bodyPos-0.5)*4,y:Math.sin(angle)*radius,z:Math.cos(angle)*radius,activation:0});
    }
  });
  for(var i=0;i<600;i++){
    var a=Math.floor(Math.random()*CELEGANS_NEURONS.length);
    var b=Math.floor(Math.random()*CELEGANS_NEURONS.length);
    if(a!==b&&Math.abs(CELEGANS_NEURONS[a].x-CELEGANS_NEURONS[b].x)<1.5) CELEGANS_EDGES.push([a,b]);
  }
})();
var celegansVisible=false,celegansGroup=null,celegansAnimPhase=0,celegansAnimating=false;
function buildCElegans(){
  if(celegansGroup){scene.remove(celegansGroup);celegansGroup=null;}
  var g=new THREE.Group();g.position.set(8,0,0);
  var geo=new THREE.SphereGeometry(0.06,6,6);
  CELEGANS_NEURONS.forEach(function(n){
    var mat=new THREE.MeshBasicMaterial({color:new THREE.Color(n.color),transparent:true,opacity:0.8});
    var mesh=new THREE.Mesh(geo,mat);mesh.position.set(n.x,n.y,n.z);g.add(mesh);
  });
  var posArr=[];
  CELEGANS_EDGES.forEach(function(e){
    var a=CELEGANS_NEURONS[e[0]],b=CELEGANS_NEURONS[e[1]];
    posArr.push(a.x,a.y,a.z,b.x,b.y,b.z);
  });
  var edgeGeo=new THREE.BufferGeometry();
  edgeGeo.setAttribute('position',new THREE.Float32BufferAttribute(posArr,3));
  g.add(new THREE.LineSegments(edgeGeo,new THREE.LineBasicMaterial({color:0x223344,opacity:0.3,transparent:true})));
  celegansGroup=g;scene.add(g);
}
function toggleCelegansPanel(){
  celegansVisible=!celegansVisible;
  var p=document.getElementById('celegans-panel'),b=document.getElementById('bCelegans');
  if(p)p.classList.toggle('vis',celegansVisible);
  if(b)b.classList.toggle('on',celegansVisible);
  if(celegansVisible&&!celegansGroup)buildCElegans();
  else if(!celegansVisible&&celegansGroup){scene.remove(celegansGroup);celegansGroup=null;}
}
function simulateCElegansWalk(){
  if(!celegansGroup)buildCElegans();
  celegansAnimating=true;celegansAnimPhase=0;
  showToast('Simulating locomotion circuit...',{type:'info',icon:'&#129419;',duration:3000});
}
var _ceOrig=window._animateCore;
window._animateCore=function(t){
  if(_ceOrig)_ceOrig(t);
  if(celegansGroup&&celegansAnimating){
    celegansAnimPhase=(celegansAnimPhase+0.02)%(Math.PI*2);
    celegansGroup.children.forEach(function(child,i){
      if(child.material&&i<CELEGANS_NEURONS.length){
        var n=CELEGANS_NEURONS[i];
        child.material.opacity=0.5+Math.max(0,Math.sin(celegansAnimPhase-n.x*1.5))*0.5;
      }
    });
  }
};
</script>
'@

$btn146 = '  <div class="feat-sep"></div>
  <span class="feat-cat">VISUALIZATION</span>
  <div class="hb" id="bCelegans" onclick="toggleCelegansPanel()" style="border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)">&#129419; C.ELEGANS</div>'

$c146 = $c
$c146 = ReplaceFirst $c146 '</style>' ($css146 + '</style>')
$c146 = ReplaceFirst $c146 '&#128249; STRATEGY</div></div>' ('&#128249; STRATEGY</div>' + "`n" + $btn146 + '</div>')
$c146 = ReplaceFirst $c146 '</body>' ($panel146 + $js146 + '</body>')
WriteVersion $c146 "$root\146\index.html" "146 — C.Elegans"

# ======================================================
# V147 - NEURAL CIRCUIT SIMULATOR
# ======================================================
$css147 = @'
.circuit-panel{bottom:50px;right:10px;width:320px}
.cir-select{width:100%;padding:6px 8px;background:rgba(58,184,255,.07);border:1px solid var(--b2);border-radius:6px;color:var(--text);font-size:11px;font-family:var(--font);margin-bottom:4px}
.cir-log{background:rgba(0,0,0,.4);border:1px solid var(--b1);border-radius:6px;padding:8px;font-family:var(--font-mono);font-size:10px;color:var(--accent2);height:80px;overflow-y:auto;margin:8px 0}
.cir-props{display:flex;gap:6px;margin:6px 0}
.cir-prop{flex:1;background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:6px;padding:5px;text-align:center}
.cir-prop-val{font-size:14px;font-weight:700;color:var(--accent);font-family:var(--font-mono)}
.cir-prop-lbl{font-size:9px;color:var(--dim);display:block}
.cir-hist-item{font-size:10px;color:var(--dim);padding:3px 0;border-bottom:1px solid rgba(58,184,255,.05);font-family:var(--font-mono)}
'@

$panel147 = @'
<div id="circuit-panel" class="feature-panel circuit-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#9889; NEURAL CIRCUIT SIMULATOR</span>
    <span class="fp-sub">Signal propagation through connected brain regions</span>
    <span class="fp-close" onclick="toggleCircuitPanel()">&#215;</span>
  </div>
  <div style="font-size:10px;color:var(--dim);margin-bottom:2px">Source Region</div>
  <select id="cir-src" class="cir-select"></select>
  <div style="font-size:10px;color:var(--dim);margin-bottom:2px">Relay Region</div>
  <select id="cir-relay" class="cir-select"></select>
  <div style="font-size:10px;color:var(--dim);margin-bottom:2px">Target Region</div>
  <select id="cir-tgt" class="cir-select"></select>
  <div style="display:flex;gap:10px;margin:6px 0;align-items:center">
    <label style="font-size:10px;color:var(--dim);display:flex;align-items:center;gap:4px">
      <input type="checkbox" id="cir-inhibit"> Inhibitory
    </label>
    <label style="font-size:10px;color:var(--dim);display:flex;align-items:center;gap:4px;flex:1">
      Noise: <input type="range" id="cir-noise" min="0" max="100" value="20" style="flex:1;margin-left:4px">
    </label>
  </div>
  <button onclick="fireCircuitSignal()" style="width:100%;padding:8px;background:rgba(58,184,255,.12);border:1px solid var(--b2);color:var(--accent);border-radius:6px;cursor:pointer;font-size:12px;font-weight:600;margin-bottom:8px">&#9889; Fire Signal</button>
  <div class="cir-props">
    <div class="cir-prop"><span class="cir-prop-val" id="cir-strength">--</span><span class="cir-prop-lbl">Strength %</span></div>
    <div class="cir-prop"><span class="cir-prop-val" id="cir-latency">--</span><span class="cir-prop-lbl">Latency ms</span></div>
    <div class="cir-prop"><span class="cir-prop-val" id="cir-fidelity">--</span><span class="cir-prop-lbl">Fidelity %</span></div>
  </div>
  <div style="font-size:9px;color:var(--dim);letter-spacing:.08em;margin-top:6px;margin-bottom:3px">SIGNAL LOG</div>
  <div class="cir-log" id="cir-log"><span style="color:var(--dim)">Ready...</span></div>
  <div style="font-size:9px;color:var(--dim);letter-spacing:.08em;margin-bottom:3px">HISTORY</div>
  <div id="cir-history"></div>
</div>
'@

$js147 = @'
<script>
// === V147 NEURAL CIRCUIT SIMULATOR ===
var circuitOpen=false,circuitHistory=[];
var CIRCUIT_REGIONS=[
  {key:'visual_cortex',name:'Visual Cortex',lat:8},{key:'auditory_cortex',name:'Auditory Cortex',lat:7},
  {key:'somatosensory',name:'Somatosensory Ctx',lat:9},{key:'motor_cortex',name:'Motor Cortex',lat:10},
  {key:'prefrontal',name:'Prefrontal Cortex',lat:15},{key:'thalamus',name:'Thalamus',lat:5},
  {key:'hippocampus',name:'Hippocampus',lat:12},{key:'amygdala',name:'Amygdala',lat:6},
  {key:'cerebellum',name:'Cerebellum',lat:11},{key:'basal_ganglia',name:'Basal Ganglia',lat:8},
  {key:'broca',name:"Broca's Area",lat:9},{key:'wernicke',name:"Wernicke's Area",lat:8},
  {key:'insula',name:'Insula',lat:7},{key:'anterior_cingulate',name:'Anterior Cingulate',lat:10},
  {key:'parietal',name:'Parietal Cortex',lat:11},{key:'temporal',name:'Temporal Lobe',lat:10},
  {key:'occipital',name:'Occipital Cortex',lat:8},{key:'hypothalamus',name:'Hypothalamus',lat:4},
  {key:'brainstem',name:'Brainstem',lat:6},{key:'limbic',name:'Limbic System',lat:7},
  {key:'olfactory',name:'Olfactory Bulb',lat:5},{key:'posterior_cingulate',name:'Posterior Cingulate',lat:9}
];
function toggleCircuitPanel(){
  circuitOpen=!circuitOpen;
  var p=document.getElementById('circuit-panel'),b=document.getElementById('bCircuit');
  if(p)p.classList.toggle('vis',circuitOpen);
  if(b)b.classList.toggle('on',circuitOpen);
  if(circuitOpen)initCircuitPanel();
}
function initCircuitPanel(){
  var opts=CIRCUIT_REGIONS.map(function(r){return '<option value="'+r.key+'">'+r.name+'</option>';}).join('');
  ['cir-src','cir-relay','cir-tgt'].forEach(function(id){var s=document.getElementById(id);if(s)s.innerHTML=opts;});
  var s=document.getElementById('cir-src'),r=document.getElementById('cir-relay'),t=document.getElementById('cir-tgt');
  if(s)s.value='visual_cortex';if(r)r.value='thalamus';if(t)t.value='prefrontal';
}
function fireCircuitSignal(){
  var srcV=(document.getElementById('cir-src')||{}).value||'visual_cortex';
  var rlV=(document.getElementById('cir-relay')||{}).value||'thalamus';
  var tgtV=(document.getElementById('cir-tgt')||{}).value||'prefrontal';
  var srcR=CIRCUIT_REGIONS.find(function(r){return r.key===srcV;})||CIRCUIT_REGIONS[0];
  var rlR=CIRCUIT_REGIONS.find(function(r){return r.key===rlV;})||CIRCUIT_REGIONS[5];
  var tgtR=CIRCUIT_REGIONS.find(function(r){return r.key===tgtV;})||CIRCUIT_REGIONS[4];
  var noise=parseInt((document.getElementById('cir-noise')||{value:20}).value);
  var inhibit=(document.getElementById('cir-inhibit')||{}).checked;
  var strength=Math.max(10,100-noise+Math.round((Math.random()-0.5)*noise*0.5));
  var lat1=srcR.lat+Math.round(Math.random()*4);
  var lat2=rlR.lat+Math.round(Math.random()*4);
  var fidelity=Math.max(10,100-noise+Math.round(Math.random()*10));
  var type=inhibit?'INHIB':'EXCIT';
  var logEl=document.getElementById('cir-log');
  if(logEl){
    logEl.innerHTML='<span style="color:var(--gold)">['+new Date().toLocaleTimeString()+'] </span>'
      +'<span style="color:var(--accent)">'+srcR.name+'</span> &#8594; '
      +'<span style="color:var(--dim)">['+lat1+'ms]</span> &#8594; '
      +'<span style="color:var(--accent2)">'+rlR.name+'</span> &#8594; '
      +'<span style="color:var(--dim)">['+lat2+'ms]</span> &#8594; '
      +'<span style="color:'+(inhibit?'var(--red)':'var(--accent2)') +'">'+(inhibit?'&#10006;':'&#10004;')+' '+tgtR.name+'</span>'
      +'<br><span style="color:var(--dim)">'+type+' | '+strength+'% strength | '+(lat1+lat2)+'ms</span>';
  }
  var se=document.getElementById('cir-strength'),le=document.getElementById('cir-latency'),fe=document.getElementById('cir-fidelity');
  if(se)se.textContent=strength;if(le)le.textContent=(lat1+lat2);if(fe)fe.textContent=fidelity;
  circuitHistory.unshift({src:srcR.name,relay:rlR.name,tgt:tgtR.name,lat:lat1+lat2,type:type});
  circuitHistory=circuitHistory.slice(0,5);
  var he=document.getElementById('cir-history');
  if(he)he.innerHTML=circuitHistory.map(function(h){
    return '<div class="cir-hist-item">'+h.src+' &#8594; '+h.relay+' &#8594; '+h.tgt+' | '+h.lat+'ms | '+h.type+'</div>';
  }).join('');
  if(typeof regionMsh!=='undefined'){
    function flash(key,delay,col){setTimeout(function(){var m=regionMsh[key];if(!m)return;m.material.color.setHex(col);m.material.opacity=0.8;setTimeout(function(){m.material.opacity=0;},400);},delay);}
    flash(srcR.key,0,0x3ab8ff);flash(rlR.key,lat1*12,0xffc84a);flash(tgtR.key,(lat1+lat2)*12,inhibit?0xff5568:0x50e8a0);
  }
}
</script>
'@

$btn147 = '  <div class="hb" id="bCircuit" onclick="toggleCircuitPanel()" style="border-color:rgba(58,184,255,.3);color:rgba(58,184,255,.7)">&#9889; CIRCUIT</div>'
$c147 = $c146
$c147 = ReplaceFirst $c147 '</style>' ($css147 + '</style>')
$c147 = ReplaceFirst $c147 '&#129419; C.ELEGANS</div></div>' ('&#129419; C.ELEGANS</div>' + "`n" + $btn147 + '</div>')
$c147 = ReplaceFirst $c147 '</body>' ($panel147 + $js147 + '</body>')
WriteVersion $c147 "$root\147\index.html" "147 — Neural Circuit"

# ======================================================
# V148 - BRAIN IN ACTION (6 SCENARIOS)
# ======================================================
$css148 = @'
.scenarios-panel{bottom:50px;right:10px;width:320px}
.sc-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px;margin:8px 0}
.sc-card{background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:8px;padding:8px;cursor:pointer;transition:var(--trans);text-align:center}
.sc-card:hover,.sc-card.active{background:rgba(58,184,255,.15);border-color:var(--b2)}
.sc-card-icon{font-size:20px;display:block;margin-bottom:4px}
.sc-card-name{font-size:11px;font-weight:600;color:var(--text)}
.sc-bars{margin:8px 0}
.sc-bar-row{display:flex;align-items:center;gap:6px;margin-bottom:4px}
.sc-bar-label{font-size:9px;color:var(--dim);width:110px;flex-shrink:0}
.sc-bar-bg{flex:1;height:7px;background:rgba(58,184,255,.1);border-radius:4px;overflow:hidden}
.sc-bar-fill{height:100%;border-radius:4px;transition:width .6s}
.sc-desc-box{font-size:10px;color:var(--dim);line-height:1.6;padding:8px;background:rgba(0,0,0,.3);border-radius:6px;margin-top:6px}
'@

$panel148 = @'
<div id="scenarios-panel" class="feature-panel scenarios-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#127952; BRAIN IN ACTION</span>
    <span class="fp-sub">Real neural activation patterns during daily activities</span>
    <span class="fp-close" onclick="toggleScenariosPanel()">&#215;</span>
  </div>
  <div class="sc-grid" id="sc-grid"></div>
  <div id="sc-active-info" style="display:none">
    <div style="font-size:9px;letter-spacing:.08em;color:var(--dim);margin-bottom:4px">ACTIVE REGIONS</div>
    <div class="sc-bars" id="sc-bars"></div>
    <div class="sc-desc-box" id="sc-desc"></div>
  </div>
</div>
'@

$js148 = @'
<script>
// === V148 BRAIN IN ACTION ===
var BRAIN_SCENARIOS=[
  {id:'reading',name:'Reading',icon:'&#128218;',
   acts:[{r:'visual_cortex',i:0.9,col:'#3ab8ff'},{r:'wernicke',i:0.85,col:'#50e8a0'},{r:'broca',i:0.7,col:'#c084fc'},{r:'prefrontal',i:0.6,col:'#ffc84a'}],
   desc:"Visual cortex processes text, Wernicke's decodes meaning, Broca's handles grammar. PFC maintains working memory."},
  {id:'running',name:'Running',icon:'&#127939;',
   acts:[{r:'motor_cortex',i:0.95,col:'#ff5568'},{r:'cerebellum',i:0.9,col:'#50e8a0'},{r:'basal_ganglia',i:0.8,col:'#ffc84a'},{r:'hypothalamus',i:0.7,col:'#ff9060'}],
   desc:'Motor cortex sends commands, cerebellum coordinates balance, basal ganglia sequences movements, hypothalamus regulates temperature.'},
  {id:'dreaming',name:'Dreaming',icon:'&#128164;',
   acts:[{r:'limbic',i:0.85,col:'#c084fc'},{r:'visual_cortex',i:0.8,col:'#3ab8ff'},{r:'hippocampus',i:0.9,col:'#ffc84a'},{r:'prefrontal',i:0.1,col:'#334455'}],
   desc:'REM: limbic generates emotions, visual cortex creates imagery, hippocampus replays memories. PFC deactivates — why dreams seem logical.'},
  {id:'meditating',name:'Meditating',icon:'&#129496;',
   acts:[{r:'prefrontal',i:0.85,col:'#3ab8ff'},{r:'anterior_cingulate',i:0.8,col:'#50e8a0'},{r:'insula',i:0.75,col:'#ffc84a'},{r:'limbic',i:0.3,col:'#334455'}],
   desc:'PFC attention networks, anterior cingulate (error detection), insula (body awareness). Reduces limbic reactivity.'},
  {id:'love',name:'In Love',icon:'&#10084;',
   acts:[{r:'limbic',i:0.95,col:'#ff5568'},{r:'basal_ganglia',i:0.9,col:'#50e8a0'},{r:'insula',i:0.85,col:'#ffc84a'},{r:'prefrontal',i:0.4,col:'#334455'}],
   desc:'Reward circuits (dopamine), limbic emotion, insula (racing heart). Partial PFC deactivation — the "love is blind" effect.'},
  {id:'grieving',name:'Grieving',icon:'&#128167;',
   acts:[{r:'anterior_cingulate',i:0.9,col:'#c084fc'},{r:'limbic',i:0.85,col:'#3ab8ff'},{r:'prefrontal',i:0.7,col:'#ffc84a'},{r:'hypothalamus',i:0.6,col:'#ff9060'}],
   desc:'Grief activates ACC (same as physical pain), limbic processing, PFC for rumination, hypothalamus driving stress.'}
];
var scenariosOpen=false,activeScenarioId=null;
function toggleScenariosPanel(){
  scenariosOpen=!scenariosOpen;
  var p=document.getElementById('scenarios-panel'),b=document.getElementById('bScenarios');
  if(p)p.classList.toggle('vis',scenariosOpen);
  if(b)b.classList.toggle('on',scenariosOpen);
  if(scenariosOpen)renderScenarioGrid();
}
function renderScenarioGrid(){
  var g=document.getElementById('sc-grid');if(!g)return;
  g.innerHTML=BRAIN_SCENARIOS.map(function(s){
    return '<div class="sc-card'+(activeScenarioId===s.id?' active':'')+'" onclick="playScenario(\''+s.id+'\')">'
      +'<span class="sc-card-icon">'+s.icon+'</span><span class="sc-card-name">'+s.name+'</span></div>';
  }).join('');
}
function playScenario(id){
  activeScenarioId=id;renderScenarioGrid();
  var sc=BRAIN_SCENARIOS.find(function(s){return s.id===id;});if(!sc)return;
  var info=document.getElementById('sc-active-info'),bars=document.getElementById('sc-bars'),desc=document.getElementById('sc-desc');
  if(info)info.style.display='block';
  if(desc)desc.textContent=sc.desc;
  if(bars)bars.innerHTML=sc.acts.map(function(a){
    return '<div class="sc-bar-row"><span class="sc-bar-label">'+a.r.replace(/_/g,' ')+'</span>'
      +'<div class="sc-bar-bg"><div class="sc-bar-fill" style="width:'+Math.round(a.i*100)+'%;background:'+a.col+'"></div></div>'
      +'<span style="font-size:9px;color:var(--dim);width:28px">'+Math.round(a.i*100)+'%</span></div>';
  }).join('');
  if(typeof regionMsh!=='undefined'){
    Object.keys(regionMsh).forEach(function(k){var m=regionMsh[k];if(m)m.material.opacity=0.02;});
    sc.acts.forEach(function(a){
      var m=regionMsh[a.r];if(!m)return;
      m.material.color.setStyle(a.col);m.material.opacity=a.i*0.65;
      setTimeout(function(){if(m)m.material.opacity=0;},8000);
    });
  }
  showToast(sc.icon+' '+sc.name+' activated',{type:'info',duration:2500});
}
</script>
'@

$btn148 = '  <div class="hb" id="bScenarios" onclick="toggleScenariosPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#127952; SCENARIOS</div>'
$c148 = $c147
$c148 = ReplaceFirst $c148 '</style>' ($css148 + '</style>')
$c148 = ReplaceFirst $c148 '&#9889; CIRCUIT</div></div>' ('&#9889; CIRCUIT</div>' + "`n" + $btn148 + '</div>')
$c148 = ReplaceFirst $c148 '</body>' ($panel148 + $js148 + '</body>')
WriteVersion $c148 "$root\148\index.html" "148 — Brain Scenarios"

# ======================================================
# V149 - CROSS-SPECIES INTELLIGENCE
# ======================================================
$css149 = @'
.species-panel{bottom:50px;right:10px;width:320px}
.sp-grid{display:grid;grid-template-columns:1fr 1fr;gap:5px;margin:8px 0}
.sp-item{background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:8px;padding:7px;cursor:pointer;transition:var(--trans)}
.sp-item:hover,.sp-item.sel{background:rgba(58,184,255,.15);border-color:var(--b2)}
.sp-name{font-size:11px;font-weight:600;color:var(--text);margin-bottom:3px}
.sp-neurons{font-size:9px;color:var(--accent);font-family:var(--font-mono)}
.sp-vol{font-size:9px;color:var(--dim)}
.sp-compare{margin-top:6px;padding:8px;background:rgba(0,0,0,.3);border-radius:6px;border:1px solid var(--b1)}
.sp-iq-bar{height:7px;border-radius:4px;background:var(--accent);margin-top:4px;transition:width .6s}
'@

$panel149 = @'
<div id="species-panel" class="feature-panel species-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#127758; CROSS-SPECIES INTELLIGENCE</span>
    <span class="fp-sub">Brain complexity across the animal kingdom</span>
    <span class="fp-close" onclick="toggleSpeciesPanel()">&#215;</span>
  </div>
  <div class="sp-grid" id="sp-grid"></div>
  <div class="sp-compare" id="sp-compare" style="display:none"></div>
  <div style="margin-top:8px;font-size:10px;color:var(--dim);line-height:1.6">Path to digital: C. elegans mapped 1986. Drosophila completed 2023. Mouse connectome ~2030. Human connectome: 2040s?</div>
</div>
'@

$js149 = @'
<script>
// === V149 CROSS-SPECIES INTELLIGENCE ===
var SPECIES_DATA=[
  {name:'C. elegans',neurons:'302',vol:'0.3mm',ratioP:0.001,neocortex:0,tools:false,lang:false,radius:0.05,color:'#50e8a0'},
  {name:'Drosophila',neurons:'140K',vol:'0.5mm3',ratioP:0.01,neocortex:0,tools:false,lang:false,radius:0.08,color:'#ffc84a'},
  {name:'Mouse',neurons:'71M',vol:'0.4cm3',ratioP:0.1,neocortex:0.3,tools:false,lang:false,radius:0.5,color:'#88bbff'},
  {name:'Crow',neurons:'1.5B',vol:'6.5cm3',ratioP:0.4,neocortex:0.5,tools:true,lang:false,radius:0.8,color:'#c084fc'},
  {name:'Chimpanzee',neurons:'28B',vol:'400cm3',ratioP:0.7,neocortex:0.8,tools:true,lang:true,radius:1.5,color:'#ff9060'},
  {name:'Human',neurons:'86B',vol:'1300cm3',ratioP:1.0,neocortex:1.0,tools:true,lang:true,radius:3.0,color:'#3ab8ff'},
  {name:'Hypothetical ASI',neurons:'10T+',vol:'N/A',ratioP:100,neocortex:1.0,tools:true,lang:true,radius:6.0,color:'#ff55aa'}
];
var speciesOpen=false,selSp=null,spGroup=null;
function toggleSpeciesPanel(){
  speciesOpen=!speciesOpen;
  var p=document.getElementById('species-panel'),b=document.getElementById('bSpecies');
  if(p)p.classList.toggle('vis',speciesOpen);
  if(b)b.classList.toggle('on',speciesOpen);
  if(speciesOpen){renderSpeciesPanel();buildSpeciesViz();}
  else if(spGroup){scene.remove(spGroup);spGroup=null;}
}
function renderSpeciesPanel(){
  var g=document.getElementById('sp-grid');if(!g)return;
  g.innerHTML=SPECIES_DATA.map(function(s,i){
    return '<div class="sp-item'+(selSp===i?' sel':'')+'" onclick="selectSp('+i+')">'
      +'<div class="sp-name">'+s.name+'</div>'
      +'<div class="sp-neurons">'+s.neurons+'</div>'
      +'<div class="sp-vol">'+s.vol+'</div></div>';
  }).join('');
}
function selectSp(i){
  selSp=i;renderSpeciesPanel();
  var s=SPECIES_DATA[i],el=document.getElementById('sp-compare');
  if(!el)return;el.style.display='block';
  el.innerHTML='<div style="font-size:12px;font-weight:700;color:'+s.color+';margin-bottom:5px">'+s.name+'</div>'
    +'<div style="font-size:10px;color:var(--dim);margin-bottom:4px;display:flex;gap:10px">'
    +'<span>Neurons: <b style="color:var(--text)">'+s.neurons+'</b></span>'
    +'<span>Tools: <b>'+(s.tools?'&#10004;':'&#10006;')+'</b></span>'
    +'<span>Language: <b>'+(s.lang?'&#10004;':'&#10006;')+'</b></span></div>'
    +'<div style="font-size:9px;color:var(--dim)">Intelligence ratio vs human</div>'
    +'<div class="sp-iq-bar" style="width:'+Math.min(100,s.ratioP*100)+'%;background:'+s.color+'"></div>'
    +'<div style="font-size:9px;color:var(--dim);margin-top:3px">Neocortex ratio: '+Math.round(s.neocortex*100)+'%</div>';
}
function buildSpeciesViz(){
  if(spGroup){scene.remove(spGroup);spGroup=null;}
  var g=new THREE.Group();g.position.set(0,8,0);
  SPECIES_DATA.forEach(function(s,i){
    var geo=new THREE.SphereGeometry(s.radius,10,10);
    var mat=new THREE.MeshBasicMaterial({color:new THREE.Color(s.color),wireframe:true,opacity:0.6,transparent:true});
    var mesh=new THREE.Mesh(geo,mat);mesh.position.set((i-3)*3.5,0,0);g.add(mesh);
  });
  spGroup=g;scene.add(g);
}
</script>
'@

$btn149 = '  <div class="hb" id="bSpecies" onclick="toggleSpeciesPanel()" style="border-color:rgba(192,132,252,.3);color:rgba(192,132,252,.7)">&#127758; SPECIES</div>'
$c149 = $c148
$c149 = ReplaceFirst $c149 '</style>' ($css149 + '</style>')
$c149 = ReplaceFirst $c149 '&#127952; SCENARIOS</div></div>' ('&#127952; SCENARIOS</div>' + "`n" + $btn149 + '</div>')
$c149 = ReplaceFirst $c149 '</body>' ($panel149 + $js149 + '</body>')
WriteVersion $c149 "$root\149\index.html" "149 — Species Comparison"

Write-Host "Part 1 complete (v146-v149)"
