$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$base = "c:\Users\bookf\OneDrive\Desktop\brain"

function WriteV($ver, $content) {
    $dir = "$base\$ver"
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    $path = "$dir\index.html"
    [System.IO.File]::WriteAllText($path, $content, $utf8NoBom)
    $bytes = [System.IO.File]::ReadAllBytes($path)
    $ok = if ($bytes[0] -eq 60) { "OK" } else { "FAIL(byte=$($bytes[0]))" }
    $size = (Get-Item $path).Length
    Write-Host "v$ver`: $size bytes, first-byte=$($bytes[0]) [$ok]"
}

function AddAfterBtn($content, $searchId, $newHtml) {
    # Finds id="searchId" button div and appends newHtml after its </div>
    return $content -replace "(id=""$searchId""[^>]*>[^<]*</div>)", "`$1$newHtml"
}

function AddBeforeBodyEnd($content, $newHtml) {
    return $content.Replace('</body>', $newHtml + '</body>')
}

# ============================================================
# V176 — LONGEVITY PROTOCOLS
# ============================================================
Write-Host "Building v176..."
$content = [System.IO.File]::ReadAllText("$base\175\index.html")
$content = $content.Replace('<title>NeuroScan v175 — Future Letter</title>', '<title>NeuroScan v176 — Longevity Protocols</title>')

# Feat-bar: add LONGEVITY category after bFutureLetter
$content = $content.Replace('&#128140; FUTURE LETTER</div>', '&#128140; FUTURE LETTER</div><div class="feat-sep"></div><span class="feat-cat">LONGEVITY</span><div class="hb" id="bLongevityProto" onclick="toggleLongevityProtoPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#128138; PROTOCOLS</div>')

$add176 = @'
<style>
.longevity-proto-panel{top:60px;right:10px;width:520px;max-height:82vh;overflow-y:auto}
.lp-filter{display:flex;gap:6px;margin-bottom:10px;flex-wrap:wrap}
.lp-filter-btn{padding:3px 10px;font-size:10px;border-radius:12px;border:1px solid var(--b1);color:var(--dim);background:transparent;cursor:pointer;transition:.15s}
.lp-filter-btn.on{background:rgba(255,200,74,.15);color:var(--gold);border-color:rgba(255,200,74,.4)}
.lp-card{background:var(--panel2);border:1px solid var(--b1);border-radius:8px;padding:10px 12px;margin-bottom:8px;transition:.2s}
.lp-card:hover{border-color:var(--b2)}
.lp-card-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:6px}
.lp-card-name{font-size:12px;font-weight:700;color:var(--accent)}
.lp-stars{color:var(--gold);font-size:11px;letter-spacing:1px}
.lp-mech{font-size:10px;color:var(--dim);margin-bottom:4px}
.lp-dosage{font-size:10px;color:var(--text);margin-bottom:4px}
.lp-evidence{font-size:10px;color:var(--accent2);margin-bottom:4px}
.lp-risk{font-size:10px;color:var(--red);background:rgba(255,85,104,.06);border-radius:4px;padding:3px 6px;margin-top:4px}
.lp-tag{display:inline-block;padding:2px 7px;border-radius:10px;font-size:9px;font-weight:600;letter-spacing:.05em;margin-right:4px}
.lp-tag-drug{background:rgba(255,200,74,.15);color:var(--gold)}
.lp-tag-life{background:rgba(80,232,160,.12);color:var(--accent2)}
</style>
<div id="longevity-proto-panel" class="feature-panel longevity-proto-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128138; LONGEVITY PROTOCOLS</span>
    <span class="fp-sub">6 evidence-based interventions — mechanisms, dosage, risks</span>
    <span class="fp-close" onclick="toggleLongevityProtoPanel()">&#215;</span>
  </div>
  <div class="lp-filter">
    <button class="lp-filter-btn on" onclick="lpFilter(0)">ALL</button>
    <button class="lp-filter-btn" onclick="lpFilter(5)">&#9733;&#9733;&#9733;&#9733;&#9733; 5-star</button>
    <button class="lp-filter-btn" onclick="lpFilter(4)">&#9733;&#9733;&#9733;&#9733; 4+</button>
    <button class="lp-filter-btn" onclick="lpFilter(3)">&#9733;&#9733;&#9733; 3+</button>
  </div>
  <div id="lp-cards"></div>
</div>
<script>
var lpOpen=false, lpMinStars=0;
var LP_DATA=[
  {name:'Caloric Restriction (CR)',tag:'life',stars:4,mech:'Activates AMPK, SIRT1; reduces mTOR signaling; lowers IGF-1. Reduces oxidative stress and inflammation.',dosage:'15-40% reduction from ad-libitum intake. CR mimetics (resveratrol, rapamycin) may replicate effects.',evidence:'Extends lifespan 20-50% in rodents. Human CALERIE trial: CR reduces metabolic risk factors. Biosphere-2 subjects showed profound biomarker improvements.',risk:'Risk of malnutrition, muscle loss, hormonal disruption if too severe. Not recommended during growth or pregnancy.'},
  {name:'Rapamycin (mTOR inhibitor)',tag:'drug',stars:5,mech:'Inhibits mTORC1, the master nutrient sensor. Promotes autophagy, reduces senescent cell accumulation. Most replicated longevity intervention in mice.',dosage:'ITP (Interventional Testing Program): 14 ppm in chow. Human: 1-6mg/week (off-label). Dose timing matters (intermittent dosing preferred).',evidence:'+20-25% lifespan extension in multiple mouse strains even starting late in life. Human studies show immune enhancement in elderly. PEARL trial (2024) ongoing.',risk:'Immunosuppression, impaired wound healing, metabolic effects. Not FDA-approved for longevity. Requires medical supervision.'},
  {name:'NAD+ Precursors (NMN/NR)',tag:'drug',stars:3,mech:'Boosts intracellular NAD+ levels. NAD+ is cofactor for sirtuins (SIRT1-7) and PARP DNA repair enzymes. Declines ~50% from age 20-60.',dosage:'NMN: 250-1000mg/day. NR: 300-1000mg/day. Both raise blood NAD+ but tissue delivery varies.',evidence:'Robust animal data. Human RCTs show NAD+ boost; some show metabolic benefits. Limited longevity endpoint data in humans yet.',risk:'Generally well-tolerated. Some report flushing (NR). Theoretical concern: could fuel cancer cells. Long-term safety data limited.'},
  {name:'Senolytics (Dasatinib + Quercetin)',tag:'drug',stars:3,mech:'Selectively kill senescent cells ("zombie cells") that secrete pro-inflammatory SASP factors. D+Q is the most studied combination.',dosage:'Intermittent: 100mg Dasatinib + 1000mg Quercetin for 2 consecutive days per month (Mayo Clinic protocol).',evidence:'Mayo Clinic pilot (2019): improved physical function in IPF patients. Multiple human trials ongoing (NCT02848131). Animal data: extends healthspan, reduces frailty.',risk:'Dasatinib is a cancer drug with serious side effects. Only use under medical supervision. Quercetin alone is OTC and safer (partial senolytic activity).'},
  {name:'Metformin (TAME Trial)',tag:'drug',stars:4,mech:'AMPK activator. Reduces mitochondrial complex I activity, lowering mTOR. Anti-inflammatory, reduces cancer risk, improves insulin sensitivity.',dosage:'TAME trial: 1500-1700mg/day (standard T2D dose). Also available as extended-release.',evidence:'TAME (Targeting Aging with Metformin): 3000 participants, results expected 2025-2026. Epidemiological data: T2D patients on metformin outlive non-diabetic non-users. Significant mouse lifespan extension.',risk:'GI side effects, B12 depletion. Contraindicated in renal impairment. May reduce exercise adaptation — timing relative to workouts matters.'},
  {name:'High-Intensity Interval Training (HIIT)',tag:'life',stars:5,mech:'Boosts mitochondrial biogenesis (PGC-1α), increases BDNF, telomerase activity, reduces inflammation. Improves VO2max — the #1 predictor of all-cause mortality.',dosage:'2-3x/week: 20-40 min sessions. 4×4 protocol: 4 min at 85-95% HRmax, 3 min recovery. Combine with Zone 2 cardio.',evidence:'Meta-analyses: HIIT reduces all-cause mortality 30-40%. VO2max > 10 METs correlates with 5-year survival equivalent to quitting smoking. RCTs show telomere lengthening.',risk:'Injury risk if volume too high. Start gradually. Not suitable for those with cardiovascular conditions without medical clearance.'}
];
function toggleLongevityProtoPanel(){
  lpOpen=!lpOpen;
  var p=document.getElementById('longevity-proto-panel'),b=document.getElementById('bLongevityProto');
  if(p)p.classList.toggle('vis',lpOpen);if(b)b.classList.toggle('on',lpOpen);
  if(lpOpen)renderLpCards();
}
function lpFilter(min){
  lpMinStars=min;
  document.querySelectorAll('.lp-filter-btn').forEach(function(b,i){b.classList.toggle('on',i===[0,5,4,3].indexOf(min)||(!min&&i===0));});
  renderLpCards();
}
function renderLpCards(){
  var el=document.getElementById('lp-cards');if(!el)return;
  var data=LP_DATA.filter(function(d){return d.stars>=lpMinStars;});
  el.innerHTML=data.map(function(d){
    var stars='&#9733;'.repeat(d.stars)+'&#9734;'.repeat(5-d.stars);
    var tagCls='lp-tag-'+(d.tag==='drug'?'drug':'life');
    return '<div class="lp-card">'
      +'<div class="lp-card-head"><span class="lp-card-name">'+d.name+'</span><span class="lp-stars">'+stars+'</span></div>'
      +'<span class="lp-tag '+tagCls+'">'+(d.tag==='drug'?'PHARMACOLOGICAL':'LIFESTYLE')+'</span>'
      +'<div class="lp-mech"><b style="color:var(--dim);font-size:9px;letter-spacing:.08em">MECHANISM</b><br>'+d.mech+'</div>'
      +'<div class="lp-dosage"><b style="color:var(--dim);font-size:9px;letter-spacing:.08em">DOSAGE / APPROACH</b><br>'+d.dosage+'</div>'
      +'<div class="lp-evidence"><b style="color:var(--dim);font-size:9px;letter-spacing:.08em">HUMAN EVIDENCE</b><br>'+d.evidence+'</div>'
      +'<div class="lp-risk">&#9888; RISKS: '+d.risk+'</div>'
      +'</div>';
  }).join('');
}
</script>
'@

$content = AddBeforeBodyEnd $content $add176
WriteV 176 $content

# ============================================================
# V177 — BRAIN AGE CALCULATOR
# ============================================================
Write-Host "Building v177..."
$content = [System.IO.File]::ReadAllText("$base\176\index.html")
$content = $content.Replace('<title>NeuroScan v176 — Longevity Protocols</title>', '<title>NeuroScan v177 — Brain Age</title>')
$content = AddAfterBtn $content "bLongevityProto" '<div class="hb" id="bBrainAge" onclick="toggleBrainAgePanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#129504; BRAIN AGE</div>'

$add177 = @'
<style>
.brain-age-panel{top:60px;right:10px;width:480px;max-height:82vh;overflow-y:auto}
.ba-q{background:var(--panel2);border:1px solid var(--b1);border-radius:7px;padding:9px 12px;margin-bottom:7px}
.ba-qlabel{font-size:11px;color:var(--text);margin-bottom:7px;line-height:1.4}
.ba-slider{width:100%;accent-color:var(--accent)}
.ba-slider-val{font-size:10px;color:var(--accent);text-align:right;margin-top:2px}
.ba-result{background:linear-gradient(135deg,rgba(255,200,74,.08),rgba(58,184,255,.08));border:1px solid var(--b2);border-radius:10px;padding:14px;margin-top:12px;display:none}
.ba-result.vis{display:block}
.ba-age-display{display:flex;gap:20px;align-items:center;margin-bottom:10px}
.ba-age-num{font-size:36px;font-weight:800;line-height:1}
.ba-age-chron{color:var(--dim);font-size:14px}
.ba-age-brain{color:var(--gold);font-size:14px}
.ba-gap{font-size:12px;padding:6px 10px;border-radius:6px;margin-bottom:8px}
.ba-gap.younger{background:rgba(80,232,160,.12);color:var(--accent2)}
.ba-gap.older{background:rgba(255,85,104,.1);color:var(--red)}
.ba-improvements{font-size:11px;color:var(--text);line-height:1.6}
.ba-weakest{background:rgba(255,85,104,.08);border-radius:6px;padding:8px;margin-top:6px}
.ba-weakest-title{font-size:9px;letter-spacing:.1em;color:var(--red);margin-bottom:4px}
</style>
<div id="brain-age-panel" class="feature-panel brain-age-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#129504; BRAIN AGE CALCULATOR</span>
    <span class="fp-sub">10 lifestyle factors → estimated brain age vs chronological age</span>
    <span class="fp-close" onclick="toggleBrainAgePanel()">&#215;</span>
  </div>
  <div style="font-size:11px;color:var(--dim);margin-bottom:10px">Enter your chronological age, then answer 10 lifestyle questions. Score 0-10 per question.</div>
  <div class="ba-q">
    <div class="ba-qlabel">Your chronological age (years)</div>
    <input type="number" id="ba-chron-age" value="35" min="18" max="100" style="width:80px;background:var(--panel);border:1px solid var(--b1);color:var(--text);padding:4px 8px;border-radius:4px;font-size:13px">
  </div>
  <div id="ba-questions"></div>
  <button onclick="calcBrainAge()" style="width:100%;margin-top:8px;padding:9px;background:rgba(58,184,255,.12);border:1px solid var(--b2);color:var(--accent);border-radius:7px;font-size:12px;font-weight:600;cursor:pointer;letter-spacing:.06em">CALCULATE BRAIN AGE</button>
  <div id="ba-result" class="ba-result"></div>
</div>
<script>
var brainAgeOpen=false;
var BA_QS=[
  {q:'Sleep hours per night (7-9 = 10)',low:'<5 hrs',high:'8+ hrs'},
  {q:'Exercise days per week (5+ = 10)',low:'0 days',high:'5+ days'},
  {q:'Alcohol units per week (0 = 10, 14+ = 0)',low:'Heavy drinker',high:'Abstainer'},
  {q:'Stress level (low stress = 10)',low:'Chronically stressed',high:'Low stress'},
  {q:'Social connection quality (close relationships = 10)',low:'Isolated',high:'Strong connections'},
  {q:'Cognitive challenge frequency (daily learning = 10)',low:'No challenges',high:'Daily learning'},
  {q:'Diet quality: whole foods, low ultra-processed (10 = ideal)',low:'Fast food daily',high:'Mediterranean diet'},
  {q:'Meditation / mindfulness practice (daily = 10)',low:'Never',high:'Daily 20+ min'},
  {q:'Non-smoker (10 = never smoked, 0 = current smoker)',low:'Current smoker',high:'Never smoked'},
  {q:'Healthy BMI estimate (18-25 = 10)',low:'Obese BMI 35+',high:'BMI 20-23'}
];
var baScores=new Array(10).fill(5);
function toggleBrainAgePanel(){
  brainAgeOpen=!brainAgeOpen;
  var p=document.getElementById('brain-age-panel'),b=document.getElementById('bBrainAge');
  if(p)p.classList.toggle('vis',brainAgeOpen);if(b)b.classList.toggle('on',brainAgeOpen);
  if(brainAgeOpen)renderBaQs();
}
function renderBaQs(){
  var el=document.getElementById('ba-questions');if(!el)return;
  el.innerHTML=BA_QS.map(function(q,i){
    return '<div class="ba-q">'
      +'<div class="ba-qlabel">'+(i+1)+'. '+q.q+'</div>'
      +'<div style="display:flex;align-items:center;gap:8px;font-size:9px;color:var(--dim)">'
      +'<span>'+q.low+'</span>'
      +'<input type="range" class="ba-slider" min="0" max="10" value="'+baScores[i]+'" oninput="baScores['+i+']=+this.value;document.getElementById(\'ba-v'+i+'\').textContent=this.value">'
      +'<span>'+q.high+'</span>'
      +'<span id="ba-v'+i+'" style="min-width:20px;color:var(--accent);font-weight:700">'+baScores[i]+'</span>'
      +'</div></div>';
  }).join('');
}
function calcBrainAge(){
  var chronAge=parseInt(document.getElementById('ba-chron-age').value)||35;
  var sum=baScores.reduce(function(a,b){return a+b;},0); // 0-100
  var adj=Math.round((50-sum)/5); // sum=100 -> adj=-10, sum=50 -> adj=0, sum=0 -> adj=+10... max diff
  var realAdj=Math.round((50-sum)*0.25); // more moderate
  var brainAge=chronAge+realAdj;
  var weakIdx=baScores.indexOf(Math.min.apply(null,baScores));
  var weakQ=BA_QS[weakIdx];
  var impActions=['Get 7-9 hours of quality sleep consistently','Exercise 5+ days/week (mix cardio + HIIT)','Reduce alcohol to <7 units/week','Practice stress reduction: meditation, therapy, nature','Invest in close social relationships','Learn something new daily — language, instrument, skill','Shift to Mediterranean/MIND diet pattern','Meditate 10-20 min daily','Quit smoking completely','Maintain BMI 20-25 through diet and exercise'];
  var gap=chronAge-brainAge;
  var resultEl=document.getElementById('ba-result');
  if(!resultEl)return;
  resultEl.innerHTML='<div class="ba-age-display">'
    +'<div><div class="ba-age-chron">Chronological age</div><div class="ba-age-num" style="color:var(--dim)">'+chronAge+'</div></div>'
    +'<div style="font-size:24px;color:var(--b2)">→</div>'
    +'<div><div class="ba-age-brain">Estimated brain age</div><div class="ba-age-num" style="color:var(--gold)">'+brainAge+'</div></div>'
    +'</div>'
    +'<div class="ba-gap '+(gap>=0?'younger':'older')+'">'
    +(gap>0?'Your brain is approximately <b>'+gap+' years younger</b> than your chronological age — excellent!':gap<0?'Your brain is approximately <b>'+Math.abs(gap)+' years older</b> than your chronological age.':'Your brain age matches your chronological age — average.')
    +'</div>'
    +'<div class="ba-weakest"><div class="ba-weakest-title">HIGHEST IMPACT IMPROVEMENT</div>'
    +'<div style="font-size:11px;color:var(--text)">Weakest area: <b style="color:var(--accent)">'+weakQ.q+'</b></div>'
    +'<div style="font-size:11px;color:var(--accent2);margin-top:4px">&#8594; '+impActions[weakIdx]+'</div></div>'
    +'<div style="font-size:10px;color:var(--dim);margin-top:8px">Score: '+sum+'/100 &bull; Lifestyle age modifier: '+(realAdj>0?'+':'')+realAdj+' years</div>';
  resultEl.classList.add('vis');
}
</script>
'@

$content = AddBeforeBodyEnd $content $add177
WriteV 177 $content

# ============================================================
# V178 — NEURODEGENERATION PREVENTION
# ============================================================
Write-Host "Building v178..."
$content = [System.IO.File]::ReadAllText("$base\177\index.html")
$content = $content.Replace('<title>NeuroScan v177 — Brain Age</title>', '<title>NeuroScan v178 — Neuro Prevention</title>')
$content = AddAfterBtn $content "bBrainAge" '<div class="hb" id="bNeuroPrevent" onclick="toggleNeuroPreventPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#128737; PREVENTION</div>'

$add178 = @'
<style>
.neuro-prevent-panel{top:60px;right:10px;width:500px;max-height:82vh;overflow-y:auto}
.np-risk-grid{display:grid;grid-template-columns:1fr 1fr;gap:7px;margin-bottom:12px}
.np-risk-item{background:var(--panel2);border:1px solid var(--b1);border-radius:7px;padding:8px 10px}
.np-risk-label{font-size:9px;letter-spacing:.08em;color:var(--dim);margin-bottom:4px}
.np-risk-select{width:100%;background:var(--panel);border:1px solid var(--b1);color:var(--text);padding:3px 6px;border-radius:4px;font-size:11px}
.np-disease-card{background:var(--panel2);border:1px solid var(--b1);border-radius:8px;padding:10px 12px;margin-bottom:8px}
.np-disease-name{font-size:12px;font-weight:700;margin-bottom:6px}
.np-risk-bar-bg{height:8px;background:rgba(255,255,255,.06);border-radius:4px;margin-bottom:5px}
.np-risk-bar{height:8px;border-radius:4px;transition:.5s}
.np-intervention{font-size:10px;color:var(--accent2);margin-top:4px;padding:4px 8px;background:rgba(80,232,160,.07);border-radius:4px}
.np-years-gained{font-size:10px;color:var(--gold)}
</style>
<div id="neuro-prevent-panel" class="feature-panel neuro-prevent-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128737; NEURODEGENERATION PREVENTION</span>
    <span class="fp-sub">Personal risk profile for Alzheimer's, Parkinson's, vascular dementia</span>
    <span class="fp-close" onclick="toggleNeuroPreventPanel()">&#215;</span>
  </div>
  <div class="np-risk-grid">
    <div class="np-risk-item">
      <div class="np-risk-label">APOE e4 STATUS</div>
      <select id="np-apoe" class="np-risk-select"><option value="0">Unknown / e3/e3 (average)</option><option value="1">One copy e4 (3x risk)</option><option value="2">Two copies e4 (8-12x risk)</option></select>
    </div>
    <div class="np-risk-item">
      <div class="np-risk-label">CARDIOVASCULAR HEALTH</div>
      <select id="np-cardio" class="np-risk-select"><option value="0">Excellent (no issues)</option><option value="1">Mild (controlled BP)</option><option value="2">Moderate (diabetes + HTN)</option><option value="3">Poor (uncontrolled)</option></select>
    </div>
    <div class="np-risk-item">
      <div class="np-risk-label">EXERCISE FREQUENCY</div>
      <select id="np-exercise" class="np-risk-select"><option value="0">5+ days/week</option><option value="1">3-4 days/week</option><option value="2">1-2 days/week</option><option value="3">Sedentary</option></select>
    </div>
    <div class="np-risk-item">
      <div class="np-risk-label">SLEEP QUALITY</div>
      <select id="np-sleep" class="np-risk-select"><option value="0">7-9 hrs, good quality</option><option value="1">6-7 hrs, fair</option><option value="2">Poor or <6 hrs</option></select>
    </div>
    <div class="np-risk-item">
      <div class="np-risk-label">EDUCATION LEVEL</div>
      <select id="np-edu" class="np-risk-select"><option value="0">Graduate degree</option><option value="1">College degree</option><option value="2">High school</option><option value="3">No diploma</option></select>
    </div>
    <div class="np-risk-item">
      <div class="np-risk-label">HEAD INJURIES</div>
      <select id="np-head" class="np-risk-select"><option value="0">None</option><option value="1">1 mild concussion</option><option value="2">Multiple / severe</option></select>
    </div>
    <div class="np-risk-item">
      <div class="np-risk-label">SOCIAL ISOLATION</div>
      <select id="np-social" class="np-risk-select"><option value="0">Strong connections</option><option value="1">Moderate</option><option value="2">Isolated / lonely</option></select>
    </div>
    <div class="np-risk-item">
      <div class="np-risk-label">DEPRESSION HISTORY</div>
      <select id="np-depres" class="np-risk-select"><option value="0">None</option><option value="1">Treated / resolved</option><option value="2">Ongoing</option></select>
    </div>
  </div>
  <button onclick="calcNeuroRisk()" style="width:100%;padding:9px;background:rgba(58,184,255,.12);border:1px solid var(--b2);color:var(--accent);border-radius:7px;font-size:12px;font-weight:600;cursor:pointer;letter-spacing:.06em;margin-bottom:10px">CALCULATE MY RISK PROFILE</button>
  <div id="np-results"></div>
</div>
<script>
var neuroPreventOpen=false;
function toggleNeuroPreventPanel(){
  neuroPreventOpen=!neuroPreventOpen;
  var p=document.getElementById('neuro-prevent-panel'),b=document.getElementById('bNeuroPrevent');
  if(p)p.classList.toggle('vis',neuroPreventOpen);if(b)b.classList.toggle('on',neuroPreventOpen);
}
function calcNeuroRisk(){
  var apoe=+document.getElementById('np-apoe').value;
  var cardio=+document.getElementById('np-cardio').value;
  var exercise=+document.getElementById('np-exercise').value;
  var sleep=+document.getElementById('np-sleep').value;
  var edu=+document.getElementById('np-edu').value;
  var head=+document.getElementById('np-head').value;
  var social=+document.getElementById('np-social').value;
  var depres=+document.getElementById('np-depres').value;
  var riskBase={alz:15,park:2,vasc:12}; // lifetime % base risk
  // modifiers
  var alzMod=1+apoe*0.8+cardio*0.3+exercise*0.2+sleep*0.25+edu*0.15+social*0.2+depres*0.35;
  var parkMod=1+head*0.5+exercise*0.15+depres*0.2;
  var vascMod=1+cardio*0.5+exercise*0.15+sleep*0.15+apoe*0.2;
  var alz=Math.min(70,Math.round(riskBase.alz*alzMod));
  var park=Math.min(15,Math.round(riskBase.park*parkMod));
  var vasc=Math.min(50,Math.round(riskBase.vasc*vascMod));
  var diseases=[
    {name:'Alzheimer\'s Disease',risk:alz,max:70,color:'#ff9060',
     intervention:exercise===3?'Start aerobic exercise program (5-7 yrs protective)':sleep>=2?'Improve sleep quality (glymphatic clearance)':social>=2?'Increase social engagement (cognitive reserve)':'Maintain Mediterranean diet (MIND diet reduces risk 35%)',
     yearsGained:3},
    {name:'Parkinson\'s Disease',risk:park,max:15,color:'#c084fc',
     intervention:head>=1?'Use helmets, avoid contact sports':exercise>=2?'Start vigorous aerobic exercise (50% risk reduction)':'Maintain exercise + avoid pesticide exposure',
     yearsGained:2},
    {name:'Vascular Dementia',risk:vasc,max:50,color:'#3ab8ff',
     intervention:cardio>=2?'Control blood pressure and blood sugar urgently':exercise>=2?'Cardio exercise + Mediterranean diet':'Maintain cardiovascular health — this is largely preventable',
     yearsGained:4}
  ];
  var el=document.getElementById('np-results');if(!el)return;
  el.innerHTML=diseases.map(function(d){
    var pct=Math.round(d.risk/d.max*100);
    var col=d.risk>d.max*0.6?'var(--red)':d.risk>d.max*0.35?'var(--gold)':'var(--accent2)';
    return '<div class="np-disease-card">'
      +'<div class="np-disease-name" style="color:'+d.color+'">'+d.name+' — <span style="color:'+col+'">~'+d.risk+'% lifetime risk</span></div>'
      +'<div class="np-risk-bar-bg"><div class="np-risk-bar" style="width:'+pct+'%;background:'+d.color+'"></div></div>'
      +'<div class="np-intervention">&#10003; BEST INTERVENTION: '+d.intervention+'</div>'
      +'<div class="np-years-gained">&#9679; Estimated cognitive life gained: +'+d.yearsGained+' years of healthy cognition</div>'
      +'</div>';
  }).join('');
}
</script>
'@

$content = AddBeforeBodyEnd $content $add178
WriteV 178 $content

# ============================================================
# V179 — SLEEP OPTIMIZER
# ============================================================
Write-Host "Building v179..."
$content = [System.IO.File]::ReadAllText("$base\178\index.html")
$content = $content.Replace('<title>NeuroScan v178 — Neuro Prevention</title>', '<title>NeuroScan v179 — Sleep Optimizer</title>')
$content = AddAfterBtn $content "bNeuroPrevent" '<div class="hb" id="bSleepOpt" onclick="toggleSleepOptPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#128564; SLEEP</div>'

$add179 = @'
<style>
.sleep-opt-panel{top:60px;right:10px;width:500px;max-height:82vh;overflow-y:auto}
.so-diary-row{display:flex;gap:6px;align-items:center;margin-bottom:5px;flex-wrap:wrap}
.so-day-label{font-size:9px;color:var(--dim);width:30px;flex-shrink:0}
.so-input{width:55px;background:var(--panel);border:1px solid var(--b1);color:var(--text);padding:3px 5px;border-radius:4px;font-size:11px;text-align:center}
.so-score-badge{display:inline-block;padding:3px 10px;border-radius:10px;font-size:11px;font-weight:700}
.so-guide-item{display:flex;gap:8px;padding:6px 0;border-bottom:1px solid rgba(58,184,255,.06)}
.so-guide-icon{width:20px;flex-shrink:0;text-align:center;font-size:14px}
.so-guide-text{font-size:11px;color:var(--text);line-height:1.45}
.so-stage{background:var(--panel2);border-left:3px solid var(--accent);border-radius:0 6px 6px 0;padding:7px 10px;margin-bottom:5px}
.so-stage-name{font-size:11px;font-weight:700;color:var(--accent)}
.so-stage-desc{font-size:10px;color:var(--dim);margin-top:2px}
</style>
<div id="sleep-opt-panel" class="feature-panel sleep-opt-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128564; SLEEP OPTIMIZER</span>
    <span class="fp-sub">Sleep diary + evidence-based optimization guide</span>
    <span class="fp-close" onclick="toggleSleepOptPanel()">&#215;</span>
  </div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:6px">SLEEP DIARY — LAST 7 NIGHTS</div>
  <div id="so-diary-rows"></div>
  <button onclick="saveSleepDiary()" style="margin:6px 0;padding:6px 14px;background:rgba(58,184,255,.1);border:1px solid var(--b1);color:var(--accent);border-radius:5px;font-size:11px;cursor:pointer">SAVE DIARY</button>
  <canvas id="so-chart" width="460" height="100" style="display:block;width:100%;border:1px solid var(--b1);border-radius:6px;margin-bottom:10px"></canvas>
  <div id="so-sleep-score" style="margin-bottom:10px"></div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin:10px 0 6px">OPTIMIZATION GUIDE</div>
  <div class="so-guide-item"><div class="so-guide-icon">&#9200;</div><div class="so-guide-text"><b>Consistent schedule</b> — same wake time 7 days/week. The most impactful intervention. Anchors your circadian rhythm.</div></div>
  <div class="so-guide-item"><div class="so-guide-icon">&#127774;</div><div class="so-guide-text"><b>Temperature</b> — 65-68°F (18-20°C) bedroom. Core body temp must drop 2°F to initiate sleep. Cold showers before bed help.</div></div>
  <div class="so-guide-item"><div class="so-guide-icon">&#127772;</div><div class="so-guide-text"><b>Complete darkness</b> — use blackout curtains or sleep mask. Even small light leaks suppress melatonin by 50%.</div></div>
  <div class="so-guide-item"><div class="so-guide-icon">&#128241;</div><div class="so-guide-text"><b>No screens 1 hour before bed</b> — blue light delays sleep onset by 1-2 hours. Use Night Mode or blue-light glasses if unavoidable.</div></div>
  <div class="so-guide-item"><div class="so-guide-icon">&#9749;</div><div class="so-guide-text"><b>Caffeine cutoff: 2PM</b> — caffeine half-life is 5-7 hours. A 3PM coffee still has 50% effect at 8PM. Kills deep sleep even if you fall asleep.</div></div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin:10px 0 6px">SLEEP STAGES</div>
  <div class="so-stage"><div class="so-stage-name">Stage N1 (5%): Transition</div><div class="so-stage-desc">Hypnagogic state. 1-5 min. Easily awakened. Muscle jerks common.</div></div>
  <div class="so-stage" style="border-color:var(--accent2)"><div class="so-stage-name" style="color:var(--accent2)">Stage N2 (45%): Light Sleep</div><div class="so-stage-desc">Sleep spindles consolidate motor memories. Heart rate slows. Temperature drops.</div></div>
  <div class="so-stage" style="border-color:var(--purple)"><div class="so-stage-name" style="color:var(--purple)">Stage N3 (25%): Deep Sleep</div><div class="so-stage-desc">Glymphatic system clears amyloid-beta and tau. Growth hormone released. Immune function peaks. Most restorative.</div></div>
  <div class="so-stage" style="border-color:var(--gold)"><div class="so-stage-name" style="color:var(--gold)">REM (25%): Dream Sleep</div><div class="so-stage-desc">Memory consolidation — episodic memories transferred to long-term storage. Emotional processing. Creativity peaks. Digital minds don't need this — biological ones must prioritize it.</div></div>
</div>
<script>
var sleepOptOpen=false;
var SO_DAYS=['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
var soData=JSON.parse(localStorage.getItem('ns_sleep_diary')||'null')||SO_DAYS.map(function(){return{h:7,q:3,d:false};});
function toggleSleepOptPanel(){
  sleepOptOpen=!sleepOptOpen;
  var p=document.getElementById('sleep-opt-panel'),b=document.getElementById('bSleepOpt');
  if(p)p.classList.toggle('vis',sleepOptOpen);if(b)b.classList.toggle('on',sleepOptOpen);
  if(sleepOptOpen){renderSoDiary();drawSoChart();renderSoScore();}
}
function renderSoDiary(){
  var el=document.getElementById('so-diary-rows');if(!el)return;
  el.innerHTML=SO_DAYS.map(function(d,i){
    return '<div class="so-diary-row"><span class="so-day-label">'+d+'</span>'
      +'<span style="font-size:10px;color:var(--dim)">Hrs:</span><input class="so-input" type="number" min="0" max="12" step="0.5" value="'+soData[i].h+'" oninput="soData['+i+'].h=+this.value;drawSoChart()">'
      +'<span style="font-size:10px;color:var(--dim)">Quality(1-5):</span><input class="so-input" type="number" min="1" max="5" value="'+soData[i].q+'" oninput="soData['+i+'].q=+this.value;drawSoChart()">'
      +'<label style="font-size:10px;color:var(--dim);display:flex;align-items:center;gap:3px"><input type="checkbox" '+(soData[i].d?'checked':'')+' onchange="soData['+i+'].d=this.checked"> Dreams</label>'
      +'</div>';
  }).join('');
}
function saveSleepDiary(){localStorage.setItem('ns_sleep_diary',JSON.stringify(soData));renderSoScore();}
function drawSoChart(){
  var cv=document.getElementById('so-chart');if(!cv)return;
  var ctx=cv.getContext('2d'),W=cv.width,H=cv.height;
  ctx.clearRect(0,0,W,H);
  ctx.fillStyle='rgba(4,6,15,.9)';ctx.fillRect(0,0,W,H);
  var maxH=12,bw=Math.floor(W/7)-4;
  soData.forEach(function(d,i){
    var x=i*(bw+4)+2,barH=Math.round((d.h/maxH)*(H-30));
    var g=ctx.createLinearGradient(0,H-barH,0,H);
    g.addColorStop(0,'rgba(58,184,255,.8)');g.addColorStop(1,'rgba(58,184,255,.2)');
    ctx.fillStyle=g;ctx.fillRect(x,H-barH-15,bw,barH);
    ctx.fillStyle='rgba(200,216,240,.4)';ctx.font='9px sans-serif';ctx.fillText(SO_DAYS[i],x+2,H-2);
    ctx.fillStyle='rgba(255,200,74,.7)';ctx.font='9px sans-serif';ctx.fillText(d.h+'h',x+2,H-barH-17);
  });
  // Quality line
  ctx.strokeStyle='rgba(80,232,160,.7)';ctx.lineWidth=1.5;ctx.beginPath();
  soData.forEach(function(d,i){
    var x=i*(bw+4)+bw/2;var y=H-15-((d.q/5)*(H-30));
    i===0?ctx.moveTo(x,y):ctx.lineTo(x,y);
  });
  ctx.stroke();
}
function renderSoScore(){
  var avgH=soData.reduce(function(a,b){return a+b.h;},0)/7;
  var avgQ=soData.reduce(function(a,b){return a+b.q;},0)/7;
  var debt=Math.max(0,Math.round((8-avgH)*7));
  var score=Math.min(100,Math.round(((avgH/8)*0.6+(avgQ/5)*0.4)*100));
  var el=document.getElementById('so-sleep-score');if(!el)return;
  var col=score>=75?'var(--accent2)':score>=50?'var(--gold)':'var(--red)';
  el.innerHTML='<div style="display:flex;gap:12px;flex-wrap:wrap;align-items:center">'
    +'<span class="so-score-badge" style="background:rgba(58,184,255,.1);border:1px solid var(--b2);color:'+col+'">Sleep Score: '+score+'/100</span>'
    +'<span style="font-size:11px;color:var(--dim)">Avg: '+avgH.toFixed(1)+' hrs/night</span>'
    +'<span style="font-size:11px;color:var(--red)">Weekly debt: '+debt+' hrs</span>'
    +'</div>';
}
</script>
'@

$content = AddBeforeBodyEnd $content $add179
WriteV 179 $content

# ============================================================
# V180 — COGNITIVE TRAINING SUITE
# ============================================================
Write-Host "Building v180..."
$content = [System.IO.File]::ReadAllText("$base\179\index.html")
$content = $content.Replace('<title>NeuroScan v179 — Sleep Optimizer</title>', '<title>NeuroScan v180 — Cognitive Suite</title>')
$content = AddAfterBtn $content "bSleepOpt" '<div class="hb" id="bCogSuite" onclick="toggleCogSuitePanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#127918; BRAIN GAMES</div>'

$add180 = @'
<style>
.cog-suite-panel{top:60px;right:10px;width:500px;max-height:82vh;overflow-y:auto}
.cs-game-area{background:var(--panel2);border:1px solid var(--b1);border-radius:8px;padding:14px;margin-bottom:8px;min-height:120px}
.cs-game-title{font-size:12px;font-weight:700;color:var(--accent);margin-bottom:4px;letter-spacing:.05em}
.cs-game-sub{font-size:10px;color:var(--dim);margin-bottom:10px}
.cs-letter-display{font-size:48px;font-weight:900;color:var(--accent);text-align:center;padding:10px;letter-spacing:.1em;min-height:70px;display:flex;align-items:center;justify-content:center}
.cs-btn{padding:8px 18px;border-radius:6px;border:1px solid var(--b2);background:rgba(58,184,255,.1);color:var(--accent);font-size:12px;font-weight:600;cursor:pointer;transition:.15s;letter-spacing:.05em}
.cs-btn:hover{background:rgba(58,184,255,.2)}
.cs-btn.green{border-color:rgba(80,232,160,.4);background:rgba(80,232,160,.1);color:var(--accent2)}
.cs-btn.red{border-color:rgba(255,85,104,.4);background:rgba(255,85,104,.1);color:var(--red)}
.cs-score-display{font-size:22px;font-weight:800;color:var(--gold);text-align:center;padding:8px}
.cs-react-circle{width:80px;height:80px;border-radius:50%;background:rgba(255,85,104,.3);border:3px solid var(--red);margin:10px auto;cursor:pointer;transition:.15s;display:flex;align-items:center;justify-content:center;font-size:11px;color:var(--dim)}
.cs-react-circle.go{background:rgba(80,232,160,.4);border-color:var(--accent2);color:var(--accent2);font-weight:700}
.cs-grid{display:grid;grid-template-columns:repeat(3,1fr);gap:4px;max-width:180px;margin:8px auto}
.cs-grid-cell{width:56px;height:56px;border-radius:4px;background:rgba(58,184,255,.08);border:1px solid var(--b1);cursor:pointer;transition:.15s;display:flex;align-items:center;justify-content:center;font-size:18px}
.cs-grid-cell:hover{background:rgba(58,184,255,.15)}
.cs-grid-cell.lit{background:rgba(58,184,255,.4);border-color:var(--accent)}
.cs-composite{background:linear-gradient(135deg,rgba(255,200,74,.1),rgba(58,184,255,.1));border:1px solid var(--b2);border-radius:10px;padding:14px;margin-top:8px;text-align:center}
</style>
<div id="cog-suite-panel" class="feature-panel cog-suite-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#127918; COGNITIVE TRAINING SUITE</span>
    <span class="fp-sub">4 mini-games: N-Back · Reaction · Pattern · Stroop</span>
    <span class="fp-close" onclick="toggleCogSuitePanel()">&#215;</span>
  </div>
  <div id="cs-current-game"></div>
  <div id="cs-composite-area"></div>
</div>
<script>
var cogSuiteOpen=false,csGameIndex=0,csScores=[],csGameState={};
function toggleCogSuitePanel(){
  cogSuiteOpen=!cogSuiteOpen;
  var p=document.getElementById('cog-suite-panel'),b=document.getElementById('bCogSuite');
  if(p)p.classList.toggle('vis',cogSuiteOpen);if(b)b.classList.toggle('on',cogSuiteOpen);
  if(cogSuiteOpen){csGameIndex=0;csScores=[];csGameState={};renderCurrentGame();}
}
function renderCurrentGame(){
  var el=document.getElementById('cs-current-game');if(!el)return;
  if(csGameIndex===0)renderNBack(el);
  else if(csGameIndex===1)renderReaction(el);
  else if(csGameIndex===2)renderPattern(el);
  else if(csGameIndex===3)renderStroop(el);
  else showComposite();
}
// GAME 1: N-Back
function renderNBack(el){
  var letters='BDFGHJKLMNPRSTVX',seq=[],trial=0,hits=0,falseAlarms=0,isRunning=false,seqTimer=null;
  el.innerHTML='<div class="cs-game-area">'
    +'<div class="cs-game-title">GAME 1: N-BACK (Working Memory)</div>'
    +'<div class="cs-game-sub">Press MATCH if the current letter = the letter 2 back. 15 trials at 2-back level.</div>'
    +'<div class="cs-letter-display" id="nb-letter">—</div>'
    +'<div style="text-align:center;margin-bottom:8px;font-size:10px;color:var(--dim)" id="nb-progress">Ready to start</div>'
    +'<div style="display:flex;gap:8px;justify-content:center">'
    +'<button class="cs-btn green" id="nb-match-btn" onclick="nbMatch()" disabled>MATCH</button>'
    +'<button class="cs-btn" onclick="nbStart()">START</button>'
    +'</div></div>';
  window._nbState={seq:seq,trial:trial,hits:hits,falseAlarms:falseAlarms,isRunning:isRunning,seqTimer:seqTimer,letters:letters,el:el};
}
function nbStart(){
  var s=window._nbState;if(s.isRunning)return;
  s.isRunning=true;s.trial=0;s.hits=0;s.falseAlarms=0;s.seq=[];
  var letters=s.letters,nbBtn=document.getElementById('nb-match-btn');
  if(nbBtn)nbBtn.disabled=false;
  function nextTrial(){
    if(s.trial>=15){nbEnd();return;}
    var l=letters[Math.floor(Math.random()*letters.length)];
    s.seq.push(l);s.trial++;
    var prog=document.getElementById('nb-progress'),lEl=document.getElementById('nb-letter');
    if(prog)prog.textContent='Trial '+s.trial+' / 15';
    if(lEl)lEl.textContent=l;
    s.currentTimer=setTimeout(nextTrial,2000);
  }
  nextTrial();
}
function nbMatch(){
  var s=window._nbState;if(!s||!s.isRunning)return;
  var n=s.seq.length;
  if(n>=3&&s.seq[n-1]===s.seq[n-3])s.hits++;
  else s.falseAlarms++;
}
function nbEnd(){
  var s=window._nbState;s.isRunning=false;
  var possible=Math.max(1,13);// trials 3-15 have a 2-back target
  var accuracy=Math.round((s.hits/possible)*100);
  var score=Math.max(0,accuracy-s.falseAlarms*5);
  csScores.push({game:'N-Back',score:score,detail:s.hits+' hits, '+s.falseAlarms+' false alarms'});
  document.getElementById('nb-letter').textContent='Done';
  document.getElementById('nb-progress').innerHTML='Score: <b style="color:var(--gold)">'+score+'%</b> — '+s.hits+' hits';
  var nbBtn=document.getElementById('nb-match-btn');if(nbBtn)nbBtn.disabled=true;
  setTimeout(function(){csGameIndex=1;renderCurrentGame();},1500);
}
// GAME 2: Reaction Time
function renderReaction(el){
  var trials=0,times=[],waiting=false,startTime=0;
  el.innerHTML='<div class="cs-game-area">'
    +'<div class="cs-game-title">GAME 2: REACTION TIME</div>'
    +'<div class="cs-game-sub">Click the circle when it turns GREEN. 5 trials. Avg response time measured.</div>'
    +'<div class="cs-react-circle" id="rt-circle" onclick="rtClick()">WAIT</div>'
    +'<div style="text-align:center;font-size:10px;color:var(--dim)" id="rt-progress">Click START to begin</div>'
    +'<div style="text-align:center;margin-top:8px"><button class="cs-btn" onclick="rtStart()">START</button></div>'
    +'</div>';
  window._rtState={trials:trials,times:times,waiting:waiting,startTime:startTime};
}
function rtStart(){
  var s=window._rtState;s.trials=0;s.times=[];rtNextTrial(s);
}
function rtNextTrial(s){
  if(s.trials>=5){rtEnd(s);return;}
  s.waiting=false;
  var c=document.getElementById('rt-circle');
  if(c){c.className='cs-react-circle';c.textContent='WAIT';}
  var delay=1000+Math.random()*4000;
  s.goTimer=setTimeout(function(){
    s.waiting=true;s.startTime=Date.now();
    if(c){c.className='cs-react-circle go';c.textContent='NOW!';}
    document.getElementById('rt-progress').textContent='Trial '+(s.trials+1)+' / 5 — CLICK!';
  },delay);
}
function rtClick(){
  var s=window._rtState;if(!s)return;
  if(!s.waiting){clearTimeout(s.goTimer);return;}
  var ms=Date.now()-s.startTime;s.times.push(ms);s.trials++;s.waiting=false;
  document.getElementById('rt-progress').textContent='Trial '+s.trials+': '+ms+'ms';
  var c=document.getElementById('rt-circle');if(c){c.className='cs-react-circle';c.textContent='...';}
  setTimeout(function(){rtNextTrial(s);},800);
}
function rtEnd(s){
  var avg=Math.round(s.times.reduce(function(a,b){return a+b;},0)/s.times.length);
  var score=Math.max(0,Math.min(100,Math.round((600-avg)/5)));
  csScores.push({game:'Reaction Time',score:score,detail:'Avg: '+avg+'ms'});
  document.getElementById('rt-progress').innerHTML='Avg reaction: <b style="color:var(--gold)">'+avg+'ms</b> — Score: '+score+'/100';
  setTimeout(function(){csGameIndex=2;renderCurrentGame();},1500);
}
// GAME 3: Pattern Recognition
function renderPattern(el){
  var round=0,score=0,emptyCell=-1,showing=false;
  el.innerHTML='<div class="cs-game-area">'
    +'<div class="cs-game-title">GAME 3: PATTERN RECOGNITION</div>'
    +'<div class="cs-game-sub">Remember the 3×3 grid (shown for 2s). One cell was empty — click it. 5 rounds.</div>'
    +'<div id="pat-grid" class="cs-grid"></div>'
    +'<div style="text-align:center;font-size:10px;color:var(--dim);margin-top:6px" id="pat-msg">Click START</div>'
    +'<div style="text-align:center;margin-top:8px"><button class="cs-btn" onclick="patStart()">START</button></div>'
    +'</div>';
  window._patState={round:round,score:score,emptyCell:emptyCell,showing:showing};
}
function patStart(){
  var s=window._patState;s.round=0;s.score=0;patNextRound(s);
}
function patNextRound(s){
  if(s.round>=5){patEnd(s);return;}
  s.round++;s.emptyCell=Math.floor(Math.random()*9);s.showing=true;
  var icons=['●','■','▲','◆','★','○','□','△','◇'];
  var grid=document.getElementById('pat-grid');
  if(!grid)return;
  grid.innerHTML='';
  for(var i=0;i<9;i++){
    var cell=document.createElement('div');cell.className='cs-grid-cell lit';
    cell.textContent=i===s.emptyCell?'':icons[i];
    grid.appendChild(cell);
  }
  document.getElementById('pat-msg').textContent='Round '+s.round+'/5 — Memorize!';
  setTimeout(function(){
    s.showing=false;
    grid.innerHTML='';
    for(var j=0;j<9;j++){
      var c2=document.createElement('div');c2.className='cs-grid-cell';c2.textContent='?';
      (function(idx){c2.onclick=function(){patGuess(s,idx);};})(j);
      grid.appendChild(c2);
    }
    document.getElementById('pat-msg').textContent='Which cell was EMPTY?';
  },2000);
}
function patGuess(s,idx){
  if(s.showing)return;
  if(idx===s.emptyCell){s.score++;document.getElementById('pat-msg').textContent='Correct! ✓';}
  else{document.getElementById('pat-msg').textContent='Wrong. Empty was cell '+(s.emptyCell+1);}
  setTimeout(function(){patNextRound(s);},800);
}
function patEnd(s){
  var score=Math.round(s.score/5*100);
  csScores.push({game:'Pattern',score:score,detail:s.score+'/5 correct'});
  document.getElementById('pat-msg').innerHTML='Score: <b style="color:var(--gold)">'+score+'%</b>';
  setTimeout(function(){csGameIndex=3;renderCurrentGame();},1500);
}
// GAME 4: Stroop Test
function renderStroop(el){
  var STROOP_WORDS=['RED','BLUE','GREEN','YELLOW'],STROOP_COLORS=['#ff5568','#3ab8ff','#50e8a0','#ffc84a'];
  var trials=0,correct=0,startT=0;
  el.innerHTML='<div class="cs-game-area">'
    +'<div class="cs-game-title">GAME 4: STROOP TEST</div>'
    +'<div class="cs-game-sub">Click the INK COLOR (not the word). 6 trials. Accuracy + speed scored.</div>'
    +'<div id="stroop-word" style="font-size:40px;font-weight:900;text-align:center;padding:10px;min-height:60px;letter-spacing:.08em">—</div>'
    +'<div id="stroop-btns" style="display:flex;gap:8px;justify-content:center;flex-wrap:wrap;margin:8px 0"></div>'
    +'<div style="text-align:center;font-size:10px;color:var(--dim)" id="stroop-msg">Click START</div>'
    +'<div style="text-align:center;margin-top:6px"><button class="cs-btn" onclick="stroopStart()">START</button></div>'
    +'</div>';
  window._stroopState={STROOP_WORDS:STROOP_WORDS,STROOP_COLORS:STROOP_COLORS,trials:trials,correct:correct,startT:startT,curColorIdx:-1};
}
function stroopStart(){
  var s=window._stroopState;s.trials=0;s.correct=0;stroopNext(s);
}
function stroopNext(s){
  if(s.trials>=6){stroopEnd(s);return;}
  s.trials++;
  var wi=Math.floor(Math.random()*4),ci=Math.floor(Math.random()*4);
  // make them often conflict
  if(Math.random()>0.3)while(ci===wi)ci=Math.floor(Math.random()*4);
  s.curColorIdx=ci;s.startT=Date.now();
  document.getElementById('stroop-word').textContent=s.STROOP_WORDS[wi];
  document.getElementById('stroop-word').style.color=s.STROOP_COLORS[ci];
  var btnsEl=document.getElementById('stroop-btns');
  btnsEl.innerHTML=s.STROOP_COLORS.map(function(col,i){
    return '<button onclick="stroopAnswer('+i+')" style="padding:6px 14px;border-radius:5px;border:2px solid '+col+';background:'+col+'22;color:'+col+';font-weight:700;cursor:pointer;font-size:11px">'+s.STROOP_WORDS[i]+'</button>';
  }).join('');
  document.getElementById('stroop-msg').textContent='Trial '+s.trials+'/6 — Click the INK color';
}
function stroopAnswer(idx){
  var s=window._stroopState;if(!s||s.curColorIdx<0)return;
  var ms=Date.now()-s.startT;
  if(idx===s.curColorIdx){s.correct++;document.getElementById('stroop-msg').textContent='Correct! ('+ms+'ms)';}
  else{document.getElementById('stroop-msg').textContent='Wrong. Ink was '+s.STROOP_WORDS[s.curColorIdx]+'.';}
  s.curColorIdx=-1;
  setTimeout(function(){stroopNext(s);},700);
}
function stroopEnd(s){
  var score=Math.round(s.correct/6*100);
  csScores.push({game:'Stroop',score:score,detail:s.correct+'/6 correct'});
  document.getElementById('stroop-msg').innerHTML='Score: <b style="color:var(--gold)">'+score+'%</b>';
  setTimeout(function(){csGameIndex=4;showComposite();},1200);
}
function showComposite(){
  var el=document.getElementById('cs-current-game');if(el)el.innerHTML='';
  var compEl=document.getElementById('cs-composite-area');if(!compEl)return;
  var total=Math.round(csScores.reduce(function(a,b){return a+b.score;},0)/csScores.length);
  var saved=JSON.parse(localStorage.getItem('ns_cog_scores')||'[]');
  saved.push({date:new Date().toLocaleDateString(),scores:csScores,composite:total});
  if(saved.length>30)saved=saved.slice(-30);
  localStorage.setItem('ns_cog_scores',JSON.stringify(saved));
  compEl.innerHTML='<div class="cs-composite"><div style="font-size:11px;letter-spacing:.1em;color:var(--dim);margin-bottom:6px">COMPOSITE COGNITIVE SCORE</div>'
    +'<div style="font-size:48px;font-weight:900;color:var(--gold);line-height:1">'+total+'</div>'
    +'<div style="font-size:10px;color:var(--dim);margin-bottom:8px">out of 100</div>'
    +csScores.map(function(s){return '<div style="display:flex;justify-content:space-between;font-size:11px;padding:3px 0"><span style="color:var(--dim)">'+s.game+'</span><span style="color:var(--accent)">'+s.score+'% — '+s.detail+'</span></div>';}).join('')
    +'<div style="font-size:10px;color:var(--dim);margin-top:8px">Saved '+saved.length+' sessions to history</div>'
    +'</div>';
}
</script>
'@

$content = AddBeforeBodyEnd $content $add180
WriteV 180 $content

# ============================================================
# V181 — STRESS & CORTISOL
# ============================================================
Write-Host "Building v181..."
$content = [System.IO.File]::ReadAllText("$base\180\index.html")
$content = $content.Replace('<title>NeuroScan v180 — Cognitive Suite</title>', '<title>NeuroScan v181 — Stress Tracker</title>')
$content = AddAfterBtn $content "bCogSuite" '<div class="hb" id="bStressTrack" onclick="toggleStressTrackPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#128548; STRESS</div>'

$add181 = @'
<style>
.stress-track-panel{top:60px;right:10px;width:500px;max-height:82vh;overflow-y:auto}
.st-rating-row{display:flex;gap:6px;align-items:center;margin-bottom:10px;flex-wrap:wrap}
.st-rating-btn{width:32px;height:32px;border-radius:50%;border:1px solid var(--b1);background:transparent;color:var(--dim);font-size:11px;font-weight:700;cursor:pointer;transition:.15s}
.st-rating-btn:hover,.st-rating-btn.on{border-color:var(--accent);color:var(--accent);background:rgba(58,184,255,.1)}
.st-heatmap-label{font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:5px}
.st-intervention-item{display:flex;gap:8px;align-items:flex-start;padding:6px 0;border-bottom:1px solid rgba(58,184,255,.06)}
.st-interv-ev{padding:2px 6px;border-radius:3px;font-size:9px;font-weight:600;min-width:22px;text-align:center;flex-shrink:0}
.st-interv-text{font-size:11px;color:var(--text);line-height:1.4}
.st-mech-box{background:rgba(255,85,104,.05);border:1px solid rgba(255,85,104,.2);border-radius:7px;padding:10px;margin-bottom:10px}
</style>
<div id="stress-track-panel" class="feature-panel stress-track-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128548; STRESS TRACKER</span>
    <span class="fp-sub">Chronic stress tracker + cortisol-brain damage mechanisms</span>
    <span class="fp-close" onclick="toggleStressTrackPanel()">&#215;</span>
  </div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:6px">TODAY'S STRESS LEVEL (1 = calm, 10 = crisis)</div>
  <div class="st-rating-row" id="st-rating-row"></div>
  <button onclick="saveStressRating()" style="padding:6px 14px;background:rgba(255,85,104,.1);border:1px solid rgba(255,85,104,.3);color:var(--red);border-radius:5px;font-size:11px;cursor:pointer;margin-bottom:10px">LOG TODAY</button>
  <div id="st-streak" style="font-size:10px;color:var(--dim);margin-bottom:8px"></div>
  <div class="st-heatmap-label">STRESS HEATMAP — LAST 30 DAYS</div>
  <canvas id="st-heatmap" width="460" height="70" style="display:block;width:100%;border:1px solid var(--b1);border-radius:6px;margin-bottom:12px"></canvas>
  <div class="st-mech-box">
    <div style="font-size:9px;letter-spacing:.1em;color:var(--red);margin-bottom:6px">HOW CHRONIC STRESS DAMAGES THE BRAIN</div>
    <div style="font-size:11px;color:var(--text);line-height:1.6">
      <b style="color:var(--accent)">Cortisol + Hippocampus:</b> Chronic high cortisol literally shrinks the hippocampus (memory center) by killing neurons and reducing neurogenesis. Sustained high stress = measurable IQ loss.<br>
      <b style="color:var(--accent)">Amygdala Expansion:</b> Fear center grows larger with chronic stress → heightened threat detection, anxiety loops, impaired rational decision-making.<br>
      <b style="color:var(--accent)">Prefrontal Cortex:</b> Stress weakens prefrontal-amygdala control — you lose emotional regulation and executive function.<br>
      <b style="color:var(--gold)">Upload Relevance:</b> High chronic stress accelerates neurodegeneration, accelerates cellular aging (telomere shortening), and reduces upload window. Every high-stress month matters.
    </div>
  </div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:6px">INTERVENTIONS (by evidence strength)</div>
  <div class="st-intervention-item"><span class="st-interv-ev" style="background:rgba(80,232,160,.15);color:var(--accent2)">A</span><div class="st-interv-text"><b>Aerobic exercise</b> — 30 min/day reduces cortisol baseline by 15-20%. Most replicated stress reducer. Grows hippocampus by 2% per year.</div></div>
  <div class="st-intervention-item"><span class="st-interv-ev" style="background:rgba(80,232,160,.15);color:var(--accent2)">A</span><div class="st-interv-text"><b>Mindfulness meditation</b> — MBSR (8-week program) reduces amygdala gray matter density and cortisol by 25%. 10-20 min daily is sufficient.</div></div>
  <div class="st-intervention-item"><span class="st-interv-ev" style="background:rgba(58,184,255,.15);color:var(--accent)">B</span><div class="st-interv-text"><b>Social connection</b> — Oxytocin directly down-regulates cortisol. Regular close social interaction is protective against stress-induced neurodegeneration.</div></div>
  <div class="st-intervention-item"><span class="st-interv-ev" style="background:rgba(58,184,255,.15);color:var(--accent)">B</span><div class="st-interv-text"><b>Sleep</b> — HPA axis resets during deep sleep. Chronic poor sleep is both cause and effect of high cortisol. Prioritizing sleep breaks the cycle.</div></div>
  <div class="st-intervention-item"><span class="st-interv-ev" style="background:rgba(255,200,74,.15);color:var(--gold)">C</span><div class="st-interv-text"><b>Therapy (CBT)</b> — Cognitive restructuring changes cortisol response to stressors. Particularly effective for work-related and relationship stress.</div></div>
  <div id="st-avg-display" style="margin-top:10px;padding:8px;border:1px solid var(--b1);border-radius:6px;font-size:11px;color:var(--dim)"></div>
</div>
<script>
var stressTrackOpen=false,stressSelected=5;
function toggleStressTrackPanel(){
  stressTrackOpen=!stressTrackOpen;
  var p=document.getElementById('stress-track-panel'),b=document.getElementById('bStressTrack');
  if(p)p.classList.toggle('vis',stressTrackOpen);if(b)b.classList.toggle('on',stressTrackOpen);
  if(stressTrackOpen){renderStressRating();drawStressHeatmap();renderStressAvg();}
}
function renderStressRating(){
  var el=document.getElementById('st-rating-row');if(!el)return;
  el.innerHTML='';
  for(var i=1;i<=10;i++){
    var btn=document.createElement('button');btn.className='st-rating-btn'+(i===stressSelected?' on':'');
    btn.textContent=i;(function(v){btn.onclick=function(){stressSelected=v;renderStressRating();};})(i);
    el.appendChild(btn);
  }
}
function saveStressRating(){
  var data=JSON.parse(localStorage.getItem('ns_stress_log')||'{}');
  var today=new Date().toISOString().slice(0,10);
  data[today]=stressSelected;
  // keep only last 60 days
  var keys=Object.keys(data).sort();if(keys.length>60)keys.slice(0,keys.length-60).forEach(function(k){delete data[k];});
  localStorage.setItem('ns_stress_log',JSON.stringify(data));
  drawStressHeatmap();renderStressAvg();
  var streak=document.getElementById('st-streak');
  if(streak)streak.textContent='Logged! Stress: '+stressSelected+'/10 for '+today;
}
function drawStressHeatmap(){
  var cv=document.getElementById('st-heatmap');if(!cv)return;
  var ctx=cv.getContext('2d'),W=cv.width,H=cv.height;
  ctx.clearRect(0,0,W,H);ctx.fillStyle='rgba(4,6,15,.9)';ctx.fillRect(0,0,W,H);
  var data=JSON.parse(localStorage.getItem('ns_stress_log')||'{}');
  var days=[];var now=new Date();
  for(var i=29;i>=0;i--){var d=new Date(now);d.setDate(d.getDate()-i);days.push(d.toISOString().slice(0,10));}
  var cw=Math.floor(W/30)-1;
  days.forEach(function(d,i){
    var val=data[d];
    var x=i*(cw+1),y=5;
    if(val){
      var r=Math.round(val/10*255),g=Math.round((1-val/10)*150);
      ctx.fillStyle='rgb('+r+','+g+',50)';
    } else {
      ctx.fillStyle='rgba(58,184,255,.08)';
    }
    ctx.fillRect(x,y,cw,H-20);
    if(i%7===0){ctx.fillStyle='rgba(200,216,240,.3)';ctx.font='8px sans-serif';ctx.fillText(d.slice(5),x,H-2);}
  });
}
function renderStressAvg(){
  var data=JSON.parse(localStorage.getItem('ns_stress_log')||'{}');
  var vals=Object.values(data).map(Number);
  var el=document.getElementById('st-avg-display');if(!el)return;
  if(!vals.length){el.textContent='No data logged yet. Start tracking your daily stress.';return;}
  var avg=(vals.reduce(function(a,b){return a+b;},0)/vals.length).toFixed(1);
  var recent=vals.slice(-7);
  var avgRecent=(recent.reduce(function(a,b){return a+b;},0)/recent.length).toFixed(1);
  var col=avg>7?'var(--red)':avg>5?'var(--gold)':'var(--accent2)';
  el.innerHTML='30-day avg: <b style="color:'+col+'">'+avg+'/10</b> &bull; Last 7 days: <b>'+avgRecent+'/10</b> &bull; Days logged: '+vals.length
    +'<br><span style="font-size:10px;color:var(--dim)">'+(avg>7?'⚠ High chronic stress — accelerates neurodegeneration and aging':avg>5?'Moderate stress — focus on regular exercise and sleep':'Good stress management — upload readiness maintained')+'</span>';
}
</script>
'@

$content = AddBeforeBodyEnd $content $add181
WriteV 181 $content

# ============================================================
# V182 — NUTRITION FOR NEURONS
# ============================================================
Write-Host "Building v182..."
$content = [System.IO.File]::ReadAllText("$base\181\index.html")
$content = $content.Replace('<title>NeuroScan v181 — Stress Tracker</title>', '<title>NeuroScan v182 — Brain Nutrition</title>')
$content = AddAfterBtn $content "bStressTrack" '<div class="hb" id="bBrainNutr" onclick="toggleBrainNutrPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#129367; NUTRITION</div>'

$add182 = @'
<style>
.brain-nutr-panel{top:60px;right:10px;width:510px;max-height:82vh;overflow-y:auto}
.bn-nutrient{background:var(--panel2);border:1px solid var(--b1);border-radius:7px;padding:9px 12px;margin-bottom:6px}
.bn-nutr-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:4px}
.bn-nutr-name{font-size:12px;font-weight:700;color:var(--accent)}
.bn-nutr-dose{font-size:10px;color:var(--gold);background:rgba(255,200,74,.1);padding:2px 7px;border-radius:10px}
.bn-nutr-mech{font-size:10px;color:var(--dim);margin-bottom:3px}
.bn-nutr-food{font-size:10px;color:var(--text)}
.bn-avoid-item{display:flex;gap:8px;align-items:flex-start;padding:5px 0;border-bottom:1px solid rgba(255,85,104,.08)}
.bn-meal-day{background:var(--panel2);border:1px solid var(--b1);border-radius:7px;padding:10px;margin-bottom:6px}
.bn-meal-day-title{font-size:10px;font-weight:700;color:var(--accent2);margin-bottom:6px;letter-spacing:.06em}
.bn-meal-slot{font-size:11px;color:var(--text);padding:3px 0;border-bottom:1px solid rgba(58,184,255,.06)}
.bn-diet-card{border-radius:7px;padding:10px 12px;margin-bottom:7px}
</style>
<div id="brain-nutr-panel" class="feature-panel brain-nutr-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#129367; BRAIN NUTRITION</span>
    <span class="fp-sub">6 key brain nutrients + diet patterns + 3-day meal plan</span>
    <span class="fp-close" onclick="toggleBrainNutrPanel()">&#215;</span>
  </div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:8px">KEY BRAIN NUTRIENTS</div>
  <div class="bn-nutrient">
    <div class="bn-nutr-head"><span class="bn-nutr-name">Omega-3 (DHA/EPA)</span><span class="bn-nutr-dose">2-3g DHA/EPA daily</span></div>
    <div class="bn-nutr-mech">DHA is a structural component of neuronal membranes (40% of brain fat). EPA reduces neuroinflammation. Low omega-3 index predicts smaller brain volume and cognitive decline.</div>
    <div class="bn-nutr-food">&#127839; Fatty fish (salmon, sardines, mackerel) 3x/week &bull; Algae-based DHA supplement (vegan) &bull; Walnuts (ALA — less bioavailable)</div>
  </div>
  <div class="bn-nutrient">
    <div class="bn-nutr-head"><span class="bn-nutr-name">Choline</span><span class="bn-nutr-dose">550mg/day (men), 425mg/day (women)</span></div>
    <div class="bn-nutr-mech">Precursor to acetylcholine — neurotransmitter for memory and learning. Required for myelin synthesis. 90% of Americans are deficient.</div>
    <div class="bn-nutr-food">&#129428; Eggs (2 eggs = 250mg) &bull; Liver &bull; Beef &bull; Soy lecithin &bull; Supplements: Alpha-GPC or CDP-choline (best bioavailability)</div>
  </div>
  <div class="bn-nutrient">
    <div class="bn-nutr-head"><span class="bn-nutr-name">Magnesium (especially Mg-L-Threonate)</span><span class="bn-nutr-dose">300-400mg elemental Mg daily</span></div>
    <div class="bn-nutr-mech">Cofactor in 300+ enzymatic reactions. Blocks NMDA receptors at rest (preventing excitotoxicity). Mg-L-Threonate crosses BBB and raises brain Mg levels — improves synaptic density.</div>
    <div class="bn-nutr-food">&#127807; Dark leafy greens &bull; Pumpkin seeds &bull; Dark chocolate &bull; Supplements: Mg glycinate (sleep) or Mg-L-Threonate (cognition)</div>
  </div>
  <div class="bn-nutrient">
    <div class="bn-nutr-head"><span class="bn-nutr-name">Vitamin B12</span><span class="bn-nutr-dose">2.4mcg/day (higher in elderly)</span></div>
    <div class="bn-nutr-mech">Required for myelin synthesis and DNA methylation. Deficiency causes demyelination, cognitive decline, depression. Very common in vegans and elderly (impaired absorption).</div>
    <div class="bn-nutr-food">&#129385; Meat, fish, dairy &bull; Fortified plant milk &bull; Supplements: methylcobalamin (preferred form over cyanocobalamin)</div>
  </div>
  <div class="bn-nutrient">
    <div class="bn-nutr-head"><span class="bn-nutr-name">Zinc</span><span class="bn-nutr-dose">8-11mg/day</span></div>
    <div class="bn-nutr-mech">Modulates synaptic transmission, required for neurogenesis. Zinc-deficiency impairs hippocampal function. High zinc concentration in hippocampus and amygdala.</div>
    <div class="bn-nutr-food">&#127858; Oysters (highest source), beef, pumpkin seeds, legumes &bull; Supplements: zinc picolinate (best absorbed)</div>
  </div>
  <div class="bn-nutrient">
    <div class="bn-nutr-head"><span class="bn-nutr-name">Flavonoids (especially EGCG, quercetin, anthocyanins)</span><span class="bn-nutr-dose">500-1000mg/day via food</span></div>
    <div class="bn-nutr-mech">Anti-inflammatory, protect neurons from oxidative stress, increase BDNF, improve blood flow to brain. MIND diet (berry-rich) reduces Alzheimer's risk 35%.</div>
    <div class="bn-nutr-food">&#127815; Blueberries (daily), dark chocolate 70%+, green tea, red wine (moderate), pomegranate, citrus</div>
  </div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin:10px 0 6px">WHAT TO AVOID</div>
  <div class="bn-avoid-item"><span style="color:var(--red);font-size:13px">✗</span><span style="font-size:11px;color:var(--text)"><b>Trans fats</b> — impair memory, damage hippocampus, increase dementia risk 75% in heavy consumers</span></div>
  <div class="bn-avoid-item"><span style="color:var(--red);font-size:13px">✗</span><span style="font-size:11px;color:var(--text)"><b>Excess alcohol</b> — neurotoxic above 7-14 units/week. Shrinks hippocampus. Wine in moderation: debated (flavonoids vs. toxicity)</span></div>
  <div class="bn-avoid-item"><span style="color:var(--red);font-size:13px">✗</span><span style="font-size:11px;color:var(--text)"><b>Ultra-processed foods</b> — associated with 28% faster cognitive decline (BMJ 2022 study, 10,000+ subjects)</span></div>
  <div class="bn-avoid-item"><span style="color:var(--red);font-size:13px">✗</span><span style="font-size:11px;color:var(--text)"><b>High sugar / insulin spikes</b> — Alzheimer's is sometimes called "Type 3 diabetes." Chronic high insulin impairs BDNF and promotes amyloid accumulation</span></div>
  <div style="margin-top:12px;background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:7px;padding:10px;font-size:11px;color:var(--dim)">&#11088; <b style="color:var(--accent)">Digital Advantage:</b> Digital minds require no nutrition. But biological brains — and the upload process — depend critically on neuronal integrity maintained through diet over decades.</div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin:12px 0 6px">3-DAY BRAIN-OPTIMIZED MEAL PLAN</div>
  <div class="bn-meal-day">
    <div class="bn-meal-day-title">DAY 1</div>
    <div class="bn-meal-slot"><b>Breakfast:</b> Smoked salmon + 2 eggs + blueberries + green tea</div>
    <div class="bn-meal-slot"><b>Lunch:</b> Mediterranean salad (olive oil, sardines, leafy greens, walnuts)</div>
    <div class="bn-meal-slot"><b>Dinner:</b> Grilled salmon + quinoa + broccoli + dark chocolate (25g)</div>
    <div class="bn-meal-slot"><b>Supplements:</b> Omega-3 (2g), Mg-L-Threonate (144mg), Alpha-GPC (300mg)</div>
  </div>
  <div class="bn-meal-day">
    <div class="bn-meal-day-title">DAY 2</div>
    <div class="bn-meal-slot"><b>Breakfast:</b> Oats + mixed berries + walnuts + B12-fortified almond milk</div>
    <div class="bn-meal-slot"><b>Lunch:</b> Chicken + lentil soup + turmeric + black pepper</div>
    <div class="bn-meal-slot"><b>Dinner:</b> Grass-fed beef liver (monthly!) + sweet potato + leafy greens</div>
    <div class="bn-meal-slot"><b>Snacks:</b> Pumpkin seeds, dark chocolate, pomegranate juice</div>
  </div>
  <div class="bn-meal-day">
    <div class="bn-meal-day-title">DAY 3</div>
    <div class="bn-meal-slot"><b>Breakfast:</b> Avocado toast + poached eggs + tomatoes + green tea with lemon</div>
    <div class="bn-meal-slot"><b>Lunch:</b> Tuna sashimi or canned tuna + brown rice + miso soup</div>
    <div class="bn-meal-slot"><b>Dinner:</b> Mackerel + roasted vegetables + olive oil + red wine (1 glass, optional)</div>
    <div class="bn-meal-slot"><b>Supplements:</b> Zinc picolinate (11mg), Vitamin D3 (2000IU), B-complex</div>
  </div>
</div>
<script>
var brainNutrOpen=false;
function toggleBrainNutrPanel(){
  brainNutrOpen=!brainNutrOpen;
  var p=document.getElementById('brain-nutr-panel'),b=document.getElementById('bBrainNutr');
  if(p)p.classList.toggle('vis',brainNutrOpen);if(b)b.classList.toggle('on',brainNutrOpen);
}
</script>
'@

$content = AddBeforeBodyEnd $content $add182
WriteV 182 $content

# ============================================================
# V183 — EXERCISE & NEUROGENESIS
# ============================================================
Write-Host "Building v183..."
$content = [System.IO.File]::ReadAllText("$base\182\index.html")
$content = $content.Replace('<title>NeuroScan v182 — Brain Nutrition</title>', '<title>NeuroScan v183 — Exercise & Brain</title>')
$content = AddAfterBtn $content "bBrainNutr" '<div class="hb" id="bExerciseBrain" onclick="toggleExerciseBrainPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#127939; EXERCISE</div>'

$add183 = @'
<style>
.exercise-brain-panel{top:60px;right:10px;width:500px;max-height:82vh;overflow-y:auto}
.eb-type-card{display:flex;align-items:center;gap:10px;padding:8px 10px;background:var(--panel2);border:1px solid var(--b1);border-radius:7px;margin-bottom:5px}
.eb-type-bar-bg{flex:1;height:10px;background:rgba(255,255,255,.06);border-radius:5px}
.eb-type-bar{height:10px;border-radius:5px}
.eb-type-label{font-size:11px;color:var(--text);width:140px;flex-shrink:0}
.eb-type-pct{font-size:10px;color:var(--accent);width:36px;text-align:right;flex-shrink:0}
.eb-log-row{display:flex;gap:6px;align-items:center;flex-wrap:wrap;margin-bottom:6px}
.eb-log-input{background:var(--panel);border:1px solid var(--b1);color:var(--text);padding:3px 6px;border-radius:4px;font-size:11px}
.eb-log-select{background:var(--panel);border:1px solid var(--b1);color:var(--text);padding:3px 6px;border-radius:4px;font-size:11px}
.eb-log-item{display:flex;justify-content:space-between;padding:5px 8px;background:var(--panel2);border-radius:5px;margin-bottom:3px;font-size:11px}
.eb-bdnf-meter{height:14px;background:rgba(255,255,255,.05);border-radius:7px;overflow:hidden;margin-top:4px}
.eb-bdnf-fill{height:14px;border-radius:7px;background:linear-gradient(90deg,#50e8a0,#3ab8ff);transition:.5s}
</style>
<div id="exercise-brain-panel" class="feature-panel exercise-brain-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#127939; EXERCISE & NEUROGENESIS</span>
    <span class="fp-sub">BDNF, hippocampal neurogenesis, and your exercise log</span>
    <span class="fp-close" onclick="toggleExerciseBrainPanel()">&#215;</span>
  </div>
  <div style="background:rgba(80,232,160,.05);border:1px solid rgba(80,232,160,.2);border-radius:7px;padding:10px;margin-bottom:10px;font-size:11px;color:var(--text);line-height:1.5">
    <b style="color:var(--accent2)">BDNF — Brain-Derived Neurotrophic Factor</b> is often called "fertilizer for neurons." It promotes synaptic plasticity, neuronal survival, and is the primary driver of adult neurogenesis in the hippocampus. Exercise is the most powerful known stimulator of BDNF production — more effective than any supplement.
  </div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:6px">BDNF EFFECT BY EXERCISE TYPE</div>
  <div class="eb-type-card"><span class="eb-type-label">Aerobic (Zone 2)</span><div class="eb-type-bar-bg"><div class="eb-type-bar" style="width:75%;background:#3ab8ff"></div></div><span class="eb-type-pct">+75%</span></div>
  <div class="eb-type-card"><span class="eb-type-label">HIIT</span><div class="eb-type-bar-bg"><div class="eb-type-bar" style="width:100%;background:#50e8a0"></div></div><span class="eb-type-pct">+100%</span></div>
  <div class="eb-type-card"><span class="eb-type-label">Resistance Training</span><div class="eb-type-bar-bg"><div class="eb-type-bar" style="width:55%;background:#c084fc"></div></div><span class="eb-type-pct">+55%</span></div>
  <div class="eb-type-card"><span class="eb-type-label">Yoga / Flexibility</span><div class="eb-type-bar-bg"><div class="eb-type-bar" style="width:25%;background:#ffc84a"></div></div><span class="eb-type-pct">+25%</span></div>
  <div style="font-size:10px;color:var(--dim);margin-bottom:10px;line-height:1.4">
    &#9679; <b style="color:var(--text)">Adult neurogenesis</b> in the hippocampus requires: exercise + novel experiences + adequate sleep. Without all three, new neurons don't survive. VO2max improvement is the strongest predictor.
  </div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:6px">LOG EXERCISE SESSION</div>
  <div class="eb-log-row">
    <select id="eb-type" class="eb-log-select"><option value="hiit">HIIT</option><option value="aerobic">Aerobic</option><option value="resistance">Resistance</option><option value="yoga">Yoga/Flexibility</option><option value="sports">Sports/Other</option></select>
    <input id="eb-minutes" class="eb-log-input" type="number" value="30" min="5" max="180" style="width:60px"> min
    <select id="eb-intensity" class="eb-log-select"><option value="3">High</option><option value="2">Moderate</option><option value="1">Light</option></select>
    <button onclick="logExercise()" style="padding:5px 12px;background:rgba(80,232,160,.12);border:1px solid rgba(80,232,160,.3);color:var(--accent2);border-radius:5px;font-size:11px;cursor:pointer">LOG</button>
  </div>
  <div id="eb-log-list" style="max-height:120px;overflow-y:auto;margin-bottom:10px"></div>
  <div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:4px">ESTIMATED BDNF SCORE (7-DAY)</div>
  <div style="font-size:11px;color:var(--dim);margin-bottom:4px" id="eb-bdnf-label">—</div>
  <div class="eb-bdnf-meter"><div class="eb-bdnf-fill" id="eb-bdnf-fill" style="width:0%"></div></div>
  <div style="font-size:9px;color:var(--dim);margin-top:4px">0 = sedentary baseline &nbsp;|&nbsp; 100 = optimally exercised</div>
</div>
<script>
var exerciseBrainOpen=false;
var EX_BDNF={hiit:10,aerobic:7.5,resistance:5.5,yoga:2.5,sports:6};
var EX_INTENS=[1,1,1.5,2,2.5];
function toggleExerciseBrainPanel(){
  exerciseBrainOpen=!exerciseBrainOpen;
  var p=document.getElementById('exercise-brain-panel'),b=document.getElementById('bExerciseBrain');
  if(p)p.classList.toggle('vis',exerciseBrainOpen);if(b)b.classList.toggle('on',exerciseBrainOpen);
  if(exerciseBrainOpen){renderExerciseLog();calcBdnfScore();}
}
function logExercise(){
  var type=document.getElementById('eb-type').value;
  var mins=parseInt(document.getElementById('eb-minutes').value)||30;
  var intensity=parseInt(document.getElementById('eb-intensity').value)||2;
  var log=JSON.parse(localStorage.getItem('ns_exercise_log')||'[]');
  log.push({type:type,mins:mins,intensity:intensity,date:new Date().toISOString().slice(0,10)});
  if(log.length>100)log=log.slice(-100);
  localStorage.setItem('ns_exercise_log',JSON.stringify(log));
  renderExerciseLog();calcBdnfScore();
}
function renderExerciseLog(){
  var log=JSON.parse(localStorage.getItem('ns_exercise_log')||'[]');
  var el=document.getElementById('eb-log-list');if(!el)return;
  var recent=log.slice(-10).reverse();
  el.innerHTML=recent.map(function(e){
    var col=e.type==='hiit'?'var(--accent2)':e.type==='aerobic'?'var(--accent)':'var(--dim)';
    return '<div class="eb-log-item"><span style="color:'+col+'">'+e.type.toUpperCase()+'</span><span>'+e.mins+' min</span><span>Intensity: '+['','Light','Moderate','High'][e.intensity]+'</span><span style="color:var(--dim)">'+e.date+'</span></div>';
  }).join('');
  if(!recent.length)el.innerHTML='<div style="font-size:11px;color:var(--dim);padding:6px">No sessions logged yet.</div>';
}
function calcBdnfScore(){
  var log=JSON.parse(localStorage.getItem('ns_exercise_log')||'[]');
  var now=new Date(),weekAgo=new Date(now-7*86400000);
  var recent=log.filter(function(e){return new Date(e.date)>weekAgo;});
  var score=0;
  recent.forEach(function(e){score+=EX_BDNF[e.type]*e.intensity*(e.mins/30);});
  score=Math.min(100,Math.round(score));
  var fill=document.getElementById('eb-bdnf-fill');
  var label=document.getElementById('eb-bdnf-label');
  if(fill)fill.style.width=score+'%';
  if(label){
    var desc=score>70?'Excellent — high neurogenesis, strong memory consolidation':score>40?'Good — meaningful BDNF boost, hippocampus actively growing':score>15?'Moderate — some benefit, increase frequency':  'Low — minimal neurogenesis stimulus this week';
    label.innerHTML='<b style="color:var(--accent2)">'+score+'/100</b> — '+desc;
  }
}
</script>
'@

$content = AddBeforeBodyEnd $content $add183
WriteV 183 $content

# ============================================================
# V184 — BIOMARKER TRACKING
# ============================================================
Write-Host "Building v184..."
$content = [System.IO.File]::ReadAllText("$base\183\index.html")
$content = $content.Replace('<title>NeuroScan v183 — Exercise & Brain</title>', '<title>NeuroScan v184 — Biomarkers</title>')
$content = AddAfterBtn $content "bExerciseBrain" '<div class="hb" id="bBiomarkers" onclick="toggleBiomarkersPanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#128300; BIOMARKERS</div>'

$add184 = @'
<style>
.biomarkers-panel{top:60px;right:10px;width:520px;max-height:82vh;overflow-y:auto}
.bm-card{background:var(--panel2);border:1px solid var(--b1);border-radius:7px;padding:10px 12px;margin-bottom:6px;transition:.2s}
.bm-card-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:5px}
.bm-name{font-size:12px;font-weight:700;color:var(--accent)}
.bm-traffic{width:14px;height:14px;border-radius:50%;flex-shrink:0}
.bm-desc{font-size:10px;color:var(--dim);margin-bottom:4px}
.bm-range{font-size:10px;color:var(--accent2);margin-bottom:4px}
.bm-log-row{display:flex;gap:6px;align-items:center;margin-top:5px}
.bm-log-input{background:var(--panel);border:1px solid var(--b1);color:var(--text);padding:3px 6px;border-radius:4px;font-size:11px;width:100px}
.bm-log-btn{padding:3px 10px;background:rgba(58,184,255,.1);border:1px solid var(--b1);color:var(--accent);border-radius:4px;font-size:10px;cursor:pointer}
.bm-last-val{font-size:11px;padding:2px 8px;border-radius:4px;font-weight:600}
.bm-score-display{text-align:center;padding:14px;background:var(--panel2);border:1px solid var(--b2);border-radius:10px;margin-bottom:10px}
</style>
<div id="biomarkers-panel" class="feature-panel biomarkers-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#128300; BIOMARKER TRACKING</span>
    <span class="fp-sub">8 key brain health biomarkers with traffic light system</span>
    <span class="fp-close" onclick="toggleBiomarkersPanel()">&#215;</span>
  </div>
  <div id="bm-score-area"></div>
  <div id="bm-cards-area"></div>
  <div style="margin-top:10px;background:rgba(58,184,255,.04);border:1px solid var(--b1);border-radius:7px;padding:10px;font-size:11px;color:var(--dim)">
    <b style="color:var(--accent)">How to get tested:</b> Ask your GP for a "comprehensive metabolic panel + lipids + HbA1c + vitamin D + homocysteine." Many tests covered by insurance. Private labs (Quest, LabCorp, Medichecks UK): ~$50-150 for full panel. Genetic tests (23andMe, AncestryDNA): APOE status available.
  </div>
</div>
<script>
var biomarkersOpen=false;
var BM_DATA=[
  {id:'apoe',name:'APOE Genotype',unit:'genotype',desc:'The single strongest genetic risk factor for late-onset Alzheimer\'s. APOE e4 allele is present in ~25% of population.',optimal:'e2/e3 or e3/e3',ranges:['e2/e3 (protective)','e3/e3 (average)','e3/e4 (3x risk)','e4/e4 (8-12x risk)'],thresholds:[0,1,2,3],test:'23andMe, AncestryDNA, or doctor-ordered genetic panel'},
  {id:'crp',name:'CRP (C-Reactive Protein)',unit:'mg/L',desc:'Marker of systemic inflammation. Chronic low-grade inflammation accelerates neurodegeneration.',optimal:'<1.0 mg/L',ranges:[[0,1,'green'],[1,3,'yellow'],[3,100,'red']],test:'Basic blood test, usually included in panels'},
  {id:'hba1c',name:'HbA1c (Glycated Hemoglobin)',unit:'%',desc:'3-month average blood sugar. Alzheimer\'s has been called "Type 3 diabetes" — chronic high insulin impairs BDNF.',optimal:'4.8-5.2%',ranges:[[0,5.2,'green'],[5.2,5.7,'green'],[5.7,6.5,'yellow'],[6.5,20,'red']],test:'Fasting blood draw'},
  {id:'bp',name:'Blood Pressure',unit:'mmHg systolic',desc:'Hypertension is the #1 modifiable dementia risk factor. Damages cerebral small vessels.',optimal:'<120 mmHg systolic',ranges:[[0,120,'green'],[120,130,'yellow'],[130,200,'red']],test:'Home monitor or GP visit'},
  {id:'vitd',name:'Vitamin D (25-OH)',unit:'ng/mL',desc:'Vitamin D receptors in hippocampus and cortex. Deficiency associated with 2x dementia risk.',optimal:'50-80 ng/mL',ranges:[[0,30,'red'],[30,50,'yellow'],[50,100,'green'],[100,200,'red']],test:'Simple blood test; most people are deficient'},
  {id:'homocys',name:'Homocysteine',unit:'μmol/L',desc:'High homocysteine causes vascular damage and is directly neurotoxic. B vitamins lower it.',optimal:'<8 μmol/L',ranges:[[0,8,'green'],[8,12,'yellow'],[12,100,'red']],test:'Blood test; ask for it specifically (often excluded from standard panels)'},
  {id:'omega3idx',name:'Omega-3 Index',unit:'%',desc:'% of EPA+DHA in red blood cell membranes. Most powerful predictor of brain health among blood biomarkers.',optimal:'8-12%',ranges:[[0,4,'red'],[4,8,'yellow'],[8,12,'green'],[12,20,'yellow']],test:'OmegaQuant home test kit ($60). Finger-prick blood spot.'},
  {id:'sleepq',name:'Sleep Quality (Subjective)',unit:'score 1-10',desc:'Self-reported sleep quality. Poor sleep is both a symptom and cause of brain aging.',optimal:'8-10/10',ranges:[[0,5,'red'],[5,7,'yellow'],[7,10,'green']],test:'Track via your sleep diary in Sleep Optimizer'}
];
function toggleBiomarkersPanel(){
  biomarkersOpen=!biomarkersOpen;
  var p=document.getElementById('biomarkers-panel'),b=document.getElementById('bBiomarkers');
  if(p)p.classList.toggle('vis',biomarkersOpen);if(b)b.classList.toggle('on',biomarkersOpen);
  if(biomarkersOpen){renderBmCards();renderBmScore();}
}
function bmStatus(marker,val){
  if(!val)return'gray';
  if(marker.id==='apoe'){var v=parseFloat(val);return v<1?'#50e8a0':v<2?'#ffc84a':'#ff5568';}
  if(!marker.ranges||!Array.isArray(marker.ranges[0]))return'gray';
  for(var i=0;i<marker.ranges.length;i++){
    var r=marker.ranges[i];
    if(val>=r[0]&&val<r[1]){return r[2]==='green'?'#50e8a0':r[2]==='yellow'?'#ffc84a':'#ff5568';}
  }
  return'gray';
}
function renderBmCards(){
  var saved=JSON.parse(localStorage.getItem('ns_biomarkers')||'{}');
  var el=document.getElementById('bm-cards-area');if(!el)return;
  el.innerHTML=BM_DATA.map(function(m){
    var val=saved[m.id];
    var col=bmStatus(m,val);
    return '<div class="bm-card">'
      +'<div class="bm-card-head"><span class="bm-name">'+m.name+'</span><div class="bm-traffic" style="background:'+col+';box-shadow:0 0 6px '+col+'40"></div></div>'
      +'<div class="bm-desc">'+m.desc+'</div>'
      +'<div class="bm-range">Optimal: '+m.optimal+'</div>'
      +'<div class="bm-log-row">'
      +'<input id="bm-inp-'+m.id+'" class="bm-log-input" type="text" placeholder="Enter value ('+m.unit+')" value="'+(val||'')+'">'
      +'<button class="bm-log-btn" onclick="saveBmVal(\''+m.id+'\')">SAVE</button>'
      +(val?'<span class="bm-last-val" style="background:'+col+'22;color:'+col+'">'+val+' '+m.unit+'</span>':'')
      +'</div>'
      +'<div style="font-size:9px;color:var(--dim);margin-top:4px">HOW TO TEST: '+m.test+'</div>'
      +'</div>';
  }).join('');
}
function saveBmVal(id){
  var inp=document.getElementById('bm-inp-'+id);if(!inp)return;
  var saved=JSON.parse(localStorage.getItem('ns_biomarkers')||'{}');
  saved[id]=inp.value;
  localStorage.setItem('ns_biomarkers',JSON.stringify(saved));
  renderBmCards();renderBmScore();
}
function renderBmScore(){
  var saved=JSON.parse(localStorage.getItem('ns_biomarkers')||'{}');
  var filled=Object.keys(saved).filter(function(k){return saved[k];}).length;
  var el=document.getElementById('bm-score-area');if(!el)return;
  el.innerHTML='<div class="bm-score-display"><div style="font-size:10px;letter-spacing:.1em;color:var(--dim)">BIOMARKER COMPLETENESS</div>'
    +'<div style="font-size:28px;font-weight:900;color:var(--accent)">'+filled+' / '+BM_DATA.length+'</div>'
    +'<div style="font-size:10px;color:var(--dim)">biomarkers logged</div></div>';
}
</script>
'@

$content = AddBeforeBodyEnd $content $add184
WriteV 184 $content

# ============================================================
# V185 — LONGEVITY SCORE
# ============================================================
Write-Host "Building v185..."
$content = [System.IO.File]::ReadAllText("$base\184\index.html")
$content = $content.Replace('<title>NeuroScan v184 — Biomarkers</title>', '<title>NeuroScan v185 — Longevity Score</title>')
$content = AddAfterBtn $content "bBiomarkers" '<div class="hb" id="bLongevityScore" onclick="toggleLongevityScorePanel()" style="border-color:rgba(255,200,74,.3);color:rgba(255,200,74,.7)">&#9854; LONGEVITY SCORE</div>'

$add185 = @'
<style>
.longevity-score-panel{top:60px;right:10px;width:500px;max-height:82vh;overflow-y:auto}
.ls-big-score{text-align:center;padding:20px;background:linear-gradient(135deg,rgba(255,200,74,.08),rgba(58,184,255,.08));border:1px solid var(--b2);border-radius:12px;margin-bottom:12px}
.ls-score-num{font-size:64px;font-weight:900;line-height:1;background:linear-gradient(135deg,#ffc84a,#3ab8ff);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
.ls-breakdown{margin-bottom:12px}
.ls-breakdown-row{display:flex;align-items:center;gap:8px;margin-bottom:5px}
.ls-breakdown-label{font-size:10px;color:var(--text);width:100px;flex-shrink:0}
.ls-breakdown-bar-bg{flex:1;height:8px;background:rgba(255,255,255,.06);border-radius:4px}
.ls-breakdown-bar{height:8px;border-radius:4px;transition:.5s}
.ls-breakdown-val{font-size:10px;color:var(--dim);width:50px;text-align:right;flex-shrink:0}
.ls-projection{background:var(--panel2);border:1px solid var(--b1);border-radius:8px;padding:12px;margin-bottom:10px}
.ls-proj-title{font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:8px}
.ls-proj-row{display:flex;justify-content:space-between;padding:4px 0;border-bottom:1px solid rgba(58,184,255,.06);font-size:11px}
.ls-upload-vs-death{border-radius:8px;padding:12px;margin-bottom:10px;text-align:center}
.ls-green-outcome{background:rgba(80,232,160,.08);border:1px solid rgba(80,232,160,.2)}
.ls-red-outcome{background:rgba(255,85,104,.06);border:1px solid rgba(255,85,104,.2)}
</style>
<div id="longevity-score-panel" class="feature-panel longevity-score-panel">
  <div class="fp-header" style="position:relative">
    <span class="fp-title">&#9854; LONGEVITY SCORE</span>
    <span class="fp-sub">Aggregate score from all Phase 8 data — upload timeline projection</span>
    <span class="fp-close" onclick="toggleLongevityScorePanel()">&#215;</span>
  </div>
  <div class="ls-big-score">
    <div style="font-size:9px;letter-spacing:.12em;color:var(--dim);margin-bottom:4px">YOUR LONGEVITY SCORE</div>
    <div class="ls-score-num" id="ls-total-score">—</div>
    <div style="font-size:11px;color:var(--dim);margin-top:4px" id="ls-score-label">Click CALCULATE to update</div>
    <button onclick="calcLongevityScore()" style="margin-top:12px;padding:8px 22px;background:rgba(255,200,74,.12);border:1px solid rgba(255,200,74,.4);color:var(--gold);border-radius:7px;font-size:12px;font-weight:600;cursor:pointer;letter-spacing:.06em">CALCULATE SCORE</button>
  </div>
  <div class="ls-breakdown" id="ls-breakdown"></div>
  <div class="ls-projection" id="ls-projection"></div>
  <div id="ls-upload-death" style="display:none"></div>
  <div id="ls-monthly-plan" style="display:none"></div>
</div>
<script>
var longevityScoreOpen=false;
function toggleLongevityScorePanel(){
  longevityScoreOpen=!longevityScoreOpen;
  var p=document.getElementById('longevity-score-panel'),b=document.getElementById('bLongevityScore');
  if(p)p.classList.toggle('vis',longevityScoreOpen);if(b)b.classList.toggle('on',longevityScoreOpen);
  if(longevityScoreOpen)calcLongevityScore();
}
function calcLongevityScore(){
  // Sleep (20%)
  var sleepData=JSON.parse(localStorage.getItem('ns_sleep_diary')||'null');
  var sleepScore=50;
  if(sleepData){var avgH=sleepData.reduce(function(a,b){return a+b.h;},0)/7;var avgQ=sleepData.reduce(function(a,b){return a+b.q;},0)/7;sleepScore=Math.round((avgH/8)*60+(avgQ/5)*40);}
  // Exercise (25%)
  var exLog=JSON.parse(localStorage.getItem('ns_exercise_log')||'[]');
  var exBdnf={hiit:10,aerobic:7.5,resistance:5.5,yoga:2.5,sports:6};
  var now=new Date(),weekAgo=new Date(now-7*86400000);
  var recentEx=exLog.filter(function(e){return new Date(e.date)>weekAgo;});
  var exRaw=0;recentEx.forEach(function(e){exRaw+=exBdnf[e.type||'aerobic']*e.intensity*(e.mins/30);});
  var exScore=Math.min(100,Math.round(exRaw));
  // Stress (20%)
  var stressLog=JSON.parse(localStorage.getItem('ns_stress_log')||'{}');
  var stressVals=Object.values(stressLog).map(Number).slice(-30);
  var stressScore=50;
  if(stressVals.length>0){var avgS=stressVals.reduce(function(a,b){return a+b;},0)/stressVals.length;stressScore=Math.round((1-avgS/10)*100);}
  // Biomarkers (20%)
  var bmData=JSON.parse(localStorage.getItem('ns_biomarkers')||'{}');
  var bmFilled=Object.keys(bmData).filter(function(k){return bmData[k];}).length;
  var bmScore=Math.round(bmFilled/8*100);
  // Nutrition (15%) - estimated from habits (no direct tracker, use brain health habits)
  var habits=JSON.parse(localStorage.getItem('ns_brain_habits')||'null');
  var nutrScore=habits?Math.round(habits.diet*10):50;

  var total=Math.round(sleepScore*0.20+exScore*0.25+stressScore*0.20+bmScore*0.20+nutrScore*0.15);
  document.getElementById('ls-total-score').textContent=total;
  var desc=total>=80?'Excellent — optimized for longevity':total>=60?'Good — with targeted improvements':total>=40?'Moderate — significant opportunities':  'Needs attention — critical improvements required';
  document.getElementById('ls-score-label').textContent=desc;

  var components=[
    {label:'Sleep (20%)',score:sleepScore,weight:.2,color:'#3ab8ff'},
    {label:'Exercise (25%)',score:exScore,weight:.25,color:'#50e8a0'},
    {label:'Stress (20%)',score:stressScore,weight:.2,color:'#c084fc'},
    {label:'Biomarkers (20%)',score:bmScore,weight:.2,color:'#ffc84a'},
    {label:'Nutrition (15%)',score:nutrScore,weight:.15,color:'#ff9060'}
  ];
  document.getElementById('ls-breakdown').innerHTML='<div style="font-size:9px;letter-spacing:.1em;color:var(--dim);margin-bottom:6px">SCORE BREAKDOWN</div>'
    +components.map(function(c){
      return '<div class="ls-breakdown-row"><span class="ls-breakdown-label">'+c.label+'</span><div class="ls-breakdown-bar-bg"><div class="ls-breakdown-bar" style="width:'+c.score+'%;background:'+c.color+'"></div></div><span class="ls-breakdown-val">'+c.score+'/100</span></div>';
    }).join('');

  // Projection
  var uploadYear=total>=80?2038:total>=60?2042:total>=40?2050:2065;
  var deathAge=total>=80?95:total>=60?88:total>=40?82:75;
  var chronAge=parseInt(localStorage.getItem('ns_age')||'35');
  var deathYear=new Date().getFullYear()+(deathAge-chronAge);
  var projEl=document.getElementById('ls-projection');
  projEl.innerHTML='<div class="ls-proj-title">PROJECTION — BASED ON CURRENT LONGEVITY SCORE</div>'
    +'<div class="ls-proj-row"><span>Projected lifespan (healthspan)</span><span style="color:var(--gold)">~'+deathAge+' years ('+deathYear+')</span></div>'
    +'<div class="ls-proj-row"><span>Likely WBE upload capability</span><span style="color:var(--accent2)">~'+uploadYear+'</span></div>'
    +'<div class="ls-proj-row"><span>Years to upload window</span><span style="color:var(--accent)">'+(uploadYear-new Date().getFullYear())+' years</span></div>';

  var udEl=document.getElementById('ls-upload-death');
  if(uploadYear<deathYear){
    udEl.className='ls-upload-vs-death ls-green-outcome';
    udEl.innerHTML='<div style="font-size:13px;font-weight:700;color:var(--accent2)">&#10003; UPLOAD BEFORE DEATH</div><div style="font-size:11px;color:var(--text);margin-top:4px">At your current longevity trajectory, WBE is expected ('+uploadYear+') before your biological death ('+deathYear+'). You make it — if you maintain this lifestyle.</div>';
  } else {
    udEl.className='ls-upload-vs-death ls-red-outcome';
    udEl.innerHTML='<div style="font-size:13px;font-weight:700;color:var(--red)">&#9888; TIMELINE RISK</div><div style="font-size:11px;color:var(--text);margin-top:4px">At current trajectory, your projected biological death ('+deathYear+') may precede WBE availability ('+uploadYear+'). Improving your longevity score extends your window. Each 10-point improvement = ~3 years.</div>';
  }
  udEl.style.display='block';

  // Monthly plan — weakest component
  var weakComp=components.reduce(function(a,b){return a.score<b.score?a:b;});
  var plans={
    'Sleep (20%)':'Get 7.5-8hrs nightly. Set a fixed wake time. Optimize bedroom temperature to 65-68°F.',
    'Exercise (25%)':'Add one HIIT session per week. Even 20 minutes counts. Target 3 quality sessions/week.',
    'Stress (20%)':'Start 10 min daily meditation. Identify and address your #1 stressor this month.',
    'Biomarkers (20%)':'Book a blood test this week. Get CRP, HbA1c, Vitamin D, homocysteine checked.',
    'Nutrition (15%)':'Add 2 servings of fatty fish per week. Replace 1 ultra-processed meal with whole food.'
  };
  var mPlan=document.getElementById('ls-monthly-plan');
  mPlan.style.display='block';
  mPlan.innerHTML='<div style="background:rgba(58,184,255,.05);border:1px solid var(--b1);border-radius:7px;padding:10px;font-size:11px"><b style="color:var(--accent)">HIGHEST IMPACT ACTION THIS MONTH</b><br><br>Weakest area: <b style="color:'+weakComp.color+'">'+weakComp.label+'</b> ('+weakComp.score+'/100)<br><br><span style="color:var(--text)">'+plans[weakComp.label]+'</span></div>';
}
</script>
'@

$content = AddBeforeBodyEnd $content $add185
WriteV 185 $content

Write-Host ""
Write-Host "=== PHASE 8 COMPLETE (v176-v185) ==="
