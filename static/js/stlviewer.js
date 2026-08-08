/* CRAFT project page: live STL viewers (three.js).
 * Per-element options via data attributes:
 *   data-stl       url of the model (required)
 *   data-color     hex base color (default steel blue)
 *   data-back      hex interior/back-face color ("none" disables the second pass)
 *   data-view      start pose: iso | front | back | left | right | top | bottom (default iso)
 *   data-proj      "ortho" for orthographic camera (used by the multi-view tiles)
 *   data-rotate    "0" disables auto-rotate (multi-view tiles)
 *   data-overlays  JSON [{stl,color},...] extra colored meshes (parametric hub/bore)
 *
 * Browsers cap the number of simultaneous WebGL contexts (~16 in Chrome; the
 * oldest is silently lost past that), and this page holds 60+ viewers. Two
 * mechanisms keep every tile looking rendered anyway:
 *   1. A pool manager keeps at most MAX_LIVE contexts alive, chosen by
 *      distance from the viewport center; paused viewers keep their last
 *      frame as a background snapshot.
 *   2. A one-time warm pass renders every fixed-pose tile once through a
 *      single shared renderer and stores the frame as its snapshot, so tiles
 *      that have not yet had a live slot still show their view.
 * Geometry is fetched and parsed once per URL. */
import * as THREE from 'three';
import { STLLoader } from 'three/addons/loaders/STLLoader.js';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const BG = 0xffffff, BLUE = 0x4d7ea8, AMBER = 0xc97b3a;
const MAX_LIVE = 12;
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

/* Camera poses in the three.js scene (model is rotated Z-up -> Y-up).
 * Directions and up-vectors chosen to match the OpenSCAD view convention
 * used in the paper: front looks along -Y (scad), top looks down +Z (scad). */
const POSES = {
  iso:    { dir: [ 1,  0.66, 1 ],  up: [0, 1, 0] },
  front:  { dir: [ 0,  0,  1 ],    up: [0, 1, 0] },
  back:   { dir: [ 0,  0, -1 ],    up: [0, 1, 0] },
  left:   { dir: [-1,  0,  0 ],    up: [0, 1, 0] },
  right:  { dir: [ 1,  0,  0 ],    up: [0, 1, 0] },
  top:    { dir: [ 0,  1,  0 ],    up: [0, 0, -1] },
  bottom: { dir: [ 0, -1,  0 ],    up: [0, 0, -1] },
};

/* Build the scene + camera described by a viewer element's data attributes. */
async function buildScene(el, w, h) {
  const g = await loadGeom(el.dataset.stl);
  const scene = new THREE.Scene();
  scene.background = new THREE.Color(BG);
  scene.add(new THREE.HemisphereLight(0xffffff, 0xdde4ec, 1.15));
  const key = new THREE.DirectionalLight(0xffffff, 1.35); key.position.set(1, 1.2, 1.6);
  const rim = new THREE.DirectionalLight(0x88aaff, 0.45); rim.position.set(-1.5, -0.6, -1);
  scene.add(key, rim);

  const baseColor = el.dataset.color ? new THREE.Color(el.dataset.color) : new THREE.Color(BLUE);
  const grp = new THREE.Group();
  grp.add(new THREE.Mesh(g, new THREE.MeshPhongMaterial({
    color: baseColor, specular: 0x223344, shininess: 28, flatShading: true, side: THREE.FrontSide })));
  const backOpt = el.dataset.back;
  if (backOpt !== 'none') {
    const backColor = backOpt ? new THREE.Color(backOpt) : new THREE.Color(AMBER);
    grp.add(new THREE.Mesh(g, new THREE.MeshPhongMaterial({
      color: backColor, flatShading: true, side: THREE.BackSide })));
  }
  if (el.dataset.overlays) {
    for (const ov of JSON.parse(el.dataset.overlays)) {
      const og = await loadGeom(ov.stl);
      grp.add(new THREE.Mesh(og, new THREE.MeshPhongMaterial({
        color: new THREE.Color(ov.color), flatShading: true,
        polygonOffset: true, polygonOffsetFactor: -2, polygonOffsetUnits: -2 })));
    }
  }
  grp.rotation.x = -Math.PI / 2;   // OpenSCAD Z-up -> three.js Y-up
  scene.add(grp);

  const r = g.boundingSphere.radius;
  const pose = POSES[el.dataset.view || 'iso'] || POSES.iso;
  const dLen = Math.hypot(...pose.dir);
  /* Fit the whole bounding sphere inside the view with margin. A 40-degree
   * perspective camera must sit at least r/sin(20deg) = 2.92r away for the
   * sphere to just touch the frustum; 1.14x that leaves clean air around the
   * model at every rotation angle. near/far scale with the model: ABC parts
   * arrive in normalized units (~0.03 across), so fixed planes would clip. */
  const FOV = 40;
  const D = (el.dataset.proj === 'ortho')
    ? r * 3
    : (r / Math.sin(THREE.MathUtils.degToRad(FOV / 2))) * 1.14;
  const pos = pose.dir.map(v => v / dLen * D);

  let camera;
  if (el.dataset.proj === 'ortho') {
    const s = r * 1.26, aspect = w / h;
    camera = new THREE.OrthographicCamera(-s * aspect, s * aspect, s, -s, D / 100, D * 4);
  } else {
    camera = new THREE.PerspectiveCamera(FOV, w / h, D / 100, D * 10);
  }
  camera.up.set(...pose.up);
  camera.position.set(...pos);
  camera.lookAt(0, 0, 0);
  return { scene, camera };
}

function setSnapshot(el, dataUrl) {
  if (!dataUrl || dataUrl.length < 256) return;
  el.style.backgroundImage = `url(${dataUrl})`;
  el.style.backgroundSize = 'contain';
  el.style.backgroundPosition = 'center';
  el.style.backgroundRepeat = 'no-repeat';
}

class Viewer {
  constructor(el) {
    this.el = el;
    this.active = false;
    this.wanted = false;
    this.hovered = false;
    this.resetting = false;
    this.rot = el.dataset.rotate !== '0';   // rotates when idle
    this.fails = 0;
    this.ses = 0;
    this.raf = null;
    el.addEventListener('pointerenter', () => {
      this.hovered = true;
      this.resetting = false;
      if (this.active && this.controls) this.controls.autoRotate = true;
      else reconcile();          // promote to a live slot right away
    });
    el.addEventListener('pointerleave', () => {
      this.hovered = false;
      if (!this.rot && this.controls) {
        this.controls.autoRotate = false;
        this.resetting = true;   // glide back to the canonical pose
      }
    });
  }
  async start() {
    if (this.active || this.fails > 3) return;
    this.active = true;
    const ses = ++this.ses;
    const w = this.el.clientWidth || 200, h = this.el.clientHeight || 200;
    const small = w < 240;
    try {
      this.renderer = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'low-power' });
    } catch (err) {
      this.fails = 99; this.active = false; return;
    }
    this.renderer.debug.checkShaderErrors = false;
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, small ? 1.5 : 2));
    this.renderer.setSize(w, h);
    this.renderer.domElement.addEventListener('webglcontextlost', ev => {
      ev.preventDefault();
      if (this.active) { this.fails++; this.stop(); }
    }, false);
    this.el.appendChild(this.renderer.domElement);

    let built;
    try {
      built = await buildScene(this.el, w, h);
    } catch (err) {
      this.fails++; this.stop(); return;
    }
    if (!this.active || ses !== this.ses) return;
    this.scene = built.scene;
    this.camera = built.camera;
    this.homePos = this.camera.position.clone();
    this.homeUp = this.camera.up.clone();

    this.controls = new OrbitControls(this.camera, this.renderer.domElement);
    this.controls.enableDamping = true;
    this.controls.autoRotate = this.rot || this.hovered;
    /* Idle-rotating viewers turn gently; fixed-pose tiles only rotate while
     * hovered, where a quicker turn reads as direct feedback. */
    this.controls.autoRotateSpeed = this.rot ? 1.6 : 4;
    if (this.camera.isPerspectiveCamera) {
      const d0 = this.camera.position.length();
      this.controls.minDistance = d0 * 0.5;
      this.controls.maxDistance = d0 * 2.2;
    } else {
      this.controls.minZoom = 0.6;
      this.controls.maxZoom = 3;
    }
    this.controls.addEventListener('start', () => { this.controls.autoRotate = false; });
    this.el.classList.add('is-live');

    const tick = () => {
      if (!this.active || ses !== this.ses) return;
      try {
        if (this.resetting) {
          /* Ease the camera back to the canonical pose (fixed-view tiles). */
          const c = this.camera, t = this.controls.target;
          c.position.lerp(this.homePos, 0.16);
          c.up.lerp(this.homeUp, 0.16);
          t.lerp({ x: 0, y: 0, z: 0 }, 0.16);
          c.zoom += (1 - c.zoom) * 0.16;
          c.updateProjectionMatrix();
          c.lookAt(t.x, t.y, t.z);
          if (c.position.distanceTo(this.homePos) < this.homePos.length() * 0.002) {
            c.position.copy(this.homePos);
            c.up.copy(this.homeUp);
            t.set(0, 0, 0);
            c.zoom = 1;
            c.updateProjectionMatrix();
            c.lookAt(0, 0, 0);
            this.resetting = false;
          }
        } else {
          this.controls.update();
        }
        this.renderer.render(this.scene, this.camera);
        this.fails = 0;
      } catch (err) {
        this.fails++;
        this.stop();
        return;
      }
      this.raf = requestAnimationFrame(tick);
    };
    tick();
  }
  stop() {
    if (!this.active) return;
    this.active = false;
    this.ses++;
    cancelAnimationFrame(this.raf);
    if (this.controls) this.controls.dispose();
    if (this.renderer) {
      /* Freeze the last frame as a background snapshot so a paused tile is
       * indistinguishable from a live one. Fixed-view tiles are first snapped
       * back to their canonical pose so the frozen frame is always correct. */
      try {
        if (this.scene && this.camera) {
          if (!this.rot && this.homePos) {
            this.camera.position.copy(this.homePos);
            this.camera.up.copy(this.homeUp);
            this.camera.zoom = 1;
            this.camera.updateProjectionMatrix();
            this.camera.lookAt(0, 0, 0);
          }
          this.renderer.render(this.scene, this.camera);
          setSnapshot(this.el, this.renderer.domElement.toDataURL('image/png'));
        }
      } catch (err) { /* lost context: keep whatever background is there */ }
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

function centerDist(el) {
  const r = el.getBoundingClientRect();
  return Math.abs(r.top + r.height / 2 - window.innerHeight / 2);
}

/* Keep the MAX_LIVE viewers nearest the viewport center running; pause the
 * rest. Re-run periodically so evicted-but-visible tiles get picked back up
 * as slots free (IntersectionObserver alone only fires on boundary crossings). */
let reconciling = false;
function reconcile() {
  if (reconciling || document.hidden) return;
  reconciling = true;
  try {
    /* Priority: hovered first, then viewers that rotate when idle (their
     * motion is the whole point; a paused fixed-pose tile looks identical
     * to a live one), then whatever is nearest the viewport center. */
    const wanted = viewers.filter(v => v.wanted && v.fails <= 3)
                          .sort((a, b) => (b.hovered - a.hovered)
                                       || (b.rot - a.rot)
                                       || (centerDist(a.el) - centerDist(b.el)));
    const keep = new Set(wanted.slice(0, MAX_LIVE));
    for (const v of viewers) if (v.active && !keep.has(v)) v.stop();
    for (const v of keep) if (!v.active) v.start();
  } finally {
    reconciling = false;
  }
}

const io = new IntersectionObserver(entries => {
  for (const e of entries) {
    const v = viewers.find(x => x.el === e.target);
    if (v) v.wanted = e.isIntersecting;
  }
  reconcile();
}, { rootMargin: '60px 0px' });
viewers.forEach(v => io.observe(v.el));
setInterval(reconcile, 700);

/* Keep canvases matched to their boxes when the window is resized. */
let resizeTimer;
window.addEventListener('resize', () => {
  clearTimeout(resizeTimer);
  resizeTimer = setTimeout(() => {
    for (const v of viewers) {
      if (!v.active || !v.renderer || !v.camera) continue;
      const w = v.el.clientWidth || 200, h = v.el.clientHeight || 200;
      v.renderer.setSize(w, h);
      if (v.camera.isPerspectiveCamera) {
        v.camera.aspect = w / h;
      } else {
        const s = v.camera.top, aspect = w / h;
        v.camera.left = -s * aspect;
        v.camera.right = s * aspect;
      }
      v.camera.updateProjectionMatrix();
    }
  }, 150);
});

/* One-time warm pass: render every fixed-pose tile once through a single
 * shared renderer so tiles beyond the live pool still show their view. */
async function warmAll() {
  const targets = viewers;   // fixed-pose tiles AND rotating viewers: a frozen
  if (!targets.length) return;   // default-pose frame beats a blank tile
  let wr;
  try {
    wr = new THREE.WebGLRenderer({ antialias: true, powerPreference: 'low-power',
                                   preserveDrawingBuffer: true });
  } catch (err) { return; }
  wr.debug.checkShaderErrors = false;
  wr.setPixelRatio(1.5);
  for (const v of targets) {
    if (v.active || v.el.style.backgroundImage) continue;
    try {
      const w = v.el.clientWidth || 180, h = v.el.clientHeight || 180;
      const { scene, camera } = await buildScene(v.el, w, h);
      wr.setSize(w, h);
      wr.render(scene, camera);
      if (!v.active) setSnapshot(v.el, wr.domElement.toDataURL('image/png'));
    } catch (err) { /* skip tile */ }
    await new Promise(res => setTimeout(res, 0));   // keep the page responsive
  }
  wr.dispose();
  wr.forceContextLoss();
}
warmAll();
