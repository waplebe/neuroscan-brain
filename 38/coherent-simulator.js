/**
 * Bio-Neural v34 — Когерентная симуляция
 * Все метрики связаны: health влияет на throughput, latency, synapses.
 * throughput влияет на totalProcessed. Пересечение порогов → алерты.
 */
window.CoherentSimulator = (function() {
    let health = 87;
    let stress = 0.3;
    let _load = 0.5;

    function hourlyLoad() {
        const h = new Date().getHours();
        return 0.4 + 0.5 * Math.sin((h - 9) * Math.PI / 12);
    }

    function tick() {
        _load = hourlyLoad();
        stress += (_load - 0.5) * 0.02 + (Math.random() - 0.5) * 0.05;
        stress = Math.max(0, Math.min(1, stress));
        health -= stress * 0.8;
        health += (1 - stress) * 0.3;
        health = Math.max(40, Math.min(98, health));
    }

    function snapshot() {
        tick();
        const h = health / 100;
        const throughput = Math.floor(50 + h * 45 + (Math.random() - 0.5) * 15);
        const latency = Math.floor(25 + (100 - health) * 0.5 + _load * 20 + (Math.random() - 0.3) * 12);
        const rps = Math.floor(40 + h * 40 + (Math.random() - 0.5) * 25);
        const synapses = Math.floor(1100 + h * 200 + (Math.random() - 0.5) * 50);
        // totalProcessed растёт пропорционально throughput (выше throughput → больше образцов)
        const samplesDelta = throughput > 85 ? 2 : throughput > 65 ? 1 : Math.random() < h * 0.3 ? 1 : 0;
        return {
            throughput, latency, rps, synapses,
            health: Math.round(health),
            samplesDelta,
            temp: 21.5 + (100 - health) * 0.02 + (Math.random() - 0.5) * 0.3,
            hum: 42 + stress * 8 + (Math.random() - 0.5) * 2
        };
    }

    return { snapshot, get health() { return Math.round(health); } };
})();
