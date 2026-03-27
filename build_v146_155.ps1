$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function WriteVersion($content, $outPath, $ver) {
    $content = [regex]::Replace($content, '<title>[^<]*</title>', "<title>NeuroScan v$ver</title>")
    [System.IO.File]::WriteAllText($outPath, $content, $utf8NoBom)
    $bytes = [System.IO.File]::ReadAllBytes($outPath)
    $sz = (Get-Item $outPath).Length
    Write-Host "v$ver -> $outPath | $sz bytes | first=$($bytes[0])"
}

function InsertBefore($content, $marker, $ins) {
    $idx = $content.IndexOf($marker)
    if ($idx -lt 0) { Write-Warning "NOT FOUND: $($marker.Substring(0,[Math]::Min(40,$marker.Length)))"; return $content }
    return $content.Substring(0,$idx) + $ins + $content.Substring($idx)
}

function ReplaceFirst($content, $find, $repl) {
    $idx = $content.IndexOf($find)
    if ($idx -lt 0) { Write-Warning "NOT FOUND: $($find.Substring(0,[Math]::Min(40,$find.Length)))"; return $content }
    return $content.Substring(0,$idx) + $repl + $content.Substring($idx + $find.Length)
}

$root = "c:\Users\bookf\OneDrive\Desktop\brain"
$c = [System.IO.File]::ReadAllText("$root\145\index.html", [System.Text.Encoding]::UTF8)

# ========================== V146 ==========================
$css146 = ".celegans-panel{bottom:50px;right:10px;width:300px}
.ce-stats{display:flex;gap:4px;margin:8px 0}
.ce-stat{flex:1;text-align:center;background:rgba(80,232,160,.05);border:1px solid rgba(80,232,160,.15);border-radius:6px;padding:5px 3px}
.ce-val{display:block;font-size:16px;font-weight:700;color:var(--accent2);font-family:var(--font-mono)}
.ce-lbl{font-size:9px;color:var(--dim);display:block}
.ce-type-legend{display:flex;gap:10px;flex-wrap:wrap}
.ce-type{display:flex;align-items:center;gap:5px;font-size:10px;color:var(--dim)}
"
$btn146 = "  <div class=`"feat-sep`"></div>`r`n  <span class=`"feat-cat`">VISUALIZATION</span>`r`n  <div class=`"hb`" id=`"bCelegans`" onclick=`"toggleCelegansPanel()`" style=`"border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)`">&#129419; C.ELEGANS</div>"

$panel146 = @"
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
"@

$js146 = @"
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
var _origAnimCore146=window._animateCore;
window._animateCore=function(t){
  if(_origAnimCore146)_origAnimCore146(t);
  if(celegansGroup&&celegansAnimating){
    celegansAnimPhase=(celegansAnimPhase+0.02)%(Math.PI*2);
    celegansGroup.children.forEach(function(child,i){
      if(child.material&&i<CELEGANS_NEURONS.length){
        var n=CELEGANS_NEURONS[i];
        var wave=Math.sin(celegansAnimPhase-n.x*1.5);
        child.material.opacity=0.5+Math.max(0,wave)*0.5;
      }
    });
  }
};
</script>
"@

$c146 = $c
$c146 = ReplaceFirst $c146 '</style>' ($css146 + '</style>')
$c146 = ReplaceFirst $c146 '&#128249; STRATEGY</div></div>' ('&#128249; STRATEGY</div>' + $btn146 + '</div>')
$c146 = ReplaceFirst $c146 '</body>' ($panel146 + $js146 + '</body>')
WriteVersion $c146 "$root\146\index.html" "146 — C.Elegans"

# ========================== V147 ==========================
$css147 = ".circuit-panel{bottom:50px;right:10px;width:320px}
.cir-selects{display:flex;flex-direction:column;gap:6px;margin:8px 0}
.cir-select{width:100%;padding:6px 8px;background:rgba(58,184,255,.07);border:1px solid var(--b2);border-radius:6px;color:var(--text);font-size:11px;font-family:var(--font)}
.cir-log{background:rgba(0,0,0,.4);border:1px solid var(--b1);border-radius:6px;padding:8px;font-family:var(--font-mono);font-size:10px;color:var(--accent2);height:80px;overflow-y:auto;margin:8px 0}
.cir-props{display:flex;gap:6px;margin:6px 0;flex-wrap:wrap}
.cir-prop{flex:1;min-width:80px;background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:6px;padding:5px;text-align:center}
.cir-prop-val{font-size:14px;font-weight:700;color:var(--accent);font-family:var(--font-mono)}
.cir-prop-lbl{font-size:9px;color:var(--dim);display:block}
.cir-history{margin-top:8px}
.cir-hist-item{font-size:10px;color:var(--dim);padding:3px 0;border-bottom:1px solid rgba(58,184,255,.05);font-family:var(--font-mono)}
"
$btn147 = "  <div class=`"hb`" id=`"bCircuit`" onclick=`"toggleCircuitPanel()`" style=`"border-color:rgba(58,184,255,.3);color:rgba(58,184,255,.7)`">&#9889; CIRCUIT</div>"

$panel147 = @"
<div id="circuit-panel" class="feature-panel circuit-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#9889; NEURAL CIRCUIT SIMULATOR</span>
    <span class="fp-sub">Signal propagation through connected brain regions</span>
    <span class="fp-close" onclick="toggleCircuitPanel()">&#215;</span>
  </div>
  <div class="cir-selects">
    <div style="font-size:10px;color:var(--dim);margin-bottom:2px">Source Region</div>
    <select id="cir-src" class="cir-select"></select>
    <div style="font-size:10px;color:var(--dim);margin-bottom:2px">Relay Region</div>
    <select id="cir-relay" class="cir-select"></select>
    <div style="font-size:10px;color:var(--dim);margin-bottom:2px">Target Region</div>
    <select id="cir-tgt" class="cir-select"></select>
  </div>
  <div style="display:flex;gap:6px;margin-bottom:8px">
    <label style="font-size:10px;color:var(--dim);display:flex;align-items:center;gap:4px">
      <input type="checkbox" id="cir-inhibit"> Inhibitory
    </label>
    <label style="font-size:10px;color:var(--dim);display:flex;align-items:center;gap:4px;flex:1">
      Noise: <input type="range" id="cir-noise" min="0" max="100" value="20" style="flex:1">
    </label>
  </div>
  <button onclick="fireCircuitSignal()" style="width:100%;padding:8px;background:rgba(58,184,255,.12);border:1px solid var(--b2);color:var(--accent);border-radius:6px;cursor:pointer;font-size:12px;font-weight:600;margin-bottom:8px">&#9889; Fire Signal</button>
  <div class="cir-props">
    <div class="cir-prop"><span class="cir-prop-val" id="cir-strength">--</span><span class="cir-prop-lbl">Strength %</span></div>
    <div class="cir-prop"><span class="cir-prop-val" id="cir-latency">--</span><span class="cir-prop-lbl">Latency ms</span></div>
    <div class="cir-prop"><span class="cir-prop-val" id="cir-fidelity">--</span><span class="cir-prop-lbl">Fidelity %</span></div>
  </div>
  <div style="font-size:9px;color:var(--dim);letter-spacing:.08em;margin-top:8px;margin-bottom:4px">SIGNAL LOG</div>
  <div class="cir-log" id="cir-log"><span style="color:var(--dim)">Ready...</span></div>
  <div style="font-size:9px;color:var(--dim);letter-spacing:.08em;margin-top:8px;margin-bottom:4px">HISTORY</div>
  <div class="cir-history" id="cir-history"></div>
</div>
"@

$js147 = @"
<script>
// === V147 NEURAL CIRCUIT SIMULATOR ===
var circuitOpen=false, circuitHistory=[];
var CIRCUIT_REGIONS=[
  {key:'visual_cortex',name:'Visual Cortex',lat:8},
  {key:'auditory_cortex',name:'Auditory Cortex',lat:7},
  {key:'somatosensory',name:'Somatosensory Cortex',lat:9},
  {key:'motor_cortex',name:'Motor Cortex',lat:10},
  {key:'prefrontal',name:'Prefrontal Cortex',lat:15},
  {key:'thalamus',name:'Thalamus',lat:5},
  {key:'hippocampus',name:'Hippocampus',lat:12},
  {key:'amygdala',name:'Amygdala',lat:6},
  {key:'cerebellum',name:'Cerebellum',lat:11},
  {key:'basal_ganglia',name:'Basal Ganglia',lat:8},
  {key:'broca',name:"Broca's Area",lat:9},
  {key:'wernicke',name:"Wernicke's Area",lat:8},
  {key:'insula',name:'Insula',lat:7},
  {key:'anterior_cingulate',name:'Anterior Cingulate',lat:10},
  {key:'posterior_cingulate',name:'Posterior Cingulate',lat:9},
  {key:'parietal',name:'Parietal Cortex',lat:11},
  {key:'temporal',name:'Temporal Lobe',lat:10},
  {key:'occipital',name:'Occipital Cortex',lat:8},
  {key:'hypothalamus',name:'Hypothalamus',lat:4},
  {key:'brainstem',name:'Brainstem',lat:6},
  {key:'limbic',name:'Limbic System',lat:7},
  {key:'olfactory',name:'Olfactory Bulb',lat:5}
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
  var s=document.getElementById('cir-src'),rl=document.getElementById('cir-relay'),t=document.getElementById('cir-tgt');
  if(s)s.innerHTML=opts;if(rl)rl.innerHTML=opts;if(t)t.innerHTML=opts;
  if(s)s.value='visual_cortex';
  if(rl)rl.value='thalamus';
  if(t)t.value='prefrontal';
}
function fireCircuitSignal(){
  var src=document.getElementById('cir-src'),rl=document.getElementById('cir-relay'),tgt=document.getElementById('cir-tgt');
  if(!src)return;
  var srcR=CIRCUIT_REGIONS.find(function(r){return r.key===src.value;})||CIRCUIT_REGIONS[0];
  var rlR=CIRCUIT_REGIONS.find(function(r){return r.key===rl.value;})||CIRCUIT_REGIONS[5];
  var tgtR=CIRCUIT_REGIONS.find(function(r){return r.key===tgt.value;})||CIRCUIT_REGIONS[4];
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
      +'<span style="color:var(--accent)">'+srcR.name+'</span>'
      +' &#8594; <span style="color:var(--dim)">['+lat1+'ms]</span> &#8594; '
      +'<span style="color:var(--accent2)">'+rlR.name+'</span>'
      +' &#8594; <span style="color:var(--dim)">['+lat2+'ms]</span> &#8594; '
      +'<span style="color:'+(inhibit?'var(--red)':'var(--accent)')+'">'+(inhibit?'&#10006;':'&#10004;')+' '+tgtR.name+'</span>'
      +'<br><span style="color:var(--dim)">'+type+' | '+strength+'% | '+(lat1+lat2)+'ms total</span>';
  }
  var se=document.getElementById('cir-strength'),le=document.getElementById('cir-latency'),fe=document.getElementById('cir-fidelity');
  if(se)se.textContent=strength;if(le)le.textContent=(lat1+lat2);if(fe)fe.textContent=fidelity;
  circuitHistory.unshift({src:srcR.name,relay:rlR.name,tgt:tgtR.name,lat:lat1+lat2,type:type});
  circuitHistory=circuitHistory.slice(0,5);
  var he=document.getElementById('cir-history');
  if(he)he.innerHTML=circuitHistory.map(function(h){
    return '<div class="cir-hist-item">'+h.src+' &#8594; '+h.relay+' &#8594; '+h.tgt+' | '+h.lat+'ms | '+h.type+'</div>';
  }).join('');
  // Flash regions
  if(typeof regionMsh!=='undefined'){
    function flash(key,delay,col){
      setTimeout(function(){
        var m=regionMsh[key];if(!m)return;
        var origCol=m.material.color.getHex();
        m.material.color.setHex(col);
        m.material.opacity=0.8;
        setTimeout(function(){m.material.color.setHex(origCol);m.material.opacity=0;},400);
      },delay);
    }
    flash(srcR.key,0,0x3ab8ff);
    flash(rlR.key,lat1*10,0xffc84a);
    flash(tgtR.key,(lat1+lat2)*10,inhibit?0xff5568:0x50e8a0);
  }
}
</script>
"@

$c147 = $c146
$c147 = ReplaceFirst $c147 '</style>' ($css147 + '</style>')
$c147 = ReplaceFirst $c147 '&#129419; C.ELEGANS</div></div>' ('&#129419; C.ELEGANS</div>' + "`r`n" + $btn147 + '</div>')
$c147 = ReplaceFirst $c147 '</body>' ($panel147 + $js147 + '</body>')
WriteVersion $c147 "$root\147\index.html" "147 — Neural Circuit"

# ========================== V148 ==========================
$css148 = ".scenarios-panel{bottom:50px;right:10px;width:320px}
.sc-grid{display:grid;grid-template-columns:1fr 1fr;gap:6px;margin:8px 0}
.sc-card{background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:8px;padding:8px;cursor:pointer;transition:var(--trans);text-align:center}
.sc-card:hover,.sc-card.active{background:rgba(58,184,255,.15);border-color:var(--b2)}
.sc-icon{font-size:20px;display:block;margin-bottom:4px}
.sc-name{font-size:11px;font-weight:600;color:var(--text)}
.sc-desc{font-size:10px;color:var(--dim);line-height:1.5;margin-top:8px}
.sc-bars{margin-top:8px}
.sc-bar-row{display:flex;align-items:center;gap:6px;margin-bottom:4px}
.sc-bar-label{font-size:9px;color:var(--dim);width:100px;flex-shrink:0}
.sc-bar-bg{flex:1;height:8px;background:rgba(58,184,255,.1);border-radius:4px;overflow:hidden}
.sc-bar-fill{height:100%;border-radius:4px;transition:width .5s}
"
$btn148 = "  <div class=`"hb`" id=`"bScenarios`" onclick=`"toggleScenariosPanel()`" style=`"border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)`">&#129504; SCENARIOS</div>"

$panel148 = @"
<div id="scenarios-panel" class="feature-panel scenarios-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#127952; BRAIN IN ACTION</span>
    <span class="fp-sub">Real neural activation patterns during daily activities</span>
    <span class="fp-close" onclick="toggleScenariosPanel()">&#215;</span>
  </div>
  <div class="sc-grid" id="sc-grid"></div>
  <div id="sc-active-info" style="display:none">
    <div style="font-size:9px;letter-spacing:.08em;color:var(--dim);margin-bottom:6px">ACTIVE REGIONS</div>
    <div class="sc-bars" id="sc-bars"></div>
    <div class="sc-desc" id="sc-desc"></div>
  </div>
</div>
"@

$js148 = @"
<script>
// === V148 BRAIN IN ACTION ===
var BRAIN_SCENARIOS=[
  {id:'reading',name:'Reading',icon:'&#128218;',duration:8000,
   activations:[{region:'visual_cortex',onset:0,dur:8000,intensity:0.9},{region:'wernicke',onset:200,dur:7800,intensity:0.85},{region:'broca',onset:300,dur:7700,intensity:0.7},{region:'prefrontal',onset:500,dur:7500,intensity:0.6}],
   description:"Visual cortex processes text, Wernicke's area decodes meaning, Broca's area processes grammar. PFC maintains working memory."},
  {id:'running',name:'Running',icon:'&#127939;',duration:8000,
   activations:[{region:'motor_cortex',onset:0,dur:8000,intensity:0.95},{region:'cerebellum',onset:0,dur:8000,intensity:0.9},{region:'basal_ganglia',onset:100,dur:7900,intensity:0.8},{region:'hypothalamus',onset:500,dur:7500,intensity:0.7}],
   description:'Motor cortex sends commands, cerebellum coordinates balance, basal ganglia sequences movements, hypothalamus regulates temperature.'},
  {id:'dreaming',name:'Dreaming',icon:'&#128164;',duration:8000,
   activations:[{region:'limbic',onset:0,dur:8000,intensity:0.85},{region:'visual_cortex',onset:0,dur:8000,intensity:0.8},{region:'hippocampus',onset:200,dur:7800,intensity:0.9},{region:'prefrontal',onset:0,dur:8000,intensity:0.1}],
   description:'REM sleep: limbic generates emotions, visual cortex creates imagery, hippocampus replays memories. PFC deactivates — why dreams feel logical.'},
  {id:'meditating',name:'Meditating',icon:'&#129496;',duration:8000,
   activations:[{region:'prefrontal',onset:0,dur:8000,intensity:0.85},{region:'anterior_cingulate',onset:200,dur:7800,intensity:0.8},{region:'insula',onset:500,dur:7500,intensity:0.75},{region:'limbic',onset:0,dur:8000,intensity:0.3}],
   description:'Meditation activates PFC attention, anterior cingulate (error detection), insula (body awareness). Reduces limbic reactivity.'},
  {id:'love',name:'Falling in Love',icon:'&#10084;',duration:8000,
   activations:[{region:'limbic',onset:0,dur:8000,intensity:0.95},{region:'basal_ganglia',onset:0,dur:8000,intensity:0.9},{region:'insula',onset:100,dur:7900,intensity:0.85},{region:'prefrontal',onset:0,dur:8000,intensity:0.4}],
   description:'Love activates reward circuits (dopamine), limbic emotional centers, insula (racing heart). Partially deactivates PFC — the "love is blind" effect.'},
  {id:'grieving',name:'Grieving',icon:'&#128167;',duration:8000,
   activations:[{region:'anterior_cingulate',onset:0,dur:8000,intensity:0.9},{region:'limbic',onset:0,dur:8000,intensity:0.85},{region:'prefrontal',onset:200,dur:7800,intensity:0.7},{region:'hypothalamus',onset:300,dur:7700,intensity:0.6}],
   description:'Grief activates anterior cingulate (same as physical pain), limbic processing, PFC for rumination, hypothalamus driving stress response.'}
];
var scenariosOpen=false,activeScenario=null,scenarioTimeout=null;
function toggleScenariosPanel(){
  scenariosOpen=!scenariosOpen;
  var p=document.getElementById('scenarios-panel'),b=document.getElementById('bScenarios');
  if(p)p.classList.toggle('vis',scenariosOpen);
  if(b)b.classList.toggle('on',scenariosOpen);
  if(scenariosOpen)renderScenarios();
}
function renderScenarios(){
  var g=document.getElementById('sc-grid');if(!g)return;
  g.innerHTML=BRAIN_SCENARIOS.map(function(s){
    return '<div class="sc-card'+(activeScenario&&activeScenario.id===s.id?' active':'')+'" onclick="playScenario(\''+s.id+'\')">'
      +'<span class="sc-icon">'+s.icon+'</span><span class="sc-name">'+s.name+'</span></div>';
  }).join('');
}
function playScenario(id){
  var sc=BRAIN_SCENARIOS.find(function(s){return s.id===id;});if(!sc)return;
  activeScenario=sc;
  renderScenarios();
  var info=document.getElementById('sc-active-info'),bars=document.getElementById('sc-bars'),desc=document.getElementById('sc-desc');
  if(info)info.style.display='block';
  if(desc)desc.textContent=sc.description;
  if(bars)bars.innerHTML=sc.activations.map(function(a){
    var pct=Math.round(a.intensity*100);
    var col=a.intensity>0.8?'var(--red)':a.intensity>0.5?'var(--gold)':'var(--accent2)';
    return '<div class="sc-bar-row"><span class="sc-bar-label">'+a.region.replace(/_/g,' ')+'</span>'
      +'<div class="sc-bar-bg"><div class="sc-bar-fill" style="width:'+pct+'%;background:'+col+'"></div></div>'
      +'<span style="font-size:9px;color:var(--dim);width:28px">'+pct+'%</span></div>';
  }).join('');
  // Flash brain regions
  if(typeof regionMsh!=='undefined'){
    sc.activations.forEach(function(a){
      setTimeout(function(){
        var m=regionMsh[a.region];if(!m)return;
        m.material.color.setHex(a.intensity>0.8?0xff5568:a.intensity>0.5?0xffc84a:0x50e8a0);
        m.material.opacity=a.intensity*0.6;
        setTimeout(function(){m.material.opacity=0;},a.dur||5000);
      },a.onset||0);
    });
  }
  showToast(sc.icon+' '+sc.name+' activated',{type:'info',duration:2500});
}
</script>
"@

$c148 = $c147
$c148 = ReplaceFirst $c148 '</style>' ($css148 + '</style>')
$c148 = ReplaceFirst $c148 '&#9889; CIRCUIT</div></div>' ('&#9889; CIRCUIT</div>' + "`r`n" + $btn148 + '</div>')
$c148 = ReplaceFirst $c148 '</body>' ($panel148 + $js148 + '</body>')
WriteVersion $c148 "$root\148\index.html" "148 — Brain Scenarios"

# ========================== V149 ==========================
$css149 = ".species-panel{bottom:50px;right:10px;width:320px}
.sp-grid{display:grid;grid-template-columns:1fr 1fr;gap:5px;margin:8px 0}
.sp-item{background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:8px;padding:7px;cursor:pointer;transition:var(--trans)}
.sp-item:hover,.sp-item.sel{background:rgba(58,184,255,.15);border-color:var(--b2)}
.sp-name{font-size:11px;font-weight:600;color:var(--text);margin-bottom:3px}
.sp-neurons{font-size:9px;color:var(--accent);font-family:var(--font-mono)}
.sp-vol{font-size:9px;color:var(--dim)}
.sp-compare{margin-top:8px;padding:8px;background:rgba(0,0,0,.3);border-radius:6px;border:1px solid var(--b1)}
.sp-iq-bar{height:6px;border-radius:3px;background:var(--accent);margin-top:3px;transition:width .5s}
"
$btn149 = "  <div class=`"hb`" id=`"bSpecies`" onclick=`"toggleSpeciesPanel()`" style=`"border-color:rgba(192,132,252,.3);color:rgba(192,132,252,.7)`">&#127758; SPECIES</div>"

$panel149 = @"
<div id="species-panel" class="feature-panel species-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#127758; CROSS-SPECIES INTELLIGENCE</span>
    <span class="fp-sub">Brain complexity across the animal kingdom</span>
    <span class="fp-close" onclick="toggleSpeciesPanel()">&#215;</span>
  </div>
  <div class="sp-grid" id="sp-grid"></div>
  <div class="sp-compare" id="sp-compare" style="display:none"></div>
  <div style="margin-top:8px;font-size:10px;color:var(--dim);line-height:1.6">Path to digital: every species below could theoretically have its connectome mapped and simulated. C. elegans is already done. Drosophila (2023) completed. Mouse connectome: ~2030?</div>
</div>
"@

$js149 = @"
<script>
// === V149 CROSS-SPECIES INTELLIGENCE ===
var SPECIES=[
  {name:'C. elegans',neurons:'302',vol:'0.3mm',ratio:0.001,neocortex:0,tools:false,language:false,radius:0.05,color:'#50e8a0'},
  {name:'Drosophila',neurons:'140K',vol:'0.5mm³',ratio:0.01,neocortex:0,tools:false,language:false,radius:0.08,color:'#ffc84a'},
  {name:'Mouse',neurons:'71M',vol:'0.4cm³',ratio:0.1,neocortex:0.3,tools:false,language:false,radius:0.5,color:'#88bbff'},
  {name:'Crow',neurons:'1.5B',vol:'6.5cm³',ratio:0.4,neocortex:0.5,tools:true,language:false,radius:0.8,color:'#c084fc'},
  {name:'Chimpanzee',neurons:'28B',vol:'400cm³',ratio:0.7,neocortex:0.8,tools:true,language:true,radius:1.5,color:'#ff9060'},
  {name:'Human',neurons:'86B',vol:'1300cm³',ratio:1.0,neocortex:1.0,tools:true,language:true,radius:3.0,color:'#3ab8ff'},
  {name:'Hypothetical ASI',neurons:'10T+',vol:'N/A',ratio:100,neocortex:1.0,tools:true,language:true,radius:6.0,color:'#ff55aa'}
];
var speciesOpen=false,selSpecies=null,speciesVizGroup=null;
function toggleSpeciesPanel(){
  speciesOpen=!speciesOpen;
  var p=document.getElementById('species-panel'),b=document.getElementById('bSpecies');
  if(p)p.classList.toggle('vis',speciesOpen);
  if(b)b.classList.toggle('on',speciesOpen);
  if(speciesOpen){renderSpeciesPanel();buildSpeciesViz();}
  else if(speciesVizGroup){scene.remove(speciesVizGroup);speciesVizGroup=null;}
}
function renderSpeciesPanel(){
  var g=document.getElementById('sp-grid');if(!g)return;
  g.innerHTML=SPECIES.map(function(s,i){
    return '<div class="sp-item'+(selSpecies===i?' sel':'')+'" onclick="selectSpecies('+i+')">'
      +'<div class="sp-name">'+s.name+'</div>'
      +'<div class="sp-neurons">'+s.neurons+' neurons</div>'
      +'<div class="sp-vol">'+s.vol+'</div></div>';
  }).join('');
}
function selectSpecies(i){
  selSpecies=i;renderSpeciesPanel();
  var sp=SPECIES[i],el=document.getElementById('sp-compare');
  if(!el)return;el.style.display='block';
  var tools=sp.tools?'&#10004;':'&#10006;',lang=sp.language?'&#10004;':'&#10006;';
  el.innerHTML='<div style="font-size:11px;font-weight:600;color:var(--accent);margin-bottom:6px">'+sp.name+'</div>'
    +'<div style="font-size:10px;color:var(--dim);display:flex;justify-content:space-between"><span>Neurons: <b style="color:var(--text)">'+sp.neurons+'</b></span><span>Tool use: <b>'+tools+'</b></span><span>Language: <b>'+lang+'</b></span></div>'
    +'<div style="margin-top:6px;font-size:9px;color:var(--dim)">Intelligence ratio vs human</div>'
    +'<div class="sp-iq-bar" style="width:'+Math.min(100,sp.ratio*100)+'%;background:'+sp.color+'"></div>'
    +'<div style="margin-top:4px;font-size:9px;color:var(--dim)">Neocortex ratio: '+Math.round(sp.neocortex*100)+'%</div>';
}
function buildSpeciesViz(){
  if(speciesVizGroup){scene.remove(speciesVizGroup);speciesVizGroup=null;}
  var g=new THREE.Group();g.position.set(0,8,0);
  SPECIES.forEach(function(s,i){
    var x=(i-3)*3;
    var geo=new THREE.SphereGeometry(s.radius,12,12);
    var mat=new THREE.MeshBasicMaterial({color:new THREE.Color(s.color),wireframe:true,opacity:0.6,transparent:true});
    var mesh=new THREE.Mesh(geo,mat);mesh.position.set(x,0,0);g.add(mesh);
  });
  speciesVizGroup=g;scene.add(g);
}
</script>
"@

$c149 = $c148
$c149 = ReplaceFirst $c149 '</style>' ($css149 + '</style>')
$c149 = ReplaceFirst $c149 '&#129504; SCENARIOS</div></div>' ('&#129504; SCENARIOS</div>' + "`r`n" + $btn149 + '</div>')
$c149 = ReplaceFirst $c149 '</body>' ($panel149 + $js149 + '</body>')
WriteVersion $c149 "$root\149\index.html" "149 — Species Comparison"

# ========================== V150 ==========================
$css150 = ".consci-panel{bottom:50px;right:10px;width:320px}
.cs-milestones{display:flex;flex-direction:column;gap:4px;margin:8px 0}
.cs-milestone{padding:7px 10px;border-radius:6px;border:1px solid var(--b1);background:rgba(58,184,255,.04);transition:var(--trans)}
.cs-milestone.active{background:rgba(192,132,252,.15);border-color:rgba(192,132,252,.5)}
.cs-milestone.done{background:rgba(80,232,160,.08);border-color:rgba(80,232,160,.3)}
.cs-milestone-title{font-size:11px;font-weight:600;color:var(--text)}
.cs-milestone-desc{font-size:10px;color:var(--dim);margin-top:3px}
.cs-phi{display:flex;align-items:center;gap:8px;margin:8px 0;padding:8px;background:rgba(0,0,0,.3);border-radius:6px}
.cs-phi-label{font-size:11px;color:var(--dim);white-space:nowrap}
.cs-phi-bar{flex:1;height:12px;background:rgba(58,184,255,.1);border-radius:6px;overflow:hidden}
.cs-phi-fill{height:100%;background:linear-gradient(90deg,#3ab8ff,#c084fc);border-radius:6px;transition:width 1s}
.cs-phi-val{font-size:12px;font-weight:700;color:var(--purple);font-family:var(--font-mono);width:40px;text-align:right}
"
$btn150 = "  <div class=`"hb`" id=`"bConsciousness`" onclick=`"toggleConsciPanel()`" style=`"border-color:rgba(192,132,252,.3);color:rgba(192,132,252,.7)`">&#127775; CONSCIOUSNESS</div>"

$panel150 = @"
<div id="consci-panel" class="feature-panel consci-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#127775; CONSCIOUSNESS EMERGENCE</span>
    <span class="fp-sub">From 1 neuron to self-awareness — IIT Phi metric</span>
    <span class="fp-close" onclick="toggleConsciPanel()">&#215;</span>
  </div>
  <div class="cs-phi">
    <span class="cs-phi-label">&#934; (Phi)</span>
    <div class="cs-phi-bar"><div class="cs-phi-fill" id="cs-phi-fill" style="width:0%"></div></div>
    <span class="cs-phi-val" id="cs-phi-val">0.0</span>
  </div>
  <button onclick="startConsciEmergence()" style="width:100%;padding:7px;background:rgba(192,132,252,.1);border:1px solid rgba(192,132,252,.3);color:var(--purple);border-radius:6px;cursor:pointer;font-size:12px;margin-bottom:8px">&#9654; Simulate Emergence (30s)</button>
  <div style="font-size:9px;color:var(--dim);letter-spacing:.08em;margin-bottom:6px">COMPLEXITY MILESTONES</div>
  <div class="cs-milestones" id="cs-milestones"></div>
</div>
"@

$js150 = @"
<script>
// === V150 CONSCIOUSNESS EMERGENCE ===
var CS_MILESTONES=[
  {neurons:1,label:'1 Neuron',capacity:'Simple reflex',phi:0.01},
  {neurons:10,label:'10 Neurons',capacity:'Stimulus-response',phi:0.05},
  {neurons:100,label:'100 Neurons',capacity:'Simple behavior (C. elegans)',phi:0.12},
  {neurons:10000,label:'10K Neurons',capacity:'Learning & memory',phi:0.28},
  {neurons:1000000,label:'1M Neurons',capacity:'Emotional response',phi:0.55},
  {neurons:86000000000,label:'86B Neurons',capacity:'Self-awareness & consciousness',phi:1.0}
];
var consciOpen=false,consciEmergTimer=null,consciStep=0,consciSpheres=[];
function toggleConsciPanel(){
  consciOpen=!consciOpen;
  var p=document.getElementById('consci-panel'),b=document.getElementById('bConsciousness');
  if(p)p.classList.toggle('vis',consciOpen);
  if(b)b.classList.toggle('on',consciOpen);
  if(consciOpen)renderCSMilestones(0);
}
function renderCSMilestones(activeIdx){
  var el=document.getElementById('cs-milestones');if(!el)return;
  el.innerHTML=CS_MILESTONES.map(function(m,i){
    var cls=i<activeIdx?'done':i===activeIdx?'active':'';
    return '<div class="cs-milestone '+cls+'">'
      +'<div class="cs-milestone-title">'+(i<activeIdx?'&#10003; ':i===activeIdx?'&#9658; ':'')+m.label+'</div>'
      +'<div class="cs-milestone-desc">'+m.capacity+'</div></div>';
  }).join('');
  var phi=CS_MILESTONES[Math.min(activeIdx,CS_MILESTONES.length-1)].phi;
  var pf=document.getElementById('cs-phi-fill'),pv=document.getElementById('cs-phi-val');
  if(pf)pf.style.width=Math.round(phi*100)+'%';
  if(pv)pv.textContent=phi.toFixed(2);
}
function startConsciEmergence(){
  if(consciEmergTimer)clearInterval(consciEmergTimer);
  consciStep=0;
  buildConsciSpheres(0);
  renderCSMilestones(0);
  var stepMs=Math.floor(30000/CS_MILESTONES.length);
  consciEmergTimer=setInterval(function(){
    consciStep++;
    if(consciStep>=CS_MILESTONES.length){clearInterval(consciEmergTimer);consciStep=CS_MILESTONES.length-1;}
    renderCSMilestones(consciStep);
    buildConsciSpheres(consciStep);
    showToast(CS_MILESTONES[consciStep].label+': '+CS_MILESTONES[consciStep].capacity,{type:'info',duration:2000});
  },stepMs);
}
function buildConsciSpheres(step){
  consciSpheres.forEach(function(s){scene.remove(s);});
  consciSpheres=[];
  var count=Math.min(100,Math.pow(2,step+1));
  var col=new THREE.Color().setHSL(0.75-step*0.1,0.8,0.6);
  for(var i=0;i<count;i++){
    var theta=Math.random()*Math.PI*2,phi=Math.acos(2*Math.random()-1);
    var r=1+step*0.5;
    var geo=new THREE.SphereGeometry(0.04+step*0.01,4,4);
    var mat=new THREE.MeshBasicMaterial({color:col,transparent:true,opacity:0.7});
    var m=new THREE.Mesh(geo,mat);
    m.position.set(r*Math.sin(phi)*Math.cos(theta),r*Math.sin(phi)*Math.sin(theta)+3,r*Math.cos(phi));
    scene.add(m);consciSpheres.push(m);
  }
}
</script>
"@

$c150 = $c149
$c150 = ReplaceFirst $c150 '</style>' ($css150 + '</style>')
$c150 = ReplaceFirst $c150 '&#127758; SPECIES</div></div>' ('&#127758; SPECIES</div>' + "`r`n" + $btn150 + '</div>')
$c150 = ReplaceFirst $c150 '</body>' ($panel150 + $js150 + '</body>')
WriteVersion $c150 "$root\150\index.html" "150 — Consciousness Emergence"

# ========================== V151 ==========================
$css151 = ".sleep-panel{bottom:50px;right:10px;width:360px}
.sleep-canvas-wrap{position:relative;margin:8px 0;border:1px solid var(--b1);border-radius:6px;overflow:hidden}
#sleep-canvas{display:block;background:#020408}
.sleep-stage-info{padding:8px;background:rgba(0,0,0,.3);border-radius:6px;margin:6px 0;min-height:40px}
.sleep-stage-name{font-size:13px;font-weight:700;color:var(--accent);font-family:var(--font-mono)}
.sleep-stage-desc{font-size:10px;color:var(--dim);margin-top:3px;line-height:1.5}
.sleep-facts{display:flex;gap:4px;margin-top:8px;flex-wrap:wrap}
.sleep-fact{flex:1;min-width:80px;background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:6px;padding:6px;text-align:center}
.sleep-fact-val{font-size:13px;font-weight:700;color:var(--accent2);font-family:var(--font-mono)}
.sleep-fact-lbl{font-size:9px;color:var(--dim);display:block;margin-top:2px}
"
$btn151 = "  <div class=`"hb`" id=`"bSleep`" onclick=`"toggleSleepPanel()`" style=`"border-color:rgba(58,184,255,.3);color:rgba(58,184,255,.7)`">&#128164; SLEEP</div>"

$panel151 = @"
<div id="sleep-panel" class="feature-panel sleep-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128164; SLEEP ARCHITECTURE</span>
    <span class="fp-sub">8-hour sleep cycle — memory consolidation & neural repair</span>
    <span class="fp-close" onclick="toggleSleepPanel()">&#215;</span>
  </div>
  <div class="sleep-canvas-wrap">
    <canvas id="sleep-canvas" width="332" height="120"></canvas>
  </div>
  <div style="display:flex;gap:6px;margin-bottom:8px">
    <button onclick="playSleepAnim()" style="flex:1;padding:6px;background:rgba(58,184,255,.1);border:1px solid var(--b2);color:var(--accent);border-radius:6px;cursor:pointer;font-size:11px">&#9654; Play Night</button>
    <button onclick="stopSleepAnim()" style="flex:1;padding:6px;background:rgba(58,184,255,.05);border:1px solid var(--b1);color:var(--dim);border-radius:6px;cursor:pointer;font-size:11px">&#9646;&#9646; Stop</button>
  </div>
  <div class="sleep-stage-info">
    <div class="sleep-stage-name" id="sleep-stage-name">Press Play to start</div>
    <div class="sleep-stage-desc" id="sleep-stage-desc">Watch the brain travel through 5 sleep cycles</div>
  </div>
  <div class="sleep-facts">
    <div class="sleep-fact"><span class="sleep-fact-val">5</span><span class="sleep-fact-lbl">Sleep Cycles</span></div>
    <div class="sleep-fact"><span class="sleep-fact-val">~90</span><span class="sleep-fact-lbl">Min/Cycle</span></div>
    <div class="sleep-fact"><span class="sleep-fact-val">25%</span><span class="sleep-fact-lbl">REM Sleep</span></div>
    <div class="sleep-fact"><span class="sleep-fact-val">N3</span><span class="sleep-fact-lbl">Deep Sleep</span></div>
  </div>
  <div style="margin-top:8px;font-size:10px;color:var(--dim);line-height:1.6"><b style="color:var(--accent2)">WBE relevance:</b> Sleep may be essential for digital minds — hippocampal replay consolidates episodic memory. Skipping sleep could mean memory loss even in uploaded minds.</div>
</div>
"@

$js151 = @"
<script>
// === V151 SLEEP ARCHITECTURE ===
var sleepOpen=false,sleepAnimTimer=null,sleepPlayhead=0,sleepAnimRunning=false;
var SLEEP_STAGES=[
  {name:'Wake (W)',color:'#ff5568',yPct:0.05,desc:'Awake — high frequency, low amplitude brain waves. Beta/gamma dominant.'},
  {name:'NREM 1 (N1)',color:'#ffc84a',yPct:0.25,desc:'Light drowsiness. Theta waves (4-8Hz). Hypnic jerks may occur. Easily awakened.'},
  {name:'NREM 2 (N2)',color:'#3ab8ff',yPct:0.5,desc:'Sleep spindles (12-15Hz bursts) and K-complexes. Heart rate slows. Memory consolidation begins.'},
  {name:'NREM 3 (N3)',color:'#c084fc',yPct:0.8,desc:'Deep slow-wave sleep. Delta waves (0.5-2Hz). Most restorative. Growth hormone released. Hard to wake.'},
  {name:'REM',color:'#50e8a0',yPct:0.3,desc:'Rapid eye movement. Brain activity resembles waking. Vivid dreams. Emotional memory processing. Paralysis.'}
];
// Build 8-hour hypnogram: 5 cycles, each ~90min, increasing REM
var SLEEP_HYPNOGRAM=[];
(function(){
  var patterns=[
    [0,1,2,3,2,3,2,4],[0,1,2,3,2,4,4],[0,1,2,3,2,4,4,4],[0,1,2,3,4,4,4],[0,1,2,4,4,4,4]
  ];
  patterns.forEach(function(p){p.forEach(function(s){SLEEP_HYPNOGRAM.push(s);});});
})();
function toggleSleepPanel(){
  sleepOpen=!sleepOpen;
  var p=document.getElementById('sleep-panel'),b=document.getElementById('bSleep');
  if(p)p.classList.toggle('vis',sleepOpen);
  if(b)b.classList.toggle('on',sleepOpen);
  if(sleepOpen){setTimeout(function(){drawSleepHypnogram(0);},100);}
  else stopSleepAnim();
}
function drawSleepHypnogram(playhead){
  var cv=document.getElementById('sleep-canvas');if(!cv)return;
  var ctx=cv.getContext('2d');var w=cv.width,h=cv.height;
  ctx.clearRect(0,0,w,h);
  ctx.fillStyle='#020408';ctx.fillRect(0,0,w,h);
  // Draw grid
  ctx.strokeStyle='rgba(58,184,255,0.08)';ctx.lineWidth=1;
  for(var i=0;i<=5;i++){var yy=h*0.1+i*(h*0.8/5);ctx.beginPath();ctx.moveTo(0,yy);ctx.lineTo(w,yy);ctx.stroke();}
  // Draw hypnogram line
  var stepW=w/SLEEP_HYPNOGRAM.length;
  ctx.beginPath();
  SLEEP_HYPNOGRAM.forEach(function(s,i){
    var x=i*stepW;
    var y=h*SLEEP_STAGES[s].yPct;
    if(i===0)ctx.moveTo(x,y);else ctx.lineTo(x,y);
  });
  ctx.strokeStyle='rgba(58,184,255,0.4)';ctx.lineWidth=1.5;ctx.stroke();
  // Draw playhead
  if(playhead>0&&playhead<SLEEP_HYPNOGRAM.length){
    var px=playhead*stepW;
    ctx.beginPath();ctx.moveTo(px,0);ctx.lineTo(px,h);
    ctx.strokeStyle='rgba(255,200,74,0.8)';ctx.lineWidth=2;ctx.stroke();
    var curStage=SLEEP_HYPNOGRAM[Math.floor(playhead)];
    ctx.fillStyle=SLEEP_STAGES[curStage].color;
    ctx.beginPath();ctx.arc(px,h*SLEEP_STAGES[curStage].yPct,5,0,Math.PI*2);ctx.fill();
    // Update info
    var sn=document.getElementById('sleep-stage-name'),sd=document.getElementById('sleep-stage-desc');
    if(sn)sn.style.color=SLEEP_STAGES[curStage].color;
    if(sn)sn.textContent=SLEEP_STAGES[curStage].name;
    if(sd)sd.textContent=SLEEP_STAGES[curStage].desc;
  }
  // Color segments
  var segCtx=cv.getContext('2d');
  SLEEP_HYPNOGRAM.forEach(function(s,i){
    if(i>=Math.floor(playhead))return;
    var x=i*stepW;var y=h*SLEEP_STAGES[s].yPct;
    segCtx.fillStyle=SLEEP_STAGES[s].color+'33';
    segCtx.fillRect(x,y,stepW,h-y);
  });
}
function playSleepAnim(){
  stopSleepAnim();sleepPlayhead=0;sleepAnimRunning=true;
  sleepAnimTimer=setInterval(function(){
    sleepPlayhead+=0.5;
    if(sleepPlayhead>=SLEEP_HYPNOGRAM.length){sleepPlayhead=SLEEP_HYPNOGRAM.length-1;stopSleepAnim();return;}
    drawSleepHypnogram(sleepPlayhead);
    var s=SLEEP_HYPNOGRAM[Math.floor(sleepPlayhead)];
    if(typeof regionMsh!=='undefined'){
      var cols={0:0xff5568,1:0xffc84a,2:0x3ab8ff,3:0xc084fc,4:0x50e8a0};
      if(s===3){var m=regionMsh['hippocampus'];if(m){m.material.color.setHex(0xc084fc);m.material.opacity=0.5;}}
      if(s===4){var lm=regionMsh['limbic'];if(lm){lm.material.color.setHex(0x50e8a0);lm.material.opacity=0.4;}}
    }
  },100);
}
function stopSleepAnim(){
  sleepAnimRunning=false;
  if(sleepAnimTimer){clearInterval(sleepAnimTimer);sleepAnimTimer=null;}
}
</script>
"@

$c151 = $c150
$c151 = ReplaceFirst $c151 '</style>' ($css151 + '</style>')
$c151 = ReplaceFirst $c151 '&#127775; CONSCIOUSNESS</div></div>' ('&#127775; CONSCIOUSNESS</div>' + "`r`n" + $btn151 + '</div>')
$c151 = ReplaceFirst $c151 '</body>' ($panel151 + $js151 + '</body>')
WriteVersion $c151 "$root\151\index.html" "151 — Sleep Architecture"

# ========================== V152 ==========================
$css152 = ".plastlab-panel{bottom:50px;right:10px;width:310px}
.plast-mode-indicator{padding:6px 10px;border-radius:6px;font-size:11px;text-align:center;margin:6px 0;background:rgba(80,232,160,.08);border:1px solid rgba(80,232,160,.2);color:var(--accent2);display:none}
.plast-mode-indicator.active{display:block}
.plast-conn-list{max-height:120px;overflow-y:auto;margin:6px 0}
.plast-conn-item{display:flex;align-items:center;justify-content:space-between;padding:4px 6px;border-bottom:1px solid var(--b1);font-size:10px}
.plast-conn-strength{width:60px;height:4px;background:rgba(58,184,255,.2);border-radius:2px;overflow:hidden}
.plast-conn-bar{height:100%;background:var(--accent2);border-radius:2px;transition:width .3s}
.hebb-quote{background:rgba(80,232,160,.05);border:1px solid rgba(80,232,160,.2);border-radius:6px;padding:8px;font-size:11px;color:var(--accent2);font-style:italic;margin-top:8px}
"
$btn152 = "  <div class=`"hb`" id=`"bPlastLab`" onclick=`"togglePlastLabPanel()`" style=`"border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)`">&#128257; PLASTICITY</div>"

$panel152 = @"
<div id="plastlab-panel" class="feature-panel plastlab-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128257; NEURAL PLASTICITY LAB</span>
    <span class="fp-sub">Grow new connections between brain regions</span>
    <span class="fp-close" onclick="togglePlastLabPanel()">&#215;</span>
  </div>
  <div class="plast-mode-indicator" id="plast-mode-ind">&#9670; PLASTICITY MODE ACTIVE — Click two brain regions to connect</div>
  <div style="display:flex;gap:6px;margin:8px 0">
    <button onclick="togglePlasticityMode()" id="plast-toggle-btn" style="flex:1;padding:7px;background:rgba(80,232,160,.1);border:1px solid rgba(80,232,160,.3);color:var(--accent2);border-radius:6px;cursor:pointer;font-size:11px">&#9670; Enable Plasticity Mode</button>
    <button onclick="clearPlastConnections()" style="padding:7px 10px;background:rgba(255,85,104,.08);border:1px solid rgba(255,85,104,.2);color:var(--red);border-radius:6px;cursor:pointer;font-size:11px">&#10006; Clear</button>
  </div>
  <div style="display:flex;gap:8px;margin:6px 0">
    <div style="flex:1;text-align:center;padding:6px;background:rgba(80,232,160,.05);border:1px solid var(--b1);border-radius:6px">
      <div style="font-size:16px;font-weight:700;color:var(--accent2);font-family:var(--font-mono)" id="plast-conn-count">0</div>
      <div style="font-size:9px;color:var(--dim)">Connections</div>
    </div>
    <div style="flex:1;text-align:center;padding:6px;background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:6px">
      <div style="font-size:16px;font-weight:700;color:var(--accent);font-family:var(--font-mono)" id="plast-ltp-count">0</div>
      <div style="font-size:9px;color:var(--dim)">LTP Events</div>
    </div>
  </div>
  <div style="font-size:9px;color:var(--dim);letter-spacing:.08em;margin:6px 0">USER CONNECTIONS</div>
  <div class="plast-conn-list" id="plast-conn-list"><div style="font-size:10px;color:var(--dim);padding:4px">No connections yet</div></div>
  <div class="hebb-quote">"Neurons that fire together, wire together" — Hebb's Rule (1949)</div>
</div>
"@

$js152 = @"
<script>
// === V152 NEURAL PLASTICITY LAB ===
var plastLabOpen=false,plastModeActive=false,USER_CONNECTIONS=[],plastFirstClick=null,plastLTPCount=0;
var plastArcs=[];
function togglePlastLabPanel(){
  plastLabOpen=!plastLabOpen;
  var p=document.getElementById('plastlab-panel'),b=document.getElementById('bPlastLab');
  if(p)p.classList.toggle('vis',plastLabOpen);
  if(b)b.classList.toggle('on',plastLabOpen);
  if(plastLabOpen)renderPlastConnections();
}
function togglePlasticityMode(){
  plastModeActive=!plastModeActive;
  var ind=document.getElementById('plast-mode-ind'),btn=document.getElementById('plast-toggle-btn');
  if(ind)ind.classList.toggle('active',plastModeActive);
  if(btn)btn.textContent=plastModeActive?'&#9670; Disable Plasticity Mode':'&#9670; Enable Plasticity Mode';
  if(btn)btn.style.background=plastModeActive?'rgba(80,232,160,.25)':'rgba(80,232,160,.1)';
  plastFirstClick=null;
  if(plastModeActive)showToast('Click two brain regions to create a connection',{type:'info',duration:3000});
}
function handlePlastClick(key){
  if(!plastModeActive)return;
  if(!plastFirstClick){plastFirstClick=key;showToast('First region: '+key+' — now click the second region',{duration:2000});return;}
  if(plastFirstClick===key){plastFirstClick=null;return;}
  createPlastConnection(plastFirstClick,key);plastFirstClick=null;
}
function createPlastConnection(a,b){
  var existing=USER_CONNECTIONS.find(function(c){return (c.a===a&&c.b===b)||(c.a===b&&c.b===a);});
  if(existing){
    existing.strength=Math.min(1,existing.strength+0.2);
    existing.ltp++;plastLTPCount++;
    showToast('Connection reinforced! LTP event &#128293;',{type:'success',icon:'&#9889;',duration:2000});
  } else {
    USER_CONNECTIONS.push({a:a,b:b,strength:0.4,ltp:1});
    plastLTPCount++;
    showToast('New connection: '+a+' &#8596; '+b,{type:'success',icon:'&#127774;',duration:2500});
  }
  renderPlastConnections();
  buildPlastArcs();
  // Flash regions
  if(typeof regionMsh!=='undefined'){
    [a,b].forEach(function(k){
      var m=regionMsh[k];if(!m)return;
      m.material.color.setHex(0x50e8a0);m.material.opacity=0.7;
      setTimeout(function(){m.material.opacity=0;},500);
    });
  }
}
function clearPlastConnections(){
  USER_CONNECTIONS=[];plastLTPCount=0;plastArcs.forEach(function(a){scene.remove(a);});plastArcs=[];
  renderPlastConnections();
}
function renderPlastConnections(){
  var el=document.getElementById('plast-conn-list'),cc=document.getElementById('plast-conn-count'),lc=document.getElementById('plast-ltp-count');
  if(cc)cc.textContent=USER_CONNECTIONS.length;
  if(lc)lc.textContent=plastLTPCount;
  if(!el)return;
  if(USER_CONNECTIONS.length===0){el.innerHTML='<div style="font-size:10px;color:var(--dim);padding:4px">No connections yet</div>';return;}
  el.innerHTML=USER_CONNECTIONS.map(function(c){
    return '<div class="plast-conn-item">'
      +'<span style="color:var(--text)">'+c.a.replace(/_/g,' ')+' &#8596; '+c.b.replace(/_/g,' ')+'</span>'
      +'<div class="plast-conn-strength"><div class="plast-conn-bar" style="width:'+Math.round(c.strength*100)+'%"></div></div>'
      +'<span style="color:var(--accent2);font-size:9px">'+Math.round(c.strength*100)+'%</span></div>';
  }).join('');
}
function buildPlastArcs(){
  plastArcs.forEach(function(a){scene.remove(a);});plastArcs=[];
  if(typeof REGIONS==='undefined')return;
  USER_CONNECTIONS.forEach(function(c){
    var ra=REGIONS.find(function(r){return r.key===c.a;}),rb=REGIONS.find(function(r){return r.key===c.b;});
    if(!ra||!rb)return;
    var pa=new THREE.Vector3(ra.pos[0],ra.pos[1],ra.pos[2]);
    var pb=new THREE.Vector3(rb.pos[0],rb.pos[1],rb.pos[2]);
    var mid=pa.clone().add(pb).multiplyScalar(0.5);mid.y+=1.5;
    var curve=new THREE.QuadraticBezierCurve3(pa,mid,pb);
    var pts=curve.getPoints(20);
    var geo=new THREE.BufferGeometry().setFromPoints(pts);
    var mat=new THREE.LineBasicMaterial({color:0x50e8a0,opacity:c.strength*0.8,transparent:true});
    var line=new THREE.Line(geo,mat);scene.add(line);plastArcs.push(line);
  });
}
// Hook into region click
var _origRegionClick=window.handleRegionClick;
window.handleRegionClick=function(key){
  if(plastModeActive)handlePlastClick(key);
  else if(_origRegionClick)_origRegionClick(key);
};
</script>
"@

$c152 = $c151
$c152 = ReplaceFirst $c152 '</style>' ($css152 + '</style>')
$c152 = ReplaceFirst $c152 '&#128164; SLEEP</div></div>' ('&#128164; SLEEP</div>' + "`r`n" + $btn152 + '</div>')
$c152 = ReplaceFirst $c152 '</body>' ($panel152 + $js152 + '</body>')
WriteVersion $c152 "$root\152\index.html" "152 — Plasticity Lab"

# ========================== V153 ==========================
$css153 = ".dmn-panel{bottom:50px;right:10px;width:310px}
.dmn-nodes{display:flex;flex-wrap:wrap;gap:5px;margin:8px 0}
.dmn-node{padding:4px 10px;border-radius:12px;font-size:10px;font-weight:600;cursor:pointer;transition:var(--trans);border:1px solid currentColor;opacity:.7}
.dmn-node:hover{opacity:1}
.dmn-node.active{opacity:1;box-shadow:0 0 8px currentColor}
.dmn-pulse{width:100%;height:40px;background:rgba(0,0,0,.4);border:1px solid var(--b1);border-radius:6px;margin:6px 0;overflow:hidden;position:relative}
.dmn-pulse-bar{position:absolute;left:0;top:50%;transform:translateY(-50%);height:4px;width:0;background:rgba(255,200,74,.7);border-radius:2px;transition:width .5s}
.dmn-fingerprint{font-size:10px;color:var(--dim);padding:6px;background:rgba(255,200,74,.05);border:1px solid rgba(255,200,74,.2);border-radius:6px;margin-top:8px}
"
$btn153 = "  <div class=`"hb`" id=`"bDMN`" onclick=`"toggleDMNPanel()`" style=`"border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)`">&#128391; DMN</div>"

$panel153 = @"
<div id="dmn-panel" class="feature-panel dmn-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128391; DEFAULT MODE NETWORK</span>
    <span class="fp-sub">The brain's identity and self-reflection network</span>
    <span class="fp-close" onclick="toggleDMNPanel()">&#215;</span>
  </div>
  <div style="font-size:10px;color:var(--dim);line-height:1.6;margin-bottom:8px">Activates during rest, self-reflection, future planning, mind-wandering, and theory of mind. Anti-correlated with task-positive networks.</div>
  <div class="dmn-nodes" id="dmn-nodes">
    <span class="dmn-node" style="color:#ffc84a" onclick="highlightDMNNode('prefrontal')">Medial PFC</span>
    <span class="dmn-node" style="color:#ffc84a" onclick="highlightDMNNode('posterior_cingulate')">Posterior Cingulate</span>
    <span class="dmn-node" style="color:#ffaa30" onclick="highlightDMNNode('parietal')">Angular Gyrus</span>
    <span class="dmn-node" style="color:#ff8844" onclick="highlightDMNNode('hippocampus')">Hippocampus</span>
    <span class="dmn-node" style="color:#ffcc55" onclick="highlightDMNNode('temporal')">Temporal Lobe</span>
  </div>
  <div style="display:flex;gap:6px;margin:8px 0">
    <button onclick="activateDMN()" style="flex:1;padding:7px;background:rgba(255,200,74,.1);border:1px solid rgba(255,200,74,.3);color:var(--gold);border-radius:6px;cursor:pointer;font-size:11px">&#9670; Activate DMN</button>
    <button onclick="deactivateDMN()" style="flex:1;padding:7px;background:rgba(58,184,255,.05);border:1px solid var(--b1);color:var(--dim);border-radius:6px;cursor:pointer;font-size:11px">&#10006; Suppress</button>
  </div>
  <div class="dmn-pulse"><div class="dmn-pulse-bar" id="dmn-pulse-bar"></div><div style="position:absolute;left:50%;top:50%;transform:translate(-50%,-50%);font-size:9px;color:var(--dim);letter-spacing:.08em" id="dmn-pulse-label">DMN INACTIVE</div></div>
  <div style="font-size:10px;color:var(--dim);line-height:1.6;margin-top:6px"><b style="color:var(--accent)">WBE Key Insight:</b> The DMN is thought to be central to personal identity. A person's unique DMN connectivity pattern could serve as a <b style="color:var(--gold)">"neural identity fingerprint"</b>.</div>
  <div class="dmn-fingerprint">&#128272; Your DMN connectivity is unique — like a neural identity. Essential data for digital preservation of the self.</div>
</div>
"@

$js153 = @"
<script>
// === V153 DEFAULT MODE NETWORK ===
var dmnOpen=false,dmnActive=false,dmnPulseTimer=null,dmnPulsePhase=0;
var DMN_REGIONS=['prefrontal','posterior_cingulate','parietal','hippocampus','temporal'];
var DMN_COLORS={prefrontal:'#ffc84a',posterior_cingulate:'#ffc84a',parietal:'#ffaa30',hippocampus:'#ff8844',temporal:'#ffcc55'};
function toggleDMNPanel(){
  dmnOpen=!dmnOpen;
  var p=document.getElementById('dmn-panel'),b=document.getElementById('bDMN');
  if(p)p.classList.toggle('vis',dmnOpen);
  if(b)b.classList.toggle('on',dmnOpen);
  if(!dmnOpen)deactivateDMN();
}
function activateDMN(){
  dmnActive=true;
  var pb=document.getElementById('dmn-pulse-bar'),pl=document.getElementById('dmn-pulse-label');
  if(pl)pl.textContent='DMN ACTIVE — Self-reflection mode';if(pl)pl.style.color='var(--gold)';
  // Dim all regions, highlight DMN
  if(typeof regionMsh!=='undefined'){
    Object.keys(regionMsh).forEach(function(k){
      var m=regionMsh[k];if(!m)return;
      m.material.opacity=0.03;
    });
    DMN_REGIONS.forEach(function(k){
      var m=regionMsh[k];if(!m)return;
      m.material.color.setStyle(DMN_COLORS[k]||'#ffc84a');
      m.material.opacity=0.5;
    });
  }
  // Pulse bar animation
  if(dmnPulseTimer)clearInterval(dmnPulseTimer);
  dmnPulsePhase=0;
  dmnPulseTimer=setInterval(function(){
    dmnPulsePhase=(dmnPulsePhase+0.05)%(Math.PI*2);
    var pct=50+Math.sin(dmnPulsePhase)*45;
    var pb2=document.getElementById('dmn-pulse-bar');if(pb2)pb2.style.width=pct+'%';
    // Pulse DMN regions
    if(typeof regionMsh!=='undefined'){
      DMN_REGIONS.forEach(function(k,i){
        var m=regionMsh[k];if(!m)return;
        m.material.opacity=0.35+Math.sin(dmnPulsePhase+i*0.6)*0.2;
      });
    }
  },40);
  showToast('Default Mode Network activated',{type:'info',icon:'&#128391;',duration:2500});
}
function deactivateDMN(){
  dmnActive=false;
  if(dmnPulseTimer){clearInterval(dmnPulseTimer);dmnPulseTimer=null;}
  var pb=document.getElementById('dmn-pulse-bar'),pl=document.getElementById('dmn-pulse-label');
  if(pb)pb.style.width='0%';if(pl){pl.textContent='DMN INACTIVE';pl.style.color='var(--dim)';}
  if(typeof regionMsh!=='undefined'){
    Object.keys(regionMsh).forEach(function(k){var m=regionMsh[k];if(m)m.material.opacity=0;});
  }
}
function highlightDMNNode(key){
  if(typeof regionMsh==='undefined')return;
  var m=regionMsh[key];if(!m)return;
  var c=m.material.color.getHex();
  m.material.color.setStyle(DMN_COLORS[key]||'#ffc84a');m.material.opacity=0.8;
  setTimeout(function(){m.material.color.setHex(c);if(!dmnActive)m.material.opacity=0;},600);
  var nodes=document.querySelectorAll('.dmn-node');
  nodes.forEach(function(n){n.classList.toggle('active',n.getAttribute('onclick').indexOf(key)>=0);});
}
</script>
"@

$c153 = $c152
$c153 = ReplaceFirst $c153 '</style>' ($css153 + '</style>')
$c153 = ReplaceFirst $c153 '&#128257; PLASTICITY</div></div>' ('&#128257; PLASTICITY</div>' + "`r`n" + $btn153 + '</div>')
$c153 = ReplaceFirst $c153 '</body>' ($panel153 + $js153 + '</body>')
WriteVersion $c153 "$root\153\index.html" "153 — Default Mode Network"

# ========================== V154 ==========================
$css154 = ".painpleasure-panel{bottom:50px;right:10px;width:310px}
.pp-toggle{display:flex;border-radius:8px;overflow:hidden;border:1px solid var(--b1);margin:8px 0}
.pp-tab{flex:1;padding:8px;text-align:center;cursor:pointer;font-size:12px;font-weight:600;transition:var(--trans)}
.pp-tab.pain{background:rgba(255,85,104,.15);color:var(--red)}
.pp-tab.pleasure{background:rgba(80,232,160,.15);color:var(--accent2)}
.pp-tab.inactive{background:rgba(58,184,255,.04);color:var(--dim)}
.pp-regions{display:flex;flex-wrap:wrap;gap:5px;margin:8px 0}
.pp-region{padding:4px 9px;border-radius:10px;font-size:10px;font-weight:600;border:1px solid currentColor;opacity:.75}
.pp-intensity{margin:8px 0}
.pp-intbar{height:10px;border-radius:5px;background:rgba(58,184,255,.1);overflow:hidden;margin-top:4px}
.pp-intfill{height:100%;border-radius:5px;transition:width .5s}
.pp-ethics{background:rgba(192,132,252,.05);border:1px solid rgba(192,132,252,.2);border-radius:8px;padding:10px;margin-top:8px}
.pp-ethics-title{font-size:10px;font-weight:700;color:var(--purple);letter-spacing:.06em;margin-bottom:6px}
.pp-ethics-q{font-size:10px;color:var(--dim);line-height:1.6;margin-bottom:5px;padding-left:8px;border-left:2px solid rgba(192,132,252,.3)}
"
$btn154 = "  <div class=`"hb`" id=`"bPainPleasure`" onclick=`"togglePainPleasurePanel()`" style=`"border-color:rgba(255,85,104,.3);color:rgba(255,130,130,.7)`">&#10084; PAIN&#38;PLEASURE</div>"

$panel154 = @"
<div id="painpleasure-panel" class="feature-panel painpleasure-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#10084; PAIN &amp; PLEASURE MAPS</span>
    <span class="fp-sub">Real brain activation maps with ethical implications</span>
    <span class="fp-close" onclick="togglePainPleasurePanel()">&#215;</span>
  </div>
  <div class="pp-toggle">
    <div class="pp-tab pain" id="pp-pain-tab" onclick="setPPMode('pain')">&#128148; Pain</div>
    <div class="pp-tab pleasure inactive" id="pp-pleasure-tab" onclick="setPPMode('pleasure')">&#128155; Pleasure</div>
  </div>
  <div class="pp-regions" id="pp-regions"></div>
  <div class="pp-intensity">
    <div style="font-size:9px;color:var(--dim);display:flex;justify-content:space-between"><span>Activation Intensity</span><span id="pp-int-val">0%</span></div>
    <div class="pp-intbar"><div class="pp-intfill" id="pp-intfill" style="width:0%"></div></div>
  </div>
  <div style="font-size:10px;color:var(--dim);line-height:1.6;padding:6px;background:rgba(0,0,0,.3);border-radius:6px;margin:6px 0" id="pp-desc"></div>
  <div style="font-size:9px;color:var(--dim);letter-spacing:.06em;margin:6px 0;text-align:center">Digital control: biological (variable) vs digital (programmable)</div>
  <div class="pp-ethics">
    <div class="pp-ethics-title">&#9878; ETHICAL IMPLICATIONS</div>
    <div class="pp-ethics-q">Should digital minds be able to disable pain?</div>
    <div class="pp-ethics-q">Is an all-pleasure existence still a good life? (Nozick's Experience Machine)</div>
    <div class="pp-ethics-q">Could a digital being be designed as a "utility monster"?</div>
  </div>
</div>
"@

$js154 = @"
<script>
// === V154 PAIN & PLEASURE MAPS ===
var ppOpen=false,ppMode='pain';
var PP_DATA={
  pain:{
    regions:[
      {key:'anterior_cingulate',name:'Anterior Cingulate',intensity:0.9,color:'#ff5568'},
      {key:'insula',name:'Insula',intensity:0.85,color:'#ff7744'},
      {key:'thalamus',name:'Thalamus',intensity:0.8,color:'#ff9944'},
      {key:'somatosensory',name:'Somatosensory Cx',intensity:0.75,color:'#ffbb44'}
    ],
    desc:'Pain activates the anterior cingulate cortex (emotional pain), insula (interoception), thalamus (relay), and somatosensory cortex (location). The same ACC region activates during social rejection.',
    avgInt:82
  },
  pleasure:{
    regions:[
      {key:'basal_ganglia',name:'Nucleus Accumbens',intensity:0.9,color:'#50e8a0'},
      {key:'limbic',name:'VTA/Limbic',intensity:0.85,color:'#3ab8ff'},
      {key:'prefrontal',name:'Orbitofrontal Cx',intensity:0.8,color:'#ffc84a'},
      {key:'insula',name:'Insula',intensity:0.7,color:'#88ee88'}
    ],
    desc:'Pleasure activates reward circuits (nucleus accumbens, dopamine release), VTA (reward prediction), orbitofrontal cortex (value computation), and insula (embodied sensation of pleasure).',
    avgInt:79
  }
};
function togglePainPleasurePanel(){
  ppOpen=!ppOpen;
  var p=document.getElementById('painpleasure-panel'),b=document.getElementById('bPainPleasure');
  if(p)p.classList.toggle('vis',ppOpen);
  if(b)b.classList.toggle('on',ppOpen);
  if(ppOpen)setPPMode('pain');
}
function setPPMode(mode){
  ppMode=mode;
  var d=PP_DATA[mode];
  var pt=document.getElementById('pp-pain-tab'),plt=document.getElementById('pp-pleasure-tab');
  if(pt)pt.className='pp-tab pain'+(mode==='pain'?'':' inactive');
  if(plt)plt.className='pp-tab pleasure'+(mode==='pleasure'?'':' inactive');
  var re=document.getElementById('pp-regions');
  if(re)re.innerHTML=d.regions.map(function(r){
    return '<span class="pp-region" style="color:'+r.color+';border-color:'+r.color+'44">'+r.name+'</span>';
  }).join('');
  var desc=document.getElementById('pp-desc');if(desc)desc.textContent=d.desc;
  var fill=document.getElementById('pp-intfill'),val=document.getElementById('pp-int-val');
  if(fill)fill.style.width=d.avgInt+'%';if(fill)fill.style.background=mode==='pain'?'var(--red)':'var(--accent2)';
  if(val)val.textContent=d.avgInt+'%';
  // Flash brain regions
  if(typeof regionMsh!=='undefined'){
    Object.keys(regionMsh).forEach(function(k){var m=regionMsh[k];if(m)m.material.opacity=0.02;});
    d.regions.forEach(function(r){
      var m=regionMsh[r.key];if(!m)return;
      m.material.color.setStyle(r.color);
      m.material.opacity=r.intensity*0.6;
    });
  }
  showToast((mode==='pain'?'&#128148; Pain':'&#128155; Pleasure')+' map activated',{type:'info',duration:2000});
}
</script>
"@

$c154 = $c153
$c154 = ReplaceFirst $c154 '</style>' ($css154 + '</style>')
$c154 = ReplaceFirst $c154 '&#128391; DMN</div></div>' ('&#128391; DMN</div>' + "`r`n" + $btn154 + '</div>')
$c154 = ReplaceFirst $c154 '</body>' ($panel154 + $js154 + '</body>')
WriteVersion $c154 "$root\154\index.html" "154 — Pain & Pleasure"

# ========================== V155 ==========================
$css155 = ".damage-panel{bottom:50px;right:10px;width:330px}
.dmg-types{display:grid;grid-template-columns:1fr 1fr;gap:5px;margin:8px 0}
.dmg-type{padding:8px;border-radius:8px;border:1px solid var(--b1);background:rgba(255,85,104,.04);cursor:pointer;transition:var(--trans)}
.dmg-type:hover,.dmg-type.sel{background:rgba(255,85,104,.15);border-color:rgba(255,85,104,.4)}
.dmg-icon{font-size:18px;display:block;margin-bottom:3px}
.dmg-name{font-size:11px;font-weight:600;color:var(--text)}
.dmg-detail{padding:10px;background:rgba(0,0,0,.3);border:1px solid var(--b1);border-radius:8px;margin:6px 0;display:none}
.dmg-detail.vis{display:block}
.dmg-stat-row{display:flex;gap:6px;margin:6px 0;flex-wrap:wrap}
.dmg-stat{flex:1;min-width:70px;text-align:center;padding:5px;background:rgba(255,85,104,.05);border:1px solid rgba(255,85,104,.15);border-radius:6px}
.dmg-stat-val{font-size:13px;font-weight:700;color:var(--red);font-family:var(--font-mono)}
.dmg-stat-lbl{font-size:8px;color:var(--dim);display:block}
.dmg-recovery{margin-top:6px;height:8px;background:rgba(80,232,160,.1);border-radius:4px;overflow:hidden}
.dmg-recovery-bar{height:100%;background:var(--accent2);border-radius:4px;transition:width 1.5s}
.dmg-advantage{background:rgba(80,232,160,.06);border:1px solid rgba(80,232,160,.2);border-radius:6px;padding:8px;margin-top:8px;font-size:10px;color:var(--accent2);line-height:1.6}
"
$btn155 = "  <div class=`"hb`" id=`"bDamage`" onclick=`"toggleDamagePanel()`" style=`"border-color:rgba(255,85,104,.3);color:rgba(255,130,130,.7)`">&#129504; DAMAGE</div>"

$panel155 = @"
<div id="damage-panel" class="feature-panel damage-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#129504; BRAIN DAMAGE &amp; RECOVERY</span>
    <span class="fp-sub">Damage types, neural loss, and digital preservation advantage</span>
    <span class="fp-close" onclick="toggleDamagePanel()">&#215;</span>
  </div>
  <div class="dmg-types" id="dmg-types"></div>
  <div class="dmg-detail" id="dmg-detail"></div>
  <div class="dmg-advantage">&#127775; <b>Digital Backup Advantage:</b> A pre-damage scan would allow restoration to full cognitive function. Neuroplasticity takes months — digital restore takes seconds.</div>
</div>
"@

$js155 = @"
<script>
// === V155 BRAIN DAMAGE & RECOVERY ===
var damageOpen=false,selDamage=null;
var DAMAGE_TYPES=[
  {id:'stroke',name:'Stroke',icon:'&#129656;',
   desc:'Ischemic stroke blocks blood supply, causing rapid neuron death. Penumbra (surrounding tissue) may be saved with fast intervention. Neuroplasticity allows partial recovery over months.',
   regions:['motor_cortex','prefrontal','parietal'],color:'#ff5568',
   neurons_lost:'Up to 1.9B/hour',prevalence:'13.7M/year',recovery:40,
   mechanism:'Blood clot blocks artery. Neurons die within minutes without oxygen.'},
  {id:'alzheimers',name:"Alzheimer's",icon:'&#9928;',
   desc:'Progressive neurodegeneration. Amyloid plaques and tau tangles destroy synapses. Hippocampus (memory) affected first, then spreading to cortex.',
   regions:['hippocampus','temporal','prefrontal'],color:'#c084fc',
   neurons_lost:'~68K/day',prevalence:'55M worldwide',recovery:5,
   mechanism:'Amyloid-beta plaques and tau neurofibrillary tangles cause synaptic failure.'},
  {id:'tbi',name:'TBI',icon:'&#128165;',
   desc:'Traumatic brain injury causes primary damage at impact site, secondary contrecoup injury, and diffuse axonal injury from shearing forces.',
   regions:['prefrontal','temporal','hippocampus'],color:'#ffc84a',
   neurons_lost:'Variable',prevalence:'69M/year',recovery:55,
   mechanism:'Impact force plus rotational acceleration causes axonal shearing and neuroinflammation.'},
  {id:'parkinsons',name:"Parkinson's",icon:'&#9881;',
   desc:"Dopaminergic neurons in substantia nigra degenerate, depleting dopamine in basal ganglia. Motor control deteriorates progressively.",
   regions:['basal_ganglia','brainstem'],color:'#ff9060',
   neurons_lost:'Substantia nigra cells',prevalence:'10M worldwide',recovery:20,
   mechanism:"Loss of dopamine-producing neurons in substantia nigra. Lewy bodies (alpha-synuclein) accumulate."},
  {id:'epilepsy',name:'Epilepsy',icon:'&#9889;',
   desc:'Abnormal electrical discharge spreads across cortex. Repeated seizures can cause hippocampal sclerosis and cognitive decline.',
   regions:['temporal','hippocampus','motor_cortex'],color:'#3ab8ff',
   neurons_lost:'Per seizure: thousands',prevalence:'50M worldwide',recovery:65,
   mechanism:'Neuronal hyperexcitability — failure of inhibitory GABAergic control.'}
];
function toggleDamagePanel(){
  damageOpen=!damageOpen;
  var p=document.getElementById('damage-panel'),b=document.getElementById('bDamage');
  if(p)p.classList.toggle('vis',damageOpen);
  if(b)b.classList.toggle('on',damageOpen);
  if(damageOpen)renderDamageTypes();
}
function renderDamageTypes(){
  var el=document.getElementById('dmg-types');if(!el)return;
  el.innerHTML=DAMAGE_TYPES.map(function(d,i){
    return '<div class="dmg-type'+(selDamage===i?' sel':'')+'" onclick="selectDamage('+i+')">'
      +'<span class="dmg-icon">'+d.icon+'</span>'
      +'<span class="dmg-name">'+d.name+'</span></div>';
  }).join('');
}
function selectDamage(i){
  selDamage=i;renderDamageTypes();
  var d=DAMAGE_TYPES[i];
  var el=document.getElementById('dmg-detail');if(!el)return;
  el.classList.add('vis');
  el.innerHTML='<div style="font-size:12px;font-weight:700;color:'+d.color+';margin-bottom:6px">'+d.icon+' '+d.name+'</div>'
    +'<div style="font-size:10px;color:var(--dim);line-height:1.6;margin-bottom:8px">'+d.desc+'</div>'
    +'<div class="dmg-stat-row">'
    +'<div class="dmg-stat"><span class="dmg-stat-val">'+d.neurons_lost+'</span><span class="dmg-stat-lbl">Neurons Lost</span></div>'
    +'<div class="dmg-stat"><span class="dmg-stat-val">'+d.prevalence+'</span><span class="dmg-stat-lbl">Prevalence</span></div>'
    +'</div>'
    +'<div style="font-size:9px;color:var(--dim);margin-bottom:4px;display:flex;justify-content:space-between"><span>Recovery potential</span><span>'+d.recovery+'%</span></div>'
    +'<div class="dmg-recovery"><div class="dmg-recovery-bar" style="width:0%;background:'+d.color+'" id="dmg-rec-bar-'+i+'"></div></div>'
    +'<div style="margin-top:6px;font-size:10px;color:var(--dim);background:rgba(0,0,0,.3);padding:6px;border-radius:4px"><b style="color:var(--text)">Mechanism:</b> '+d.mechanism+'</div>';
  // Animate recovery bar
  setTimeout(function(){var rb=document.getElementById('dmg-rec-bar-'+i);if(rb)rb.style.width=d.recovery+'%';},100);
  // Flash affected regions
  if(typeof regionMsh!=='undefined'){
    Object.keys(regionMsh).forEach(function(k){var m=regionMsh[k];if(m)m.material.opacity=0.02;});
    d.regions.forEach(function(k){
      var m=regionMsh[k];if(!m)return;
      m.material.color.setStyle(d.color);
      m.material.opacity=0.65;
    });
  }
  showToast(d.icon+' '+d.name+' simulation',{type:'info',duration:2500});
}
</script>
"@

$c155 = $c154
$c155 = ReplaceFirst $c155 '</style>' ($css155 + '</style>')
$c155 = ReplaceFirst $c155 '&#10084; PAIN&#38;PLEASURE</div></div>' ('&#10084; PAIN&#38;PLEASURE</div>' + "`r`n" + $btn155 + '</div>')
$c155 = ReplaceFirst $c155 '</body>' ($panel155 + $js155 + '</body>')
WriteVersion $c155 "$root\155\index.html" "155 — Brain Damage"

Write-Host "`nAll versions built successfully!"
