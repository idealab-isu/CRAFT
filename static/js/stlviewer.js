/* CRAFT project page — interactive STL viewers (three.js)
 * Two-tone CAD look: steel-blue exterior, amber interior (back faces),
 * auto-rotate + orbit/zoom, lazy WebGL contexts (created when visible,
 * disposed when far off-screen) so many viewers coexist safely. */
import * as THREE from 'three';
import { STLLoader } from 'three/addons/loaders/STLLoader.js';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const BG = 0xffffff, BLUE = 0x4d7ea8, AMBER = 0xc97b3a;
const loader = new STLLoader();
const geomCache = new Map();

function loadGeom(url) {
  if (!geomCache.has(url)) {
    geomCache.set(url, new Promise((resolve, reject) => {
      loader.load(url, g => {
        g.computeVertexNormals();
        g.center();
        g.computeBoundingSphere();
        resolve(g);
      }, undefined, reject);
    }));
  }
  return geomCache.get(url);
}

class Viewer {
  constructor(el) {
    this.el = el;
    this.url = el.dataset.stl;
    this.active = false;
    this.raf = null;
  }
  async start() {
    if (this.active) return;
    this.active = true;
    const w = this.el.clientWidth, h = this.el.clientHeight;
    this.renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'low-power' });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setSize(w, h);
    this.el.appendChild(this.renderer.domElement);

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(BG);
    this.camera = new THREE.PerspectiveCamera(40, w / h, 0.1, 5000);
    this.scene.add(new THREE.HemisphereLight(0xffffff, 0xdde4ec, 1.15));
    const key = new THREE.DirectionalLight(0xffffff, 1.4); key.position.set(1, 1.2, 1.6);
    const rim = new THREE.DirectionalLight(0x88aaff, 0.5); rim.position.set(-1.5, -0.6, -1);
    this.scene.add(key, rim);

    const g = await loadGeom(this.url);
    if (!this.active) return;
    const front = new THREE.Mesh(g, new THREE.MeshPhongMaterial({
      color: BLUE, specular: 0x223344, shininess: 28, flatShading: true, side: THREE.FrontSide }));
    const back = new THREE.Mesh(g, new THREE.MeshPhongMaterial({
      color: AMBER, flatShading: true, side: THREE.BackSide }));
    // Z-up (OpenSCAD) -> Y-up (three)
    const grp = new THREE.Group(); grp.add(front, back);
    if (this.el.dataset.overlays) {
      for (const ov of JSON.parse(this.el.dataset.overlays)) {
        const og = await loadGeom(ov.stl);
        const m = new THREE.Mesh(og, new THREE.MeshPhongMaterial({
          color: new THREE.Color(ov.color), flatShading: true,
          polygonOffset: true, polygonOffsetFactor: -2, polygonOffsetUnits: -2 }));
        grp.add(m);
      }
    }
    grp.rotation.x = -Math.PI / 2;
    this.scene.add(grp);

    const r = g.boundingSphere.radius;
    this.camera.position.set(r * 1.9, r * 1.25, r * 1.9);
    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.controls.autoRotate = true;
    this.controls.autoRotateSpeed = 1.6;
    this.controls.addEventListener('start', () => { this.controls.autoRotate = false; });
    this.el.classList.add('is-live');

    const tick = () => {
      if (!this.active) return;
      this.controls.update();
      this.renderer.render(this.scene, this.camera);
      this.raf = requestAnimationFrame(tick);
    };
    tick();
  }
  stop() {
    if (!this.active) return;
    this.active = false;
    cancelAnimationFrame(this.raf);
    if (this.controls) this.controls.dispose();
    if (this.renderer) {
      this.renderer.dispose();
      this.renderer.forceContextLoss();
      this.renderer.domElement.remove();
    }
    this.el.classList.remove('is-live');
    this.renderer = this.scene = this.camera = this.controls = null;
  }
}

const viewers = [];
document.querySelectorAll('.stl-viewer').forEach(el => viewers.push(new Viewer(el)));
const io = new IntersectionObserver(entries => {
  for (const e of entries) {
    const v = viewers.find(x => x.el === e.target);
    if (!v) continue;
    if (e.isIntersecting) v.start();
    else v.stop();
  }
}, { rootMargin: '200px 0px' });
viewers.forEach(v => io.observe(v.el));
