/**
 * Bio-Neural v18 — Движок реалистичных данных
 * Тренды, суточные циклы, сезонность
 */
window.DataEngine = (function() {
    const t0 = Date.now() / 1000;
    // Базовые тренды: черезput растёт утром, падает ночью
    function hourlyCycle() {
        const h = new Date().getHours();
        return 0.7 + 0.3 * Math.sin((h - 6) * Math.PI / 12);
    }
    function throughput() {
        const base = 70 + 15 * hourlyCycle();
        const noise = (Math.random() - 0.5) * 20;
        const trend = Math.sin(t0 * 0.0001) * 5;
        return Math.max(40, Math.min(100, base + noise + trend));
    }
    function latency() {
        const h = new Date().getHours();
        const rush = (h >= 9 && h <= 18) ? 15 : 0;
        return 30 + rush + (Math.random() - 0.3) * 25;
    }
    function rps() {
        return Math.floor(50 + 25 * hourlyCycle() + (Math.random() - 0.5) * 30);
    }
    return { throughput, latency, rps, hourlyCycle };
})();
