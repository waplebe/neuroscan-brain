/**
 * Bio-Neural v38 — Brain Model
 * Регионы с цветами, освещение, соединительные тракты
 */
window.BrainModel = (function() {
    const THREE = window.THREE;
    if (!THREE) return {};

    // Каждый регион: позиция, радиус, цвет, роль
    const PARTS = [
        { key: 'cortexL',   name: 'Кора (Л)',        pos: [-0.22, 0.25, 0],    r: 0.52, color: 0x00e87a, role: 'Серое вещество — левое полушарие' },
        { key: 'cortexR',   name: 'Кора (П)',        pos: [ 0.22, 0.25, 0],    r: 0.52, color: 0x00c87a, role: 'Серое вещество — правое полушарие' },
        { key: 'frontalL',  name: 'Лобная (Л)',       pos: [-0.18, 0.52, 0.38], r: 0.24, color: 0x00d4ff, role: 'Планирование, исполнительные функции' },
        { key: 'frontalR',  name: 'Лобная (П)',       pos: [ 0.18, 0.52, 0.38], r: 0.24, color: 0x00aff5, role: 'Планирование, исполнительные функции' },
        { key: 'parietal',  name: 'Теменная',         pos: [0, 0.58, -0.08],    r: 0.22, color: 0xa0f070, role: 'Соматосенсорная кора, пространство' },
        { key: 'temporalL', name: 'Височная (Л)',     pos: [-0.52, 0.08, 0.1],  r: 0.2,  color: 0xffd060, role: 'Память, речь (зона Вернике)' },
        { key: 'temporalR', name: 'Височная (П)',     pos: [ 0.52, 0.08, 0.1],  r: 0.2,  color: 0xffa040, role: 'Память, слух' },
        { key: 'occipital', name: 'Затылочная',       pos: [0, 0.18, -0.56],    r: 0.22, color: 0xff6b6b, role: 'Зрительная кора (V1)' },
        { key: 'cerL',      name: 'Мозжечок (Л)',    pos: [-0.32, -0.3, -0.5], r: 0.22, color: 0xc084fc, role: 'Движение, координация' },
        { key: 'cerR',      name: 'Мозжечок (П)',    pos: [ 0.32, -0.3, -0.5], r: 0.22, color: 0xa855f7, role: 'Баланс, координация' },
        { key: 'vermis',    name: 'Червь мозжечка',  pos: [0, -0.28, -0.5],    r: 0.11, color: 0xd8b4fe, role: 'Координация движений' },
        { key: 'brainstem', name: 'Ствол мозга',     pos: [0, -0.58, -0.38],   r: 0.1,  color: 0xfb923c, role: 'Дыхание, сердцебиение, сознание' },
        { key: 'thalamus',  name: 'Таламус',         pos: [0, 0.1, 0.05],      r: 0.14, color: 0x38bdf8, role: 'Реле сенсорных сигналов' },
        { key: 'hippocampL',name: 'Гиппокамп (Л)',  pos: [-0.28, -0.04, -0.18],r: 0.1,  color: 0x4ade80, role: 'Формирование памяти' },
        { key: 'hippocampR',name: 'Гиппокамп (П)',  pos: [ 0.28, -0.04, -0.18],r: 0.1,  color: 0x22c55e, role: 'Формирование памяти' },
        { key: 'amygdalaL', name: 'Миндалина (Л)',  pos: [-0.3, -0.02, 0.12], r: 0.08, color: 0xf472b6, role: 'Эмоции, страх' },
        { key: 'amygdalaR', name: 'Миндалина (П)',  pos: [ 0.3, -0.02, 0.12], r: 0.08, color: 0xec4899, role: 'Эмоции, страх' },
    ];

    // Пары для соединительных трактов
    const TRACTS = [
        ['cortexL','cortexR'],
        ['frontalL','parietal'], ['frontalR','parietal'],
        ['parietal','occipital'],
        ['temporalL','hippocampL'], ['temporalR','hippocampR'],
        ['thalamus','frontalL'], ['thalamus','frontalR'],
        ['brainstem','cerL'], ['brainstem','cerR'],
        ['occipital','cerL'], ['occipital','cerR'],
        ['hippocampL','amygdalaL'], ['hippocampR','amygdalaR'],
        ['cortexL','temporalL'], ['cortexR','temporalR'],
    ];

    function noise(x, y, z) {
        return (Math.sin(x * 13.4 + y * 7.3) * Math.cos(z * 11.2 + x * 5.7) + Math.sin(y * 9.1 + z * 6.3)) * 0.5;
    }

    function createBrainGroup() {
        const group = new THREE.Group();
        const meshes = [];
        const partMap = {};
        PARTS.forEach(p => { partMap[p.key] = p; });

        PARTS.forEach(p => {
            const geo = new THREE.SphereGeometry(p.r, 36, 28);
            const pos = geo.attributes.position;
            for (let i = 0; i < pos.count; i++) {
                const v = new THREE.Vector3().fromBufferAttribute(pos, i);
                const n = noise(v.x, v.y, v.z) * 0.045 * p.r;
                v.normalize().multiplyScalar(p.r + n);
                pos.setXYZ(i, v.x, v.y, v.z);
            }
            pos.needsUpdate = true;
            geo.computeVertexNormals();

            const mat = new THREE.MeshPhongMaterial({
                color: p.color,
                emissive: p.color,
                emissiveIntensity: 0.08,
                shininess: 35,
                specular: 0x226644,
                transparent: true,
                opacity: 0.92,
            });
            const mesh = new THREE.Mesh(geo, mat);
            mesh.position.set(...p.pos);
            mesh.userData = { ...p, isBrainRegion: true, baseColor: p.color };
            group.add(mesh);
            meshes.push({ key: p.key, mesh, region: p });
        });

        // Соединительные тракты
        const tractColors = { default: 0x334455, corpus: 0x99ffcc, limbic: 0xff99bb };
        TRACTS.forEach(([a, b]) => {
            const pa = partMap[a], pb = partMap[b];
            if (!pa || !pb) return;
            const p0 = new THREE.Vector3(...pa.pos);
            const p1 = new THREE.Vector3(...pb.pos);
            const mid = p0.clone().add(p1).multiplyScalar(0.5);
            mid.y += 0.12;
            // Кривая Безье через среднюю точку
            const curve = new THREE.QuadraticBezierCurve3(p0, mid, p1);
            const pts = curve.getPoints(20);
            const geo = new THREE.BufferGeometry().setFromPoints(pts);
            const col = (a === 'cortexL' && b === 'cortexR') ? 0x99ffcc : 0x1a6644;
            const mat = new THREE.LineBasicMaterial({ color: col, transparent: true, opacity: 0.35 });
            group.add(new THREE.Line(geo, mat));
        });

        group.userData.regionMeshes = meshes;
        group.userData.partMap = partMap;

        group.userData.setGlowColor = function(hexStr) {
            const base = parseInt(hexStr.replace('#', ''), 16);
            meshes.forEach(({ mesh }) => {
                mesh.material.emissive.setHex(base);
                mesh.material.emissiveIntensity = 0.12;
            });
        };

        return group;
    }

    return { createBrainGroup, PARTS };
})();
