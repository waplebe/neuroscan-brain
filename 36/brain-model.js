/**
 * Bio-Neural v35+ — Оцифровка мозга (план 1–30+)
 * Пункты 1–10: сферы, щель, мозжечок L/R, червь, единый меш коры, извилины, борозды
 */
window.BrainModel = (function() {
    const THREE = window.THREE;
    if (!THREE) return { createBrainGroup: () => new THREE.Group(), REGIONS: {} };

    function simplex(x, y, z) {
        const p = (Math.sin(x * 12.9898 + y * 78.233 + z * 45.164) * 43758.5453) % 1;
        return p * 2 - 1;
    }
    function noise3(x, y, z, octaves) {
        let v = 0, f = 1, a = 1;
        for (let i = 0; i < (octaves || 3); i++) {
            v += a * simplex(x * f, y * f, z * f);
            f *= 2;
            a *= 0.5;
        }
        return v;
    }

    function createCortexMesh(color) {
        const geo = new THREE.SphereGeometry(0.85, 48, 32, 0, Math.PI * 2, 0, Math.PI);
        const pos = geo.attributes.position;
        const v = new THREE.Vector3();
        for (let i = 0; i < pos.count; i++) {
            v.fromBufferAttribute(pos, i);
            const phi = Math.acos(Math.max(-1, Math.min(1, v.y / 0.85)));
            const theta = Math.atan2(v.z, v.x);
            const r = v.length();
            const nx = Math.abs(v.x) / (r || 0.001);
            const fissure = Math.max(0, 1 - nx * 8);
            const gyri = 0.03 * noise3(v.x * 4, v.y * 4, v.z * 4);
            const sulcusCentral = Math.exp(-Math.pow((theta - 0.3) * 2, 2)) * Math.exp(-Math.pow(phi - 1.2, 2) * 4) * (-0.04);
            const sulcusLateral = Math.exp(-Math.pow((theta + 1.2) * 1.5, 2)) * Math.exp(-Math.pow(phi - 0.8, 2) * 3) * (-0.035);
            const sulcusParietalOcc = Math.exp(-Math.pow((theta - 2.2) * 1.2, 2)) * Math.exp(-Math.pow(phi - 0.6, 2) * 5) * (-0.03);
            const disp = (r + gyri + sulcusCentral + sulcusLateral + sulcusParietalOcc + fissure * 0.02) * (0.98 + 0.04 * Math.sin(phi * 6));
            v.normalize().multiplyScalar(disp);
            pos.setXYZ(i, v.x, v.y, v.z);
        }
        pos.needsUpdate = true;
        geo.computeVertexNormals();
        const mat = new THREE.MeshBasicMaterial({ color, transparent: false, opacity: 1, side: THREE.DoubleSide, depthWrite: true, depthTest: true });
        const mesh = new THREE.Mesh(geo, mat);
        mesh.userData = { regionKey: 'cortex', name: 'Кора головного мозга', role: 'Серое вещество', isBrainRegion: true, baseOpacity: 0.85 };
        return mesh;
    }

    function createHemisphere(side, color) {
        const geo = new THREE.SphereGeometry(0.25, 20, 16);
        const pos = geo.attributes.position;
        for (let i = 0; i < pos.count; i++) {
            const v = new THREE.Vector3().fromBufferAttribute(pos, i);
            v.normalize();
            pos.setXYZ(i, v.x, v.y, v.z);
        }
        pos.needsUpdate = true;
        geo.computeVertexNormals();
        const mat = new THREE.MeshBasicMaterial({ color, transparent: false, opacity: 1 });
        const mesh = new THREE.Mesh(geo, mat);
        mesh.position.set(side === 'L' ? -0.32 : 0.32, -0.1, -0.5);
        mesh.userData = { regionKey: 'cerebellum' + side, name: 'Мозжечок ' + (side === 'L' ? 'L' : 'R'), role: 'Движение, баланс', isBrainRegion: true, baseOpacity: 0.82 };
        return mesh;
    }

    function createVermis(color) {
        const geo = new THREE.CylinderGeometry(0.12, 0.15, 0.4, 16);
        const mat = new THREE.MeshBasicMaterial({ color, transparent: false, opacity: 1 });
        const mesh = new THREE.Mesh(geo, mat);
        mesh.rotation.x = Math.PI / 2;
        mesh.position.set(0, -0.1, -0.5);
        mesh.userData = { regionKey: 'vermis', name: 'Червь мозжечка', role: 'Координация', isBrainRegion: true, baseOpacity: 0.8 };
        return mesh;
    }

    const LOBE_DEFS = {
        frontal:    { name: 'Лобная доля',  pos: [0, 0.55, 0.45],  radius: 0.18, role: 'Исполнительные функции' },
        parietal:   { name: 'Теменная',     pos: [0, 0.35, 0],    radius: 0.17, role: 'Соматосенсорная кора' },
        temporalL:  { name: 'Височная (L)', pos: [-0.4, 0.05, 0.08], radius: 0.15, role: 'Память, речь' },
        temporalR:  { name: 'Височная (R)', pos: [0.4, 0.05, 0.08],  radius: 0.15, role: 'Память, речь' },
        occipital:  { name: 'Затылочная',   pos: [0, 0.25, -0.45], radius: 0.16, role: 'Зрительная кора' },
    };

    function createLobeMesh(key, region, color, useSphere) {
        const geo = useSphere
            ? new THREE.SphereGeometry(region.radius, 24, 20)
            : new THREE.IcosahedronGeometry(region.radius, 2);
        const mat = new THREE.MeshBasicMaterial({ color, transparent: false, opacity: 1 });
        const mesh = new THREE.Mesh(geo, mat);
        mesh.position.set(...region.pos);
        mesh.userData = { regionKey: key, ...region, isBrainRegion: true, baseOpacity: 0.82 };
        return mesh;
    }

    function createBrainGroup(glowColor) {
        const color = typeof glowColor === 'number' ? glowColor : 0x00ff88;
        const group = new THREE.Group();
        const meshes = [];

        const cortex = createCortexMesh(color);
        group.add(cortex);
        meshes.push({ key: 'cortex', mesh: cortex, region: { name: 'Кора', role: 'Серое вещество' } });

        const cerL = createHemisphere('L', color);
        const cerR = createHemisphere('R', color);
        group.add(cerL); group.add(cerR);
        meshes.push({ key: 'cerebellumL', mesh: cerL, region: cerL.userData });
        meshes.push({ key: 'cerebellumR', mesh: cerR, region: cerR.userData });

        const vermis = createVermis(color);
        group.add(vermis);
        meshes.push({ key: 'vermis', mesh: vermis, region: vermis.userData });

        function addStructure(shape, pos, scale, name, role, key) {
            const mesh = new THREE.Mesh(shape, new THREE.MeshBasicMaterial({ color, transparent: false, opacity: 1 }));
            mesh.position.set(...pos);
            if (scale) mesh.scale.setScalar(scale);
            mesh.userData = { regionKey: key, name, role, isBrainRegion: true, baseOpacity: 0.75 };
            group.add(mesh);
            meshes.push({ key, mesh, region: mesh.userData });
        }
        const r = 0.06;
        addStructure(new THREE.SphereGeometry(r, 12, 10), [0, -0.5, -0.55], null, 'Ствол мозга', 'Мост, продолговатый мозг', 'brainstem');
        addStructure(new THREE.SphereGeometry(r * 1.4, 14, 12), [0, 0.1, 0.1], null, 'Таламус', 'Реле сенсорных сигналов', 'thalamus');
        addStructure(new THREE.SphereGeometry(r * 0.9, 10, 8), [-0.12, -0.15, -0.2], null, 'Гиппокамп', 'Память', 'hippocampus');
        addStructure(new THREE.SphereGeometry(r * 0.6, 8, 6), [0.15, -0.08, 0.05], null, 'Миндалина', 'Эмоции', 'amygdala');
        addStructure(new THREE.SphereGeometry(r * 0.8, 10, 8), [-0.1, 0.02, 0.12], null, 'Хвостатое ядро', 'Базальные ганглии', 'caudate');
        addStructure(new THREE.SphereGeometry(r * 0.7, 10, 8), [0.1, 0.02, 0.12], null, 'Скорлупа', 'Базальные ганглии', 'putamen');
        const ccMesh = new THREE.Mesh(new THREE.CylinderGeometry(r * 0.4, r * 0.5, 0.25, 12), new THREE.MeshBasicMaterial({ color, transparent: false, opacity: 1 }));
        ccMesh.rotation.z = Math.PI / 2;
        ccMesh.position.set(0, 0.15, 0.05);
        ccMesh.userData = { regionKey: 'corpusCallosum', name: 'Мозолистое тело', role: 'Межполушарные связи', isBrainRegion: true, baseOpacity: 0.75 };
        group.add(ccMesh);
        meshes.push({ key: 'corpusCallosum', mesh: ccMesh, region: ccMesh.userData });
        const fornixMesh = new THREE.Mesh(new THREE.TorusGeometry(r * 1.2, r * 0.3, 8, 16, Math.PI), new THREE.MeshBasicMaterial({ color, transparent: false, opacity: 1 }));
        fornixMesh.rotation.x = Math.PI / 2;
        fornixMesh.position.set(0, -0.05, 0);
        fornixMesh.userData = { regionKey: 'fornix', name: 'Свод', role: 'Память', isBrainRegion: true, baseOpacity: 0.75 };
        group.add(fornixMesh);
        meshes.push({ key: 'fornix', mesh: fornixMesh, region: fornixMesh.userData });

        for (const [key, region] of Object.entries(LOBE_DEFS)) {
            const mesh = createLobeMesh(key, region, color, true);
            group.add(mesh);
            meshes.push({ key, mesh, region });
        }

        function bezierPoints(p0, p1, p2, p3, n) {
            const pts = [];
            for (let i = 0; i <= n; i++) {
                const t = i / n;
                const u = 1 - t;
                const x = u*u*u*p0.x + 3*u*u*t*p1.x + 3*u*t*t*p2.x + t*t*t*p3.x;
                const y = u*u*u*p0.y + 3*u*u*t*p1.y + 3*u*t*t*p2.y + t*t*t*p3.y;
                const z = u*u*u*p0.z + 3*u*u*t*p1.z + 3*u*t*t*p2.z + t*t*t*p3.z;
                pts.push(new THREE.Vector3(x, y, z));
            }
            return pts;
        }
        const REGIONS = { ...LOBE_DEFS, cerebellumL: { pos: [-0.32, -0.1, -0.5] }, cerebellumR: { pos: [0.32, -0.1, -0.5] } };
        const tractMat = new THREE.LineBasicMaterial({ color, transparent: true, opacity: 0.25 });
        const tractMatMotor = new THREE.LineBasicMaterial({ color: 0xff6666, transparent: true, opacity: 0.35 });
        const tractMatAssoc = new THREE.LineBasicMaterial({ color: 0x66aaff, transparent: true, opacity: 0.3 });
        const pairs = [
            ['frontal', 'parietal'], ['parietal', 'temporalL'], ['parietal', 'temporalR'],
            ['parietal', 'occipital'], ['occipital', 'cerebellumL'], ['temporalL', 'cerebellumL'],
            ['occipital', 'cerebellumR']
        ];
        pairs.forEach(([a, b]) => {
            if (!REGIONS[a] || !REGIONS[b]) return;
            const p1 = new THREE.Vector3(...(REGIONS[a].pos || [0,0,0]));
            const p2 = new THREE.Vector3(...(REGIONS[b].pos || [0,0,0]));
            const geom = new THREE.BufferGeometry().setFromPoints([p1, p2]);
            group.add(new THREE.Line(geom, tractMat));
        });
        const arcuateP0 = new THREE.Vector3(-0.2, 0.5, 0.25);
        const arcuateP3 = new THREE.Vector3(-0.35, 0.05, 0.1);
        const arcuateP1 = arcuateP0.clone().add(new THREE.Vector3(-0.3, -0.1, -0.2));
        const arcuateP2 = arcuateP3.clone().add(new THREE.Vector3(0.2, 0.15, 0.1));
        const arcuatePts = bezierPoints(arcuateP0, arcuateP1, arcuateP2, arcuateP3, 24);
        group.add(new THREE.Line(new THREE.BufferGeometry().setFromPoints(arcuatePts), tractMatAssoc));
        const pyramidalP0 = new THREE.Vector3(0, 0.45, 0.3);
        const pyramidalP3 = new THREE.Vector3(0, -0.55, -0.4);
        const pyramidalP1 = new THREE.Vector3(0.05, 0.2, 0);
        const pyramidalP2 = new THREE.Vector3(-0.02, -0.3, -0.2);
        const pyramidalPts = bezierPoints(pyramidalP0, pyramidalP1, pyramidalP2, pyramidalP3, 20);
        group.add(new THREE.Line(new THREE.BufferGeometry().setFromPoints(pyramidalPts), tractMatMotor));

        group.userData.regionMeshes = meshes;
        group.userData.regions = { ...LOBE_DEFS, cerebellumL: cerL.userData, cerebellumR: cerR.userData, vermis: vermis.userData, cortex: cortex.userData };
        group.userData.lodLevel = 1;
        group.userData.setLOD = function(level) { group.userData.lodLevel = Math.max(0, Math.min(2, level)); };
        group.userData.exportOBJ = function() {
            let s = 'o BioNeuralBrain\n';
            let vOffset = 0;
            meshes.slice(0, 1).forEach(({ mesh }) => {
                mesh.updateMatrixWorld(true);
                const pos = mesh.geometry.attributes.position;
                for (let j = 0; j < pos.count; j++) {
                    const v = new THREE.Vector3().fromBufferAttribute(pos, j).applyMatrix4(mesh.matrixWorld);
                    s += `v ${v.x.toFixed(4)} ${v.y.toFixed(4)} ${v.z.toFixed(4)}\n`;
                    vOffset++;
                }
                const idx = mesh.geometry.index;
                if (idx) {
                    const arr = idx.array;
                    for (let j = 0; j < arr.length; j += 3) {
                        s += `f ${arr[j] + 1} ${arr[j + 1] + 1} ${arr[j + 2] + 1}\n`;
                    }
                }
            });
            return s;
        };
        return group;
    }

    const REGIONS = { ...LOBE_DEFS };
    return { createBrainGroup, REGIONS, getRegionByKey: k => REGIONS[k] || LOBE_DEFS[k] };
})();
