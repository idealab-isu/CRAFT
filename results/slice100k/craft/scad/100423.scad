// Faceted low-poly spiral/rosette solid (single connected body)
// Target bbox: ~6.2 x 6.0 x 11.6 mm

// ---------------- Parameters ----------------
bbox_x = 6.15; //[3.08:12.3:0.01]
bbox_y = 6.01; //[3.01:12.02:0.01]
bbox_z = 11.63; //[5.82:23.26:0.01]

r_base = min(bbox_x, bbox_y)/2;     // ~3.0 mm
r_top  = 1.20;                      // top radius (taper)
taper_power = 1.55;                 // taper curve

twist_deg = 540;                    // overall swirl
facets_around = 18;                 // low-poly around
facets_z = 26;                      // low-poly along height

vortex_depth = 4.2;                 // depression depth from top
vortex_r0 = 0.55;                   // center radius
vortex_r1 = 2.35;                   // outer influence radius
vortex_power = 1.35;                // depression profile

rim_keep = 0.35;                    // keep a small rim at top
base_keep = 0.55;                   // keep base thickness

// small overlap to ensure watertight boolean
eps = 0.02;

// ---------------- Helpers ----------------
function clamp(x,a,b) = x < a ? a : (x > b ? b : x);
function lerp(a,b,t) = a + (b-a)*t;

// radius of outer envelope at normalized height t (0 bottom -> 1 top)
function r_env(t) =
    lerp(r_base, r_top, pow(t, taper_power));

// swirl angle at normalized height t
function ang_twist(t) =
    twist_deg * t;

// vortex depression amount at (t, r) where r is radial distance
// depression is strongest near top and within vortex_r1
function vortex_drop(t, r) =
    let(
        top_weight = pow(clamp((t - (1 - vortex_depth/bbox_z)) / (vortex_depth/bbox_z), 0, 1), 1.0),
        rr = clamp((r - vortex_r0) / max(vortex_r1 - vortex_r0, 1e-6), 0, 1),
        radial = pow(1 - rr, vortex_power)
    )
    vortex_depth * top_weight * radial;

// ---------------- Mesh builder ----------------
module rosette_mesh() {
    // Build a closed polyhedron from a twisted, faceted surface with a vortex-like top depression.
    // Coordinates are centered at origin; Z spans [-bbox_z/2, +bbox_z/2].

    nA = facets_around;
    nZ = facets_z;

    // Precompute points: rings along Z, each ring has nA points.
    // Also add a bottom center point and a top center point (depressed).
    points =
        concat(
            // side surface rings
            [
                for (k = [0:nZ])  // nZ+1 rings
                    let(
                        t = k / nZ,
                        z0 = -bbox_z/2 + t*bbox_z,
                        r0 = r_env(t),
                        a0 = ang_twist(t)
                    )
                    for (i = [0:nA-1])
                        let(
                            a = a0 + i*360/nA,
                            x = r0*cos(a),
                            y = r0*sin(a),
                            // apply vortex depression only near top and toward center
                            // approximate local radial distance as r0 (outer ring), but modulate with a rosette-like inward pull
                            // by slightly varying effective r for depression using a low-poly "petal" term
                            petal = 0.18 * (1 - t) * cos(i*360/nA*2),
                            r_eff = max(0, r0*(1 - 0.10) - petal),
                            z = z0 - vortex_drop(t, r_eff) * (0.55 + 0.45*cos(a*1.0))
                        )
                        [x, y, z]
            ],
            // bottom center point (kept flat-ish)
            [[0, 0, -bbox_z/2 + base_keep]],
            // top center point (depressed)
            [[0, 0, bbox_z/2 - rim_keep - vortex_depth]]
        );

    // Indices helpers
    function idx(k,i) = k*nA + (i % nA);
    bottom_center = (nZ+1)*nA;
    top_center    = bottom_center + 1;

    faces =
        concat(
            // side quads split into triangles (with alternating diagonal for faceted look)
            [
                for (k = [0:nZ-1])
                    for (i = [0:nA-1])
                        let(
                            a = idx(k,i),
                            b = idx(k,i+1),
                            c = idx(k+1,i+1),
                            d = idx(k+1,i),
                            flip = ((k + i) % 2)
                        )
                        each (flip == 0
                            ? [[a,b,c],[a,c,d]]
                            : [[a,b,d],[b,c,d]])
            ],

            // bottom cap: fan to bottom_center using ring k=0
            [
                for (i = [0:nA-1])
                    [bottom_center, idx(0,i+1), idx(0,i)]
            ],

            // top cap: connect last ring k=nZ to top_center (creates vortex-like closure)
            [
                for (i = [0:nA-1])
                    [top_center, idx(nZ,i), idx(nZ,i+1)]
            ]
        );

    polyhedron(points=points, faces=faces, convexity=10);
}

// ---------------- Final model ----------------
$fn = 1; // ensure polyhedron defines facets; no smoothing primitives used

// Slight scale to match bbox precisely in X/Y if needed (keeps Z exact)
sx = (bbox_x/2) / r_base;
sy = (bbox_y/2) / r_base;

scale([sx, sy, 1])
    rosette_mesh();