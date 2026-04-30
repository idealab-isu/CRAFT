/**
 * CRAFT 3D Viewer
 *
 * Interactive STL viewer using Three.js with orthographic camera
 * Supports preset views (Top, Front, Left, Right, Isometric)
 */

import * as THREE from 'three';
import { STLLoader } from 'three/addons/loaders/STLLoader.js';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

class CADViewer {
    constructor(containerId) {
        this.container = document.getElementById(containerId);
        if (!this.container) {
            console.error(`Container ${containerId} not found`);
            return;
        }

        this.scene = null;
        this.camera = null;
        this.renderer = null;
        this.controls = null;
        this.mesh = null;
        this.gridHelper = null;
        this.axesHelper = null;

        this.init();
        this.animate();
    }

    init() {
        // Scene
        this.scene = new THREE.Scene();
        this.scene.background = new THREE.Color(0x2a2a2a);

        // Camera (Orthographic for technical views)
        const aspect = this.container.clientWidth / this.container.clientHeight;
        const frustumSize = 200;
        this.camera = new THREE.OrthographicCamera(
            frustumSize * aspect / -2,
            frustumSize * aspect / 2,
            frustumSize / 2,
            frustumSize / -2,
            0.01,   // Near plane - smaller to avoid front clipping
            50000   // Far plane - larger to handle big models
        );
        this.camera.position.set(100, 100, 100);
        this.camera.lookAt(0, 0, 0);

        // Renderer
        this.renderer = new THREE.WebGLRenderer({ antialias: true });
        this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
        this.renderer.setPixelRatio(window.devicePixelRatio);
        this.container.appendChild(this.renderer.domElement);

        // Controls
        this.controls = new OrbitControls(this.camera, this.renderer.domElement);
        this.controls.enableDamping = true;
        this.controls.dampingFactor = 0.05;
        this.controls.screenSpacePanning = true;
        this.controls.minZoom = 0.5;
        this.controls.maxZoom = 10;
        this.controls.target.set(0, 0, 0);

        // Lighting
        const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
        this.scene.add(ambientLight);

        const directionalLight1 = new THREE.DirectionalLight(0xffffff, 0.8);
        directionalLight1.position.set(1, 1, 1);
        this.scene.add(directionalLight1);

        const directionalLight2 = new THREE.DirectionalLight(0xffffff, 0.4);
        directionalLight2.position.set(-1, -1, -1);
        this.scene.add(directionalLight2);

        // Grid
        this.gridHelper = new THREE.GridHelper(200, 20, 0x444444, 0x333333);
        this.scene.add(this.gridHelper);

        // Axes
        this.axesHelper = new THREE.AxesHelper(50);
        this.scene.add(this.axesHelper);

        // Handle window resize
        window.addEventListener('resize', () => this.onWindowResize(), false);
    }

    async loadSTL(url) {
        // Remove existing mesh if any
        if (this.mesh) {
            this.scene.remove(this.mesh);
            this.mesh.geometry.dispose();
            this.mesh.material.dispose();
        }

        return new Promise((resolve, reject) => {
            const loader = new STLLoader();
            loader.load(
                url,
                (geometry) => {
                    // Center the geometry
                    geometry.computeBoundingBox();
                    const center = new THREE.Vector3();
                    geometry.boundingBox.getCenter(center);
                    geometry.translate(-center.x, -center.y, -center.z);

                    // Create material
                    const material = new THREE.MeshPhongMaterial({
                        color: 0x5c9ee0,
                        specular: 0x111111,
                        shininess: 100,
                        flatShading: false
                    });

                    // Create mesh
                    this.mesh = new THREE.Mesh(geometry, material);

                    // Rotate to match OpenSCAD orientation (Z-up to Y-up)
                    // OpenSCAD uses Z as up, Three.js uses Y as up
                    this.mesh.rotation.x = -Math.PI / 2;

                    this.scene.add(this.mesh);

                    // Auto-zoom to fit
                    this.zoomToFit();

                    resolve();
                },
                (xhr) => {
                    console.log((xhr.loaded / xhr.total * 100) + '% loaded');
                },
                (error) => {
                    console.error('Error loading STL:', error);
                    reject(error);
                }
            );
        });
    }

    zoomToFit() {
        if (!this.mesh) return;

        // Calculate bounding box
        const box = new THREE.Box3().setFromObject(this.mesh);
        const size = box.getSize(new THREE.Vector3());
        const maxDim = Math.max(size.x, size.y, size.z);

        // Adjust camera zoom - use 2.5x padding to prevent clipping
        const aspect = this.container.clientWidth / this.container.clientHeight;
        const frustumSize = maxDim * 2.5;

        this.camera.left = frustumSize * aspect / -2;
        this.camera.right = frustumSize * aspect / 2;
        this.camera.top = frustumSize / 2;
        this.camera.bottom = frustumSize / -2;
        this.camera.updateProjectionMatrix();

        this.controls.update();
    }

    setView(viewName) {
        if (!this.mesh) return;

        const box = new THREE.Box3().setFromObject(this.mesh);
        const size = box.getSize(new THREE.Vector3());
        const maxDim = Math.max(size.x, size.y, size.z);
        const distance = maxDim * 3;  // Increased for better view coverage

        switch (viewName.toLowerCase()) {
            case 'top':
                this.camera.position.set(0, distance, 0);
                this.camera.up.set(0, 0, -1);
                break;
            case 'front':
                this.camera.position.set(0, 0, distance);
                this.camera.up.set(0, 1, 0);
                break;
            case 'left':
                this.camera.position.set(-distance, 0, 0);
                this.camera.up.set(0, 1, 0);
                break;
            case 'right':
                this.camera.position.set(distance, 0, 0);
                this.camera.up.set(0, 1, 0);
                break;
            case 'bottom':
                this.camera.position.set(0, -distance, 0);
                this.camera.up.set(0, 0, 1);
                break;
            case 'back':
                this.camera.position.set(0, 0, -distance);
                this.camera.up.set(0, 1, 0);
                break;
            case 'iso':
            case 'isometric':
                this.camera.position.set(distance, distance, distance);
                this.camera.up.set(0, 1, 0);
                break;
        }

        this.camera.lookAt(0, 0, 0);
        this.controls.target.set(0, 0, 0);
        this.controls.update();
    }

    onWindowResize() {
        const aspect = this.container.clientWidth / this.container.clientHeight;

        // Calculate frustumSize based on loaded model, or use default
        let frustumSize = 200;  // Default for when no model is loaded
        if (this.mesh) {
            const box = new THREE.Box3().setFromObject(this.mesh);
            const size = box.getSize(new THREE.Vector3());
            const maxDim = Math.max(size.x, size.y, size.z);
            frustumSize = maxDim * 2.5;  // Match zoomToFit padding
        }

        this.camera.left = frustumSize * aspect / -2;
        this.camera.right = frustumSize * aspect / 2;
        this.camera.top = frustumSize / 2;
        this.camera.bottom = frustumSize / -2;
        this.camera.updateProjectionMatrix();

        this.renderer.setSize(this.container.clientWidth, this.container.clientHeight);
    }

    animate() {
        requestAnimationFrame(() => this.animate());
        this.controls.update();
        this.renderer.render(this.scene, this.camera);
    }

    toggleGrid(visible) {
        if (this.gridHelper) {
            this.gridHelper.visible = visible;
        }
    }

    toggleAxes(visible) {
        if (this.axesHelper) {
            this.axesHelper.visible = visible;
        }
    }

    setBackgroundColor(color) {
        this.scene.background = new THREE.Color(color);
    }

    dispose() {
        if (this.mesh) {
            this.scene.remove(this.mesh);
            this.mesh.geometry.dispose();
            this.mesh.material.dispose();
        }
        this.renderer.dispose();
        this.controls.dispose();
    }
}

// Export for global use
window.CADViewer = CADViewer;
