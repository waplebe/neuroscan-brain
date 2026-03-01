/**
 * Bio-Neural Monitor v17 — Модульная структура
 * Состояние и утилиты
 */
window.BioNeural = (function() {
    const STATE = {
        health: 87, synapses: 1247, totalProcessed: 5271, paused: false,
        activity: [72, 45, 38, 55, 68, 85, 78],
        throughput: [65, 72, 58, 81, 70, 65, 78, 82, 75, 68],
        rps: [45, 62, 58, 71, 55, 68, 72, 58],
        latency: [42, 38, 45, 35, 40, 38, 42, 35, 38, 40],
        weekData: [60, 75, 68, 82, 78, 85, 72],
        env: { temp: 22.3, hum: 44, status: 'НОРМА' },
        alerts: [{ msg: 'Модуль v17 загружен', type: 'ok', time: '00:00:00' }],
        log: []
    };
    function now() {
        const d = new Date();
        return `${String(d.getHours()).padStart(2,'0')}:${String(d.getMinutes()).padStart(2,'0')}:${String(d.getSeconds()).padStart(2,'0')}`;
    }
    function addLog(msg, type = 'ok') { STATE.log.unshift({ ts: now(), msg, type }); if (STATE.log.length > 14) STATE.log.pop(); }
    function addAlert(msg, type = 'ok') { STATE.alerts.unshift({ msg, type, time: now() }); if (STATE.alerts.length > 5) STATE.alerts.pop(); }
    const KEY = 'bioNeural_v19';
    function save() { try { localStorage.setItem(KEY, JSON.stringify({...STATE, savedAt: new Date().toISOString()})); } catch(e){} }
    function load() { try { const r = localStorage.getItem(KEY); if(r){ Object.assign(STATE, JSON.parse(r)); STATE.paused = false; return true; } } catch(e){} return false; }
    return { STATE, now, addLog, addAlert, save, load, version: 19 };
})();
