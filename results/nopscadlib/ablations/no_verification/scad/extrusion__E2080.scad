// 20x80 aluminium T-slot extrusion (approximate standard profile)
// Cross-section: 20mm x 80mm, Length: 100mm
// One connected solid, no floating parts.

$fn = 96;

// Parameters (mm)
W = 20.0;     // overall width (X)
H = 80.0;     // overall height (Y)
L = 100.0;    // length (Z)

wall = 2.2;          // outer wall thickness
slot_open = 6.0;     // slot mouth opening
slot_depth = 8.0;    // depth from outer face to inner cavity
slot_cavity_w = 12.0;// undercut cavity width
slot_cavity_d = 4.0; // additional depth for cavity beyond slot_depth

center_bore_d = 6.0; // center bore diameter

web = 2.0;           // internal web thickness
overlap = 0.25;      // boolean overlap

// ---- Helpers ----
module slot_cut_x(sign=1) {
    // Cuts a T-slot on the +/-X face, running along Z
    // Mouth (narrow)
    translate([sign*(W/2 - slot_depth/2 + overlap/2), 0, 0])
        cube([slot_depth + overlap, slot_open, L + 2*overlap], center=true);

    // Undercut cavity (wide)
    translate([sign*(W/2 - (slot_depth + slot_cavity_d)/2 + overlap/2), 0, 0])
        cube([slot_depth + slot_cavity_d + overlap, slot_cavity_w, L + 2*overlap], center=true);
}

module slot_cut_y(sign=1) {
    // Cuts a T-slot on the +/-Y face, running along Z
    translate([0, sign*(H/2 - slot_depth/2 + overlap/2), 0])
        cube([slot_open, slot_depth + overlap, L + 2*overlap], center=true);

    translate([0, sign*(H/2 - (slot_depth + slot_cavity_d)/2 + overlap/2), 0])
        cube([slot_cavity_w, slot_depth + slot_cavity_d + overlap, L + 2*overlap], center=true);
}

// ---- Main profile ----
module extrusion_20x80() {
    // Build as a single unioned solid: (outer shell minus cuts) + internal webs
    union() {
        difference() {
            // Outer body (ensures visible outer rectangular boundary)
            cube([W, H, L], center=true);

            // Inner void (keeps outer walls)
            cube([W - 2*wall, H - 2*wall, L + 2*overlap], center=true);

            // T-slots on all four faces
            slot_cut_x( 1);
            slot_cut_x(-1);
            slot_cut_y( 1);
            slot_cut_y(-1);

            // Center bore
            cylinder(d=center_bore_d, h=L + 2*overlap, center=true);
        }

        // Internal webs (overlap slightly into shell so everything is one connected manifold)
        cube([web, H - 2*wall + 2*overlap, L], center=true); // vertical web
        cube([W - 2*wall + 2*overlap, web, L], center=true); // horizontal web
    }
}

// Render
color("Silver") extrusion_20x80();