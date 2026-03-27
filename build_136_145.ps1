# Build NeuroScan v136-v145
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$base = "c:\Users\bookf\OneDrive\Desktop\brain"

function WriteVersion($content, $ver) {
  $outDir = "$base\$ver"
  if (!(Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
  $outPath = "$outDir\index.html"
  [System.IO.File]::WriteAllText($outPath, $content, $utf8NoBom)
  $bytes = [System.IO.File]::ReadAllBytes($outPath)
  $size = (Get-Item $outPath).Length
  Write-Host "v$ver -> $outPath | size=$size | first_byte=$($bytes[0]) (must be 60)"
}

function ApplyVersion($content, $title, $cssNew, $htmlNew, $featMarker, $featReplacement, $jsNew) {
  $content = $content -replace '<title>NeuroScan v\d+ [^<]+</title>', "<title>$title</title>"
  $cssTarget = '</style>'
  $idx = $content.IndexOf($cssTarget)
  $content = $content.Substring(0,$idx) + $cssNew + "`n" + $content.Substring($idx)
  $htmlTarget = '</div><div class="panel-overlay" id="panel-overlay"></div>'
  $idx2 = $content.IndexOf($htmlTarget)
  $content = $content.Substring(0,$idx2) + "`n" + $htmlNew + "`n" + $content.Substring($idx2)
  $content = $content.Replace($featMarker, $featReplacement)
  $bodyClose = '</body>'
  $idx3 = $content.LastIndexOf($bodyClose)
  $content = $content.Substring(0,$idx3) + "<script>`n" + $jsNew + "`n</script>`n" + $content.Substring($idx3)
  return $content
}

$content = [System.IO.File]::ReadAllText("$base\135\index.html", $utf8NoBom)
# ============================================================
# V136 - PERSONAL ACTION PLAN
# ============================================================
$css136 = @"
.action-plan-panel{top:60px;right:320px;width:400px;max-height:80vh;overflow-y:auto}
.action-filter-row{display:flex;gap:4px;margin-bottom:10px;flex-wrap:wrap}
.action-filter{padding:3px 10px;font-size:10px;border:1px solid var(--b1);border-radius:12px;cursor:pointer;color:var(--dim);transition:var(--trans)}
.action-filter:hover,.action-filter.on{background:rgba(80,232,160,.1);color:var(--accent2);border-color:rgba(80,232,160,.3)}
.action-progress{margin-bottom:12px;padding:8px;background:rgba(80,232,160,.04);border:1px solid rgba(80,232,160,.15);border-radius:6px}
.action-list{display:flex;flex-direction:column;gap:8px}
.action-item{background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:8px;padding:10px;display:flex;gap:10px;align-items:flex-start;transition:background .15s}
.action-item.done{background:rgba(80,232,160,.05);border-color:rgba(80,232,160,.2)}
.action-check{width:18px;height:18px;border:2px solid var(--b2);border-radius:4px;cursor:pointer;flex-shrink:0;margin-top:1px;display:flex;align-items:center;justify-content:center;transition:all .15s}
.action-check.checked{background:var(--accent2);border-color:var(--accent2);color:#000}
.action-body{flex:1}
.action-title{font-size:12px;font-weight:600;color:var(--text);margin-bottom:2px}
.action-item.done .action-title{text-decoration:line-through;color:var(--dim)}
.action-desc{font-size:11px;color:var(--dim);line-height:1.5;margin-bottom:4px}
.action-meta{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
.action-cat{font-size:9px;padding:1px 6px;border-radius:8px;border:1px solid var(--b1);color:var(--dim)}
.action-timeframe{font-size:9px;color:var(--accent);font-weight:600}
.impact-dots{display:flex;gap:2px}
.impact-dot{width:6px;height:6px;border-radius:50%;background:var(--b2)}
.impact-dot.filled{background:var(--gold)}
"@

$html136 = @"
<div id="action-plan-panel" class="feature-panel action-plan-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#127919; PERSONAL ACTION PLAN</span>
    <span class="fp-sub">What you can do right now toward digital immortality</span>
    <span class="fp-close" onclick="toggleActionPlanPanel()">&#215;</span>
  </div>
  <div class="action-filter-row">
    <span class="action-filter on" onclick="filterActions('all')">All</span>
    <span class="action-filter" onclick="filterActions('Today')">Today</span>
    <span class="action-filter" onclick="filterActions('This Week')">This Week</span>
    <span class="action-filter" onclick="filterActions('This Month')">This Month</span>
  </div>
  <div class="action-progress">
    <span id="action-done-count" style="font-size:13px;font-weight:700;color:var(--accent2)">0</span>
    <span style="font-size:11px;color:var(--dim)"> / 15 actions completed</span>
    <div style="height:4px;background:rgba(80,232,160,.1);border-radius:2px;margin-top:5px;overflow:hidden">
      <div id="action-progress-bar" style="height:100%;background:var(--accent2);border-radius:2px;transition:width .5s;width:0%"></div>
    </div>
  </div>
  <div id="action-list" class="action-list"></div>
</div>
"@

$featMarker136 = '&#9993; LEGACY LETTER</div></div>'
$featRepl136 = '&#9993; LEGACY LETTER</div>
  <div class="feat-sep"></div>
  <span class="feat-cat">ACTION</span>
  <div class="hb" id="bActionPlan" onclick="toggleActionPlanPanel()" style="border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)">&#127919; ACTION PLAN</div></div>'

$js136 = @"
// === V136 PERSONAL ACTION PLAN ===
var ACTION_ITEMS = [
  {id:'cryo_research',title:'Research Cryonics Options',category:'Preservation',difficulty:1,impact:5,timeframe:'This Week',description:'Spend 30 minutes reading about Alcor and Cryonics Institute. Understand the process and costs.'},
  {id:'cryo_signup',title:'Sign up for Cryonics',category:'Preservation',difficulty:3,impact:5,timeframe:'This Month',description:'Sign up for cryonics membership. Alcor costs \$80K (neuro) or use CI for \$28K whole body.'},
  {id:'digital_journal',title:'Start a Digital Memory Journal',category:'Digital Self',difficulty:1,impact:4,timeframe:'Today',description:'Open the Memory Journal and add 5 significant memories. Foundation of your digital self.'},
  {id:'personality_test',title:'Complete the Personality Assessment',category:'Digital Self',difficulty:1,impact:4,timeframe:'Today',description:'Take the Big Five personality test. Takes 5 minutes. Establishes your psychological baseline.'},
  {id:'values_rank',title:'Rank Your Core Values',category:'Digital Self',difficulty:1,impact:3,timeframe:'Today',description:'Drag to rank your core values. Defines what your digital self must preserve.'},
  {id:'digital_will',title:'Write a Digital Will',category:'Legal',difficulty:2,impact:5,timeframe:'This Month',description:'Document your digital assets, passwords (in a password manager), and wishes for your digital legacy.'},
  {id:'donate_research',title:'Donate to WBE Research',category:'Advocacy',difficulty:1,impact:3,timeframe:'This Week',description:'Donate to Carboncopies Foundation (\$20/month) - the leading nonprofit for whole brain emulation research.'},
  {id:'brain_health',title:'Start a Brain Health Protocol',category:'Health',difficulty:2,impact:4,timeframe:'This Month',description:'Sleep 8 hours, exercise 30min/day, eat omega-3 rich foods. Preserves the brain you want to upload.'},
  {id:'life_story',title:'Record Your Life Story',category:'Digital Self',difficulty:2,impact:4,timeframe:'This Week',description:'Add 10+ life events to your Life Story Timeline. Your narrative is part of who you are.'},
  {id:'share_mission',title:'Share NeuroScan with Someone',category:'Advocacy',difficulty:1,impact:2,timeframe:'Today',description:'Share this project with one person who might be interested in digital immortality research.'},
  {id:'emergency_card',title:'Carry a Cryonics Emergency Card',category:'Preservation',difficulty:1,impact:5,timeframe:'After signup',description:'Cryonics organizations provide medical alert cards. Carry one to ensure proper procedures if incapacitated.'},
  {id:'learn_neuro',title:'Learn Basic Neuroscience',category:'Education',difficulty:2,impact:3,timeframe:'This Year',description:'Take a free online course: Neuroscience Fundamentals on Coursera. Understanding your brain matters.'},
  {id:'cognitive_baseline',title:'Record Your Cognitive Baseline',category:'Health',difficulty:1,impact:3,timeframe:'This Week',description:'Take the Cognitive Baseline Test (v141). Track your brain health over time.'},
  {id:'legacy_letter',title:'Write a Letter to Your Digital Self',category:'Digital Self',difficulty:2,impact:3,timeframe:'This Week',description:'Open the Legacy Letter feature and write a letter to your future digital self.'},
  {id:'setup_backup',title:'Set Up Digital Backup System',category:'Digital Self',difficulty:2,impact:4,timeframe:'This Month',description:'Create regular backups of all your digital data. Photos, writings, emails - your digital history.'}
];
var actionPlanOpen=false,actionFilter='all';
var actionDone=JSON.parse(localStorage.getItem('ns_action_done')||'[]');
function toggleActionPlanPanel(){
  actionPlanOpen=!actionPlanOpen;
  var p=document.getElementById('action-plan-panel'),b=document.getElementById('bActionPlan');
  if(p)p.classList.toggle('vis',actionPlanOpen);
  if(b)b.classList.toggle('on',actionPlanOpen);
  if(actionPlanOpen)renderActionPlan();
}
function filterActions(f){
  actionFilter=f;
  document.querySelectorAll('.action-filter').forEach(function(el){
    el.classList.toggle('on',el.textContent.trim()===f||(f==='all'&&el.textContent.trim()==='All'));
  });
  renderActionPlan();
}
function toggleAction(id){
  var idx=actionDone.indexOf(id);
  if(idx>=0)actionDone.splice(idx,1);else actionDone.push(id);
  localStorage.setItem('ns_action_done',JSON.stringify(actionDone));
  renderActionPlan();
  if(actionDone.indexOf(id)>=0)showToast('Action completed!',{type:'success',icon:'&#10003;',duration:2000});
}
function renderActionPlan(){
  var items=ACTION_ITEMS.filter(function(a){return actionFilter==='all'||a.timeframe===actionFilter;});
  var doneAll=ACTION_ITEMS.filter(function(a){return actionDone.indexOf(a.id)>=0;}).length;
  var dc=document.getElementById('action-done-count'),pb=document.getElementById('action-progress-bar');
  if(dc)dc.textContent=doneAll;
  if(pb)pb.style.width=Math.round(doneAll/ACTION_ITEMS.length*100)+'%';
  var list=document.getElementById('action-list');if(!list)return;
  list.innerHTML=items.map(function(a){
    var isDone=actionDone.indexOf(a.id)>=0;
    var dots='';for(var i=1;i<=5;i++)dots+='<div class="impact-dot'+(i<=a.impact?' filled':'')+'"></div>';
    return '<div class="action-item'+(isDone?' done':'')+'">'
      +'<div class="action-check'+(isDone?' checked':'')+'" onclick="toggleAction(\''+a.id+'\')">'+(isDone?'&#10003;':'')+'</div>'
      +'<div class="action-body"><div class="action-title">'+a.title+'</div>'
      +'<div class="action-desc">'+a.description+'</div>'
      +'<div class="action-meta"><span class="action-cat">'+a.category+'</span>'
      +'<span class="action-timeframe">'+a.timeframe+'</span>'
      +'<span style="font-size:9px;color:var(--dim)">Impact:</span><div class="impact-dots">'+dots+'</div>'
      +'</div></div></div>';
  }).join('');
}
"@

$content = ApplyVersion $content 'NeuroScan v136 - Action Plan' $css136 $html136 $featMarker136 $featRepl136 $js136
WriteVersion $content 136
# ============================================================
# V137 - BRAIN HEALTH PROTOCOL
# ============================================================
$css137 = @"
.brain-health-panel{top:60px;right:740px;width:420px;max-height:80vh;overflow-y:auto}
.bh-score-bar{background:rgba(80,232,160,.04);border:1px solid rgba(80,232,160,.15);border-radius:8px;padding:10px;margin-bottom:10px}
.bh-score-label{font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:5px;text-transform:uppercase}
.bh-score-display{display:flex;align-items:baseline;gap:2px;margin-bottom:5px}
#bh-score-num{font-size:28px;font-weight:700;color:var(--accent2);line-height:1}
.bh-score-max{font-size:12px;color:var(--dim)}
.bh-score-track{height:6px;background:rgba(80,232,160,.1);border-radius:3px;overflow:hidden}
.bh-score-fill{height:100%;background:linear-gradient(90deg,var(--accent2),#88ffcc);border-radius:3px;transition:width .5s}
.bh-filter-row{display:flex;gap:4px;flex-wrap:wrap;margin-bottom:10px}
.bh-filter{padding:3px 8px;font-size:9px;border:1px solid var(--b1);border-radius:10px;cursor:pointer;color:var(--dim);transition:var(--trans)}
.bh-filter.on,.bh-filter:hover{background:rgba(80,232,160,.1);color:var(--accent2);border-color:rgba(80,232,160,.3)}
.bh-habits-list{display:flex;flex-direction:column;gap:6px}
.bh-habit{background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:8px;padding:10px;display:flex;gap:10px;align-items:flex-start;transition:background .15s;cursor:pointer}
.bh-habit.done{background:rgba(80,232,160,.06);border-color:rgba(80,232,160,.25)}
.bh-hcheck{width:20px;height:20px;border:2px solid var(--b2);border-radius:50%;flex-shrink:0;margin-top:1px;display:flex;align-items:center;justify-content:center;font-size:11px;transition:all .15s}
.bh-habit.done .bh-hcheck{background:var(--accent2);border-color:var(--accent2);color:#000}
.bh-hicon{font-size:18px;flex-shrink:0;margin-top:1px;width:24px;text-align:center}
.bh-body{flex:1}
.bh-htitle{font-size:12px;font-weight:600;color:var(--text);margin-bottom:2px}
.bh-habit.done .bh-htitle{text-decoration:line-through;color:var(--dim)}
.bh-hdesc{font-size:10px;color:var(--dim);line-height:1.5;margin-bottom:4px}
.bh-hmeta{display:flex;gap:8px;align-items:center;flex-wrap:wrap}
.bh-hcat{font-size:9px;padding:1px 6px;border-radius:8px;border:1px solid var(--b1);color:var(--dim)}
.bh-hregion{font-size:9px;color:var(--accent);font-weight:600}
.bh-hstreak{font-size:9px;color:var(--gold);font-weight:600}
"@

$html137 = @"
<div id="brain-health-panel" class="feature-panel brain-health-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#129504; BRAIN HEALTH PROTOCOL</span>
    <span class="fp-sub">Evidence-based daily habits for neural optimization</span>
    <span class="fp-close" onclick="toggleBrainHealthPanel()">&#215;</span>
  </div>
  <div class="bh-score-bar">
    <div class="bh-score-label">Today's Brain Health Score</div>
    <div class="bh-score-display"><span id="bh-score-num">0</span><span class="bh-score-max">/100</span></div>
    <div class="bh-score-track"><div id="bh-score-fill" class="bh-score-fill" style="width:0%"></div></div>
  </div>
  <div class="bh-filter-row">
    <span class="bh-filter on" onclick="filterBrainHabits('all')">All</span>
    <span class="bh-filter" onclick="filterBrainHabits('Sleep')">Sleep</span>
    <span class="bh-filter" onclick="filterBrainHabits('Exercise')">Exercise</span>
    <span class="bh-filter" onclick="filterBrainHabits('Nutrition')">Nutrition</span>
    <span class="bh-filter" onclick="filterBrainHabits('Cognitive')">Cognitive</span>
    <span class="bh-filter" onclick="filterBrainHabits('Social')">Social</span>
    <span class="bh-filter" onclick="filterBrainHabits('Stress')">Stress</span>
  </div>
  <div id="bh-habits-list" class="bh-habits-list"></div>
</div>
"@

$featMarker137 = '&#127919; ACTION PLAN</div></div>'
$featRepl137 = '&#127919; ACTION PLAN</div>
  <div class="hb" id="bBrainHealth" onclick="toggleBrainHealthPanel()" style="border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)">&#129504; BRAIN HEALTH</div></div>'

$js137 = @"
// === V137 BRAIN HEALTH PROTOCOL ===
var BRAIN_HABITS=[
  {id:'sleep8',title:'Sleep 8 Hours',category:'Sleep',icon:'&#128564;',desc:'Sleep consolidates memories and removes metabolic waste (glymphatic system). Most critical for neural health.',region:'hippocampus'},
  {id:'exercise30',title:'30 Min Aerobic Exercise',category:'Exercise',icon:'&#127939;',desc:'Exercise increases BDNF, promotes neurogenesis in hippocampus. Best evidence for cognitive enhancement.',region:'hippocampus'},
  {id:'omega3',title:'Omega-3 Rich Meal',category:'Nutrition',icon:'&#128031;',desc:'DHA is essential for synaptic membranes. 2g/day fish oil reduces neuroinflammation.',region:'prefrontal'},
  {id:'meditation',title:'10 Min Meditation',category:'Stress',icon:'&#129488;',desc:'Meditation thickens prefrontal cortex, reduces amygdala reactivity. 8 weeks shows measurable brain changes.',region:'prefrontal'},
  {id:'novel_learning',title:'Learn Something New',category:'Cognitive',icon:'&#128218;',desc:'Novel learning triggers neuroplasticity. Challenges create new synaptic connections.',region:'cerebellum'},
  {id:'social',title:'Meaningful Social Connection',category:'Social',icon:'&#128101;',desc:'Social interaction activates multiple brain networks. Loneliness is as harmful as smoking.',region:'insula'},
  {id:'no_alcohol',title:'No Alcohol Today',category:'Nutrition',icon:'&#128683;',desc:'Alcohol damages white matter and hippocampal neurons. Even moderate use accelerates brain aging.',region:'hippocampus'},
  {id:'hydration',title:'2L Water',category:'Nutrition',icon:'&#128167;',desc:'Even mild dehydration impairs concentration and short-term memory.',region:'prefrontal'},
  {id:'sunlight',title:'Morning Sunlight',category:'Sleep',icon:'&#9728;',desc:'Morning light sets circadian rhythm, improving sleep quality and cognitive performance.',region:'hypothalamus'},
  {id:'cold_shower',title:'Cold Exposure',category:'Exercise',icon:'&#128703;',desc:'Cold exposure increases norepinephrine by 300%, improving mood, focus, and attention.',region:'locus coeruleus'},
  {id:'no_phones',title:'1 Hour Phone-Free',category:'Cognitive',icon:'&#128245;',desc:'Constant interruptions fragment attention and reduce cognitive capacity.',region:'prefrontal'},
  {id:'gratitude',title:'Gratitude Practice',category:'Stress',icon:'&#10024;',desc:'Gratitude activates reward circuits, reduces cortisol, and promotes positive neuroplasticity.',region:'ant. cingulate'}
];
var brainHealthOpen=false,bhHabitFilter='all';
var bhToday=new Date().toDateString();
var bhDoneKey='ns_bh_done_'+btoa(bhToday).substring(0,8);
var bhDone=JSON.parse(localStorage.getItem(bhDoneKey)||'[]');
var bhStreaks=JSON.parse(localStorage.getItem('ns_bh_streaks')||'{}');
function toggleBrainHealthPanel(){
  brainHealthOpen=!brainHealthOpen;
  var p=document.getElementById('brain-health-panel'),b=document.getElementById('bBrainHealth');
  if(p)p.classList.toggle('vis',brainHealthOpen);
  if(b)b.classList.toggle('on',brainHealthOpen);
  if(brainHealthOpen)renderBrainHabits();
}
function filterBrainHabits(f){
  bhHabitFilter=f;
  document.querySelectorAll('.bh-filter').forEach(function(el){
    el.classList.toggle('on',el.textContent.trim()===f||(f==='all'&&el.textContent.trim()==='All'));
  });
  renderBrainHabits();
}
function toggleBHabit(id){
  var idx=bhDone.indexOf(id);
  if(idx>=0)bhDone.splice(idx,1);
  else{bhDone.push(id);bhStreaks[id]=(bhStreaks[id]||0)+1;localStorage.setItem('ns_bh_streaks',JSON.stringify(bhStreaks));showToast('Habit logged!',{type:'success',icon:'&#10003;',duration:2000});}
  localStorage.setItem(bhDoneKey,JSON.stringify(bhDone));renderBrainHabits();
}
function renderBrainHabits(){
  var score=Math.round(bhDone.length/BRAIN_HABITS.length*100);
  var sn=document.getElementById('bh-score-num'),sf=document.getElementById('bh-score-fill');
  if(sn)sn.textContent=score;if(sf)sf.style.width=score+'%';
  var items=BRAIN_HABITS.filter(function(h){return bhHabitFilter==='all'||h.category===bhHabitFilter;});
  var list=document.getElementById('bh-habits-list');if(!list)return;
  list.innerHTML=items.map(function(h){
    var isDone=bhDone.indexOf(h.id)>=0;
    var streak=bhStreaks[h.id]||0;
    return '<div class="bh-habit'+(isDone?' done':'')+'" onclick="toggleBHabit(\''+h.id+'\')">'
      +'<div class="bh-hcheck">'+(isDone?'&#10003;':'')+'</div>'
      +'<div class="bh-hicon">'+h.icon+'</div>'
      +'<div class="bh-body"><div class="bh-htitle">'+h.title+'</div>'
      +'<div class="bh-hdesc">'+h.desc+'</div>'
      +'<div class="bh-hmeta"><span class="bh-hcat">'+h.category+'</span><span class="bh-hregion">'+h.region+'</span>'
      +(streak>0?'<span class="bh-hstreak">&#128293; '+streak+' day streak</span>':'')
      +'</div></div></div>';
  }).join('');
}
"@

$content = ApplyVersion $content 'NeuroScan v137 - Brain Health' $css137 $html137 $featMarker137 $featRepl137 $js137
WriteVersion $content 137
# ============================================================
# V138 - DIGITAL ASSET INVENTORY
# ============================================================
$css138 = @"
.digital-assets-panel{top:60px;right:320px;width:460px;max-height:82vh;overflow-y:auto}
.da-completeness{background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:8px;padding:10px;margin-bottom:12px}
.da-complete-label{font-size:9px;letter-spacing:.1em;color:var(--dim);text-transform:uppercase;margin-bottom:4px}
.da-complete-bar{height:6px;background:rgba(58,184,255,.1);border-radius:3px;overflow:hidden;margin:6px 0}
.da-complete-fill{height:100%;background:linear-gradient(90deg,var(--accent),#88ddff);border-radius:3px;transition:width .5s}
.da-tabs{display:flex;gap:4px;margin-bottom:10px;overflow-x:auto;scrollbar-width:none}
.da-tab{padding:4px 10px;font-size:10px;border:1px solid var(--b1);border-radius:12px;cursor:pointer;color:var(--dim);transition:var(--trans);white-space:nowrap;flex-shrink:0}
.da-tab.on,.da-tab:hover{background:rgba(58,184,255,.1);color:var(--accent);border-color:var(--b2)}
.da-category{display:none}
.da-category.on{display:block}
.da-cat-title{font-size:12px;font-weight:700;color:var(--accent);margin-bottom:4px}
.da-cat-desc{font-size:10px;color:var(--dim);line-height:1.5;margin-bottom:8px}
.da-checklist{display:flex;flex-direction:column;gap:5px;margin-bottom:10px}
.da-check-item{display:flex;align-items:center;gap:8px;padding:6px 8px;background:rgba(58,184,255,.03);border:1px solid var(--b1);border-radius:6px;cursor:pointer;transition:background .15s}
.da-check-item.checked{background:rgba(58,184,255,.08);border-color:var(--b2)}
.da-check-box{width:14px;height:14px;border:2px solid var(--b2);border-radius:3px;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-size:9px;transition:all .15s}
.da-check-item.checked .da-check-box{background:var(--accent);border-color:var(--accent);color:#000}
.da-check-text{font-size:11px;color:var(--text);flex:1}
.da-check-item.checked .da-check-text{text-decoration:line-through;color:var(--dim)}
.da-export-btn{width:100%;padding:8px;background:rgba(80,232,160,.08);border:1px solid rgba(80,232,160,.3);border-radius:6px;color:var(--accent2);font-size:11px;font-weight:600;cursor:pointer;letter-spacing:.05em;transition:var(--trans);text-align:center;margin-top:6px}
.da-export-btn:hover{background:rgba(80,232,160,.16)}
"@

$html138 = @"
<div id="digital-assets-panel" class="feature-panel digital-assets-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128230; DIGITAL ASSET INVENTORY</span>
    <span class="fp-sub">Organize your digital estate for posthumous access</span>
    <span class="fp-close" onclick="toggleDigitalAssetsPanel()">&#215;</span>
  </div>
  <div class="da-completeness">
    <div class="da-complete-label">Estate Completeness: <span id="da-pct" style="color:var(--accent);font-weight:700">0%</span></div>
    <div class="da-complete-bar"><div id="da-complete-fill" class="da-complete-fill" style="width:0%"></div></div>
    <div style="font-size:9px;color:var(--dim)"><span id="da-done-cnt">0</span> / <span id="da-total-cnt">40</span> tasks completed</div>
  </div>
  <div class="da-tabs" id="da-tabs"></div>
  <div id="da-categories"></div>
  <div class="da-export-btn" onclick="exportDigitalEstatePlan()">&#128190; Export Digital Estate Plan (.txt)</div>
</div>
"@

$featMarker138 = '&#129504; BRAIN HEALTH</div></div>'
$featRepl138 = '&#129504; BRAIN HEALTH</div>
  <div class="hb" id="bDigitalAssets" onclick="toggleDigitalAssetsPanel()" style="border-color:rgba(58,184,255,.3);color:rgba(100,180,255,.7)">&#128230; ASSETS</div></div>'

$js138 = @"
// === V138 DIGITAL ASSET INVENTORY ===
var DA_CATEGORIES=[
  {id:'identity',title:'Identity Documents',icon:'&#128100;',desc:'Secure digital copies of government ID, passport, birth certificate. Use encrypted cloud storage.',tools:['Bitwarden','1Password','Tresorit'],items:['Scan govt ID to encrypted PDF','Photograph passport (all pages)','Store birth certificate scan','Backup SS/NI number securely','Store medical records digitally']},
  {id:'passwords',title:'Passwords and Access',icon:'&#128273;',desc:'Use a password manager. Document how your executor can access it posthumously.',tools:['Bitwarden (free)','1Password','KeePass'],items:['Set up password manager','Export and encrypt password backup','Document posthumous access method','Designate digital executor','Store recovery codes safely']},
  {id:'photos',title:'Photos and Videos',icon:'&#128247;',desc:'Back up photos to 3 locations (local HDD, cloud, optical disc). Tag photos with names, dates, locations.',tools:['Google Photos','iCloud','Amazon Photos','Backblaze'],items:['Backup all photos to cloud','Create local HDD backup','Tag important photos with metadata','Export videos from social media','Archive family photos from relatives']},
  {id:'creative',title:'Creative Works',icon:'&#127912;',desc:'Writings, code, music, art. License your works clearly. Store master files with license info.',tools:['GitHub','Creative Commons','Notion'],items:['Archive all writings to cloud','Back up code repositories','Document copyright status','Set up Creative Commons licenses','Create index of all creative works']},
  {id:'financial',title:'Financial Accounts',icon:'&#128176;',desc:'Bank accounts, investments, crypto. Ensure beneficiary designations are up to date.',tools:['Mint','Personal Capital','Coinbase'],items:['List all bank accounts','Document investment accounts','Secure crypto wallet keys','Update beneficiary designations','Document recurring subscriptions']},
  {id:'social',title:'Social Media',icon:'&#128241;',desc:'Facebook legacy contact, Twitter archive, Instagram data download.',tools:['Facebook Legacy','Google Inactive Account'],items:['Set Facebook legacy contact','Download Twitter/X archive','Enable Google inactive account manager','Export Instagram data','Download LinkedIn connections']},
  {id:'comms',title:'Communications',icon:'&#128140;',desc:'Valuable emails, messages. Archive important correspondence.',tools:['Gmail Takeout','Thunderbird','MailStore'],items:['Archive important email threads','Back up old messages (SMS/iMessage)','Export chat histories','Save important voicemails','Document email accounts and access']},
  {id:'professional',title:'Professional Legacy',icon:'&#128188;',desc:'LinkedIn, portfolio, publications. Ensure your professional contributions are accessible.',tools:['LinkedIn','ORCID','Academia.edu'],items:['Export LinkedIn profile','Back up portfolio/website','List all publications','Document professional achievements','Create professional bio document']}
];
var daOpen=false,daChecked=JSON.parse(localStorage.getItem('ns_da_checked')||'[]'),daActiveTab=0;
function toggleDigitalAssetsPanel(){
  daOpen=!daOpen;
  var p=document.getElementById('digital-assets-panel'),b=document.getElementById('bDigitalAssets');
  if(p)p.classList.toggle('vis',daOpen);if(b)b.classList.toggle('on',daOpen);
  if(daOpen)renderDAPanel();
}
function renderDAPanel(){
  var tabs=document.getElementById('da-tabs'),cats=document.getElementById('da-categories');
  if(!tabs||!cats)return;
  tabs.innerHTML=DA_CATEGORIES.map(function(c,i){return '<span class="da-tab'+(i===daActiveTab?' on':'')+'" onclick="switchDATab('+i+')">'+c.icon+' '+c.title+'</span>';}).join('');
  cats.innerHTML=DA_CATEGORIES.map(function(c,i){
    return '<div class="da-category'+(i===daActiveTab?' on':'')+'">'
      +'<div class="da-cat-title">'+c.icon+' '+c.title+'</div>'
      +'<div class="da-cat-desc">'+c.desc+'</div>'
      +'<div style="font-size:9px;color:var(--purple);margin-bottom:8px">&#128736; Tools: '+c.tools.join(' &bull; ')+'</div>'
      +'<div class="da-checklist">'
      +c.items.map(function(item,j){var key=c.id+'_'+j;var isDone=daChecked.indexOf(key)>=0;
        return '<div class="da-check-item'+(isDone?' checked':'')+'" onclick="toggleDACheck(\''+key+'\')">'
          +'<div class="da-check-box">'+(isDone?'&#10003;':'')+'</div>'
          +'<span class="da-check-text">'+item+'</span></div>';
      }).join('')+'</div></div>';
  }).join('');
  updateDACompleteness();
}
function switchDATab(i){
  daActiveTab=i;
  document.querySelectorAll('.da-tab').forEach(function(t,idx){t.classList.toggle('on',idx===i);});
  document.querySelectorAll('.da-category').forEach(function(c,idx){c.classList.toggle('on',idx===i);});
}
function toggleDACheck(key){
  var idx=daChecked.indexOf(key);
  if(idx>=0)daChecked.splice(idx,1);else daChecked.push(key);
  localStorage.setItem('ns_da_checked',JSON.stringify(daChecked));
  renderDAPanel();
}
function updateDACompleteness(){
  var total=DA_CATEGORIES.reduce(function(s,c){return s+c.items.length;},0);
  var done=daChecked.length,pct=total>0?Math.round(done/total*100):0;
  var pEl=document.getElementById('da-pct'),fEl=document.getElementById('da-complete-fill');
  var dEl=document.getElementById('da-done-cnt'),tEl=document.getElementById('da-total-cnt');
  if(pEl)pEl.textContent=pct+'%';if(fEl)fEl.style.width=pct+'%';
  if(dEl)dEl.textContent=done;if(tEl)tEl.textContent=total;
}
function exportDigitalEstatePlan(){
  var lines=['DIGITAL ESTATE PLAN','Generated: '+new Date().toLocaleDateString(),'==========================================',''];
  DA_CATEGORIES.forEach(function(c){
    lines.push('== '+c.title.toUpperCase()+' ==');lines.push(c.desc);lines.push('');lines.push('Tasks:');
    c.items.forEach(function(item,j){var key=c.id+'_'+j;lines.push('  '+(daChecked.indexOf(key)>=0?'[X]':'[ ]')+' '+item);});
    lines.push('');
  });
  var blob=new Blob([lines.join('\n')],{type:'text/plain'});
  var a=document.createElement('a');a.href=URL.createObjectURL(blob);a.download='digital_estate_plan.txt';a.click();
  showToast('Estate plan exported!',{type:'success',icon:'&#128190;',duration:2000});
}
"@

$content = ApplyVersion $content 'NeuroScan v138 - Digital Assets' $css138 $html138 $featMarker138 $featRepl138 $js138
WriteVersion $content 138
# ============================================================
# V139 - MIND BACKUP FREQUENCY
# ============================================================
$css139 = @"
.mind-backup-panel{top:60px;right:760px;width:400px;max-height:82vh;overflow-y:auto}
.mb-status-card{background:rgba(80,232,160,.04);border:1px solid rgba(80,232,160,.2);border-radius:8px;padding:12px;margin-bottom:12px}
.mb-last-backup{font-size:11px;color:var(--dim);margin-bottom:4px}
.mb-last-date{font-size:14px;font-weight:700;color:var(--accent2)}
.mb-streak-row{display:flex;gap:16px;margin-top:8px}
.mb-streak-item{text-align:center}
.mb-streak-num{font-size:20px;font-weight:700;color:var(--gold)}
.mb-streak-label{font-size:9px;color:var(--dim);letter-spacing:.05em}
.mb-tasks{display:flex;flex-direction:column;gap:6px;margin-bottom:12px}
.mb-task{display:flex;align-items:center;gap:10px;padding:8px 10px;background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:8px;cursor:pointer;transition:background .15s}
.mb-task.done{background:rgba(80,232,160,.06);border-color:rgba(80,232,160,.25)}
.mb-task-check{width:16px;height:16px;border:2px solid var(--b2);border-radius:3px;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-size:10px;transition:all .15s}
.mb-task.done .mb-task-check{background:var(--accent2);border-color:var(--accent2);color:#000}
.mb-task-text{font-size:11px;color:var(--text);flex:1}
.mb-task.done .mb-task-text{text-decoration:line-through;color:var(--dim)}
.mb-backup-btn{width:100%;padding:10px;background:rgba(80,232,160,.1);border:2px solid rgba(80,232,160,.35);border-radius:8px;color:var(--accent2);font-size:12px;font-weight:700;cursor:pointer;letter-spacing:.06em;transition:var(--trans);text-align:center;margin-bottom:12px}
.mb-backup-btn:hover{background:rgba(80,232,160,.2)}
.mb-badges{display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px}
.mb-badge{padding:4px 10px;border-radius:12px;font-size:10px;font-weight:600;border:1px solid;opacity:.4;transition:.3s}
.mb-badge.earned{opacity:1}
.mb-heatmap-title{font-size:9px;letter-spacing:.1em;color:var(--dim);text-transform:uppercase;margin-bottom:6px}
.mb-heatmap{display:flex;gap:2px;flex-wrap:nowrap;overflow-x:auto;padding-bottom:4px}
.mb-hm-week{display:flex;flex-direction:column;gap:2px}
.mb-hm-day{width:10px;height:10px;border-radius:2px;background:rgba(58,184,255,.07)}
.mb-hm-day.active{background:rgba(80,232,160,.6)}
"@

$html139 = @"
<div id="mind-backup-panel" class="feature-panel mind-backup-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128190; MIND BACKUP</span>
    <span class="fp-sub">Regular self-reflection backups for your digital self</span>
    <span class="fp-close" onclick="toggleMindBackupPanel()">&#215;</span>
  </div>
  <div class="mb-status-card">
    <div class="mb-last-backup">Last backup: <span id="mb-last-date" class="mb-last-date">Never</span></div>
    <div style="font-size:10px;color:var(--dim);margin-top:2px">Recommended: weekly &bull; Good: monthly &bull; Minimum: quarterly</div>
    <div class="mb-streak-row">
      <div class="mb-streak-item"><div class="mb-streak-num" id="mb-week-streak">0</div><div class="mb-streak-label">WEEK STREAK</div></div>
      <div class="mb-streak-item"><div class="mb-streak-num" id="mb-total-backups">0</div><div class="mb-streak-label">TOTAL BACKUPS</div></div>
      <div class="mb-streak-item"><div class="mb-streak-num" id="mb-days-since">&#8734;</div><div class="mb-streak-label">DAYS SINCE</div></div>
    </div>
  </div>
  <div class="mb-tasks" id="mb-tasks"></div>
  <div class="mb-backup-btn" onclick="completeMindBackup()">&#128190; COMPLETE BACKUP NOW</div>
  <div class="mb-badges" id="mb-badges"></div>
  <div class="mb-heatmap-title">Backup History (52 weeks)</div>
  <div class="mb-heatmap" id="mb-heatmap"></div>
</div>
"@

$featMarker139 = '&#128230; ASSETS</div></div>'
$featRepl139 = '&#128230; ASSETS</div>
  <div class="hb" id="bMindBackup" onclick="toggleMindBackupPanel()" style="border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)">&#128190; MIND BACKUP</div></div>'

$js139 = @"
// === V139 MIND BACKUP FREQUENCY ===
var MB_TASKS=[
  {id:'mb_memories',text:'Add 3 new memories to Memory Journal',icon:'&#128221;'},
  {id:'mb_values',text:'Review and update Values ranking',icon:'&#129517;'},
  {id:'mb_change',text:'Write 1 sentence: how did you change this period?',icon:'&#128161;'},
  {id:'mb_event',text:'Note 1 key life event from this period',icon:'&#128197;'},
  {id:'mb_reflect',text:'Rate your wellbeing this period (reflect honestly)',icon:'&#9733;'}
];
var MB_BADGES=[
  {id:'b4w',label:'4-Week',icon:'&#129353;',threshold:4,color:'rgba(80,232,160,.5)'},
  {id:'b12w',label:'12-Week',icon:'&#129352;',threshold:12,color:'rgba(255,200,74,.5)'},
  {id:'b52w',label:'1-Year',icon:'&#129351;',threshold:52,color:'rgba(192,132,252,.5)'},
  {id:'b10t',label:'10 Backups',icon:'&#10024;',threshold_total:10,color:'rgba(58,184,255,.5)'},
  {id:'b50t',label:'50 Backups',icon:'&#128293;',threshold_total:50,color:'rgba(255,150,80,.5)'}
];
var mindBackupOpen=false;
var mbData=JSON.parse(localStorage.getItem('ns_mb_data')||'{"backups":[],"tasksDone":[]}');
function toggleMindBackupPanel(){
  mindBackupOpen=!mindBackupOpen;
  var p=document.getElementById('mind-backup-panel'),b=document.getElementById('bMindBackup');
  if(p)p.classList.toggle('vis',mindBackupOpen);if(b)b.classList.toggle('on',mindBackupOpen);
  if(mindBackupOpen)renderMindBackup();
}
function renderMindBackup(){
  var tEl=document.getElementById('mb-tasks');
  if(tEl)tEl.innerHTML=MB_TASKS.map(function(t){
    var done=mbData.tasksDone.indexOf(t.id)>=0;
    return '<div class="mb-task'+(done?' done':'')+'" onclick="toggleMBTask(\''+t.id+'\')">'
      +'<div class="mb-task-check">'+(done?'&#10003;':'')+'</div>'
      +'<div class="mb-task-text">'+t.icon+' '+t.text+'</div></div>';
  }).join('');
  var backups=mbData.backups||[];var total=backups.length;
  var streak=calcMBStreak(backups);
  var lastEl=document.getElementById('mb-last-date');
  if(lastEl)lastEl.textContent=total>0?new Date(backups[backups.length-1]).toLocaleDateString():'Never';
  var weekEl=document.getElementById('mb-week-streak');if(weekEl)weekEl.textContent=streak;
  var totEl=document.getElementById('mb-total-backups');if(totEl)totEl.textContent=total;
  var daysEl=document.getElementById('mb-days-since');
  if(daysEl){if(total>0){var diff=Math.floor((Date.now()-backups[backups.length-1])/86400000);daysEl.textContent=diff;}else daysEl.innerHTML='&#8734;';}
  renderMBBadges(streak,total);renderMBHeatmap(backups);
}
function toggleMBTask(id){
  var idx=mbData.tasksDone.indexOf(id);
  if(idx>=0)mbData.tasksDone.splice(idx,1);else mbData.tasksDone.push(id);
  localStorage.setItem('ns_mb_data',JSON.stringify(mbData));renderMindBackup();
}
function completeMindBackup(){
  mbData.backups=mbData.backups||[];mbData.backups.push(Date.now());mbData.tasksDone=[];
  localStorage.setItem('ns_mb_data',JSON.stringify(mbData));
  showToast('Mind backup completed! &#128190;',{type:'success',icon:'&#10003;',duration:3000});renderMindBackup();
}
function calcMBStreak(backups){
  if(!backups.length)return 0;
  var sorted=backups.slice().sort(function(a,b){return b-a;});
  var streak=1,week=604800000;
  for(var i=1;i<sorted.length;i++){if(sorted[i-1]-sorted[i]<=week*1.5)streak++;else break;}
  return streak;
}
function renderMBBadges(streak,total){
  var el=document.getElementById('mb-badges');if(!el)return;
  el.innerHTML=MB_BADGES.map(function(b){
    var earned=b.threshold?streak>=b.threshold:total>=(b.threshold_total||999);
    return '<div class="mb-badge'+(earned?' earned':'')+'" style="border-color:'+b.color+';background:'+(earned?b.color:'transparent')+'">'+b.icon+' '+b.label+'</div>';
  }).join('');
}
function renderMBHeatmap(backups){
  var el=document.getElementById('mb-heatmap');if(!el)return;
  var now=Date.now(),week=604800000;
  var html='';
  for(var w=51;w>=0;w--){
    html+='<div class="mb-hm-week">';
    for(var d=6;d>=0;d--){
      var t=now-(w*week)-(d*86400000);
      var hasBackup=backups.some(function(bk){return Math.abs(bk-t)<86400000;});
      html+='<div class="mb-hm-day'+(hasBackup?' active':'')+'"></div>';
    }
    html+='</div>';
  }
  el.innerHTML=html;
}
"@

$content = ApplyVersion $content 'NeuroScan v139 - Mind Backup' $css139 $html139 $featMarker139 $featRepl139 $js139
WriteVersion $content 139
# ============================================================
# V140 - MY UPLOAD BUDGET
# ============================================================
$css140 = @"
.upload-budget-panel{top:60px;right:320px;width:460px;max-height:84vh;overflow-y:auto}
.ub-section{background:rgba(58,184,255,.03);border:1px solid var(--b1);border-radius:8px;padding:12px;margin-bottom:10px}
.ub-section-title{font-size:10px;letter-spacing:.1em;color:var(--dim);text-transform:uppercase;margin-bottom:8px;font-weight:600}
.ub-cost-row{display:flex;justify-content:space-between;align-items:center;padding:5px 0;border-bottom:1px solid rgba(58,184,255,.06)}
.ub-cost-row:last-child{border-bottom:none}
.ub-cost-name{font-size:11px;color:var(--text)}
.ub-cost-val{font-size:12px;font-weight:700;color:var(--gold)}
.ub-cost-year{font-size:9px;color:var(--dim);font-style:italic}
.ub-input-row{display:flex;align-items:center;gap:10px;margin-bottom:8px}
.ub-input-label{font-size:11px;color:var(--dim);flex:1}
.ub-input{background:rgba(58,184,255,.06);border:1px solid var(--b1);border-radius:4px;color:var(--text);font-size:12px;padding:4px 8px;width:100px;font-family:var(--font-mono);text-align:right}
.ub-input:focus{outline:none;border-color:var(--b2)}
.ub-select{background:rgba(58,184,255,.06);border:1px solid var(--b1);border-radius:4px;color:var(--text);font-size:11px;padding:4px 8px;cursor:pointer}
.ub-result-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:10px}
.ub-result-card{background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:8px;padding:10px;text-align:center}
.ub-result-num{font-size:20px;font-weight:700;color:var(--accent2)}
.ub-result-label{font-size:9px;color:var(--dim);letter-spacing:.05em;margin-top:2px}
.ub-chart-wrap{background:rgba(0,0,0,.3);border-radius:6px;overflow:hidden;margin-top:8px}
.ub-reach{padding:8px 12px;border-radius:6px;font-size:11px;font-weight:700;text-align:center;letter-spacing:.06em}
.ub-reach.yes{background:rgba(80,232,160,.12);border:1px solid rgba(80,232,160,.3);color:var(--accent2)}
.ub-reach.no{background:rgba(255,85,104,.08);border:1px solid rgba(255,85,104,.25);color:var(--red)}
"@

$html140 = @"
<div id="upload-budget-panel" class="feature-panel upload-budget-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128176; MY UPLOAD BUDGET</span>
    <span class="fp-sub">Financial planning for digital immortality</span>
    <span class="fp-close" onclick="toggleUploadBudgetPanel()">&#215;</span>
  </div>
  <div class="ub-section">
    <div class="ub-section-title">&#128200; Cost Estimates</div>
    <div class="ub-cost-row">
      <span class="ub-cost-name">Cryonics option: <select class="ub-select" id="ub-cryo-type" onchange="calcUploadBudget()">
        <option value="28000">CI Whole Body (\$28K)</option>
        <option value="80000" selected>Alcor Neuro (\$80K)</option>
        <option value="220000">Alcor Whole Body (\$220K)</option>
      </select></span>
      <span class="ub-cost-val" id="ub-cryo-cost">\$80,000</span>
    </div>
    <div class="ub-cost-row"><span class="ub-cost-name">BCI Enhancement (est. 2035-2050)</span><span><span class="ub-cost-val">\$50K-\$500K</span><span class="ub-cost-year"> ~2040</span></span></div>
    <div class="ub-cost-row"><span class="ub-cost-name">Upload Procedure (est. 2050-2080)</span><span><span class="ub-cost-val">\$100K-\$10M</span><span class="ub-cost-year"> ~2060</span></span></div>
    <div class="ub-cost-row"><span class="ub-cost-name">Cryonics membership (monthly)</span><span class="ub-cost-val" id="ub-monthly-cost">\$275/mo</span></div>
  </div>
  <div class="ub-section">
    <div class="ub-section-title">&#127775; Your Financial Profile</div>
    <div class="ub-input-row"><label class="ub-input-label">Current age</label><input type="number" class="ub-input" id="ub-age" value="30" min="1" max="99" oninput="calcUploadBudget()"></div>
    <div class="ub-input-row"><label class="ub-input-label">Monthly savings capacity (\$)</label><input type="number" class="ub-input" id="ub-savings" value="500" min="0" oninput="calcUploadBudget()"></div>
    <div class="ub-input-row"><label class="ub-input-label">Target year to be ready</label><input type="number" class="ub-input" id="ub-target-year" value="2035" min="2025" max="2080" oninput="calcUploadBudget()"></div>
  </div>
  <div class="ub-section">
    <div class="ub-section-title">&#128200; Projections</div>
    <div id="ub-reach-indicator" class="ub-reach yes" style="margin-bottom:10px">Click Calculate to see results</div>
    <div class="ub-result-grid" id="ub-result-grid"></div>
    <div class="ub-chart-wrap"><canvas id="ub-chart" width="420" height="150"></canvas></div>
  </div>
</div>
"@

$featMarker140 = '&#128190; MIND BACKUP</div></div>'
$featRepl140 = '&#128190; MIND BACKUP</div>
  <div class="hb" id="bUploadBudget" onclick="toggleUploadBudgetPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#128176; BUDGET</div></div>'

$js140 = @"
// === V140 MY UPLOAD BUDGET ===
var uploadBudgetOpen=false;
function toggleUploadBudgetPanel(){
  uploadBudgetOpen=!uploadBudgetOpen;
  var p=document.getElementById('upload-budget-panel'),b=document.getElementById('bUploadBudget');
  if(p)p.classList.toggle('vis',uploadBudgetOpen);if(b)b.classList.toggle('on',uploadBudgetOpen);
  if(uploadBudgetOpen)calcUploadBudget();
}
function calcUploadBudget(){
  var age=parseInt((document.getElementById('ub-age')||{}).value||30);
  var monthlySavings=parseFloat((document.getElementById('ub-savings')||{}).value||500);
  var targetYear=parseInt((document.getElementById('ub-target-year')||{}).value||2035);
  var cryoType=document.getElementById('ub-cryo-type');
  var cryoCost=parseInt(cryoType?cryoType.value:80000);
  var monthlyMembership=cryoCost>=200000?800:cryoCost>=75000?275:120;
  var mc=document.getElementById('ub-monthly-cost');if(mc)mc.textContent='\$'+monthlyMembership+'/mo';
  var cc=document.getElementById('ub-cryo-cost');if(cc)cc.textContent='\$'+cryoCost.toLocaleString();
  var currentYear=new Date().getFullYear();
  var yearsToTarget=Math.max(0,targetYear-currentYear);
  var annualSavings=monthlySavings*12,rate=0.07;
  var futureValue=0;
  for(var y=0;y<yearsToTarget;y++){futureValue=(futureValue+annualSavings)*(1+rate);}
  var yearsToCryo=0,accum=0;
  for(var y2=0;y2<100;y2++){accum=(accum+annualSavings)*(1+rate);if(accum>=cryoCost){yearsToCryo=y2+1;break;}}
  var canAfford=futureValue>=cryoCost;
  var monthlyNeeded=yearsToTarget>0?Math.ceil(cryoCost/((Math.pow(1+rate,yearsToTarget)-1)/rate*12)):0;
  var ri=document.getElementById('ub-reach-indicator');
  if(ri){
    ri.textContent=canAfford?'&#9989; CRYONICS WITHIN REACH by '+targetYear:'&#9888; Need \$'+Math.round(Math.max(0,monthlyNeeded-monthlySavings))+'/mo more by '+targetYear;
    ri.className='ub-reach '+(canAfford?'yes':'no');
  }
  var rg=document.getElementById('ub-result-grid');
  if(rg)rg.innerHTML=[
    {num:yearsToCryo>0?yearsToCryo+'y':'<1y',label:'Years to afford cryonics'},
    {num:'\$'+Math.round(futureValue/1000)+'K',label:'Savings by '+targetYear+' (7% CAGR)'},
    {num:'\$'+monthlyNeeded,label:'Monthly needed for '+targetYear},
    {num:'\$'+Math.round((cryoCost*3)/1000)+'K+',label:'Total immortality path est.'}
  ].map(function(r){return '<div class="ub-result-card"><div class="ub-result-num">'+r.num+'</div><div class="ub-result-label">'+r.label+'</div></div>';}).join('');
  drawUBChart(monthlySavings,yearsToTarget,rate,cryoCost);
}
function drawUBChart(monthlySavings,years,rate,goal){
  var canvas=document.getElementById('ub-chart');if(!canvas)return;
  var ctx=canvas.getContext('2d');var W=canvas.width,H=canvas.height;
  ctx.clearRect(0,0,W,H);
  var pad={left:48,right:15,top:14,bottom:26};var annual=monthlySavings*12;
  var maxYears=Math.max(years+5,30);var pts=[];
  for(var y=0;y<=maxYears;y++){var v=0;for(var i=0;i<y;i++){v=(v+annual)*(1+rate);}pts.push({y:y,v:v});}
  var maxV=Math.max(goal*1.3,pts[pts.length-1].v,1);
  function xp(y){return pad.left+(W-pad.left-pad.right)*y/maxYears;}
  function yp(v){return H-pad.bottom-(H-pad.top-pad.bottom)*Math.min(v,maxV)/maxV;}
  ctx.strokeStyle='rgba(58,184,255,.1)';ctx.lineWidth=1;
  [0,0.25,0.5,0.75,1].forEach(function(f){
    var v=maxV*f;ctx.beginPath();ctx.moveTo(pad.left,yp(v));ctx.lineTo(W-pad.right,yp(v));ctx.stroke();
    ctx.fillStyle='rgba(180,210,255,.5)';ctx.font='8px Inter,sans-serif';ctx.fillText('\$'+Math.round(v/1000)+'K',2,yp(v)+3);
  });
  if(goal<=maxV){
    ctx.strokeStyle='rgba(255,200,74,.6)';ctx.lineWidth=1.5;ctx.setLineDash([4,3]);
    ctx.beginPath();ctx.moveTo(pad.left,yp(goal));ctx.lineTo(W-pad.right,yp(goal));ctx.stroke();ctx.setLineDash([]);
    ctx.fillStyle='rgba(255,200,74,.8)';ctx.font='8px Inter,sans-serif';ctx.fillText('Goal',W-pad.right-26,yp(goal)-3);
  }
  ctx.strokeStyle='#50e8a0';ctx.lineWidth=2;ctx.lineJoin='round';ctx.beginPath();
  pts.forEach(function(p,j){if(j===0)ctx.moveTo(xp(p.y),yp(p.v));else ctx.lineTo(xp(p.y),yp(p.v));});ctx.stroke();
  ctx.fillStyle='rgba(80,232,160,.1)';ctx.beginPath();ctx.moveTo(xp(0),yp(0));
  pts.forEach(function(p){ctx.lineTo(xp(p.y),yp(p.v));});ctx.lineTo(xp(maxYears),yp(0));ctx.closePath();ctx.fill();
  ctx.fillStyle='rgba(180,210,255,.6)';ctx.font='8px Inter,sans-serif';ctx.textAlign='center';
  [0,10,20,30].filter(function(y){return y<=maxYears;}).forEach(function(y){ctx.fillText(new Date().getFullYear()+y,xp(y),H-8);});
  ctx.textAlign='left';
}
"@

$content = ApplyVersion $content 'NeuroScan v140 - Upload Budget' $css140 $html140 $featMarker140 $featRepl140 $js140
WriteVersion $content 140
# ============================================================
# V141 - COGNITIVE BASELINE TEST
# ============================================================
$css141 = @"
.cogtest-panel{top:60px;right:420px;width:500px;max-height:84vh;overflow-y:auto}
.ct-intro{font-size:11px;color:var(--dim);line-height:1.6;margin-bottom:12px}
.ct-test-list{display:flex;flex-direction:column;gap:6px;margin-bottom:12px}
.ct-test-item{background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:8px;padding:10px;display:flex;align-items:center;gap:10px}
.ct-test-num{width:24px;height:24px;background:rgba(58,184,255,.1);border:1px solid var(--b2);border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700;color:var(--accent);flex-shrink:0}
.ct-test-status.done{color:var(--accent2)}
.ct-start-btn{width:100%;padding:10px;background:rgba(58,184,255,.1);border:2px solid var(--b2);border-radius:8px;color:var(--accent);font-size:12px;font-weight:700;cursor:pointer;letter-spacing:.06em;transition:var(--trans);text-align:center;margin-bottom:12px}
.ct-start-btn:hover{background:rgba(58,184,255,.2)}
.ct-arena{background:rgba(0,0,0,.4);border:1px solid var(--b2);border-radius:10px;padding:16px;margin-bottom:12px;min-height:140px;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center}
.ct-arena-title{font-size:11px;letter-spacing:.1em;color:var(--dim);text-transform:uppercase;margin-bottom:8px}
.ct-arena-prompt{font-size:18px;color:var(--text);margin-bottom:12px;font-family:var(--font-mono);line-height:1.6;letter-spacing:.12em}
.ct-arena-input{background:rgba(58,184,255,.08);border:1px solid var(--b2);border-radius:6px;color:var(--accent);font-size:16px;padding:6px 12px;text-align:center;font-family:var(--font-mono);width:160px;letter-spacing:.1em}
.ct-arena-input:focus{outline:none;border-color:var(--accent)}
.ct-arena-btn{padding:7px 20px;background:rgba(58,184,255,.15);border:1px solid var(--b2);border-radius:6px;color:var(--accent);font-size:11px;font-weight:600;cursor:pointer;letter-spacing:.05em;transition:var(--trans);margin-top:8px}
.ct-arena-btn:hover{background:rgba(58,184,255,.28)}
.ct-reaction-circle{width:80px;height:80px;border-radius:50%;background:rgba(255,85,104,.15);border:3px solid var(--red);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:11px;color:var(--dim);transition:all .15s;margin:8px auto;user-select:none}
.ct-reaction-circle.go{background:rgba(80,232,160,.3);border-color:var(--accent2);color:var(--accent2)}
.ct-stroop-opts{display:flex;gap:8px;flex-wrap:wrap;justify-content:center;margin-top:8px}
.ct-stroop-btn{padding:6px 16px;border-radius:6px;font-size:12px;font-weight:700;cursor:pointer;border:2px solid transparent;transition:all .15s;color:#000}
.ct-score-summary{display:grid;grid-template-columns:repeat(5,1fr);gap:6px;margin-bottom:12px}
.ct-score-card{background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:8px;padding:8px;text-align:center}
.ct-score-num{font-size:16px;font-weight:700;color:var(--accent2)}
.ct-score-name{font-size:8px;color:var(--dim);letter-spacing:.04em;margin-top:2px}
.ct-composite{background:rgba(80,232,160,.06);border:1px solid rgba(80,232,160,.25);border-radius:8px;padding:12px;text-align:center;margin-bottom:10px}
.ct-composite-num{font-size:40px;font-weight:700;color:var(--accent2)}
.ct-history-title{font-size:9px;letter-spacing:.1em;color:var(--dim);text-transform:uppercase;margin-bottom:6px}
"@

$html141 = @"
<div id="cogtest-panel" class="feature-panel cogtest-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#129504; COGNITIVE BASELINE TEST</span>
    <span class="fp-sub">5 quick tests: memory, reaction, pattern, Stroop, counting</span>
    <span class="fp-close" onclick="toggleCogTestPanel()">&#215;</span>
  </div>
  <div id="ct-main-view">
    <div class="ct-intro">Establish your cognitive baseline. Takes ~5 minutes. Results stored locally to track changes over time.</div>
    <div class="ct-test-list" id="ct-test-list"></div>
    <div class="ct-start-btn" onclick="startCogTest()">&#9654; START TEST</div>
    <div id="ct-history-section"></div>
  </div>
  <div id="ct-test-view" style="display:none">
    <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:10px">
      <div style="font-size:10px;color:var(--dim)">Test <span id="ct-test-idx">1</span> of 5</div>
    </div>
    <div class="ct-arena" id="ct-arena"></div>
    <div style="font-size:10px;color:var(--dim);text-align:center;min-height:18px" id="ct-feedback"></div>
  </div>
  <div id="ct-results-view" style="display:none">
    <div class="ct-composite"><div class="ct-composite-num" id="ct-composite-score">0</div><div style="font-size:9px;color:var(--dim);letter-spacing:.1em;text-transform:uppercase;margin-top:2px">COMPOSITE COGNITIVE SCORE</div></div>
    <div class="ct-score-summary" id="ct-score-summary"></div>
    <div id="ct-interpretation" style="font-size:11px;color:var(--dim);line-height:1.6;margin-bottom:10px;padding:8px;background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:6px"></div>
    <div class="ct-start-btn" onclick="resetCogTest()">&#9654; TEST AGAIN</div>
    <div class="ct-history-title">Score History</div>
    <div id="ct-history-results"></div>
  </div>
</div>
"@

$featMarker141 = '&#128176; BUDGET</div></div>'
$featRepl141 = '&#128176; BUDGET</div>
  <div class="hb" id="bCogTest" onclick="toggleCogTestPanel()" style="border-color:rgba(192,132,252,.3);color:rgba(192,132,252,.7)">&#129504; COGN. TEST</div></div>'

$js141 = @"
// === V141 COGNITIVE BASELINE TEST ===
var cogTestOpen=false;
var CT_STATE={phase:'menu',testIdx:0,scores:{}};
var CT_TESTS=[
  {id:'memory',name:'Memory Span',desc:'Remember digit sequences'},
  {id:'reaction',name:'Reaction Time',desc:'Click the green circle fast'},
  {id:'pattern',name:'Pattern Recognition',desc:'Which square was missing?'},
  {id:'stroop',name:'Stroop Test',desc:'Click the actual ink color'},
  {id:'counting',name:'Dot Counting',desc:'Count the dots quickly'}
];
var ctHistory=JSON.parse(localStorage.getItem('ns_ct_history')||'[]');
function toggleCogTestPanel(){
  cogTestOpen=!cogTestOpen;
  var p=document.getElementById('cogtest-panel'),b=document.getElementById('bCogTest');
  if(p)p.classList.toggle('vis',cogTestOpen);if(b)b.classList.toggle('on',cogTestOpen);
  if(cogTestOpen)renderCogTestMenu();
}
function renderCogTestMenu(){
  document.getElementById('ct-main-view').style.display='block';
  document.getElementById('ct-test-view').style.display='none';
  document.getElementById('ct-results-view').style.display='none';
  var tl=document.getElementById('ct-test-list');
  if(tl)tl.innerHTML=CT_TESTS.map(function(t,i){
    var s=CT_STATE.scores[t.id];
    return '<div class="ct-test-item"><div class="ct-test-num">'+(i+1)+'</div>'
      +'<div style="flex:1"><div style="font-size:12px;font-weight:600;color:var(--text)">'+t.name+'</div>'
      +'<div style="font-size:10px;color:var(--dim)">'+t.desc+'</div></div>'
      +'<div class="ct-test-status'+(s!==undefined?' done':'')+'">'+(s!==undefined?s:'--')+'</div></div>';
  }).join('');
  var hs=document.getElementById('ct-history-section');
  if(hs&&ctHistory.length){
    hs.innerHTML='<div class="ct-history-title">Previous Results</div>'
      +ctHistory.slice(-5).reverse().map(function(r){
        return '<div style="display:flex;justify-content:space-between;padding:4px 0;border-bottom:1px solid var(--b1)">'
          +'<span style="font-size:10px;color:var(--dim)">'+new Date(r.ts).toLocaleDateString()+'</span>'
          +'<span style="font-size:11px;font-weight:700;color:var(--accent2)">'+r.composite+'</span></div>';
      }).join('');
  }
}
function startCogTest(){
  CT_STATE={phase:'running',testIdx:0,scores:{}};
  document.getElementById('ct-main-view').style.display='none';
  document.getElementById('ct-test-view').style.display='block';
  document.getElementById('ct-results-view').style.display='none';
  runCTTest(0);
}
function runCTTest(idx){
  document.getElementById('ct-test-idx').textContent=(idx+1);
  document.getElementById('ct-feedback').textContent='';
  var t=CT_TESTS[idx];
  if(t.id==='memory')runMemoryTest();
  else if(t.id==='reaction')runReactionTest();
  else if(t.id==='pattern')runPatternTest();
  else if(t.id==='stroop')runStroopTest();
  else if(t.id==='counting')runCountingTest();
}
var memState={sequence:[],round:0,maxSpan:0};
function runMemoryTest(){memState={sequence:[],round:0,maxSpan:0};nextMemRound();}
function nextMemRound(){
  memState.round++;var len=4+memState.round;
  if(memState.round>4){ctRecordScore('memory',memState.maxSpan*20);return nextCTTest();}
  memState.sequence=[];for(var i=0;i<len;i++)memState.sequence.push(Math.floor(Math.random()*9)+1);
  var arena=document.getElementById('ct-arena');if(!arena)return;
  arena.innerHTML='<div class="ct-arena-title">MEMORY SPAN</div>'
    +'<div class="ct-arena-prompt">'+memState.sequence.join('  ')+'</div>'
    +'<div style="font-size:10px;color:var(--dim)">Memorize the sequence...</div>';
  setTimeout(function(){
    arena.innerHTML='<div class="ct-arena-title">TYPE THE SEQUENCE</div>'
      +'<input class="ct-arena-input" id="mem-input" placeholder="digits with spaces" autofocus>'
      +'<div class="ct-arena-btn" onclick="checkMemory()">Submit &#9654;</div>';
    var mi=document.getElementById('mem-input');
    if(mi){mi.focus();mi.onkeydown=function(e){if(e.key==='Enter')checkMemory();};}
  },2500);
}
function checkMemory(){
  var inp=document.getElementById('mem-input');if(!inp)return;
  var answer=inp.value.trim().replace(/\s+/g,' ');
  var correct=memState.sequence.join(' ');
  if(answer===correct)memState.maxSpan=memState.round+3;
  document.getElementById('ct-feedback').textContent=answer===correct?'&#10003; Correct!':'&#10007; Expected: '+correct;
  setTimeout(nextMemRound,1000);
}
var rtState={trials:0,times:[],startTime:0};
function runReactionTest(){rtState={trials:0,times:[],startTime:0};nextRTTrial();}
function nextRTTrial(){
  if(rtState.trials>=5){
    var avg=Math.round(rtState.times.reduce(function(a,b){return a+b;},0)/rtState.times.length);
    ctRecordScore('reaction',Math.max(0,Math.min(100,Math.round((1200-avg)/10))));
    document.getElementById('ct-feedback').textContent='Avg: '+avg+'ms';
    return setTimeout(nextCTTest,1200);
  }
  var arena=document.getElementById('ct-arena');if(!arena)return;
  arena.innerHTML='<div class="ct-arena-title">REACTION TIME &mdash; Trial '+(rtState.trials+1)+'/5</div>'
    +'<div class="ct-reaction-circle" id="rt-circle">WAIT</div>'
    +'<div style="font-size:10px;color:var(--dim);margin-top:8px">Click when circle turns GREEN</div>';
  setTimeout(function(){
    var c=document.getElementById('rt-circle');if(!c)return;
    c.className='ct-reaction-circle go';c.textContent='CLICK!';rtState.startTime=performance.now();
    c.onclick=function(){
      var t=Math.round(performance.now()-rtState.startTime);
      rtState.times.push(t);rtState.trials++;
      document.getElementById('ct-feedback').textContent=t+'ms';
      c.className='ct-reaction-circle';c.textContent='WAIT';c.onclick=null;
      setTimeout(nextRTTrial,800);
    };
  },1500+Math.random()*2500);
}
var ptState={round:0,emptyCell:0,score:0};
function runPatternTest(){ptState={round:0,emptyCell:0,score:0};nextPTRound();}
function nextPTRound(){
  if(ptState.round>=5){ctRecordScore('pattern',Math.round(ptState.score/5*100));return nextCTTest();}
  ptState.round++;ptState.emptyCell=Math.floor(Math.random()*9);
  var arena=document.getElementById('ct-arena');if(!arena)return;
  var cells='';for(var i=0;i<9;i++)cells+='<div style="width:28px;height:28px;background:'+(i===ptState.emptyCell?'transparent':'rgba(58,184,255,.4)')+';border:1px solid var(--b2);border-radius:3px"></div>';
  arena.innerHTML='<div class="ct-arena-title">PATTERN RECOGNITION &mdash; Round '+ptState.round+'/5</div>'
    +'<div style="display:grid;grid-template-columns:repeat(3,30px);gap:4px;margin-bottom:8px">'+cells+'</div>'
    +'<div style="font-size:10px;color:var(--dim)">Which cell is missing?</div>';
  var positions=['Top-left','Top-center','Top-right','Mid-left','Center','Mid-right','Bot-left','Bot-center','Bot-right'];
  setTimeout(function(){
    var shuffled=positions.map(function(p,i){return {p:p,i:i};}).sort(function(){return Math.random()-.5;});
    arena.innerHTML='<div class="ct-arena-title">WHICH CELL WAS EMPTY?</div>'
      +'<div style="display:flex;flex-wrap:wrap;gap:5px;justify-content:center">'
      +shuffled.map(function(o){return '<div class="ct-arena-btn" onclick="checkPattern('+o.i+')">'+o.p+'</div>';}).join('')
      +'</div>';
  },2000);
}
function checkPattern(idx){
  if(idx===ptState.emptyCell)ptState.score++;
  document.getElementById('ct-feedback').textContent=idx===ptState.emptyCell?'&#10003; Correct!':'&#10007; Wrong';
  setTimeout(nextPTRound,700);
}
var stroopState={trials:0,score:0};
var SC=['red','blue','green','yellow','purple'];
var SH={red:'#ff5568',blue:'#3ab8ff',green:'#50e8a0',yellow:'#ffc84a',purple:'#c084fc'};
function runStroopTest(){stroopState={trials:0,score:0};nextStroopTrial();}
function nextStroopTrial(){
  if(stroopState.trials>=6){ctRecordScore('stroop',Math.round(stroopState.score/6*100));return nextCTTest();}
  stroopState.trials++;
  var wi=Math.floor(Math.random()*SC.length),ci=Math.floor(Math.random()*SC.length);
  if(ci===wi)ci=(ci+1)%SC.length;
  var word=SC[wi],color=SC[ci];
  var shuffled=SC.slice().sort(function(){return Math.random()-.5;});
  var arena=document.getElementById('ct-arena');if(!arena)return;
  arena.innerHTML='<div class="ct-arena-title">STROOP TEST &mdash; Trial '+stroopState.trials+'/6</div>'
    +'<div style="font-size:34px;font-weight:700;color:'+SH[color]+';margin-bottom:12px;font-family:var(--font-mono)">'+word.toUpperCase()+'</div>'
    +'<div style="font-size:10px;color:var(--dim);margin-bottom:10px">Click the ACTUAL COLOR of the text</div>'
    +'<div class="ct-stroop-opts">'
    +shuffled.map(function(c){return '<div class="ct-stroop-btn" style="background:'+SH[c]+'" onclick="checkStroop(\''+c+'\',\''+color+'\')">'+c+'</div>';}).join('')
    +'</div>';
}
function checkStroop(chosen,correct){
  if(chosen===correct)stroopState.score++;
  document.getElementById('ct-feedback').textContent=chosen===correct?'&#10003; Correct!':'&#10007; Was '+correct;
  setTimeout(nextStroopTrial,800);
}
var dotState={round:0,score:0};
function runCountingTest(){dotState={round:0,score:0};nextDotRound();}
function nextDotRound(){
  if(dotState.round>=5){ctRecordScore('counting',Math.round(dotState.score/5*100));return finishCogTest();}
  dotState.round++;
  var count=6+Math.floor(Math.random()*18);
  var dots='';for(var i=0;i<count;i++){var x=Math.random()*88+4,y=Math.random()*68+12;dots+='<div style="position:absolute;left:'+x+'%;top:'+y+'%;width:8px;height:8px;background:var(--accent2);border-radius:50%;transform:translate(-50%,-50%)"></div>';}
  var arena=document.getElementById('ct-arena');if(!arena)return;
  arena.innerHTML='<div class="ct-arena-title">DOT COUNTING &mdash; Round '+dotState.round+'/5</div>'
    +'<div style="position:relative;width:200px;height:120px;background:rgba(0,0,0,.4);border:1px solid var(--b1);border-radius:6px;overflow:hidden">'+dots+'</div>'
    +'<div style="font-size:10px;color:var(--dim);margin-top:6px">Count the dots!</div>';
  setTimeout(function(){
    arena.innerHTML='<div class="ct-arena-title">HOW MANY DOTS?</div>'
      +'<input class="ct-arena-input" id="dot-input" type="number" min="1" max="50" placeholder="Count" autofocus>'
      +'<div class="ct-arena-btn" onclick="checkDots('+count+')">Submit</div>';
    var di=document.getElementById('dot-input');
    if(di){di.focus();di.onkeydown=function(e){if(e.key==='Enter')checkDots(count);};}
  },3000);
}
function checkDots(correct){
  var inp=document.getElementById('dot-input');if(!inp)return;
  var ans=parseInt(inp.value)||0;
  if(Math.abs(ans-correct)<=2)dotState.score++;
  document.getElementById('ct-feedback').textContent=Math.abs(ans-correct)<=2?'&#10003; Close enough! ('+correct+')':'&#10007; Was '+correct;
  setTimeout(nextDotRound,800);
}
function nextCTTest(){CT_STATE.testIdx++;if(CT_STATE.testIdx<CT_TESTS.length)runCTTest(CT_STATE.testIdx);else finishCogTest();}
function ctRecordScore(id,score){CT_STATE.scores[id]=Math.max(0,Math.min(100,score));}
function finishCogTest(){
  var scores=CT_STATE.scores;var keys=Object.keys(scores);
  var composite=keys.length>0?Math.round(keys.reduce(function(s,k){return s+scores[k];},0)/keys.length):0;
  ctHistory.push({ts:Date.now(),composite:composite,scores:scores});
  localStorage.setItem('ns_ct_history',JSON.stringify(ctHistory));
  document.getElementById('ct-test-view').style.display='none';
  document.getElementById('ct-results-view').style.display='block';
  var cs=document.getElementById('ct-composite-score');if(cs)cs.textContent=composite;
  var ss=document.getElementById('ct-score-summary');
  if(ss)ss.innerHTML=CT_TESTS.map(function(t){var s=scores[t.id];return '<div class="ct-score-card"><div class="ct-score-num">'+(s!==undefined?s:'--')+'</div><div class="ct-score-name">'+t.name+'</div></div>';}).join('');
  var interp=document.getElementById('ct-interpretation');
  if(interp){
    var lowest=keys.sort(function(a,b){return scores[a]-scores[b];})[0];
    var lowestName=lowest?CT_TESTS.find(function(t){return t.id===lowest;}):null;
    var tier=composite>=80?'excellent':composite>=65?'above average':composite>=50?'average':'below average';
    interp.innerHTML='Composite score: <b style="color:var(--accent2)">'+composite+'</b> &mdash; <b>'+tier+'</b>'
      +(lowestName?'<br>Weakest area: <b style="color:var(--gold)">'+lowestName.name+'</b>. Focus improvement here.':'')
      +'<br><span style="font-size:9px">Retake regularly to track cognitive changes over time.</span>';
  }
  var hr=document.getElementById('ct-history-results');
  if(hr&&ctHistory.length>1){
    hr.innerHTML=ctHistory.slice(-5).reverse().map(function(r){
      return '<div style="display:flex;justify-content:space-between;padding:4px 0;border-bottom:1px solid var(--b1)">'
        +'<span style="font-size:10px;color:var(--dim)">'+new Date(r.ts).toLocaleDateString()+'</span>'
        +'<span style="font-size:11px;font-weight:700;color:var(--accent2)">'+r.composite+'</span></div>';
    }).join('');
  }
}
function resetCogTest(){
  CT_STATE={phase:'menu',testIdx:0,scores:{}};
  document.getElementById('ct-results-view').style.display='none';
  document.getElementById('ct-main-view').style.display='block';
  renderCogTestMenu();
}
"@

$content = ApplyVersion $content 'NeuroScan v141 - Cognitive Test' $css141 $html141 $featMarker141 $featRepl141 $js141
WriteVersion $content 141
# ============================================================
# V142 - RISK ASSESSMENT
# ============================================================
$css142 = @"
.risk-panel{top:60px;right:320px;width:460px;max-height:84vh;overflow-y:auto}
.risk-summary-bar{background:rgba(255,85,104,.05);border:1px solid rgba(255,85,104,.2);border-radius:8px;padding:10px;margin-bottom:12px;display:flex;align-items:center;gap:12px}
.risk-total-num{font-size:28px;font-weight:700;color:var(--red)}
.risk-total-label{font-size:9px;color:var(--dim);letter-spacing:.05em}
.risk-gauge{flex:1;height:8px;background:rgba(255,85,104,.1);border-radius:4px;overflow:hidden}
.risk-gauge-fill{height:100%;border-radius:4px;transition:width .5s}
.risk-category{background:rgba(58,184,255,.03);border:1px solid var(--b1);border-radius:8px;padding:10px;margin-bottom:8px}
.risk-cat-header{display:flex;align-items:center;gap:8px;margin-bottom:8px}
.risk-cat-icon{font-size:16px;flex-shrink:0}
.risk-cat-title{font-size:12px;font-weight:600;color:var(--text);flex:1}
.risk-cat-score{font-size:11px;font-weight:700;padding:2px 8px;border-radius:8px;background:rgba(255,85,104,.1);color:var(--red)}
.risk-items{display:flex;flex-direction:column;gap:7px}
.risk-item{padding:8px;background:rgba(0,0,0,.2);border-radius:6px;border-left:3px solid var(--b2)}
.risk-item.high{border-left-color:var(--red)}
.risk-item.medium{border-left-color:var(--gold)}
.risk-item.low{border-left-color:var(--accent2)}
.risk-item-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:4px}
.risk-item-name{font-size:11px;font-weight:600;color:var(--text)}
.risk-item-score.high{color:var(--red)}.risk-item-score.medium{color:var(--gold)}.risk-item-score.low{color:var(--accent2)}
.risk-item-desc{font-size:10px;color:var(--dim);line-height:1.5;margin-bottom:6px}
.risk-slider-row{display:flex;align-items:center;gap:8px}
.risk-slider-label{font-size:9px;color:var(--dim);width:90px;flex-shrink:0}
.risk-slider{flex:1;-webkit-appearance:none;height:4px;border-radius:2px;background:rgba(58,184,255,.2);cursor:pointer}
.risk-slider::-webkit-slider-thumb{-webkit-appearance:none;width:14px;height:14px;border-radius:50%;background:var(--accent);cursor:pointer}
.risk-slider-val{font-size:10px;font-weight:700;color:var(--accent);width:14px;text-align:right;flex-shrink:0}
.risk-mitigation{font-size:9px;color:var(--accent2);margin-top:5px;padding:4px 6px;background:rgba(80,232,160,.05);border-radius:4px;border-left:2px solid rgba(80,232,160,.3)}
"@

$html142 = @"
<div id="risk-panel" class="feature-panel risk-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#9888; RISK ASSESSMENT</span>
    <span class="fp-sub">Personal threats to your digital immortality path</span>
    <span class="fp-close" onclick="toggleRiskPanel()">&#215;</span>
  </div>
  <div class="risk-summary-bar">
    <div>
      <div class="risk-total-num" id="risk-total-score">0</div>
      <div class="risk-total-label">RISK SCORE</div>
    </div>
    <div style="flex:1">
      <div class="risk-gauge"><div id="risk-gauge-fill" class="risk-gauge-fill" style="width:0%;background:var(--accent2)"></div></div>
      <div style="display:flex;justify-content:space-between;margin-top:3px">
        <span style="font-size:8px;color:var(--accent2)">LOW</span>
        <span style="font-size:8px;color:var(--gold)">MEDIUM</span>
        <span style="font-size:8px;color:var(--red)">HIGH</span>
      </div>
    </div>
    <div style="text-align:center">
      <div id="risk-crit-num" style="font-size:18px;font-weight:700;color:var(--gold)">0</div>
      <div style="font-size:8px;color:var(--dim)">CRITICAL</div>
    </div>
  </div>
  <div id="risk-categories"></div>
</div>
"@

$featMarker142 = '&#129504; COGN. TEST</div></div>'
$featRepl142 = '&#129504; COGN. TEST</div>
  <div class="hb" id="bRiskAssess" onclick="toggleRiskPanel()" style="border-color:rgba(255,85,104,.3);color:rgba(255,130,130,.7)">&#9888; RISK</div></div>'

$js142 = @"
// === V142 RISK ASSESSMENT ===
var RISK_CATS=[
  {id:'personal',title:'Personal Risks',icon:'&#128100;',items:[
    {id:'health',name:'Chronic Disease Risk',prob:3,impact:5,desc:'Your health status. Unhealthy lifestyle dramatically increases premature death risk.',mitigation:'Annual checkups, preventive care, brain health protocol.'},
    {id:'accident',name:'Accident Probability',prob:2,impact:5,desc:'Risk of sudden death before cryonics/upload available.',mitigation:'Carry cryonics emergency card. Avoid extreme risks.'},
    {id:'lifestyle',name:'Risky Lifestyle',prob:2,impact:4,desc:'Smoking, alcohol, drugs accelerate death risk.',mitigation:'Eliminate lifestyle risks. Treat your brain as irreplaceable.'}
  ]},
  {id:'tech',title:'Technological Risks',icon:'&#128300;',items:[
    {id:'timing',name:'Upload Technology Too Slow',prob:4,impact:4,desc:'Technology may not arrive in your lifetime even with cryonics bridge.',mitigation:'Support WBE research funding. Cryonics buys time.'},
    {id:'data_loss',name:'Digital Data Loss',prob:3,impact:3,desc:'Your digital self data could be lost to hardware failure.',mitigation:'Triple backups: local, cloud, distributed.'},
    {id:'cryo_fail',name:'Cryonics Provider Failure',prob:2,impact:5,desc:'Cryonics provider could fail financially or technically.',mitigation:'Choose established provider. Alcor/CI have 50+ year track records.'}
  ]},
  {id:'economic',title:'Economic Risks',icon:'&#128200;',items:[
    {id:'afford',name:'Affordability Gap',prob:3,impact:4,desc:'Cryonics and future upload costs may be beyond reach.',mitigation:'Start saving now. Use the Upload Budget calculator.'},
    {id:'inflation',name:'Cost Inflation',prob:3,impact:3,desc:'Medical and tech costs may inflate faster than savings.',mitigation:'Invest in diversified portfolio at 7%/yr.'},
    {id:'collapse',name:'Economic Collapse',prob:2,impact:4,desc:'Major economic disruption could halt tech development.',mitigation:'Diversify assets. Political stability matters.'}
  ]},
  {id:'social',title:'Social and Legal Risks',icon:'&#127970;',items:[
    {id:'legal',name:'Legal Status of Digital Minds',prob:4,impact:4,desc:'Future digital minds may have no legal rights and could be deleted.',mitigation:'Advocate now. Fund legal organizations working on digital rights.'},
    {id:'disc',name:'Social Discrimination',prob:3,impact:3,desc:'Digital minds may face prejudice or second-class status.',mitigation:'Build social acceptance through education and advocacy.'}
  ]},
  {id:'geo',title:'Geopolitical Risks',icon:'&#127758;',items:[
    {id:'war',name:'Global Conflict',prob:2,impact:5,desc:'Major war could destroy infrastructure and delay tech by decades.',mitigation:'Support international cooperation.'},
    {id:'nuke',name:'Nuclear/Bioweapon Risk',prob:1,impact:5,desc:'Existential weapons could eliminate civilization entirely.',mitigation:'Support nuclear disarmament. Fund existential risk research.'}
  ]},
  {id:'exist',title:'Existential Risks',icon:'&#9883;',items:[
    {id:'ai_align',name:'AI Misalignment',prob:3,impact:5,desc:'Misaligned superintelligence could be harmful to digital minds.',mitigation:'Support AI safety research: MIRI, Anthropic, Redwood.'},
    {id:'sim',name:'Simulation Termination',prob:1,impact:5,desc:'If simulated, it could end. Low probability, ultimate impact.',mitigation:'Philosophical acceptance. Focus on what you can control.'}
  ]}
];
var riskOpen=false;
var riskValues=JSON.parse(localStorage.getItem('ns_risk_vals')||'{}');
function toggleRiskPanel(){
  riskOpen=!riskOpen;
  var p=document.getElementById('risk-panel'),b=document.getElementById('bRiskAssess');
  if(p)p.classList.toggle('vis',riskOpen);if(b)b.classList.toggle('on',riskOpen);
  if(riskOpen)renderRiskPanel();
}
function renderRiskPanel(){
  var container=document.getElementById('risk-categories');if(!container)return;
  container.innerHTML=RISK_CATS.map(function(cat){
    return '<div class="risk-category">'
      +'<div class="risk-cat-header"><div class="risk-cat-icon">'+cat.icon+'</div><div class="risk-cat-title">'+cat.title+'</div>'
      +'<div class="risk-cat-score" id="rcs-'+cat.id+'">0</div></div>'
      +'<div class="risk-items">'
      +cat.items.map(function(item){
        var val=riskValues[item.id]!==undefined?riskValues[item.id]:item.prob;
        var score=Math.round(val*item.impact/5);var tier=score>=7?'high':score>=4?'medium':'low';
        return '<div class="risk-item '+tier+'" id="ri-'+item.id+'">'
          +'<div class="risk-item-header"><div class="risk-item-name">'+item.name+'</div>'
          +'<div class="risk-item-score '+tier+'" id="ris-'+item.id+'">'+score+'/10</div></div>'
          +'<div class="risk-item-desc">'+item.desc+'</div>'
          +'<div class="risk-slider-row">'
          +'<span class="risk-slider-label">Your exposure:</span>'
          +'<input type="range" class="risk-slider" min="1" max="5" value="'+val+'" oninput="updateRisk(\''+item.id+'\',\''+cat.id+'\','+item.impact+',this.value)">'
          +'<span class="risk-slider-val" id="rsv-'+item.id+'">'+val+'</span></div>'
          +'<div class="risk-mitigation">&#128736; '+item.mitigation+'</div></div>';
      }).join('')+'</div></div>';
  }).join('');
  updateRiskTotal();
}
function updateRisk(itemId,catId,impact,val){
  riskValues[itemId]=parseInt(val);localStorage.setItem('ns_risk_vals',JSON.stringify(riskValues));
  var sv=document.getElementById('rsv-'+itemId);if(sv)sv.textContent=val;
  var score=Math.round(parseInt(val)*impact/5);var tier=score>=7?'high':score>=4?'medium':'low';
  var ri=document.getElementById('ri-'+itemId),ris=document.getElementById('ris-'+itemId);
  if(ri)ri.className='risk-item '+tier;if(ris){ris.className='risk-item-score '+tier;ris.textContent=score+'/10';}
  updateRiskTotal();
}
function updateRiskTotal(){
  var total=0,critical=0;
  RISK_CATS.forEach(function(cat){
    var catScore=0;
    cat.items.forEach(function(item){
      var val=riskValues[item.id]!==undefined?riskValues[item.id]:item.prob;
      var score=Math.round(val*item.impact/5);catScore+=score;total+=score;if(score>=7)critical++;
    });
    var csel=document.getElementById('rcs-'+cat.id);if(csel)csel.textContent=catScore;
  });
  var maxScore=RISK_CATS.reduce(function(s,c){return s+c.items.length*10;},0);
  var pct=Math.round(total/maxScore*100);
  var ts=document.getElementById('risk-total-score'),gf=document.getElementById('risk-gauge-fill'),cn=document.getElementById('risk-crit-num');
  if(ts)ts.textContent=total;
  if(gf){gf.style.width=pct+'%';gf.style.background=pct>60?'var(--red)':pct>35?'var(--gold)':'var(--accent2)';}
  if(cn)cn.textContent=critical;
}
"@

$content = ApplyVersion $content 'NeuroScan v142 - Risk Assessment' $css142 $html142 $featMarker142 $featRepl142 $js142
WriteVersion $content 142
# ============================================================
# V143 - LEARNING PATH
# ============================================================
$css143 = @"
.learning-panel{top:60px;right:760px;width:450px;max-height:84vh;overflow-y:auto}
.lp-progress-row{display:flex;gap:6px;align-items:center;margin-bottom:12px;padding:8px;background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:8px}
.lp-prog-num{font-size:20px;font-weight:700;color:var(--accent2)}
.lp-prog-label{font-size:9px;color:var(--dim);letter-spacing:.05em}
.lp-prog-bar{flex:1;height:6px;background:rgba(58,184,255,.1);border-radius:3px;overflow:hidden}
.lp-prog-fill{height:100%;background:linear-gradient(90deg,var(--accent),var(--accent2));border-radius:3px;transition:width .5s}
.lp-level{margin-bottom:10px}
.lp-level-header{display:flex;align-items:center;gap:8px;padding:8px 10px;background:rgba(58,184,255,.06);border:1px solid var(--b1);border-radius:8px;cursor:pointer;margin-bottom:2px}
.lp-level-badge{width:24px;height:24px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700;color:#000;flex-shrink:0}
.lp-level-name{font-size:12px;font-weight:600;color:var(--text);flex:1}
.lp-level-done{font-size:9px;color:var(--accent2);font-weight:600}
.lp-resources{display:flex;flex-direction:column;gap:4px;padding:4px 0 4px 8px}
.lp-resource{display:flex;align-items:flex-start;gap:8px;padding:7px 8px;background:rgba(58,184,255,.03);border:1px solid var(--b1);border-radius:6px;cursor:pointer;transition:background .15s}
.lp-resource.done{background:rgba(80,232,160,.05);border-color:rgba(80,232,160,.2)}
.lp-res-check{width:14px;height:14px;border:2px solid var(--b2);border-radius:3px;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-size:9px;transition:all .15s;margin-top:1px}
.lp-resource.done .lp-res-check{background:var(--accent2);border-color:var(--accent2);color:#000}
.lp-res-title{font-size:11px;font-weight:600;color:var(--text);margin-bottom:2px}
.lp-resource.done .lp-res-title{text-decoration:line-through;color:var(--dim)}
.lp-res-meta{display:flex;gap:6px;align-items:center;flex-wrap:wrap}
.lp-res-type{font-size:9px;padding:1px 5px;border-radius:6px;border:1px solid var(--b1);color:var(--dim)}
.lp-res-time{font-size:9px;color:var(--accent);font-weight:600}
.lp-res-free{font-size:9px;color:var(--accent2);font-weight:700}
"@

$html143 = @"
<div id="learning-panel" class="feature-panel learning-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128218; LEARNING PATH</span>
    <span class="fp-sub">Curated curriculum for digital immortality — 5 levels, 25 resources</span>
    <span class="fp-close" onclick="toggleLearningPanel()">&#215;</span>
  </div>
  <div class="lp-progress-row">
    <div><div class="lp-prog-num" id="lp-done-num">0</div><div class="lp-prog-label">DONE</div></div>
    <div class="lp-prog-bar"><div id="lp-prog-fill" class="lp-prog-fill" style="width:0%"></div></div>
    <div><div class="lp-prog-num" id="lp-pct-num">0%</div><div class="lp-prog-label">PROGRESS</div></div>
  </div>
  <div id="lp-levels"></div>
</div>
"@

$featMarker143 = '&#9888; RISK</div></div>'
$featRepl143 = '&#9888; RISK</div>
  <div class="hb" id="bLearning" onclick="toggleLearningPanel()" style="border-color:rgba(58,184,255,.3);color:rgba(100,180,255,.7)">&#128218; LEARNING</div></div>'

$js143 = @"
// === V143 LEARNING PATH ===
var LP_LEVELS=[
  {level:1,name:'Beginner',color:'#50e8a0',resources:[
    {id:'yale_death',title:'Death: A Course About Life (Yale)',type:'Course',time:'8h',free:true,desc:'Yale open course on mortality, meaning, and persistence.'},
    {id:'khan_neuro',title:'Introduction to Neuroscience (Khan Academy)',type:'Course',time:'5h',free:true,desc:'Free intro to brain function and neural basics.'},
    {id:'homo_deus',title:'Homo Deus (Harari)',type:'Book',time:'10h',free:false,desc:"Visionary look at humanity's future including digital consciousness."},
    {id:'singularity_near',title:'The Singularity Is Near (Kurzweil)',type:'Book',time:'15h',free:false,desc:"Kurzweil's roadmap to merging human and artificial intelligence."},
    {id:'howstuff_brain',title:'How Your Brain Works (HowStuffWorks)',type:'Article',time:'1h',free:true,desc:'Accessible overview of brain structure and cognition.'}
  ]},
  {level:2,name:'Intermediate',color:'#3ab8ff',resources:[
    {id:'purves',title:'Neuroscience (Dale Purves textbook)',type:'Book',time:'40h',free:false,desc:'Standard neuroscience textbook covering all fundamentals.'},
    {id:'brain_changes',title:'The Brain That Changes Itself (Doidge)',type:'Book',time:'9h',free:false,desc:'Neuroplasticity and the brain\u2019s remarkable ability to rewire.'},
    {id:'dennett',title:'Consciousness Explained (Dennett)',type:'Book',time:'14h',free:false,desc:"Dennett's materialist account of consciousness and mind."},
    {id:'mit_ocw',title:'MIT OCW: Neuroscience',type:'Course',time:'30h',free:true,desc:'MIT OpenCourseWare neuroscience course materials.'},
    {id:'godel_escher',title:"Godel, Escher, Bach (Hofstadter)",type:'Book',time:'20h',free:false,desc:'Classic exploration of consciousness, self-reference, and mind.'}
  ]},
  {level:3,name:'Advanced',color:'#ffc84a',resources:[
    {id:'parfit',title:'Reasons and Persons (Parfit)',type:'Book',time:'20h',free:false,desc:'Philosophical treatment of personal identity \u2014 essential for digital mind theory.'},
    {id:'penrose',title:"The Emperor's New Mind (Penrose)",type:'Book',time:'16h',free:false,desc:"Penrose's argument about consciousness and quantum mechanics."},
    {id:'churchland',title:'Neurophilosophy (Churchland)',type:'Book',time:'18h',free:false,desc:'Connecting neuroscience with philosophy of mind.'},
    {id:'wbe_roadmap',title:'WBE Roadmap (Sandberg/Bostrom 2008)',type:'Paper',time:'3h',free:true,desc:'Technical roadmap for whole brain emulation. Essential reading.'},
    {id:'gwt_iit',title:'GWT/IIT Consciousness Papers',type:'Papers',time:'5h',free:true,desc:'Global Workspace Theory and Integrated Information Theory papers.'}
  ]},
  {level:4,name:'Technical',color:'#c084fc',resources:[
    {id:'hodgkin',title:'Hodgkin-Huxley Model (1952)',type:'Paper',time:'4h',free:true,desc:'Original mathematical model of neuron action potentials.'},
    {id:'neuron_sim',title:'NEURON Simulator Tutorials',type:'Course',time:'8h',free:true,desc:'Learn to simulate neurons computationally.'},
    {id:'allen_atlas',title:'Allen Brain Atlas Tutorials',type:'Resource',time:'6h',free:true,desc:"World's most comprehensive 3D brain gene expression atlas."},
    {id:'connectomics',title:'Connectomics Papers (Seung et al.)',type:'Papers',time:'5h',free:true,desc:'Electron microscopy connectomics \u2014 mapping synapses at nanoscale.'},
    {id:'wbe_workshop',title:'WBE Workshop Proceedings (Carboncopies)',type:'Report',time:'6h',free:true,desc:'Technical proceedings from whole brain emulation workshops.'}
  ]},
  {level:5,name:'Expert',color:'#ff8040',resources:[
    {id:'nature_neuro',title:'Nature Neuroscience (journal)',type:'Journal',time:'ongoing',free:false,desc:'Top peer-reviewed neuroscience research.'},
    {id:'carboncopies_nl',title:'Carboncopies Newsletter',type:'Newsletter',time:'1h/mo',free:true,desc:'Leading WBE research organization updates.'},
    {id:'fhi_reports',title:'FHI Technical Reports',type:'Papers',time:'variable',free:true,desc:'Future of Humanity Institute reports on digital minds and x-risk.'},
    {id:'cryo_research',title:'Cryonics Research Papers',type:'Papers',time:'variable',free:true,desc:'Current research on vitrification and revival protocols.'},
    {id:'brain_emulation',title:'Brain Emulation Conference Proceedings',type:'Papers',time:'variable',free:true,desc:'Annual computational neuroscience and brain emulation proceedings.'}
  ]}
];
var lpOpen=false,lpDone=JSON.parse(localStorage.getItem('ns_lp_done')||'[]');
var lpExpanded=JSON.parse(localStorage.getItem('ns_lp_expanded')||'[0]');
function toggleLearningPanel(){
  lpOpen=!lpOpen;
  var p=document.getElementById('learning-panel'),b=document.getElementById('bLearning');
  if(p)p.classList.toggle('vis',lpOpen);if(b)b.classList.toggle('on',lpOpen);
  if(lpOpen)renderLearningPath();
}
function renderLearningPath(){
  var total=LP_LEVELS.reduce(function(s,l){return s+l.resources.length;},0);
  var done=lpDone.length;
  var dn=document.getElementById('lp-done-num'),pf=document.getElementById('lp-prog-fill'),pn=document.getElementById('lp-pct-num');
  if(dn)dn.textContent=done;if(pf)pf.style.width=Math.round(done/total*100)+'%';if(pn)pn.textContent=Math.round(done/total*100)+'%';
  var el=document.getElementById('lp-levels');if(!el)return;
  el.innerHTML=LP_LEVELS.map(function(lv,li){
    var lvDone=lv.resources.filter(function(r){return lpDone.indexOf(r.id)>=0;}).length;
    var isExp=lpExpanded.indexOf(li)>=0;
    return '<div class="lp-level">'
      +'<div class="lp-level-header" onclick="toggleLPLevel('+li+')">'
      +'<div class="lp-level-badge" style="background:'+lv.color+'">'+lv.level+'</div>'
      +'<div class="lp-level-name">Level '+lv.level+': '+lv.name+'</div>'
      +'<div class="lp-level-done">'+lvDone+'/'+lv.resources.length+'</div>'
      +'<div style="font-size:12px;color:var(--dim);margin-left:4px">'+(isExp?'&#9650;':'&#9660;')+'</div></div>'
      +(isExp?'<div class="lp-resources">'
        +lv.resources.map(function(r){
          var isDone=lpDone.indexOf(r.id)>=0;
          return '<div class="lp-resource'+(isDone?' done':'')+'" onclick="toggleLPResource(\''+r.id+'\')">'
            +'<div class="lp-res-check">'+(isDone?'&#10003;':'')+'</div>'
            +'<div style="flex:1"><div class="lp-res-title">'+r.title+'</div>'
            +'<div class="lp-res-meta"><span class="lp-res-type">'+r.type+'</span>'
            +'<span class="lp-res-time">&#128336; '+r.time+'</span>'
            +(r.free?'<span class="lp-res-free">FREE</span>':'')+'</div>'
            +'<div style="font-size:10px;color:var(--dim);margin-top:2px">'+r.desc+'</div>'
            +'</div></div>';
        }).join('')+'</div>':'')
      +'</div>';
  }).join('');
}
function toggleLPLevel(i){
  var idx=lpExpanded.indexOf(i);if(idx>=0)lpExpanded.splice(idx,1);else lpExpanded.push(i);
  localStorage.setItem('ns_lp_expanded',JSON.stringify(lpExpanded));renderLearningPath();
}
function toggleLPResource(id){
  var idx=lpDone.indexOf(id);
  if(idx>=0)lpDone.splice(idx,1);
  else{lpDone.push(id);showToast('Resource completed! &#128218;',{type:'success',icon:'&#10003;',duration:2000});}
  localStorage.setItem('ns_lp_done',JSON.stringify(lpDone));renderLearningPath();
}
"@

$content = ApplyVersion $content 'NeuroScan v143 - Learning Path' $css143 $html143 $featMarker143 $featRepl143 $js143
WriteVersion $content 143
# ============================================================
# V144 - ADVOCACY TOOLKIT
# ============================================================
$css144 = @"
.advocacy-panel{top:60px;right:320px;width:440px;max-height:84vh;overflow-y:auto}
.adv-impact-bar{background:rgba(80,232,160,.04);border:1px solid rgba(80,232,160,.2);border-radius:8px;padding:10px;margin-bottom:12px}
.adv-impact-title{font-size:9px;letter-spacing:.1em;color:var(--dim);text-transform:uppercase;margin-bottom:6px}
.adv-impact-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:6px}
.adv-impact-item{text-align:center}
.adv-impact-num{font-size:18px;font-weight:700;color:var(--accent2)}
.adv-impact-label{font-size:8px;color:var(--dim);letter-spacing:.04em}
.adv-impact-input{background:rgba(58,184,255,.06);border:1px solid var(--b1);border-radius:4px;color:var(--text);font-size:11px;padding:3px 6px;width:70px;font-family:var(--font-mono);text-align:center}
.adv-tabs{display:flex;gap:4px;margin-bottom:10px}
.adv-tab{flex:1;padding:6px;font-size:10px;border:1px solid var(--b1);border-radius:8px;cursor:pointer;color:var(--dim);transition:var(--trans);text-align:center;font-weight:600}
.adv-tab.on,.adv-tab:hover{background:rgba(80,232,160,.1);color:var(--accent2);border-color:rgba(80,232,160,.3)}
.adv-section{display:none}
.adv-section.on{display:block}
.adv-template{background:rgba(0,0,0,.3);border:1px solid var(--b1);border-radius:6px;padding:10px;margin-bottom:8px;position:relative}
.adv-template-platform{font-size:9px;letter-spacing:.08em;color:var(--accent);font-weight:600;margin-bottom:4px;text-transform:uppercase}
.adv-template-text{font-size:11px;color:var(--text);line-height:1.6;white-space:pre-wrap;word-break:break-word}
.adv-copy-btn{position:absolute;top:8px;right:8px;padding:3px 8px;font-size:9px;background:rgba(58,184,255,.1);border:1px solid var(--b2);border-radius:4px;cursor:pointer;color:var(--accent);transition:var(--trans)}
.adv-copy-btn:hover{background:rgba(58,184,255,.22)}
.adv-donate-item{display:flex;align-items:center;justify-content:space-between;padding:8px 10px;background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:6px;margin-bottom:6px}
.adv-donate-name{font-size:11px;font-weight:600;color:var(--text)}
.adv-donate-desc{font-size:9px;color:var(--dim);margin-top:1px}
.adv-donate-link{font-size:10px;color:var(--accent);font-weight:600;padding:3px 8px;border:1px solid var(--b2);border-radius:4px;cursor:pointer}
.adv-community-item{padding:7px 10px;background:rgba(58,184,255,.03);border:1px solid var(--b1);border-radius:6px;margin-bottom:5px}
.adv-create-tip{padding:8px 10px;background:rgba(80,232,160,.04);border-left:3px solid rgba(80,232,160,.4);border-radius:0 6px 6px 0;margin-bottom:6px;font-size:11px;color:var(--text);line-height:1.5}
.adv-viral{background:rgba(255,200,74,.05);border:1px solid rgba(255,200,74,.2);border-radius:8px;padding:10px;margin-top:10px}
.adv-viral-title{font-size:9px;letter-spacing:.1em;color:var(--gold);text-transform:uppercase;margin-bottom:6px}
"@

$html144 = @"
<div id="advocacy-panel" class="feature-panel advocacy-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128227; ADVOCACY TOOLKIT</span>
    <span class="fp-sub">Advance the digital immortality movement</span>
    <span class="fp-close" onclick="toggleAdvocacyPanel()">&#215;</span>
  </div>
  <div class="adv-impact-bar">
    <div class="adv-impact-title">Your Impact Score</div>
    <div class="adv-impact-grid">
      <div class="adv-impact-item"><input class="adv-impact-input" id="adv-hours" type="number" value="0" min="0" oninput="calcAdvImpact()"><div class="adv-impact-label">HOURS</div></div>
      <div class="adv-impact-item"><input class="adv-impact-input" id="adv-dollars" type="number" value="0" min="0" oninput="calcAdvImpact()"><div class="adv-impact-label">\$ DONATED</div></div>
      <div class="adv-impact-item"><input class="adv-impact-input" id="adv-people" type="number" value="0" min="0" oninput="calcAdvImpact()"><div class="adv-impact-label">INFORMED</div></div>
    </div>
    <div id="adv-impact-score" style="text-align:center;margin-top:8px;font-size:11px;color:var(--dim)">Enter your advocacy activity above</div>
  </div>
  <div class="adv-tabs">
    <div class="adv-tab on" onclick="switchAdvTab('share')">&#128279; Share</div>
    <div class="adv-tab" onclick="switchAdvTab('donate')">&#128176; Donate</div>
    <div class="adv-tab" onclick="switchAdvTab('community')">&#127968; Participate</div>
    <div class="adv-tab" onclick="switchAdvTab('create')">&#9999; Create</div>
  </div>
  <div id="adv-share" class="adv-section on"></div>
  <div id="adv-donate" class="adv-section"></div>
  <div id="adv-community" class="adv-section"></div>
  <div id="adv-create" class="adv-section"></div>
  <div class="adv-viral" id="adv-viral" style="display:none"></div>
</div>
"@

$featMarker144 = '&#128218; LEARNING</div></div>'
$featRepl144 = '&#128218; LEARNING</div>
  <div class="hb" id="bAdvocacy" onclick="toggleAdvocacyPanel()" style="border-color:rgba(80,232,160,.3);color:rgba(80,232,160,.7)">&#128227; ADVOCACY</div></div>'

$js144 = @"
// === V144 ADVOCACY TOOLKIT ===
var advocacyOpen=false;
var advData=JSON.parse(localStorage.getItem('ns_adv_data')||'{"hours":0,"dollars":0,"people":0}');
var ADV_TEMPLATES=[
  {platform:'Twitter / X',text:'The scientific consensus on brain preservation is shifting.\n\nCryoprotectants can now preserve the connectome of a mammalian brain with electron-microscopy verifiable fidelity.\n\nWhole brain emulation might be possible. Are you thinking about this?\n\nLearn: carboncopies.org #WBE #DigitalImmortality #Neuroscience'},
  {platform:'LinkedIn',text:"I've been studying the science of digital immortality.\n\nWhole Brain Emulation (WBE) is the theoretical process of scanning and simulating a human brain at sufficient resolution to reproduce behavior. Carboncopies Foundation is mapping the technical roadmap.\n\nWhether you believe it's possible or not, the questions about consciousness, identity, and what it means to be human are worth exploring. What are your thoughts?"},
  {platform:'Reddit',text:'Discussion: Current state of Whole Brain Emulation research [2026]\n\nKey orgs working on this: Carboncopies Foundation (roadmap), Brain Preservation Foundation (preservation prizes)\n\nMajor recent milestones: aldehyde-stabilized cryopreservation, high-res connectomics\n\nWhat do you think is the biggest technical blocker? Scanning resolution? Computational scale? Incomplete neuroscience?'}
];
var ADV_DONATE=[
  {name:'Carboncopies Foundation',desc:'WBE research and roadmap coordination',url:'carboncopies.org/donate',suggested:'$20/month'},
  {name:'Brain Preservation Foundation',desc:'Preservation research prizes and advocacy',url:'brainpreservation.org',suggested:'$10/month'},
  {name:'Alcor Research Fund',desc:'Cryonics R&D and procedure improvement',url:'alcor.org/donate',suggested:'varies'},
  {name:'SENS Research Foundation',desc:'Aging reversal biotechnology',url:'sens.org/donate',suggested:'$25/month'},
  {name:'MIRI (AI Safety)',desc:'Machine Intelligence Research Institute',url:'intelligence.org/donate',suggested:'$15/month'}
];
function toggleAdvocacyPanel(){
  advocacyOpen=!advocacyOpen;
  var p=document.getElementById('advocacy-panel'),b=document.getElementById('bAdvocacy');
  if(p)p.classList.toggle('vis',advocacyOpen);if(b)b.classList.toggle('on',advocacyOpen);
  if(advocacyOpen)renderAdvocacyPanel();
}
function renderAdvocacyPanel(){
  var hi=document.getElementById('adv-hours'),di=document.getElementById('adv-dollars'),pi=document.getElementById('adv-people');
  if(hi)hi.value=advData.hours||0;if(di)di.value=advData.dollars||0;if(pi)pi.value=advData.people||0;
  var shareEl=document.getElementById('adv-share');
  if(shareEl)shareEl.innerHTML='<div style="font-size:11px;color:var(--dim);margin-bottom:8px;line-height:1.6">Pre-written posts to copy and share:</div>'
    +ADV_TEMPLATES.map(function(t,i){
      return '<div class="adv-template"><div class="adv-template-platform">'+t.platform+'</div>'
        +'<div class="adv-template-text" id="adv-tmpl-'+i+'">'+t.text+'</div>'
        +'<div class="adv-copy-btn" onclick="copyAdvTemplate('+i+')">Copy</div></div>';
    }).join('');
  var donateEl=document.getElementById('adv-donate');
  if(donateEl)donateEl.innerHTML=ADV_DONATE.map(function(o){
    return '<div class="adv-donate-item"><div><div class="adv-donate-name">'+o.name+'</div>'
      +'<div class="adv-donate-desc">'+o.desc+'</div>'
      +'<div style="font-size:9px;color:var(--accent2);margin-top:2px">Suggested: '+o.suggested+'</div></div>'
      +'<div class="adv-donate-link" onclick="showToast(\''+o.url+'\',{duration:2000})">&#9654; Visit</div></div>';
  }).join('');
  var communityEl=document.getElementById('adv-community');
  if(communityEl)communityEl.innerHTML=[
    {name:'r/digitalimmortality',desc:'Reddit community for digital mind discussions'},
    {name:'Carboncopies Forum',desc:'Technical discussions on WBE research and roadmap'},
    {name:'WBE Mailing List',desc:'Academic list for whole brain emulation researchers'},
    {name:'r/cryonics',desc:'Cryonics community - practical preservation discussions'},
    {name:'LessWrong',desc:'Rationalist community with extensive digital mind discussions'},
    {name:'Foresight Institute',desc:'Annual conferences on nanotechnology and brain preservation'}
  ].map(function(c){
    return '<div class="adv-community-item"><div style="font-size:11px;font-weight:600;color:var(--text)">'+c.name+'</div>'
      +'<div style="font-size:10px;color:var(--dim);margin-top:2px">'+c.desc+'</div></div>';
  }).join('');
  var createEl=document.getElementById('adv-create');
  if(createEl)createEl.innerHTML='<div style="font-size:11px;color:var(--dim);margin-bottom:8px">Ways to create impact:</div>'
    +['Write: blog post about why you signed up for cryonics','Create: YouTube video explaining WBE to general audience','Talk: lightning talk at a local tech or science meetup','Write: sci-fi short story from a digital mind perspective','Organize: local discussion group on digital immortality','Translate: WBE resources into another language','Build: an educational tool or visualization about brain emulation','Advocate: contact your local representative about research funding']
    .map(function(t){return '<div class="adv-create-tip">&#9654; '+t+'</div>';}).join('');
  calcAdvImpact();
}
function switchAdvTab(tab){
  document.querySelectorAll('.adv-tab').forEach(function(t,i){
    t.classList.toggle('on',['share','donate','community','create'][i]===tab);
  });
  document.querySelectorAll('.adv-section').forEach(function(s){s.classList.remove('on');});
  var el=document.getElementById('adv-'+tab);if(el)el.classList.add('on');
}
function copyAdvTemplate(i){
  var el=document.getElementById('adv-tmpl-'+i);if(!el)return;
  navigator.clipboard.writeText(el.textContent).then(function(){
    showToast('Copied to clipboard!',{type:'success',icon:'&#128279;',duration:2000});
  }).catch(function(){showToast('Select text above and copy manually.',{duration:2500});});
}
function calcAdvImpact(){
  var hours=parseFloat((document.getElementById('adv-hours')||{}).value||0);
  var dollars=parseFloat((document.getElementById('adv-dollars')||{}).value||0);
  var people=parseFloat((document.getElementById('adv-people')||{}).value||0);
  advData={hours:hours,dollars:dollars,people:people};
  localStorage.setItem('ns_adv_data',JSON.stringify(advData));
  var score=Math.round(hours*5+dollars*0.1+people*10);
  var el=document.getElementById('adv-impact-score');
  if(el)el.innerHTML='Impact score: <b style="color:var(--accent2);font-size:14px">'+score+'</b> pts &mdash; '
    +(score===0?'Start contributing!'
    :score<50?'&#127959; Getting started!'
    :score<200?'&#127775; Making a difference!'
    :score<500?'&#128293; Significant impact!'
    :'&#129351; Movement leader!');
  var vEl=document.getElementById('adv-viral');
  if(vEl){
    if(people>0){
      var gen2=Math.round(people*1.5),gen3=Math.round(gen2*1.5);
      vEl.style.display='block';
      vEl.innerHTML='<div class="adv-viral-title">&#127758; Viral Coefficient Estimate</div>'
        +'<div style="font-size:11px;color:var(--dim);line-height:1.6">You informed <b style="color:var(--gold)">'+people+'</b> people. If each informs 1.5 more: 2nd-gen ~<b style="color:var(--gold)">'+gen2+'</b>, 3rd-gen ~<b style="color:var(--gold)">'+gen3+'</b>. Total cascade: <b style="color:var(--accent2)">~'+(Math.round(people)+gen2+gen3)+'</b> minds.</div>';
    } else vEl.style.display='none';
  }
}
"@

$content = ApplyVersion $content 'NeuroScan v144 - Advocacy' $css144 $html144 $featMarker144 $featRepl144 $js144
WriteVersion $content 144
# ============================================================
# V145 - SURVIVAL STRATEGY
# ============================================================
$css145 = @"
.survival-panel{top:60px;right:740px;width:460px;max-height:85vh;overflow-y:auto}
.sv-inputs{background:rgba(58,184,255,.03);border:1px solid var(--b1);border-radius:8px;padding:12px;margin-bottom:12px}
.sv-inputs-title{font-size:9px;letter-spacing:.1em;color:var(--dim);text-transform:uppercase;margin-bottom:10px}
.sv-input-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px}
.sv-input-item{display:flex;flex-direction:column;gap:3px}
.sv-input-label{font-size:9px;color:var(--dim);letter-spacing:.05em}
.sv-input-field{background:rgba(58,184,255,.06);border:1px solid var(--b1);border-radius:4px;color:var(--text);font-size:11px;padding:4px 8px;font-family:var(--font-mono)}
.sv-input-field:focus{outline:none;border-color:var(--b2)}
.sv-calc-btn{width:100%;padding:9px;background:rgba(58,184,255,.1);border:2px solid var(--b2);border-radius:7px;color:var(--accent);font-size:11px;font-weight:700;cursor:pointer;letter-spacing:.06em;transition:var(--trans);text-align:center;margin-bottom:12px}
.sv-calc-btn:hover{background:rgba(58,184,255,.2)}
.sv-score-bar{background:rgba(80,232,160,.05);border:1px solid rgba(80,232,160,.2);border-radius:8px;padding:12px;margin-bottom:12px;text-align:center}
.sv-survivability{font-size:36px;font-weight:700;color:var(--accent2)}
.sv-tier-badge{display:inline-block;padding:4px 14px;border-radius:12px;font-size:10px;font-weight:700;margin-top:6px;letter-spacing:.06em}
.sv-strategy{border-radius:10px;padding:14px;margin-bottom:8px;border:2px solid}
.sv-strategy.recommended{border-color:rgba(80,232,160,.5);background:rgba(80,232,160,.06)}
.sv-strategy.alt{border-color:var(--b1);background:rgba(58,184,255,.03);opacity:.85}
.sv-strategy-header{display:flex;align-items:center;gap:8px;margin-bottom:6px}
.sv-strategy-icon{font-size:20px;flex-shrink:0}
.sv-strategy-name{font-size:13px;font-weight:700;color:var(--text);flex:1}
.sv-strategy-tag{font-size:8px;padding:2px 8px;border-radius:8px;background:rgba(80,232,160,.2);color:var(--accent2);font-weight:600;border:1px solid rgba(80,232,160,.3)}
.sv-strategy-desc{font-size:11px;color:var(--dim);line-height:1.6;margin-bottom:8px}
.sv-action-plan{background:rgba(0,0,0,.3);border-radius:6px;padding:8px}
.sv-action-plan-title{font-size:9px;letter-spacing:.08em;color:var(--accent);text-transform:uppercase;margin-bottom:6px;font-weight:600}
.sv-action-step{display:flex;gap:6px;align-items:flex-start;margin-bottom:4px}
.sv-action-month{font-size:9px;color:var(--gold);font-weight:700;width:52px;flex-shrink:0;padding-top:1px}
.sv-action-text{font-size:10px;color:var(--text);line-height:1.5;flex:1}
.sv-timeline{margin-top:12px;background:rgba(0,0,0,.3);border:1px solid var(--b1);border-radius:8px;padding:10px}
.sv-timeline-title{font-size:9px;letter-spacing:.1em;color:var(--dim);text-transform:uppercase;margin-bottom:8px}
"@

$html145 = @"
<div id="survival-panel" class="feature-panel survival-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128249; SURVIVAL STRATEGY</span>
    <span class="fp-sub">Your personalized path to digital immortality</span>
    <span class="fp-close" onclick="toggleSurvivalPanel()">&#215;</span>
  </div>
  <div class="sv-inputs">
    <div class="sv-inputs-title">&#128101; Your Profile</div>
    <div class="sv-input-grid">
      <div class="sv-input-item"><label class="sv-input-label">Age</label><input type="number" class="sv-input-field" id="sv-age" value="30" min="1" max="99"></div>
      <div class="sv-input-item"><label class="sv-input-label">Health status</label><select class="sv-input-field" id="sv-health"><option value="excellent">Excellent</option><option value="good" selected>Good</option><option value="fair">Fair</option><option value="poor">Poor</option></select></div>
      <div class="sv-input-item"><label class="sv-input-label">Financial situation</label><select class="sv-input-field" id="sv-finance"><option value="wealthy">Wealthy (\$500K+)</option><option value="comfortable" selected>Comfortable (\$100K+)</option><option value="middle">Middle class</option><option value="limited">Limited income</option></select></div>
      <div class="sv-input-item"><label class="sv-input-label">Country / Region</label><select class="sv-input-field" id="sv-country"><option value="usa" selected>USA</option><option value="europe">Europe</option><option value="other_dev">Other developed</option><option value="developing">Developing nation</option></select></div>
    </div>
  </div>
  <div class="sv-calc-btn" onclick="calcSurvivalStrategy()">&#9881; CALCULATE MY STRATEGY</div>
  <div id="sv-results" style="display:none">
    <div class="sv-score-bar">
      <div class="sv-survivability" id="sv-score">0</div>
      <div style="font-size:9px;color:var(--dim);letter-spacing:.1em;text-transform:uppercase;margin-top:2px">SURVIVABILITY SCORE</div>
      <div id="sv-tier-badge" class="sv-tier-badge" style="background:rgba(80,232,160,.15);color:var(--accent2)">CALCULATING</div>
      <div id="sv-score-explain" style="font-size:10px;color:var(--dim);margin-top:6px"></div>
    </div>
    <div id="sv-strategies"></div>
    <div class="sv-timeline" id="sv-timeline" style="display:none"></div>
  </div>
</div>
"@

$featMarker145 = '&#128227; ADVOCACY</div></div>'
$featRepl145 = '&#128227; ADVOCACY</div>
  <div class="hb" id="bSurvival" onclick="toggleSurvivalPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#128249; STRATEGY</div></div>'

$js145 = @"
// === V145 SURVIVAL STRATEGY ===
var survivalOpen=false;
var SV_STRATS=[
  {id:'cryo_bridge',name:'Cryonics Bridge',icon:'&#10052;',
   desc:'Sign up for cryonics now, stay healthy, and wait for upload technology. The most reliable strategy for most people. Available today at \$28K-\$220K.',
   suit:{ageMax:72,health:['excellent','good','fair'],finance:['wealthy','comfortable','middle']},
   plan:[
     {month:'Month 1',action:'Research and select cryonics provider (Alcor or Cryonics Institute).'},
     {month:'Month 2',action:'Begin membership application. Get a medical physical exam.'},
     {month:'Month 3',action:'Complete sign-up. Order emergency card. Update legal documents.'},
     {month:'Month 6',action:'Fund first year of membership. Notify family of your wishes.'},
     {month:'Year 1',action:'Annual review: health checkup, confirm membership active, update digital estate.'}
   ]},
  {id:'longevity',name:'Aggressive Longevity',icon:'&#9889;',
   desc:'Pursue aggressive anti-aging interventions to extend life until upload technology arrives. Metformin, senolytics, continuous biomarker monitoring.',
   suit:{ageMax:60,health:['excellent','good'],finance:['wealthy','comfortable']},
   plan:[
     {month:'Month 1',action:'Find longevity-focused physician. Get comprehensive bloodwork + genomics.'},
     {month:'Month 2',action:'Begin evidence-based protocol: optimize sleep, exercise, diet.'},
     {month:'Month 3',action:'Discuss pharmaceutical interventions with physician.'},
     {month:'Month 6',action:'Join longevity research community. Consider clinical trials.'},
     {month:'Year 1',action:'Track biomarkers quarterly. Adjust protocol based on data.'}
   ]},
  {id:'bci_path',name:'Early BCI Enhancement',icon:'&#128301;',
   desc:'Position to adopt brain-computer interfaces as they become available (2030s+). Gradually create detailed digital records of your neural patterns.',
   suit:{ageMax:50,health:['excellent','good'],finance:['wealthy','comfortable']},
   plan:[
     {month:'Month 1',action:'Follow Neuralink and Synchron clinical trials. Join waitlists.'},
     {month:'Month 2',action:'Build technical skills: neuroscience, ML, brain signal processing.'},
     {month:'Month 6',action:'Network with BCI researchers and companies actively.'},
     {month:'Year 1',action:'Position as early adopter. Monitor regulatory approvals.'}
   ]},
  {id:'collective',name:'Collective Approach',icon:'&#127968;',
   desc:'Join or build a community dedicated to accelerating WBE technology. Pool resources, advocate, fund research collectively.',
   suit:{ageMax:99,health:['excellent','good','fair','poor'],finance:['comfortable','middle','limited']},
   plan:[
     {month:'Month 1',action:'Join Carboncopies Forum and r/digitalimmortality.'},
     {month:'Month 2',action:'Begin donating to WBE research (\$20+/month to Carboncopies).'},
     {month:'Month 3',action:'Find local people interested in digital immortality. Start meetup.'},
     {month:'Month 6',action:'Volunteer for advocacy: write articles, give talks.'},
     {month:'Year 1',action:'Assess measurable impact: recruits, donations, media coverage.'}
   ]},
  {id:'digital_legacy',name:'Digital Legacy',icon:'&#128249;',
   desc:'If upload in your lifetime seems unlikely, create the richest possible digital legacy: complete life documentation, values, memories, creative works.',
   suit:{ageMax:99,health:['fair','poor'],finance:['middle','limited']},
   plan:[
     {month:'Month 1',action:'Begin intensive Memory Journal (50+ life memories). Record life story.'},
     {month:'Month 2',action:'Complete personality assessment, values ranking, skills inventory.'},
     {month:'Month 3',action:'Write legacy letters to future digital self and descendants.'},
     {month:'Month 6',action:'Complete digital estate plan. Ensure 3x backups of all files.'},
     {month:'Year 1',action:'Create video autobiography. Expand all records comprehensively.'}
   ]}
];
function toggleSurvivalPanel(){
  survivalOpen=!survivalOpen;
  var p=document.getElementById('survival-panel'),b=document.getElementById('bSurvival');
  if(p)p.classList.toggle('vis',survivalOpen);if(b)b.classList.toggle('on',survivalOpen);
}
function calcSurvivalStrategy(){
  var age=parseInt((document.getElementById('sv-age')||{}).value||30);
  var health=(document.getElementById('sv-health')||{}).value||'good';
  var finance=(document.getElementById('sv-finance')||{}).value||'comfortable';
  var country=(document.getElementById('sv-country')||{}).value||'usa';
  var hScore={excellent:25,good:20,fair:12,poor:6}[health]||15;
  var fScore={wealthy:25,comfortable:20,middle:12,limited:6}[finance]||12;
  var aScore=age<35?25:age<50?21:age<65?16:10;
  var cScore={usa:15,europe:14,other_dev:12,developing:8}[country]||10;
  var score=hScore+fScore+aScore+cScore;
  var tier=score>=75?'EXCELLENT':score>=60?'STRONG':score>=45?'MODERATE':'CHALLENGING';
  var tierColor={EXCELLENT:'var(--accent2)',STRONG:'var(--accent)',MODERATE:'var(--gold)',CHALLENGING:'var(--red)'}[tier];
  document.getElementById('sv-results').style.display='block';
  var sEl=document.getElementById('sv-score');if(sEl)sEl.textContent=score;
  var tbEl=document.getElementById('sv-tier-badge');
  if(tbEl){tbEl.textContent=tier+' OUTLOOK';tbEl.style.color=tierColor;tbEl.style.background=tierColor+'20';tbEl.style.borderColor=tierColor+'55';}
  var seEl=document.getElementById('sv-score-explain');
  if(seEl)seEl.textContent={
    EXCELLENT:'Your profile gives strong chances at digital immortality with multiple viable paths.',
    STRONG:'Good chances. Cryonics bridge plus longevity strategy is your best bet.',
    MODERATE:'Achievable with focused effort. Prioritize cryonics signup and digital legacy.',
    CHALLENGING:'Focus on what you can control: digital legacy and collective advocacy.'
  }[tier]||'';
  var ranked=SV_STRATS.slice().sort(function(a,b){
    function suit(st){
      var sc=0;
      if(st.suit.ageMax&&age<=st.suit.ageMax)sc+=3;
      if(st.suit.health&&st.suit.health.indexOf(health)>=0)sc+=3;
      if(st.suit.finance&&st.suit.finance.indexOf(finance)>=0)sc+=2;
      return sc;
    }
    return suit(b)-suit(a);
  });
  var stEl=document.getElementById('sv-strategies');
  if(stEl)stEl.innerHTML=ranked.map(function(s,i){
    var isRec=i===0;
    return '<div class="sv-strategy '+(isRec?'recommended':'alt')+'">'
      +'<div class="sv-strategy-header">'
      +'<div class="sv-strategy-icon">'+s.icon+'</div>'
      +'<div class="sv-strategy-name">'+s.name+'</div>'
      +(isRec?'<div class="sv-strategy-tag">&#9733; RECOMMENDED</div>':'')
      +'</div>'
      +'<div class="sv-strategy-desc">'+s.desc+'</div>'
      +(isRec?'<div class="sv-action-plan"><div class="sv-action-plan-title">Year 1 Action Plan</div>'
        +s.plan.map(function(step){
          return '<div class="sv-action-step"><div class="sv-action-month">'+step.month+'</div><div class="sv-action-text">'+step.action+'</div></div>';
        }).join('')+'</div>':'')
      +'</div>';
  }).join('');
  var tlEl=document.getElementById('sv-timeline');
  if(tlEl){
    tlEl.style.display='block';
    var curYear=new Date().getFullYear();
    var uploadYear=Math.min(2080,2060+Math.round((50-score)*0.4));
    var events=[
      {year:curYear,event:'Start your strategy - TODAY',color:'var(--accent2)'},
      {year:2030,event:'Advanced BCI first generation (N1 implants)',color:'var(--accent)'},
      {year:2035,event:'High-resolution brain scanning routine',color:'var(--accent)'},
      {year:uploadYear-10,event:'Early upload experiments (animal models)',color:'var(--gold)'},
      {year:uploadYear,event:'Human upload: estimated availability',color:'var(--gold)'},
    ].sort(function(a,b){return a.year-b.year;});
    tlEl.innerHTML='<div class="sv-timeline-title">&#128197; Technology Timeline for Your Profile</div>'
      +'<div style="display:flex;flex-direction:column;gap:6px">'
      +events.map(function(e){
        return '<div style="display:flex;gap:8px;align-items:flex-start">'
          +'<div style="font-size:10px;font-weight:700;color:'+e.color+';width:38px;flex-shrink:0">'+e.year+'</div>'
          +'<div style="font-size:10px;color:var(--dim);flex:1;border-left:1px solid var(--b1);padding-left:8px;padding:2px 0 2px 8px">'+e.event+'</div></div>';
      }).join('')+'</div>';
  }
}
"@

$content = ApplyVersion $content 'NeuroScan v145 - Survival Strategy' $css145 $html145 $featMarker145 $featRepl145 $js145
WriteVersion $content 145

Write-Host "`n=== ALL VERSIONS BUILT SUCCESSFULLY ==="