// Dimension-calibrated (target: 70.55 x 65.21 x 70.37 mm)
scale([0.891453, 0.978241, 0.783600])
{
// Irregular low-poly rock / gemstone (single connected solid)
// Target bounding box: 70.55 x 65.21 x 70.37 mm

// Parameters
bbox_x = 70.55; //[35.28:141.1:0.01]
bbox_y = 65.21; //[32.61:130.42:0.01]
bbox_z = 70.37; //[35.19:140.74:0.01]

base_radius = 35; //[17.5:70:0.1]
facet_count = 120; //[40:240:1]
jitter_amp = 6; //[0:12:0.1]
seed = 1; //[1:9999:1]
edge_sharpness = 0.85; //[0.2:1:0.01]

asymmetry_bias_x = 0.06; //[0:0.2:0.01]
asymmetry_bias_y = 0.03; //[0:0.2:0.01]
asymmetry_bias_z = 0.08; //[0:0.2:0.01]

global_scale_x = 1; //[0.5:2:0.001]
global_scale_y = 1; //[0.5:2:0.001]
global_scale_z = 1; //[0.5:2:0.001]

// ---------- helpers ----------
function clamp(x,a,b) = x < a ? a : (x > b ? b : x);
function vlen(v) = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
function vnorm(v) = let(L=vlen(v)) (L==0 ? [0,0,0] : [v[0]/L, v[1]/L, v[2]/L]);

// deterministic pseudo-noise from direction vector (no symmetry like a sphere's lat/long grid)
function dir_noise(d, s) =
    let(
        // mix several trig terms to avoid obvious radial regularity
        a = sin((d[0]*12.73 + d[1]*7.31 + d[2]*9.17 + s*0.17) * 3.1),
        b = sin((d[0]*5.11  - d[1]*13.37 + d[2]*4.29 + s*0.31) * 4.7),
        c = sin((d[0]*9.91  + d[1]*2.83  - d[2]*11.19 + s*0.23) * 2.9),
        n = (a*0.55 + b*0.30 + c*0.15)
    ) n;

// random-ish direction on sphere using rands()
function rand_dir(i, s) =
    let(
        u = rands(-1, 1, 1, s + i*101)[0],
        t = rands(0, 360, 1, s + i*101 + 17)[0],
        r = sqrt(max(0, 1 - u*u))
    ) [r*cos(t), r*sin(t), u];

// ---------- core: irregular faceted rock via convex hull of jittered points ----------
module lowpoly_rock_points() {
    // number of hull points: tied to facet_count but clamped for performance
    n = clamp(facet_count, 40, 220);

    // jitter amplitude scaled by edge_sharpness (higher sharpness => more pronounced facets)
    amp = jitter_amp * (0.35 + 0.85*edge_sharpness);

    // base radius with slight asymmetry bias baked into point generation
    sx = 1 + asymmetry_bias_x;
    sy = 1 + asymmetry_bias_y;
    sz = 1 + asymmetry_bias_z;

    hull() {
        // Add a few "anchor" points to keep an ovoid mass and avoid extreme spikes
        for (k = [0:5]) {
            d = rand_dir(1000 + k, seed);
            // anchors closer to base radius
            rr = base_radius * (0.92 + 0.06*dir_noise(d, seed+999));
            translate([d[0]*rr*sx, d[1]*rr*sy, d[2]*rr*sz]) sphere(r=0.9, $fn=10);
        }

        // Main irregular hull points
        for (i = [0:n-1]) {
            d = rand_dir(i, seed);
            // irregular radius: combine directional noise + per-point random
            rn = dir_noise(d, seed);
            rj = rands(-1, 1, 1, seed + i*313 + 7)[0];

            // bias distribution: more variation on some directions to break symmetry
            anis = 1 + 0.25*sin((d[0]*3 + d[1]*5 - d[2]*4 + seed*0.1)*57);

            rr = base_radius
                 + amp * (0.75*rn + 0.55*rj) * anis;

            // clamp to keep rounded/ovoid overall
            rr2 = clamp(rr, base_radius*0.78, base_radius*1.18);

            translate([d[0]*rr2*sx, d[1]*rr2*sy, d[2]*rr2*sz])
                sphere(r=0.9, $fn=10);
        }
    }
}

// ---------- final geometry with exact bounding box scaling ----------
module final_geometry() {
    // scale to requested bounding box (based on base_radius diameter)
    scale([
        global_scale_x * (bbox_x / (2*base_radius)),
        global_scale_y * (bbox_y / (2*base_radius)),
        global_scale_z * (bbox_z / (2*base_radius))
    ])
    // slight rotation derived from seed to avoid axis-aligned look (formula-based)
    rotate([ (seed*13) % 360, (seed*29) % 360, (seed*47) % 360 ])
        lowpoly_rock_points();
}

// Render
color([0.85, 0.85, 0.8])
final_geometry();
}
