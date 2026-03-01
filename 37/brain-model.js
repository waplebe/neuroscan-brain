/**
 * Bio-Neural v37 — Простой видимый мозг
 * Непрозрачные сферы, без сложных тем, гарантированная видимость
 */
window.BrainModel = (function() {
    const THREE = window.THREE;
    if (!THREE) return { createBrainGroup: function() { return new THREE.Group(); }, REGIONS: {} };

    const PARTS = [
        { key: 'cortex', name: 'Кора', pos: [0, 0.3, 0], r: 0.5, role: 'Серое вещество' },
        { key: 'frontal', name: 'Лобная доля', pos: [0, 0.45, 0.35], r: 0.22, role: 'Исполнительные функции' },
        { key: 'parietal', name: 'Теменная', pos: [0, 0.35, 0], r: 0.2, role: 'Соматосенсорная кора' },
        { key: 'temporalL', name: 'Височная L', pos: [-0.38, 0.05, 0.05], r: 0.18, role: 'Память, речь' },
        { key: 'temporalR', name: 'Височная R', pos: [0.38, 0.05, 0.05], r: 0.18, role: 'Память, речь' },
        { key: 'occipital', name: 'Затылочная', pos: [0, 0.2, -0.42], r: 0.2, role: 'Зрительная кора' },
        { key: 'cerebellumL', name: 'Мозжечок L', pos: [-0.28, -0.12, -0.45], r: 0.18, role: 'Движение' },
        { key: 'cerebellumR', name: 'Мозжечок R', pos: [0.28, -0.12, -0.45], r: 0.18, role: 'Баланс' },
        { key: 'vermis', name: 'Червь мозжечка', pos: [0, -0.15, -0.45], r: 0.1, role: 'Координация' },
        { key: 'brainstem', name: 'Ствол мозга', pos: [0, -0.45, -0.4], r: 0.08, role: 'Мост' },
        { key: 'thalamus', name: 'Таламус', pos: [0, 0.15, 0.1], r: 0.12, role: 'Реле сигналов' }
    ];

    function createBrainGroup(color) {
        const c = typeof color === 'number' ? color : 0x00ff88;
        const group = new THREE.Group();
        const meshes = [];

        PARTS.forEach(p => {
            const geo = new THREE.SphereGeometry(p.r, 20, 16);
            const mat = new THREE.MeshBasicMaterial({ color: c });
            const mesh = new THREE.Mesh(geo, mat);
            mesh.position.set(p.pos[0], p.pos[1], p.pos[2]);
            mesh.userData = { ...p, isBrainRegion: true };
            group.add(mesh);
            meshes.push({ key: p.key, mesh, region: p });
        });

        group.userData.regionMeshes = meshes;
        return group;
    }

    return { createBrainGroup, REGIONS: Object.fromEntries(PARTS.map(p => [p.key, p])) };
})();
