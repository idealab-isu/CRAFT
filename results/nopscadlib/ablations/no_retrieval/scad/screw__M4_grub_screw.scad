// M4 grub screw (set screw) with internal hex socket and simplified helical external thread
// Headless form factor: uniform OD along length, recessed hex socket, simple end treatment.
// Single connected solid (thread ridge + core are unioned), all cuts are subtractive and aligned.

// ---------- Parameters ----------
nom_d = 4.0;                 // M4 nominal major diameter
pitch = 0.7;                 // M4 coarse pitch
L = 6.0;                     // overall length (typical short grub)

// Thread (approx ISO metric profile)
major_d = nom_d;
minor_d = 3.1;               // approximate for M4x0.7 external
thread_len = L;              // full length for grub screw

// Socket (internal hex)
socket_af = 2.0;             // typical M4 hex key ~2.0mm
socket_depth = 2.0;          // recessed depth

// Ends
chamfer = 0.25;              // small edge break at both ends
tip_style = "cup";           // "flat" or "cup"
cup_point_r = 0.6;           // cup point radius
cup_point_depth = 0.25;      // cup point depth

// Quality
$fn = 80;

// ---------- Helpers ----------
function clamp(x, a, b) = x < a ? a : (x > b ? b : x);

module hex_prism(af, h, center=false) {
    // Regular hex with given across-flats
    R = af / 1.7320508075688772; // circumradius from across-flats
    linear_extrude(height=h, center=center, convexity=10)
        polygon([ for (i=[0:5]) [ R*cos(60*i), R*sin(60*i) ] ]);
}

module chamfer_ring_cut(z0, r, c) {
    // 45-ish chamfer cut at an end face located at z0 (face plane).
    // Uses a frustum that removes the outer edge only.
    // Slight oversize/overlap to ensure clean subtraction.
    eps = 0.02;
    translate([0,0,z0 - (c+eps)/2])
        cylinder(h=c+eps, r1=r+0.25, r2=max(0, r-c), center=true);
}

// Helical thread via linear_extrude(twist=...)
module metric_thread_external(major_d, minor_d, pitch, len) {
    r_maj = major_d/2;
    r_min = minor_d/2;

    // Approximate ISO metric thread height (external) ~ 0.6134*p
    h_iso = 0.61343 * pitch;
    h_use = clamp(r_maj - r_min, 0.01, h_iso);

    // Tooth profile (simple triangular ridge)
    tooth_radial = h_use;
    tooth_tan = 0.35 * pitch;
    turns = len / pitch;
    twist_deg = 360 * turns;

    // Overlap to ensure manifold union with core
    eps = 0.05;

    union() {
        // Core cylinder at minor diameter (centered)
        cylinder(h=len, r=r_min, center=true);

        // Helical ridge: start slightly inside r_min so it fuses to core
        linear_extrude(
            height=len,
            center=true,
            twist=twist_deg,
            slices=max(ceil(turns*40), 80),
            convexity=10
        )
            translate([r_min - eps, 0, 0])
                polygon(points=[
                    [0, -tooth_tan/2],
                    [tooth_radial, 0],
                    [0,  tooth_tan/2]
                ]);
    }
}

// ---------- Main model ----------
module m4_grub_screw() {
    r_maj = major_d/2;
    eps = 0.02;

    difference() {
        // Solid: threaded body (headless, uniform OD silhouette)
        metric_thread_external(major_d=major_d, minor_d=minor_d, pitch=pitch, len=thread_len);

        // Internal hex socket recessed into the top end face (no head)
        // Place so its top is flush with the end face at +L/2.
        translate([0,0, (L/2) - (socket_depth/2)])
            hex_prism(socket_af, socket_depth + eps, center=true);

        // Small chamfers on both ends (edge break, still headless)
        chamfer_ring_cut(z0= L/2, r=r_maj, c=chamfer);
        chamfer_ring_cut(z0=-L/2, r=r_maj, c=chamfer);

        // Tip style: cup point (common for grub screws) or flat
        if (tip_style == "cup") {
            // Spherical dimple centered slightly inside the bottom face
            // so it creates a shallow cup without breaking through.
            translate([0,0, -L/2 + cup_point_r - cup_point_depth])
                sphere(r=cup_point_r);
        }
    }
}

m4_grub_screw();