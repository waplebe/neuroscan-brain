$utf8NoBom = New-Object System.Text.UTF8Encoding $false

# Read base v120
$content = [System.IO.File]::ReadAllText("c:\Users\bookf\OneDrive\Desktop\brain\120\index.html")

# Helper: insert text before anchor
function insertBefore($str, $anchor, $insert) {
    $idx = $str.IndexOf($anchor)
    if ($idx -lt 0) { Write-Warning "Anchor not found: [$anchor]"; return $str }
    return $str.Substring(0, $idx) + $insert + $str.Substring($idx)
}

# ==============================================================
# V121 — RELATIONSHIP GRAPH
# ==============================================================
$content = $content.Replace('<title>NeuroScan v120 — Skills</title>', '<title>NeuroScan v121 — Relationships</title>')

$v121Css = @'
/* === V121 RELATIONSHIP GRAPH === */
.rel-graph-panel{top:60px;left:260px;width:340px;max-height:80vh;overflow-y:auto;position:fixed}
.rel-input{width:100%;background:rgba(80,232,160,.05);border:1px solid rgba(80,232,160,.2);border-radius:6px;color:var(--text);font-size:12px;padding:6px 9px;outline:none;font-family:var(--font);margin-bottom:6px}
.rel-input:focus{border-color:rgba(80,232,160,.5)}
.rel-select{background:rgba(80,232,160,.05);border:1px solid rgba(80,232,160,.2);border-radius:6px;color:var(--text);font-size:12px;padding:5px 8px;outline:none}
.rel-add-btn{background:rgba(80,232,160,.15);border:1px solid rgba(80,232,160,.4);color:var(--accent2);font-size:12px;font-weight:600;padding:6px 14px;border-radius:6px;cursor:pointer;transition:var(--trans);width:100%;margin-bottom:8px}
.rel-add-btn:hover{background:rgba(80,232,160,.25)}
.rel-person-list{display:flex;flex-direction:column;gap:4px;max-height:160px;overflow-y:auto;margin-bottom:8px}
.rel-person-item{display:flex;align-items:center;gap:8px;padding:6px 10px;background:rgba(80,232,160,.04);border:1px solid rgba(80,232,160,.12);border-radius:6px;position:relative}
.rel-person-name{font-size:12px;color:var(--text);flex:1}
.rel-person-type{font-size:10px;border:1px solid currentColor;border-radius:8px;padding:1px 6px;flex-shrink:0}
.rel-person-close{font-size:10px;color:var(--accent2);font-weight:700;width:18px;text-align:right;flex-shrink:0}
.rel-person-del{position:absolute;top:4px;right:6px;font-size:11px;color:var(--dim);cursor:pointer;opacity:.5;transition:.15s}
.rel-person-del:hover{opacity:1;color:var(--red)}
.rel-score-row{display:flex;justify-content:space-between;font-size:11px;color:var(--dim);padding:6px 0;border-top:1px solid var(--b1)}
.rel-score-val{color:var(--accent2);font-weight:700}
.hb.relgraph{border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)}
.hb.relgraph.on{background:rgba(80,232,160,.18);color:var(--accent2);border-color:rgba(80,232,160,.5)}
'@
$content = insertBefore $content '</style>' $v121Css

$v121Btn = ' <div class="hb relgraph" id="bRelGraph" onclick="toggleRelGraphPanel()">&#128101; RELATIONSHIPS</div>'
$content = $content.Replace('>&#128221; MEMORIES</div></div>', '>&#128221; MEMORIES</div>' + $v121Btn + '</div>')

$v121Panel = @'
    <div id="rel-graph-panel" class="feature-panel rel-graph-panel">
      <div class="fp-header">
        <span class="fp-title">&#128101; RELATIONSHIP GRAPH</span>
        <span class="fp-sub">Map your social connections &#8212; the fabric of your identity</span>
        <span class="fp-close" onclick="toggleRelGraphPanel()">&#215;</span>
      </div>
      <input id="rel-name-input" class="rel-input" type="text" placeholder="Person's name..." maxlength="50">
      <div style="display:flex;gap:6px;margin-bottom:6px">
        <select id="rel-type-sel" class="rel-select">
          <option value="parent">Parent</option>
          <option value="sibling">Sibling</option>
          <option value="partner">&#10084; Partner</option>
          <option value="friend" selected>Friend</option>
          <option value="mentor">Mentor</option>
          <option value="colleague">Colleague</option>
          <option value="other">Other</option>
        </select>
        <div style="display:flex;align-items:center;gap:5px;flex:1;font-size:11px;color:var(--dim)">
          <span>Close:</span>
          <input type="range" id="rel-closeness" min="1" max="5" value="3" style="flex:1;accent-color:var(--accent2)" oninput="document.getElementById('rel-close-val').textContent=this.value">
          <span id="rel-close-val" style="color:var(--accent2);font-weight:700;width:14px">3</span>
        </div>
      </div>
      <input id="rel-desc-input" class="rel-input" type="text" placeholder="One sentence about this relationship..." maxlength="120">
      <button class="rel-add-btn" onclick="addRelation()">+ Add Person</button>
      <div id="rel-person-list" class="rel-person-list"></div>
      <canvas id="rel-graph-cv" width="280" height="200" style="display:block;width:100%;background:rgba(0,0,0,.4);border:1px solid var(--b1);border-radius:8px;margin-bottom:8px"></canvas>
      <div class="rel-score-row">
        <span>Richness Score: <span class="rel-score-val" id="rel-richness-score">0%</span></span>
        <span>Unique Types: <span class="rel-score-val" id="rel-types-count">0</span></span>
      </div>
    </div>
'@
$content = insertBefore $content '    </div>    <div class="fmri-bar"' $v121Panel

$v121Js = @'
// ============================================================
// V121 — RELATIONSHIP GRAPH
// ============================================================
var USER_RELATIONS = JSON.parse(localStorage.getItem('ns_user_relations') || '[]');
var relGraphOpen = false;
var REL_COLORS = {parent:'#3ab8ff',sibling:'#50e8a0',partner:'#ff6eb4',friend:'#ffc84a',mentor:'#c084fc',colleague:'#ff9060',other:'#aabbcc'};
function toggleRelGraphPanel(){
  relGraphOpen = !relGraphOpen;
  var p=document.getElementById('rel-graph-panel'),b=document.getElementById('bRelGraph');
  if(p) p.classList.toggle('vis',relGraphOpen);
  if(b) b.classList.toggle('on',relGraphOpen);
  if(relGraphOpen){renderRelPersonList();drawRelGraph();}
}
function addRelation(){
  var name=(document.getElementById('rel-name-input')||{}).value||'';
  var type=(document.getElementById('rel-type-sel')||{}).value||'friend';
  var closeness=parseInt((document.getElementById('rel-closeness')||{}).value)||3;
  var desc=(document.getElementById('rel-desc-input')||{}).value||'';
  if(!name.trim()) return showToast('Enter a person\'s name',{type:'warning'});
  if(USER_RELATIONS.length>=20) return showToast('Maximum 20 people reached',{type:'warning'});
  USER_RELATIONS.unshift({id:Date.now(),name:name.trim(),type:type,closeness:closeness,desc:desc.trim()});
  localStorage.setItem('ns_user_relations',JSON.stringify(USER_RELATIONS));
  document.getElementById('rel-name-input').value='';
  document.getElementById('rel-desc-input').value='';
  renderRelPersonList();drawRelGraph();
  showToast('Added: '+name.substring(0,25),{type:'success',icon:'\uD83D\uDC65',duration:2000});
}
function deleteRelation(id){
  USER_RELATIONS=USER_RELATIONS.filter(function(r){return r.id!==id;});
  localStorage.setItem('ns_user_relations',JSON.stringify(USER_RELATIONS));
  renderRelPersonList();drawRelGraph();
}
function renderRelPersonList(){
  var list=document.getElementById('rel-person-list'); if(!list) return;
  if(!USER_RELATIONS.length){
    list.innerHTML='<div style="text-align:center;padding:12px;color:var(--dim);font-size:11px">No relationships added yet.</div>';
  } else {
    list.innerHTML=USER_RELATIONS.map(function(r){
      var c=REL_COLORS[r.type]||'#aabbcc';
      return '<div class="rel-person-item">'+
        '<span style="width:8px;height:8px;border-radius:50%;background:'+c+';flex-shrink:0;display:inline-block"></span>'+
        '<span class="rel-person-name">'+escapeHtml(r.name)+'</span>'+
        '<span class="rel-person-type" style="color:'+c+'">'+r.type+'</span>'+
        '<span class="rel-person-close">'+r.closeness+'\u2605</span>'+
        '<span class="rel-person-del" onclick="deleteRelation('+r.id+')">&#215;</span>'+
      '</div>';
    }).join('');
  }
  var maxP=Math.min(USER_RELATIONS.length,20)*5;
  var tot=USER_RELATIONS.reduce(function(a,r){return a+r.closeness;},0);
  var rEl=document.getElementById('rel-richness-score'); if(rEl) rEl.textContent=Math.round(maxP>0?tot/maxP*100:0)+'%';
  var types=new Set(USER_RELATIONS.map(function(r){return r.type;}));
  var tEl=document.getElementById('rel-types-count'); if(tEl) tEl.textContent=types.size;
}
function drawRelGraph(){
  var cv=document.getElementById('rel-graph-cv'); if(!cv) return;
  var ctx=cv.getContext('2d'),W=cv.width,H=cv.height;
  ctx.clearRect(0,0,W,H);
  var cx=W/2,cy=H/2;
  if(!USER_RELATIONS.length){
    ctx.fillStyle='rgba(180,210,255,.3)';ctx.font='10px Inter,sans-serif';ctx.textAlign='center';ctx.textBaseline='middle';
    ctx.fillText('Add people to visualize your social graph',cx,cy);
  }
  // Center YOU node
  var grd=ctx.createRadialGradient(cx,cy,4,cx,cy,20);
  grd.addColorStop(0,'rgba(58,184,255,.5)');grd.addColorStop(1,'rgba(58,184,255,0)');
  ctx.beginPath();ctx.arc(cx,cy,20,0,Math.PI*2);ctx.fillStyle=grd;ctx.fill();
  ctx.strokeStyle='rgba(58,184,255,.9)';ctx.lineWidth=2;ctx.stroke();
  ctx.fillStyle='rgba(200,225,255,.9)';ctx.font='bold 8px Inter,sans-serif';ctx.textAlign='center';ctx.textBaseline='middle';
  ctx.fillText('YOU',cx,cy);
  var n=USER_RELATIONS.length; if(!n) return;
  USER_RELATIONS.forEach(function(r,i){
    var angle=(i/n)*Math.PI*2-Math.PI/2;
    var maxD=Math.min(W,H)*0.42,minD=Math.min(W,H)*0.18;
    var dist=minD+(5-r.closeness)/4*(maxD-minD);
    var nx=cx+Math.cos(angle)*dist,ny=cy+Math.sin(angle)*dist;
    var col=REL_COLORS[r.type]||'#aabbcc';
    ctx.beginPath();ctx.moveTo(cx,cy);ctx.lineTo(nx,ny);
    ctx.globalAlpha=0.25+r.closeness*0.07;ctx.strokeStyle=col;ctx.lineWidth=r.closeness*0.7+0.5;ctx.stroke();ctx.globalAlpha=1;
    var rad=5+r.closeness*1.2;
    ctx.beginPath();ctx.arc(nx,ny,rad,0,Math.PI*2);ctx.fillStyle=col+'22';ctx.fill();
    ctx.strokeStyle=col;ctx.lineWidth=1.5;ctx.stroke();
    ctx.fillStyle=col;ctx.font='8px Inter,sans-serif';ctx.textAlign='center';
    var below=Math.sin(angle)>0;ctx.textBaseline=below?'top':'bottom';
    ctx.fillText(r.name.substring(0,10),nx,ny+(below?rad+2:-(rad+2)));
  });
}
'@
$content = insertBefore $content '</script>' $v121Js

[System.IO.File]::WriteAllText("c:\Users\bookf\OneDrive\Desktop\brain\121\index.html", $content, $utf8NoBom)
Write-Host "V121 written"

# ==============================================================
# V122 — DIGITAL PROFILE CARD
# ==============================================================
$content = $content.Replace('<title>NeuroScan v121 — Relationships</title>', '<title>NeuroScan v122 — Profile Card</title>')

$v122Css = @'
/* === V122 DIGITAL PROFILE CARD === */
.profile-card-panel{top:50%;left:50%;transform:translate(-50%,-50%);width:360px;max-height:85vh;overflow-y:auto;position:fixed}
.mind-card{background:linear-gradient(135deg,rgba(8,15,35,.98),rgba(12,20,50,.98));border:1px solid rgba(58,184,255,.35);border-radius:12px;padding:18px;margin-bottom:12px;position:relative;overflow:hidden}
.mind-card::before{content:'';position:absolute;top:0;left:0;right:0;height:2px;background:linear-gradient(90deg,var(--accent),var(--accent2),var(--purple))}
.mind-card-name{font-size:18px;font-weight:700;color:var(--text);margin-bottom:2px}
.mind-card-id{font-size:10px;color:var(--dim);font-family:var(--font-mono);letter-spacing:.08em;margin-bottom:8px}
.mind-card-section{margin-bottom:10px}
.mind-card-section-title{font-size:9px;letter-spacing:.12em;color:var(--dim);margin-bottom:4px;text-transform:uppercase}
.mind-card-stat{display:flex;justify-content:space-between;align-items:center;padding:3px 0;border-bottom:1px solid rgba(58,184,255,.06)}
.mind-card-stat:last-child{border-bottom:none}
.mind-card-stat-lbl{font-size:11px;color:var(--text)}
.mind-card-stat-val{font-size:12px;font-weight:700;color:var(--accent)}
.mind-completeness{text-align:center;padding:10px 0;border-top:1px solid var(--b1)}
.mind-completeness-val{font-size:32px;font-weight:700;color:var(--accent2);text-shadow:0 0 12px rgba(80,232,160,.4)}
.mind-completeness-lbl{font-size:9px;letter-spacing:.1em;color:var(--dim);margin-top:2px}
.profile-export-btn{background:rgba(58,184,255,.1);border:1px solid var(--b2);color:var(--accent);font-size:11px;font-weight:600;padding:6px 14px;border-radius:6px;cursor:pointer;transition:var(--trans);margin-right:6px}
.profile-export-btn:hover{background:rgba(58,184,255,.2)}
.profile-name-input{width:100%;background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:6px;color:var(--text);font-size:14px;font-weight:700;padding:6px 9px;outline:none;font-family:var(--font);margin-bottom:8px}
.profile-name-input:focus{border-color:var(--b2)}
.hb.profilecard{border-color:rgba(58,184,255,.3);color:rgba(100,180,255,.7)}
.hb.profilecard.on{background:rgba(58,184,255,.2);color:var(--accent);border-color:var(--b2)}
'@
$content = insertBefore $content '</style>' $v122Css

$v122Btn = ' <div class="hb profilecard" id="bProfileCard" onclick="toggleProfileCardPanel()">&#128250; MIND CARD</div>'
$content = $content.Replace('>&#128101; RELATIONSHIPS</div></div>', '>&#128101; RELATIONSHIPS</div>' + $v122Btn + '</div>')

$v122Panel = @'
    <div id="profile-card-panel" class="feature-panel profile-card-panel">
      <div class="fp-header">
        <span class="fp-title">&#128250; DIGITAL PROFILE CARD</span>
        <span class="fp-sub">Your Mind Card &#8212; aggregated identity snapshot</span>
        <span class="fp-close" onclick="toggleProfileCardPanel()">&#215;</span>
      </div>
      <input id="profile-name-input" class="profile-name-input" type="text" placeholder="Your display name..." maxlength="50" oninput="saveUsername(this.value)">
      <div class="mind-card" id="mind-card-view">
        <div style="text-align:center;padding:20px;color:var(--dim);font-size:12px">Loading profile...</div>
      </div>
      <div style="display:flex;gap:6px;margin-top:4px;flex-wrap:wrap">
        <button class="profile-export-btn" onclick="copyProfileJSON()">&#128203; Copy as JSON</button>
        <button class="profile-export-btn" onclick="copyProfileText()">&#128196; Copy Mind Card</button>
      </div>
    </div>
'@
$content = insertBefore $content '    </div>    <div class="fmri-bar"' $v122Panel

$v122Js = @'
// ============================================================
// V122 — DIGITAL PROFILE CARD
// ============================================================
var profileCardOpen = false;
function toggleProfileCardPanel(){
  profileCardOpen=!profileCardOpen;
  var p=document.getElementById('profile-card-panel'),b=document.getElementById('bProfileCard');
  if(p) p.classList.toggle('vis',profileCardOpen);
  if(b) b.classList.toggle('on',profileCardOpen);
  if(profileCardOpen) renderProfileCard();
}
function saveUsername(val){localStorage.setItem('ns_username',val);}
function getMindID(){
  var id=localStorage.getItem('ns_mind_id');
  if(!id){id=Array.from({length:16},function(){return Math.floor(Math.random()*16).toString(16)}).join('');localStorage.setItem('ns_mind_id',id);}
  return id;
}
function getCreationDate(){
  var d=localStorage.getItem('ns_creation_date');
  if(!d){d=new Date().toISOString().split('T')[0];localStorage.setItem('ns_creation_date',d);}
  return d;
}
function getProfileData(){
  var memories=JSON.parse(localStorage.getItem('ns_memories')||'[]');
  var ps=JSON.parse(localStorage.getItem('ns_personality_scores')||'null');
  var voIds=JSON.parse(localStorage.getItem('ns_values_order')||'[]');
  var le=JSON.parse(localStorage.getItem('ns_life_events')||'[]');
  var us=JSON.parse(localStorage.getItem('ns_user_skills')||'[]');
  var ur=JSON.parse(localStorage.getItem('ns_user_relations')||'[]');
  var username=localStorage.getItem('ns_username')||'Anonymous';
  var sects=[memories.length>0?1:0,ps?1:0,voIds.length>0?1:0,le.length>0?1:0,us.length>0?1:0,ur.length>0?1:0];
  var completeness=Math.round(sects.reduce(function(a,b){return a+b;},0)/sects.length*100);
  var traitNames=['Openness','Conscientiousness','Extraversion','Agreeableness','Neuroticism'];
  var dominantTrait='Not assessed';
  if(ps){var best=null,bv=-1;traitNames.forEach(function(t){if(ps[t]!=null&&ps[t]>bv){bv=ps[t];best=t;}});if(best)dominantTrait=best;}
  var cv=typeof CORE_VALUES!=='undefined'?CORE_VALUES:[];
  var top3=voIds.slice(0,3).map(function(id){var v=cv.find(function(c){return c.id===id;});return v?v.label:id;});
  return {username:username,mindId:getMindID(),creationDate:getCreationDate(),memories:memories,ps:ps,voIds:voIds,top3:top3,le:le,us:us,ur:ur,completeness:completeness,dominantTrait:dominantTrait};
}
function renderProfileCard(){
  var ni=document.getElementById('profile-name-input');
  if(ni) ni.value=localStorage.getItem('ns_username')||'';
  var data=getProfileData();
  var cardEl=document.getElementById('mind-card-view'); if(!cardEl) return;
  var idFmt=data.mindId.toUpperCase().match(/.{1,4}/g).join('-');
  cardEl.innerHTML=
    '<div style="display:flex;justify-content:space-between;align-items:flex-start;margin-bottom:14px">'+
      '<div>'+
        '<div class="mind-card-name">'+(data.username||'Anonymous')+'</div>'+
        '<div class="mind-card-id">ID: '+idFmt+'</div>'+
        '<div style="font-size:10px;color:var(--dim)">Since: '+data.creationDate+'</div>'+
      '</div>'+
      '<canvas id="mind-fingerprint-cv" width="72" height="72" style="border-radius:50%;border:1px solid var(--b2);flex-shrink:0"></canvas>'+
    '</div>'+
    '<div class="mind-card-section">'+
      '<div class="mind-card-section-title">PERSONALITY</div>'+
      '<div class="mind-card-stat"><span class="mind-card-stat-lbl">Dominant Trait</span><span class="mind-card-stat-val">'+data.dominantTrait+'</span></div>'+
      '<div class="mind-card-stat"><span class="mind-card-stat-lbl">Top Values</span><span class="mind-card-stat-val" style="font-size:10px;text-align:right;max-width:180px">'+(data.top3.join(', ')||'&#8212;')+'</span></div>'+
    '</div>'+
    '<div class="mind-card-section">'+
      '<div class="mind-card-section-title">MIND ARCHIVE</div>'+
      '<div class="mind-card-stat"><span class="mind-card-stat-lbl">Memories</span><span class="mind-card-stat-val">'+data.memories.length+'</span></div>'+
      '<div class="mind-card-stat"><span class="mind-card-stat-lbl">Life Events</span><span class="mind-card-stat-val">'+data.le.length+'</span></div>'+
      '<div class="mind-card-stat"><span class="mind-card-stat-lbl">Skills</span><span class="mind-card-stat-val">'+data.us.length+'</span></div>'+
      '<div class="mind-card-stat"><span class="mind-card-stat-lbl">Relationships</span><span class="mind-card-stat-val">'+data.ur.length+'</span></div>'+
    '</div>'+
    '<div class="mind-completeness"><div class="mind-completeness-val">'+data.completeness+'%</div><div class="mind-completeness-lbl">PROFILE COMPLETENESS</div></div>';
  setTimeout(function(){var fc=document.getElementById('mind-fingerprint-cv');if(fc)drawMindFingerprint(fc,data);},50);
}
function drawMindFingerprint(canvas,data){
  var ctx=canvas.getContext('2d'),W=canvas.width,H=canvas.height;
  ctx.clearRect(0,0,W,H);ctx.fillStyle='rgba(4,8,20,.9)';ctx.fillRect(0,0,W,H);
  var seed=JSON.stringify(data).split('').reduce(function(a,c){return(a*31+c.charCodeAt(0))|0;},1234567);
  var rng=function(){seed=(seed*1664525+1013904223)|0;return(seed>>>0)/4294967296;};
  ctx.lineWidth=1;
  for(var i=0;i<20;i++){
    ctx.beginPath();ctx.arc(W/2,H/2,rng()*W*0.45+2,rng()*Math.PI*2,rng()*Math.PI*2);
    ctx.globalAlpha=0.3+rng()*0.4;ctx.strokeStyle='rgba(58,184,255,.6)';ctx.stroke();
  }
  ctx.globalAlpha=1;
}
function copyProfileJSON(){
  var data=getProfileData();
  navigator.clipboard.writeText(JSON.stringify(data,null,2)).then(function(){showToast('Profile JSON copied!',{type:'success',icon:'\uD83D\uDCCB',duration:2000});}).catch(function(){showToast('Copy failed',{type:'error'});});
}
function copyProfileText(){
  var data=getProfileData();
  var t='=== NEUROSCAN MIND CARD ===\nName: '+data.username+'\nID: '+data.mindId.toUpperCase().match(/.{1,4}/g).join('-')+
    '\nCreated: '+data.creationDate+'\n\nPERSONALITY:\n  Dominant Trait: '+data.dominantTrait+
    '\n  Top Values: '+data.top3.join(', ')+'\n\nMIND ARCHIVE:\n  Memories: '+data.memories.length+
    '\n  Life Events: '+data.le.length+'\n  Skills: '+data.us.length+
    '\n  Relationships: '+data.ur.length+'\n\nCompleteness: '+data.completeness+'%\n==========================';
  navigator.clipboard.writeText(t).then(function(){showToast('Mind Card text copied!',{type:'success',icon:'\uD83D\uDCC4',duration:2000});}).catch(function(){showToast('Copy failed',{type:'error'});});
}
'@
$content = insertBefore $content '</script>' $v122Js

[System.IO.File]::WriteAllText("c:\Users\bookf\OneDrive\Desktop\brain\122\index.html", $content, $utf8NoBom)
Write-Host "V122 written"

# ==============================================================
# V123 — IDENTITY CONTINUITY SCORE
# ==============================================================
$content = $content.Replace('<title>NeuroScan v122 — Profile Card</title>', '<title>NeuroScan v123 — Identity Score</title>')

$v123Css = @'
/* === V123 IDENTITY CONTINUITY SCORE === */
.identity-score-panel{top:50%;left:50%;transform:translate(-50%,-50%);width:380px;max-height:85vh;overflow-y:auto;position:fixed}
.ids-main-score{text-align:center;padding:16px 0;margin-bottom:12px;background:linear-gradient(135deg,rgba(80,232,160,.04),rgba(58,184,255,.04));border:1px solid var(--b1);border-radius:10px}
.ids-score-num{font-size:54px;font-weight:700;color:var(--accent2);text-shadow:0 0 20px rgba(80,232,160,.5);line-height:1}
.ids-score-pct{font-size:22px;font-weight:700;color:var(--accent2)}
.ids-score-class{font-size:13px;letter-spacing:.1em;color:var(--accent);margin-top:6px;font-weight:600}
.ids-dim-list{display:flex;flex-direction:column;gap:6px;margin-bottom:12px}
.ids-dim-row{padding:7px 10px;background:rgba(58,184,255,.03);border:1px solid var(--b1);border-radius:6px}
.ids-dim-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px}
.ids-dim-name{font-size:11px;color:var(--text);font-weight:600}
.ids-dim-val{font-size:11px;color:var(--accent);font-weight:700}
.ids-dim-bar-bg{height:4px;background:rgba(58,184,255,.1);border-radius:2px;overflow:hidden;margin-bottom:3px}
.ids-dim-bar-fill{height:100%;border-radius:2px;transition:width 1.2s}
.ids-dim-tip{font-size:9px;color:var(--dim);line-height:1.4}
.ids-sparkline{display:block;width:100%;height:42px;background:rgba(0,0,0,.3);border:1px solid rgba(58,184,255,.1);border-radius:4px;margin:8px 0}
.hb.identityscore{border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)}
.hb.identityscore.on{background:rgba(80,232,160,.18);color:var(--accent2);border-color:rgba(80,232,160,.5)}
'@
$content = insertBefore $content '</style>' $v123Css

$v123Btn = ' <div class="hb identityscore" id="bIdentityScore" onclick="toggleIdentityScorePanel()">&#127919; IDENTITY SCORE</div>'
$content = $content.Replace('>&#128250; MIND CARD</div></div>', '>&#128250; MIND CARD</div>' + $v123Btn + '</div>')

$v123Panel = @'
    <div id="identity-score-panel" class="feature-panel identity-score-panel">
      <div class="fp-header">
        <span class="fp-title">&#127919; IDENTITY CONTINUITY SCORE</span>
        <span class="fp-sub">How well would a digital copy preserve you?</span>
        <span class="fp-close" onclick="toggleIdentityScorePanel()">&#215;</span>
      </div>
      <div class="ids-main-score">
        <div><span class="ids-score-num" id="ids-score-num">0</span><span class="ids-score-pct">%</span></div>
        <div class="ids-score-class" id="ids-score-class">Scattered</div>
      </div>
      <canvas class="ids-sparkline" id="ids-sparkline" width="340" height="42"></canvas>
      <div id="ids-dim-list" class="ids-dim-list"></div>
      <div id="ids-tips" style="font-size:11px;color:var(--dim);padding:8px 10px;background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:6px;line-height:1.7"></div>
    </div>
'@
$content = insertBefore $content '    </div>    <div class="fmri-bar"' $v123Panel

$v123Js = @'
// ============================================================
// V123 — IDENTITY CONTINUITY SCORE
// ============================================================
var identityScoreOpen = false;
var IDS_CLASSES = ['Scattered','Emerging','Taking Shape','Well-Defined','Fully Digitizable'];
var IDS_DIM_NAMES = ['Memory Richness','Personality Clarity','Values Definition','Life Narrative','Skills Documented','Relationship Map','Profile Completeness','Engagement Time'];
var IDS_WEIGHTS = [0.18,0.14,0.12,0.14,0.12,0.12,0.10,0.08];
var IDS_COLORS = ['#3ab8ff','#c084fc','#ffc84a','#50e8a0','#ff9060','#50e8a0','#3ab8ff','#aabbcc'];
function toggleIdentityScorePanel(){
  identityScoreOpen=!identityScoreOpen;
  var p=document.getElementById('identity-score-panel'),b=document.getElementById('bIdentityScore');
  if(p) p.classList.toggle('vis',identityScoreOpen);
  if(b) b.classList.toggle('on',identityScoreOpen);
  if(identityScoreOpen) renderIdentityScore();
}
function calcIdentityDimensions(){
  var memories=JSON.parse(localStorage.getItem('ns_memories')||'[]');
  var ps=JSON.parse(localStorage.getItem('ns_personality_scores')||'null');
  var vo=JSON.parse(localStorage.getItem('ns_values_order')||'[]');
  var le=JSON.parse(localStorage.getItem('ns_life_events')||'[]');
  var us=JSON.parse(localStorage.getItem('ns_user_skills')||'[]');
  var ur=JSON.parse(localStorage.getItem('ns_user_relations')||'[]');
  var fv=parseInt(localStorage.getItem('ns_first_visit')||'0');
  if(!fv){fv=Date.now();localStorage.setItem('ns_first_visit',fv);}
  var sects=[memories.length>0?1:0,ps?1:0,vo.length>0?1:0,le.length>0?1:0,us.length>0?1:0,ur.length>0?1:0];
  var comp=sects.reduce(function(a,b){return a+b;},0)/sects.length*100;
  return [
    Math.min(memories.length/50,1)*100,
    ps?100:0,
    vo.length>0?90:0,
    Math.min(le.length/20,1)*100,
    Math.min(us.length/10,1)*100,
    Math.min(ur.length/8,1)*100,
    comp,
    Math.min(Date.now()-fv,7*24*3600000)/(7*24*3600000)*100
  ];
}
function renderIdentityScore(){
  var dims=calcIdentityDimensions();
  var total=Math.round(dims.reduce(function(acc,d,i){return acc+d*IDS_WEIGHTS[i];},0));
  var cidx=Math.min(Math.floor(total/20),4);
  var ne=document.getElementById('ids-score-num'),ce=document.getElementById('ids-score-class');
  if(ne) ne.textContent=total; if(ce) ce.textContent=IDS_CLASSES[cidx];
  var hist=JSON.parse(localStorage.getItem('ns_score_history')||'[]');
  var today=new Date().toISOString().split('T')[0];
  if(!hist.length||hist[hist.length-1].date!==today){
    hist.push({date:today,score:total});
    if(hist.length>30) hist.shift();
    localStorage.setItem('ns_score_history',JSON.stringify(hist));
  }
  drawScoreSparkline(hist);
  var memories=JSON.parse(localStorage.getItem('ns_memories')||'[]');
  var le=JSON.parse(localStorage.getItem('ns_life_events')||'[]');
  var us=JSON.parse(localStorage.getItem('ns_user_skills')||'[]');
  var ur=JSON.parse(localStorage.getItem('ns_user_relations')||'[]');
  var ps=JSON.parse(localStorage.getItem('ns_personality_scores')||'null');
  var vo=JSON.parse(localStorage.getItem('ns_values_order')||'[]');
  var tips=[
    memories.length<50?'Add '+(50-memories.length)+' more memories':'',
    !ps?'Complete the Personality Map (OCEAN test)':'',
    !vo.length?'Define your Values Compass':'',
    le.length<20?'Add '+(20-le.length)+' more life events':'',
    us.length<10?'Add '+(10-us.length)+' more skills':'',
    ur.length<8?'Add '+(8-ur.length)+' more relationships':'',
    '','Continue using NeuroScan regularly'
  ];
  var de=document.getElementById('ids-dim-list');
  if(de) de.innerHTML=dims.map(function(d,i){
    return '<div class="ids-dim-row">'+
      '<div class="ids-dim-head"><span class="ids-dim-name">'+IDS_DIM_NAMES[i]+'</span><span class="ids-dim-val">'+Math.round(d)+'%</span></div>'+
      '<div class="ids-dim-bar-bg"><div class="ids-dim-bar-fill" style="width:'+Math.round(d)+'%;background:'+IDS_COLORS[i]+'"></div></div>'+
      (tips[i]?'<div class="ids-dim-tip">\uD83D\uDCA1 '+tips[i]+'</div>':'')+
    '</div>';
  }).join('');
  var te=document.getElementById('ids-tips');
  if(te){
    var tl=[];
    if(memories.length<10) tl.push('\uD83D\uDCDD Write at least 10 memories');
    if(!ps) tl.push('\uD83C\uDFAD Complete the Personality Map');
    if(!vo.length) tl.push('\uD83E\uDDED Define your Values Compass');
    if(!tl.length) tl.push('\u2705 Great progress! Keep building your digital mind');
    te.innerHTML='<div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:4px">IMPROVEMENT TIPS</div>'+tl.map(function(t){return '<div>'+t+'</div>';}).join('');
  }
}
function drawScoreSparkline(history){
  var cv=document.getElementById('ids-sparkline'); if(!cv) return;
  var ctx=cv.getContext('2d'),W=cv.width,H=cv.height;
  ctx.clearRect(0,0,W,H);
  if(history.length<2){
    ctx.fillStyle='rgba(180,210,255,.25)';ctx.font='9px Inter,sans-serif';ctx.textAlign='center';ctx.textBaseline='middle';
    ctx.fillText('Score history appears after multiple sessions',W/2,H/2);return;
  }
  var pad=8,scores=history.map(function(h){return h.score;}),maxS=Math.max.apply(null,scores.concat([100]));
  ctx.strokeStyle='rgba(80,232,160,.7)';ctx.lineWidth=2;ctx.beginPath();
  scores.forEach(function(s,i){
    var x=pad+i/(scores.length-1)*(W-pad*2),y=H-pad-(s/maxS)*(H-pad*2);
    if(i===0) ctx.moveTo(x,y); else ctx.lineTo(x,y);
  });
  ctx.stroke();
  scores.forEach(function(s,i){
    var x=pad+i/(scores.length-1)*(W-pad*2),y=H-pad-(s/maxS)*(H-pad*2);
    ctx.beginPath();ctx.arc(x,y,2.5,0,Math.PI*2);ctx.fillStyle='rgba(80,232,160,.9)';ctx.fill();
  });
}
'@
$content = insertBefore $content '</script>' $v123Js

[System.IO.File]::WriteAllText("c:\Users\bookf\OneDrive\Desktop\brain\123\index.html", $content, $utf8NoBom)
Write-Host "V123 written"

# ==============================================================
# V124 — MEMORY COMPRESSION VISUALIZER
# ==============================================================
$content = $content.Replace('<title>NeuroScan v123 — Identity Score</title>', '<title>NeuroScan v124 — Memory Compression</title>')

$v124Css = @'
/* === V124 MEMORY COMPRESSION VISUALIZER === */
.mem-compress-panel{top:60px;left:260px;width:380px;max-height:85vh;overflow-y:auto;position:fixed}
.mc-stage-tabs{display:flex;gap:4px;margin-bottom:12px}
.mc-stage-tab{flex:1;padding:6px;font-size:10px;font-weight:600;letter-spacing:.06em;border:1px solid var(--b1);border-radius:6px;cursor:pointer;color:var(--dim);transition:var(--trans);text-align:center;user-select:none}
.mc-stage-tab:hover{background:rgba(58,184,255,.08);color:var(--text)}
.mc-stage-tab.on{background:rgba(58,184,255,.18);color:var(--accent);border-color:var(--b2)}
.mc-stats{display:flex;gap:8px;margin-bottom:10px}
.mc-stat{flex:1;text-align:center;padding:7px;background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:6px}
.mc-stat-val{font-size:13px;font-weight:700;color:var(--accent);display:block;margin-bottom:2px}
.mc-stat-lbl{font-size:8px;color:var(--dim);letter-spacing:.06em}
.mc-encode-select{background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:6px;color:var(--text);font-size:11px;padding:5px 8px;outline:none;margin-bottom:8px;width:100%}
.mc-encode-btn{background:rgba(58,184,255,.15);border:1px solid var(--b2);color:var(--accent);font-size:11px;font-weight:600;padding:6px 14px;border-radius:6px;cursor:pointer;transition:var(--trans);width:100%}
.mc-encode-btn:hover{background:rgba(58,184,255,.25)}
.hb.memcompress{border-color:rgba(58,184,255,.3);color:rgba(100,180,255,.7)}
.hb.memcompress.on{background:rgba(58,184,255,.2);color:var(--accent);border-color:var(--b2)}
'@
$content = insertBefore $content '</style>' $v124Css

$v124Btn = ' <div class="hb memcompress" id="bMemCompress" onclick="toggleMemCompressPanel()">&#129514; MEM COMPRESS</div>'
$content = $content.Replace('>&#127919; IDENTITY SCORE</div></div>', '>&#127919; IDENTITY SCORE</div>' + $v124Btn + '</div>')

$v124Panel = @'
    <div id="mem-compress-panel" class="feature-panel mem-compress-panel">
      <div class="fp-header">
        <span class="fp-title">&#129514; MEMORY COMPRESSION</span>
        <span class="fp-sub">How the brain encodes, consolidates &amp; recalls</span>
        <span class="fp-close" onclick="toggleMemCompressPanel()">&#215;</span>
      </div>
      <div class="mc-stage-tabs">
        <div class="mc-stage-tab on" id="mc-tab-0" onclick="setMCPhase(0)">&#9312; ENCODE</div>
        <div class="mc-stage-tab" id="mc-tab-1" onclick="setMCPhase(1)">&#9313; CONSOLIDATE</div>
        <div class="mc-stage-tab" id="mc-tab-2" onclick="setMCPhase(2)">&#9314; RECALL</div>
      </div>
      <canvas id="mem-compress-cv" width="360" height="180" style="display:block;width:100%;background:rgba(0,0,0,.5);border:1px solid var(--b1);border-radius:8px;margin-bottom:10px"></canvas>
      <div class="mc-stats">
        <div class="mc-stat"><span class="mc-stat-val">2.5 PB</span><span class="mc-stat-lbl">HUMAN CAPACITY</span></div>
        <div class="mc-stat"><span class="mc-stat-val">~0.1%</span><span class="mc-stat-lbl">RECALL RATE</span></div>
        <div class="mc-stat"><span class="mc-stat-val" id="mc-user-count">0</span><span class="mc-stat-lbl">YOUR MEMORIES</span></div>
      </div>
      <div style="font-size:11px;color:rgba(80,232,160,.8);padding:6px 0 8px;border-top:1px solid var(--b1)">&#9889; Digital advantage: perfect recall, zero compression loss</div>
      <select id="mc-memory-sel" class="mc-encode-select"><option value="">&#8212; Select a memory to encode &#8212;</option></select>
      <button class="mc-encode-btn" onclick="encodeSelectedMemory()">&#9654; Encode through all 3 stages</button>
    </div>
'@
$content = insertBefore $content '    </div>    <div class="fmri-bar"' $v124Panel

$v124Js = @'
// ============================================================
// V124 — MEMORY COMPRESSION VISUALIZER
// ============================================================
var memCompressOpen = false;
var memCompressPhase = 0;
var mcAnimFrame = null;
var mcParticles = [];
var mcTime = 0;
var mcLastTS = 0;
function toggleMemCompressPanel(){
  memCompressOpen=!memCompressOpen;
  var p=document.getElementById('mem-compress-panel'),b=document.getElementById('bMemCompress');
  if(p) p.classList.toggle('vis',memCompressOpen);
  if(b) b.classList.toggle('on',memCompressOpen);
  if(memCompressOpen){initMCParticles();populateMCMemorySelect();if(!mcAnimFrame) mcAnimFrame=requestAnimationFrame(runMCAnimation);}
  else{if(mcAnimFrame){cancelAnimationFrame(mcAnimFrame);mcAnimFrame=null;}}
}
function setMCPhase(ph){
  memCompressPhase=ph;
  for(var i=0;i<3;i++){var t=document.getElementById('mc-tab-'+i);if(t)t.classList.toggle('on',i===ph);}
  initMCParticles();
}
function initMCParticles(){
  mcParticles=[];mcTime=0;
  var cv=document.getElementById('mem-compress-cv'); if(!cv) return;
  var W=cv.width,H=cv.height;
  var cols=['#3ab8ff','#50e8a0','#ffc84a','#ff6eb4','#c084fc'];
  if(memCompressPhase===0){
    for(var s=0;s<5;s++){
      var sx=s/4*W*0.85+W*0.075;
      for(var p=0;p<10;p++) mcParticles.push({x:sx+(Math.random()-0.5)*14,y:8+Math.random()*20,tx:W/2,ty:H/2,color:cols[s],spd:0.35+Math.random()*0.5,ph:Math.random()});
    }
  } else if(memCompressPhase===1){
    for(var q=0;q<50;q++){
      var a=Math.random()*Math.PI*2,d=16+Math.random()*Math.min(W,H)*0.44;
      mcParticles.push({x:W/2,y:H/2,tx:W/2+Math.cos(a)*d,ty:H/2+Math.sin(a)*d,color:'hsl('+(Math.floor(Math.random()*360))+',65%,60%)',spd:0.2+Math.random()*0.35,ph:Math.random(),fade:true});
    }
  } else {
    for(var r=0;r<35;r++){
      var miss=Math.random()>0.65;
      mcParticles.push({x:Math.random()*W,y:H-8,tx:W/2+(Math.random()-0.5)*90,ty:H/2+(Math.random()-0.5)*50,color:miss?'rgba(255,85,104,.55)':'rgba(80,232,160,.75)',spd:0.3+Math.random()*0.4,ph:Math.random()});
    }
  }
}
function runMCAnimation(ts){
  var cv=document.getElementById('mem-compress-cv');
  if(!cv||!memCompressOpen){mcAnimFrame=null;return;}
  var dt=ts-mcLastTS; if(dt>100) dt=16; mcLastTS=ts;
  mcTime+=dt*0.001;
  var ctx=cv.getContext('2d'),W=cv.width,H=cv.height;
  ctx.clearRect(0,0,W,H);
  ctx.fillStyle='rgba(2,5,15,.96)';ctx.fillRect(0,0,W,H);
  var phLabels=['ENCODING: Sensory inputs \u2192 Hippocampus','CONSOLIDATION: Memory spreading through Neocortex','RECALL: Partial reconstruction (~65% fidelity)'];
  ctx.fillStyle='rgba(180,210,255,.5)';ctx.font='8px Inter,sans-serif';ctx.textAlign='center';ctx.textBaseline='top';
  ctx.fillText(phLabels[memCompressPhase],W/2,6);
  if(memCompressPhase===0){
    var g=ctx.createRadialGradient(W/2,H/2,4,W/2,H/2,28);
    g.addColorStop(0,'rgba(58,184,255,.55)');g.addColorStop(1,'rgba(58,184,255,0)');
    ctx.beginPath();ctx.arc(W/2,H/2,28,0,Math.PI*2);ctx.fillStyle=g;ctx.fill();
    ctx.fillStyle='rgba(200,225,255,.85)';ctx.font='bold 7px Inter,sans-serif';ctx.textBaseline='middle';
    ctx.fillText('HIPPO-',W/2,H/2-5);ctx.fillText('CAMPUS',W/2,H/2+5);
  } else if(memCompressPhase===1){
    ctx.strokeStyle='rgba(200,130,255,.18)';ctx.lineWidth=1;ctx.strokeRect(18,22,W-36,H-30);
    ctx.beginPath();ctx.arc(W/2,H/2,7,0,Math.PI*2);ctx.fillStyle='rgba(200,130,255,.5)';ctx.fill();
  } else {
    ctx.fillStyle='rgba(255,85,104,.45)';ctx.font='8px Inter,sans-serif';ctx.textBaseline='bottom';
    ctx.fillText('RED = missing/distorted fragments',W/2,H-4);
  }
  mcParticles.forEach(function(p){
    var t=(mcTime*p.spd+p.ph)%1;
    var px=p.x+(p.tx-p.x)*t,py=p.y+(p.ty-p.y)*t;
    var alpha=p.fade?(1-t):(t<0.5?t*2:2-t*2);
    ctx.beginPath();ctx.arc(px,py,2.2,0,Math.PI*2);
    ctx.fillStyle=p.color;ctx.globalAlpha=Math.max(0,alpha*0.9);ctx.fill();ctx.globalAlpha=1;
  });
  var ce=document.getElementById('mc-user-count');
  if(ce){var m=JSON.parse(localStorage.getItem('ns_memories')||'[]');ce.textContent=m.length;}
  mcAnimFrame=requestAnimationFrame(runMCAnimation);
}
function populateMCMemorySelect(){
  var sel=document.getElementById('mc-memory-sel'); if(!sel) return;
  var memories=JSON.parse(localStorage.getItem('ns_memories')||'[]');
  if(!memories.length){sel.innerHTML='<option value="">No memories yet \u2014 add some in Memory Journal</option>';return;}
  sel.innerHTML='<option value="">\u2014 Select a memory \u2014</option>'+
    memories.slice(0,20).map(function(m){return '<option value="'+m.id+'">'+escapeHtml((m.title||'Memory').substring(0,50))+'</option>';}).join('');
}
function encodeSelectedMemory(){
  var sel=document.getElementById('mc-memory-sel'); if(!sel||!sel.value) return;
  var memories=JSON.parse(localStorage.getItem('ns_memories')||'[]');
  var mem=memories.find(function(m){return String(m.id)===String(sel.value);});
  if(!mem) return;
  showToast('Encoding: "'+mem.title.substring(0,30)+'"',{type:'info',icon:'\uD83E\uDDEC',duration:1500});
  var ph=0;
  function next(){setMCPhase(ph);ph++;if(ph<3)setTimeout(next,2200);else showToast('All 3 stages complete!',{type:'success',icon:'\uD83E\uDDEC',duration:2500});}
  next();
}
'@
$content = insertBefore $content '</script>' $v124Js

[System.IO.File]::WriteAllText("c:\Users\bookf\OneDrive\Desktop\brain\124\index.html", $content, $utf8NoBom)
Write-Host "V124 written"

# ==============================================================
# V125 — LEGACY LETTER V2
# ==============================================================
$content = $content.Replace('<title>NeuroScan v124 — Memory Compression</title>', '<title>NeuroScan v125 — Legacy Letter</title>')

$v125Css = @'
/* === V125 LEGACY LETTER V2 === */
.legacy-letter-panel{top:60px;right:10px;width:400px;max-height:80vh;overflow-y:auto;position:fixed}
.ll-mood-row{display:flex;gap:5px;flex-wrap:wrap;margin-bottom:10px}
.ll-mood-btn{font-size:18px;cursor:pointer;padding:4px 8px;border:1px solid transparent;border-radius:6px;transition:var(--trans);user-select:none}
.ll-mood-btn:hover{background:rgba(255,200,74,.1)}
.ll-mood-btn.sel{background:rgba(255,200,74,.18);border-color:rgba(255,200,74,.4)}
.ll-prompt-box{background:rgba(255,200,74,.04);border:1px solid rgba(255,200,74,.2);border-radius:6px;padding:8px 12px;margin-bottom:10px;font-size:11px;color:rgba(255,220,150,.85);line-height:1.6;cursor:pointer;transition:var(--trans)}
.ll-prompt-box:hover{background:rgba(255,200,74,.09);border-color:rgba(255,200,74,.45)}
.ll-input{width:100%;background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:6px;color:var(--text);font-size:12px;padding:6px 9px;outline:none;font-family:var(--font);margin-bottom:6px}
.ll-input:focus{border-color:var(--b2)}
.ll-textarea{width:100%;background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:6px;color:var(--text);font-size:12px;padding:7px 10px;outline:none;resize:vertical;font-family:var(--font);margin-bottom:6px;min-height:110px}
.ll-textarea:focus{border-color:var(--b2)}
.ll-meta-row{display:flex;justify-content:space-between;font-size:10px;color:var(--dim);margin-bottom:8px}
.ll-seal-btn{background:linear-gradient(135deg,rgba(255,200,74,.2),rgba(255,160,40,.2));border:1px solid rgba(255,200,74,.4);color:var(--gold);font-size:12px;font-weight:700;padding:8px 18px;border-radius:8px;cursor:pointer;transition:var(--trans);width:100%;margin-bottom:8px;letter-spacing:.06em}
.ll-seal-btn:hover{background:linear-gradient(135deg,rgba(255,200,74,.32),rgba(255,160,40,.32));box-shadow:0 0 12px rgba(255,200,74,.3)}
.ll-archived{display:flex;flex-direction:column;gap:5px;max-height:170px;overflow-y:auto}
.ll-archived-item{padding:8px 10px;background:rgba(255,200,74,.04);border:1px solid rgba(255,200,74,.18);border-radius:6px;cursor:pointer;transition:var(--trans)}
.ll-archived-item:hover{background:rgba(255,200,74,.09)}
.ll-archived-date{font-size:10px;color:var(--dim);margin-bottom:2px}
.ll-archived-subject{font-size:12px;font-weight:600;color:var(--text)}
.ll-sealed-badge{display:inline-block;font-size:8px;padding:1px 7px;background:rgba(255,200,74,.15);border:1px solid rgba(255,200,74,.3);color:var(--gold);border-radius:8px;margin-left:6px;vertical-align:middle}
@keyframes goldSparkle{0%{opacity:0;transform:scale(0) translateY(0)}30%{opacity:1;transform:scale(1.4) translateY(-10px)}100%{opacity:0;transform:scale(0.8) translateY(-32px)}}
.hb.legacyletter{border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)}
.hb.legacyletter.on{background:rgba(255,200,74,.18);color:var(--gold);border-color:rgba(255,200,74,.5)}
'@
$content = insertBefore $content '</style>' $v125Css

$v125Btn = ' <div class="hb legacyletter" id="bLegacyLetter" onclick="toggleLegacyLetterPanel()">&#9993; LEGACY LETTER</div>'
$content = $content.Replace('>&#129514; MEM COMPRESS</div></div>', '>&#129514; MEM COMPRESS</div>' + $v125Btn + '</div>')

$v125Panel = @'
    <div id="legacy-letter-panel" class="feature-panel legacy-letter-panel">
      <div class="fp-header">
        <span class="fp-title">&#9993; LEGACY LETTER</span>
        <span class="fp-sub">Write to your future digital self &#8212; sealed &amp; preserved</span>
        <span class="fp-close" onclick="toggleLegacyLetterPanel()">&#215;</span>
      </div>
      <div id="ll-compose-form">
        <div style="display:flex;gap:6px;margin-bottom:6px">
          <input id="ll-recipient-input" class="ll-input" type="text" value="My Digital Self" placeholder="Recipient..." style="flex:1;margin-bottom:0">
          <input id="ll-date-input" class="ll-input" type="text" placeholder="Date..." style="width:110px;margin-bottom:0">
        </div>
        <div style="height:6px"></div>
        <div class="ll-mood-row" id="ll-mood-row">
          <span class="ll-mood-btn sel" data-mood="content" onclick="selectLLMood(this)">&#128524;</span>
          <span class="ll-mood-btn" data-mood="hopeful" onclick="selectLLMood(this)">&#127775;</span>
          <span class="ll-mood-btn" data-mood="nostalgic" onclick="selectLLMood(this)">&#127749;</span>
          <span class="ll-mood-btn" data-mood="anxious" onclick="selectLLMood(this)">&#128560;</span>
          <span class="ll-mood-btn" data-mood="grateful" onclick="selectLLMood(this)">&#128591;</span>
          <span class="ll-mood-btn" data-mood="determined" onclick="selectLLMood(this)">&#128170;</span>
          <span class="ll-mood-btn" data-mood="philosophical" onclick="selectLLMood(this)">&#129300;</span>
        </div>
        <input id="ll-subject-input" class="ll-input" type="text" placeholder="Subject line..." maxlength="100">
        <div class="ll-prompt-box" id="ll-prompt-box" onclick="nextLLPrompt()" title="Click for a new prompt">&#128161; Click for writing inspiration...</div>
        <textarea id="ll-body-textarea" class="ll-textarea" placeholder="Write your letter here..." rows="7" oninput="updateLLWordCount()"></textarea>
        <div class="ll-meta-row">
          <span id="ll-wordcount">0 words</span>
          <span id="ll-readtime">0 min read</span>
        </div>
        <button class="ll-seal-btn" onclick="sealLetter()">&#128274; Seal &amp; Archive Letter</button>
      </div>
      <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin:4px 0 6px;padding-top:8px;border-top:1px solid var(--b1)">ARCHIVED LETTERS</div>
      <div id="ll-archived-list" class="ll-archived"></div>
    </div>
'@
$content = insertBefore $content '    </div>    <div class="fmri-bar"' $v125Panel

$v125Js = @'
// ============================================================
// V125 — LEGACY LETTER V2
// ============================================================
var legacyLetterOpen = false;
var llSelectedMood = 'content';
var llPromptIdx = 0;
var LL_PROMPTS = [
  '\uD83D\uDCAD What do you most fear losing in digital translation?',
  '\uD83C\uDF1F What accomplishment are you most proud of right now?',
  '\uD83D\uDD2E What advice would you give your digital self?',
  '\uD83D\uDC9D What relationships define who you are most deeply?',
  '\uD83C\uDFAF What is your most important unfulfilled goal?',
  '\uD83C\uDF3F What brings you the most peace and contentment?',
  '\u26A1 What experience changed you most profoundly?',
  '\uD83E\uDD8B What would you want your digital self to never forget?'
];
var LL_MOOD_EMOJI = {content:'\uD83D\uDE0C',hopeful:'\uD83C\uDF1F',nostalgic:'\uD83C\uDF05',anxious:'\uD83D\uDE30',grateful:'\uD83D\uDE4F',determined:'\uD83D\uDCAA',philosophical:'\uD83E\uDD14'};
function toggleLegacyLetterPanel(){
  legacyLetterOpen=!legacyLetterOpen;
  var p=document.getElementById('legacy-letter-panel'),b=document.getElementById('bLegacyLetter');
  if(p) p.classList.toggle('vis',legacyLetterOpen);
  if(b) b.classList.toggle('on',legacyLetterOpen);
  if(legacyLetterOpen) initLegacyLetterPanel();
}
function initLegacyLetterPanel(){
  var di=document.getElementById('ll-date-input');
  if(di&&!di.value) di.value=new Date().toLocaleDateString('en-US',{year:'numeric',month:'long',day:'numeric'});
  var pb=document.getElementById('ll-prompt-box');
  if(pb) pb.textContent=LL_PROMPTS[llPromptIdx];
  renderArchivedLetters();
}
function nextLLPrompt(){
  llPromptIdx=(llPromptIdx+1)%LL_PROMPTS.length;
  var pb=document.getElementById('ll-prompt-box');
  if(pb) pb.textContent=LL_PROMPTS[llPromptIdx];
}
function selectLLMood(el){
  llSelectedMood=el.getAttribute('data-mood');
  document.querySelectorAll('.ll-mood-btn').forEach(function(b){b.classList.remove('sel');});
  el.classList.add('sel');
}
function updateLLWordCount(){
  var ta=document.getElementById('ll-body-textarea'); if(!ta) return;
  var words=ta.value.trim().split(/\s+/).filter(function(w){return w.length>0;});
  var wc=words.length,rm=Math.max(1,Math.round(wc/200));
  var we=document.getElementById('ll-wordcount'),re=document.getElementById('ll-readtime');
  if(we) we.textContent=wc+' word'+(wc!==1?'s':'');
  if(re) re.textContent=rm+' min read';
}
function sealLetter(){
  var recipient=(document.getElementById('ll-recipient-input')||{}).value||'My Digital Self';
  var subject=(document.getElementById('ll-subject-input')||{}).value||'Letter to my future self';
  var body=(document.getElementById('ll-body-textarea')||{}).value||'';
  var dateStr=(document.getElementById('ll-date-input')||{}).value||new Date().toLocaleDateString();
  if(!body.trim()) return showToast('Write something before sealing!',{type:'warning'});
  var words=body.trim().split(/\s+/).filter(function(w){return w.length>0;}).length;
  var letter={id:Date.now(),recipient:recipient.trim(),subject:subject.trim(),body:body.trim(),mood:llSelectedMood,date:dateStr,sealedAt:new Date().toISOString(),words:words};
  var letters=JSON.parse(localStorage.getItem('ns_legacy_letters')||'[]');
  letters.unshift(letter);
  localStorage.setItem('ns_legacy_letters',JSON.stringify(letters));
  var bta=document.getElementById('ll-body-textarea'); if(bta) bta.value='';
  var sia=document.getElementById('ll-subject-input'); if(sia) sia.value='';
  updateLLWordCount();
  renderArchivedLetters();
  showGoldSparkleEffect();
  downloadSealedLetter(letter);
  showToast('Letter sealed and archived!',{type:'success',icon:'\uD83D\uDD12',duration:3000});
}
function showGoldSparkleEffect(){
  var p=document.getElementById('legacy-letter-panel'); if(!p) return;
  var wrap=document.createElement('div');
  wrap.style.cssText='position:absolute;top:0;left:0;width:100%;height:100%;pointer-events:none;z-index:9999;overflow:hidden;border-radius:12px';
  var cols=['#ffc84a','#ffaa00','#ffee88','#ffffff','#ffdd66'];
  for(var i=0;i<22;i++){
    var s=document.createElement('div');
    s.style.cssText='position:absolute;left:'+(Math.random()*100)+'%;top:'+(Math.random()*100)+'%;width:7px;height:7px;background:'+cols[Math.floor(Math.random()*cols.length)]+';border-radius:50%;animation:goldSparkle 1.6s ease-out forwards;animation-delay:'+(Math.random()*0.5)+'s;opacity:0';
    wrap.appendChild(s);
  }
  p.appendChild(wrap);
  setTimeout(function(){if(wrap.parentNode)wrap.parentNode.removeChild(wrap);},2500);
}
function downloadSealedLetter(letter){
  var me=LL_MOOD_EMOJI[letter.mood]||'\uD83D\uDCE7';
  var html='<!DOCTYPE html><html><head><meta charset="UTF-8"><title>Legacy Letter</title>'+
    '<style>body{font-family:Georgia,serif;background:#06091a;color:#c8d8f0;max-width:660px;margin:60px auto;padding:0 24px;line-height:1.75}'+
    'h1{color:#ffc84a;font-size:22px;margin-bottom:6px}'+
    '.meta{font-size:13px;color:#6a7e94;margin-bottom:32px;letter-spacing:.04em}'+
    '.body{font-size:16px;white-space:pre-wrap;color:#d8e8f8;border-left:3px solid rgba(255,200,74,.3);padding-left:20px}'+
    '.footer{margin-top:40px;padding-top:16px;border-top:1px solid rgba(255,200,74,.2);font-size:11px;color:#4a5e72;text-align:center}'+
    '</style></head><body>'+
    '<h1>'+me+' '+escapeHtml(letter.subject)+'</h1>'+
    '<div class="meta">To: '+escapeHtml(letter.recipient)+' &nbsp;|&nbsp; Written: '+escapeHtml(letter.date)+' &nbsp;|&nbsp; '+letter.words+' words</div>'+
    '<div class="body">'+escapeHtml(letter.body)+'</div>'+
    '<div class="footer">Sealed via NeuroScan Digital Immortality &bull; '+new Date(letter.sealedAt).toLocaleString()+'<br>This letter is a fragment of a human mind preserved in time.</div>'+
    '</body></html>';
  var blob=new Blob([html],{type:'text/html'});
  var url=URL.createObjectURL(blob);
  var a=document.createElement('a');a.href=url;a.download='legacy-letter-'+letter.id+'.html';a.click();
  URL.revokeObjectURL(url);
}
function renderArchivedLetters(){
  var list=document.getElementById('ll-archived-list'); if(!list) return;
  var letters=JSON.parse(localStorage.getItem('ns_legacy_letters')||'[]');
  if(!letters.length){list.innerHTML='<div style="text-align:center;padding:14px;color:var(--dim);font-size:11px">No sealed letters yet.</div>';return;}
  list.innerHTML=letters.map(function(l,i){
    var me=LL_MOOD_EMOJI[l.mood]||'\uD83D\uDCE7';
    return '<div class="ll-archived-item" onclick="redownloadLetter('+i+')">'+
      '<div class="ll-archived-date">'+me+' '+escapeHtml(l.date)+' &bull; '+l.words+' words<span class="ll-sealed-badge">SEALED</span></div>'+
      '<div class="ll-archived-subject">'+escapeHtml(l.subject)+'</div>'+
    '</div>';
  }).join('');
}
function redownloadLetter(idx){
  var letters=JSON.parse(localStorage.getItem('ns_legacy_letters')||'[]');
  if(letters[idx]) downloadSealedLetter(letters[idx]);
}
'@
$content = insertBefore $content '</script>' $v125Js

[System.IO.File]::WriteAllText("c:\Users\bookf\OneDrive\Desktop\brain\125\index.html", $content, $utf8NoBom)
Write-Host "V125 written"
Write-Host "ALL DONE"
