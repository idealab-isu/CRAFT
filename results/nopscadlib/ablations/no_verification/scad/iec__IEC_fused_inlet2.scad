$fn = 96;

// ---------------- Parameters ----------------
// Requested panel cutout size (opening in panel)
cutout_width  = 36.0;
cutout_height = 27.0;

// Panel / front features
panel_thickness  = 2.0;
flange_thickness = 2.0;
bezel_thickness  = 1.6;

// Body
body_depth = 30.0;
body_wall  = 2.0;

// Mounting
screw_hole_diameter = 3.2;
screw_hole_pitch_x  = 40.0;
screw_hole_pitch_y  = 31.0;

// Overhangs
flange_overhang_x = 4.0;
flange_overhang_y = 4.0;
bezel_overhang_x  = 2.0;
bezel_overhang_y  = 2.0;

// Fuse drawer (front top area)
fuse_drawer_width  = 20.0;
fuse_drawer_height = 10.0;
fuse_drawer_depth  = 18.0;

// Rear terminals block (kept as solid, connected)
terminal_block_w = 22.0;
terminal_block_h = 14.0;
terminal_block_d = 10.0;

// IEC C14 inlet opening (front face detailing)
iec_open_w = 27.5;
iec_open_h = 20.0;
iec_open_r = 2.0;
iec_open_depth = 6.0;   // recess depth into body from front

// Pin cavities (approximate C14 geometry)
pin_d = 4.8;
pin_depth = 10.0;
pin_pitch_x = 10.0;     // L/N spacing
pin_y = -2.0;           // slightly below center
earth_d = 5.2;
earth_y = 7.0;

// Small overlap to guarantee manifold unions/differences
overlap = 0.6;

// ---------------- Helpers ----------------
module rounded_rect_2d(w, h, r) {
    r2 = min(r, min(w, h)/2);
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(w/2 - r2), sy*(h/2 - r2)]) circle(r=r2);
    }
}

module rounded_box(w, h, d, r) {
    linear_extrude(height=d, center=true)
        rounded_rect_2d(w, h, r);
}

// ---------------- Model ----------------
module iec_fused_inlet_old() {

    // Coordinate system:
    // Z=0 is the panel plane. +Z is front/outside, -Z is rear/inside.
    // The cutout opening is centered at origin in X/Y.

    // Derived sizes
    body_w = cutout_width  + 2*body_wall;
    body_h = cutout_height + 2*body_wall;

    flange_w = cutout_width  + 2*flange_overhang_x;
    flange_h = cutout_height + 2*flange_overhang_y;

    bezel_w  = cutout_width  + 2*bezel_overhang_x;
    bezel_h  = cutout_height + 2*bezel_overhang_y;

    // Corner radii (visual only)
    body_r   = 1.2;
    flange_r = 1.5;
    bezel_r  = 1.2;

    // Z placements (all formulas, no arbitrary offsets)
    z_body_center   = -panel_thickness/2 - body_depth/2 + overlap; // overlaps into panel
    z_flange_center =  flange_thickness/2 - overlap;               // slightly overlaps panel plane
    z_bezel_center  =  flange_thickness + bezel_thickness/2 - overlap;

    // Front face of body (where inlet recess starts)
    z_body_front = z_body_center + body_depth/2;

    // Fuse drawer housing: attached to front face of body, near top
    z_fuse_center = z_body_front - fuse_drawer_depth/2 + overlap; // overlaps into body
    y_fuse_center = cutout_height/2 - body_wall - fuse_drawer_height/2;

    // Rear terminal block: attached to rear end of body
    z_body_rear = z_body_center - body_depth/2;
    z_term_center = z_body_rear - terminal_block_d/2 + overlap;   // overlaps into body rear

    // Inlet recess placement (cut into body from front)
    z_recess_center = z_body_front - iec_open_depth/2 + overlap;

    // Pin cavity placement (cut deeper than recess)
    z_pin_center = z_body_front - pin_depth/2 + overlap;

    // Fuse drawer pocket (cut into fuse housing from front)
    fuse_pocket_w = fuse_drawer_width - 2.0;
    fuse_pocket_h = fuse_drawer_height - 2.0;
    fuse_pocket_d = fuse_drawer_depth - 2.0;
    z_fuse_front = z_fuse_center + fuse_drawer_depth/2;
    z_fuse_pocket_center = z_fuse_front - fuse_pocket_d/2 + overlap;

    // Terminal block shallow wire entry pockets (rear face)
    term_pocket_d = terminal_block_d - 2.0;
    term_pocket_w = terminal_block_w - 2.0;
    term_pocket_h = terminal_block_h - 2.0;
    z_term_rear = z_term_center - terminal_block_d/2;
    z_term_pocket_center = z_term_rear + term_pocket_d/2 - overlap;

    // Build as one connected solid: union of solids, then subtract details
    difference() {
        union() {
            // Main body (solid)
            translate([0, 0, z_body_center])
                rounded_box(body_w, body_h, body_depth, body_r);

            // Front flange (solid)
            translate([0, 0, z_flange_center])
                rounded_box(flange_w, flange_h, flange_thickness, flange_r);

            // Front bezel (solid)
            translate([0, 0, z_bezel_center])
                rounded_box(bezel_w, bezel_h, bezel_thickness, bezel_r);

            // Fuse drawer housing (solid protrusion), connected to body
            translate([0, y_fuse_center, z_fuse_center])
                rounded_box(fuse_drawer_width, fuse_drawer_height, fuse_drawer_depth, 0.8);

            // Rear terminal block (solid), connected to body rear
            translate([0, 0, z_term_center])
                rounded_box(terminal_block_w, terminal_block_h, terminal_block_d, 0.8);
        }

        // ---- Panel cutout opening through flange+bezel (36x27) ----
        translate([0, 0, (z_flange_center + z_bezel_center)/2])
            rounded_box(cutout_width, cutout_height,
                        (flange_thickness + bezel_thickness) + 6*overlap, 0.8);

        // ---- Screw holes through flange+bezel ----
        for (x = [-screw_hole_pitch_x/2, screw_hole_pitch_x/2])
            for (y = [-screw_hole_pitch_y/2, screw_hole_pitch_y/2])
                translate([x, y, (z_flange_center + z_bezel_center)/2])
                    cylinder(d=screw_hole_diameter,
                             h=(flange_thickness + bezel_thickness) + 8*overlap,
                             center=true);

        // ---- IEC C14 inlet recess on front face (recognizable opening) ----
        translate([0, 0, z_recess_center])
            rounded_box(iec_open_w, iec_open_h, iec_open_depth + 2*overlap, iec_open_r);

        // ---- Pin cavities (L/N + Earth) ----
        // L/N
        for (x = [-pin_pitch_x/2, pin_pitch_x/2])
            translate([x, pin_y, z_pin_center])
                cylinder(d=pin_d, h=pin_depth + 2*overlap, center=true);

        // Earth (top center)
        translate([0, earth_y, z_pin_center])
            cylinder(d=earth_d, h=pin_depth + 2*overlap, center=true);

        // ---- Fuse drawer pocket (front opening) ----
        translate([0, y_fuse_center, z_fuse_pocket_center])
            rounded_box(fuse_pocket_w, fuse_pocket_h, fuse_pocket_d + 2*overlap, 0.6);

        // Small finger notch on fuse drawer pocket (top edge)
        notch_r = 3.0;
        translate([0, y_fuse_center + fuse_pocket_h/2 - notch_r, z_fuse_front - notch_r + overlap])
            rotate([90, 0, 0])
                cylinder(r=notch_r, h=fuse_pocket_w + 2*overlap, center=true);

        // ---- Rear terminal block wire entry pocket ----
        translate([0, 0, z_term_pocket_center])
            rounded_box(term_pocket_w, term_pocket_h, term_pocket_d + 2*overlap, 0.6);

        // Three rear wire holes (approx), aligned horizontally
        wire_d = 4.0;
        wire_pitch = 7.0;
        for (x = [-wire_pitch, 0, wire_pitch])
            translate([x, 0, z_term_rear + overlap])
                cylinder(d=wire_d, h=terminal_block_d + 4*overlap, center=false);
    }
}

iec_fused_inlet_old();