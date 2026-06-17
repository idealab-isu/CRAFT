// Rigid shaft coupling: 5.0mm to 8.0mm bore, 12.5mm OD, 25.0mm long
// One connected solid; visible stepped bores + clamp slit + cross set-screw holes.

$fn = 128;

// Parameters
L = 25.0;                 // overall length
OD = 12.5;                // outer diameter

bore_a_d = 5.0;           // end A bore diameter
bore_b_d = 8.0;           // end B bore diameter
bore_a_depth = 12.5;      // depth from end A
bore_b_depth = 12.5;      // depth from end B

step_len = 0.6;           // short transition length at center
eps = 0.02;               // small overlap for robust booleans

set_screw_d = 3.0;        // cross hole diameter
set_screw_z_offset = 6.25;// distance from center along length to each cross hole

slit_w = 1.2;             // clamp slit width
slit_depth = OD/2 + 0.6;  // how far slit cuts radially inward (must reach bore)

chamfer_len = 0.8;        // end chamfer length

// Derived
R = OD/2;
bore_a_r = bore_a_d/2;
bore_b_r = bore_b_d/2;

// --- Base body ---
module body() {
    cylinder(h=L, r=R, center=true);
}

// --- Stepped bores (from each end) ---
module bore_a() {
    // From end A (negative Z) toward center
    translate([0,0, -L/2 + bore_a_depth/2])
        cylinder(h=bore_a_depth + 2*eps, r=bore_a_r, center=true);
}

module bore_b() {
    // From end B (positive Z) toward center
    translate([0,0,  L/2 - bore_b_depth/2])
        cylinder(h=bore_b_depth + 2*eps, r=bore_b_r, center=true);
}

module bore_transition() {
    // Transition centered at Z=0; ensure it bridges between the two bores
    cylinder(h=step_len + 2*eps, r1=bore_a_r, r2=bore_b_r, center=true);
}

// --- Cross set-screw holes (through OD) ---
module set_screw_holes() {
    // Drill along Y axis (after rotate), positioned at +/- set_screw_z_offset along Z
    for (zpos = [-set_screw_z_offset, set_screw_z_offset]) {
        translate([0,0,zpos])
            rotate([90,0,0])
                cylinder(h=OD + 4*eps, r=set_screw_d/2, center=true);
    }
}

// --- Clamp slit (axial slit from OD into bore) ---
module clamp_slit() {
    // A rectangular cut running full length, positioned at +X edge so it opens to outside.
    // Center at x = R - slit_depth/2 so outer face intersects OD and inner face reaches past center.
    translate([R - slit_depth/2, 0, 0])
        cube([slit_depth + 2*eps, slit_w, L + 4*eps], center=true);
}

// --- End chamfers (cut away) ---
module end_chamfers() {
    // Cut cones at both ends to create chamfers
    translate([0,0, -L/2 + chamfer_len/2])
        cylinder(h=chamfer_len + 2*eps, r1=R + eps, r2=R - chamfer_len, center=true);

    translate([0,0,  L/2 - chamfer_len/2])
        cylinder(h=chamfer_len + 2*eps, r1=R - chamfer_len, r2=R + eps, center=true);
}

// --- Final model ---
difference() {
    body();

    // Internal features
    bore_a();
    bore_b();
    bore_transition();

    // External/functional features
    set_screw_holes();
    clamp_slit();
    end_chamfers();
}