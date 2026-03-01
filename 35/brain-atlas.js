/**
 * Bio-Neural v35+ — Атлас мозга (план 31–55)
 * Области Бродмана, функциональные зоны, сети
 */
window.BrainAtlas = (function() {
    const BRODMANN = {
        4:  { name: 'BA4 (M1)', lobe: 'frontal', role: 'Первичная моторная кора', pos: [0, 0.5, 0.35] },
        3:  { name: 'BA3 (S1)', lobe: 'parietal', role: 'Соматосенсорная', pos: [0, 0.4, 0.2] },
        17: { name: 'BA17 (V1)', lobe: 'occipital', role: 'Зрительная кора', pos: [0, 0.2, -0.4] },
        41: { name: 'BA41 (A1)', lobe: 'temporal', role: 'Слуховая кора', pos: [0, 0, 0] },
        44: { name: 'BA44 Брока', lobe: 'frontal', role: 'Речевая продукция', pos: [-0.15, 0.45, 0.4] },
        22: { name: 'BA22 Вернике', lobe: 'temporal', role: 'Понимание речи', pos: [-0.2, 0.05, 0.1] },
        6:  { name: 'BA6 (SMA)', lobe: 'frontal', role: 'Доп. моторная область', pos: [0, 0.52, 0.42] },
        24: { name: 'BA24 (ACC)', lobe: 'frontal', role: 'Передняя поясная', pos: [0, 0.48, 0.38] },
        23: { name: 'BA23 (PCC)', lobe: 'parietal', role: 'Задняя поясная', pos: [0, 0.22, -0.15] },
    };
    const NETWORKS = {
        DMN: { name: 'Default Mode', nodes: ['PCC', 'mPFC', 'angular'], color: 0xffaa00 },
        SMN: { name: 'Сенсомоторная', nodes: ['M1', 'S1'], color: 0x00ff88 },
        VAN: { name: 'Визуальная', nodes: ['V1', 'V2'], color: 0x0088ff },
        EXEC: { name: 'Исполнительный контроль', nodes: ['DLPFC', 'ACC'], color: 0xff0088 },
        SAL: { name: 'Значимости', nodes: ['ACC', 'insula'], color: 0xff8800 },
    };
    const FUNCTIONAL_ZONES = {
        M1: { name: 'M1 моторная', brodmann: 4 },
        S1: { name: 'S1 сенсорная', brodmann: 3 },
        V1: { name: 'V1 зрительная', brodmann: 17 },
        A1: { name: 'A1 слуховая', brodmann: 41 },
        Broca: { name: 'Брока', brodmann: 44 },
        Wernicke: { name: 'Вернике', brodmann: 22 },
    };
    return { BRODMANN, NETWORKS, FUNCTIONAL_ZONES };
})();
