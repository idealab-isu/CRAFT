// T-slot nut (sliding rectangular body) for 5.0mm screw, 6.0mm AF hex recess, 3.7mm thick
$fn = 96;

// --- Requested dimensions ---
nut_af        = 6.0;   // across flats (hex recess)
nut_thickness = 3.7;   // overall thickness (Z)
screw_d       = 5.0;   // clearance hole for screw

// --- T-slot nut body (T-profile) ---
body_len = 12.0;       // along slot (X)
body_w   = 8.0;        // base width (Y) - wider part that captures under slot lips
body_h   = nut_thickness;

neck_w   = 6.0;        // neck width (Y) - fits slot opening
neck_h   = 1.6;        // neck height (Z) - top portion

// --- Details ---
eps = 0.02;
edge_bevel = 0.35;

// Hex recess depth (must be <= thickness)
hex_recess_depth = 2.2;

// --- Helpers ---
function hex_points_from_af(af) =
    let(r = af / sqrt(3))  // circumradius for given across-flats
    [ for (i = [0:5]) [ r*cos(60*i + 30), r*sin(60*i + 30) ] ];

module hex_prism_from_af(af, h, center=false) {
    linear_extrude(height=h, center=center)
        polygon(points = hex_points_from_af(af));
}

module beveled_block(size=[10,10,3], bevel=0.3) {
    sx = size[0]; sy = size[1]; sz = size[2];
    b  = min(bevel, min(sx,sy,sz)/4);

    hull() {
        translate([0,0, b/2])
            cube([sx, sy, sz-b], center=true);
        translate([0,0,-b/2])
            cube([sx, sy, sz-b], center=true);
    }
}

// --- Main model ---
module t_slot_nut() {
    // Ensure a true T-profile: base is wider than neck
    assert(body_w > neck_w, "body_w must be > neck_w to form a T-slot nut profile.");
    assert(neck_h > 0 && neck_h < body_h, "neck_h must be > 0 and < body_h.");
    assert(hex_recess_depth > 0 && hex_recess_depth <= body_h, "hex_recess_depth must be <= body_h.");

    base_h = body_h - neck_h;

    difference() {
        // ONE connected solid: wide base + narrow neck (connected with slight overlap)
        union() {
            // Base (bottom)
            translate([0,0, -body_h/2 + base_h/2])
                beveled_block([body_len, body_w, base_h], edge_bevel);

            // Neck (top), overlaps into base by eps to guarantee connectivity
            translate([0,0, body_h/2 - neck_h/2 - eps/2])
                beveled_block([body_len, neck_w, neck_h + eps], edge_bevel);
        }

        // Through hole for 5.0mm screw (clearance)
        cylinder(h = body_h + 2, d = screw_d, center=true);

        // Hex recess on top face (6.0mm AF), does not break through bottom
        translate([0,0, body_h/2 - hex_recess_depth/2 + eps])
            hex_prism_from_af(nut_af, hex_recess_depth + 2*eps, center=true);
    }
}

t_slot_nut();