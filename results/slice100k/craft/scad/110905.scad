// Paddle-like solid: rectangular body + stepped shoulder + obround peg
// Bounding box target: X=43.5, Y=26, Z=10 (elongated along X)

$fn = 96;

// Parameters (mm)
bbox_X = 43.5;
bbox_Y = 26;
bbox_Z = 10;

body_L = 30;
body_W = 26;
body_T = 10;

shoulder_L = 3;
shoulder_W = 18;
shoulder_T = 10;

peg_L = 13.5;
peg_W = 12;   // obround width (diameter of end caps)
peg_T = 8;    // peg thickness (Z)

hole_d = 6;
hole_axis_offset_from_center_Y = 0;
hole_axis_offset_from_center_Z = 0;
hole_center_from_flat_end_X = 15;

notch_W = 4;
notch_L = 3;
notch_D = 2;

eps = 0.2;

// --- Helpers ---
module obround_2d(L, W) {
    // 2D obround along X, centered at origin
    hull() {
        translate([-(L - W)/2, 0]) circle(r=W/2);
        translate([ +(L - W)/2, 0]) circle(r=W/2);
    }
}

module peg_obround_3d(L, W, T) {
    // 3D obround extruded in Z, centered at origin
    linear_extrude(height=T, center=true)
        obround_2d(L, W);
}

// --- Main solids (all centered in Y and Z, start at X=0 flat end) ---
module main_body_block() {
    translate([body_L/2, 0, 0])
        cube([body_L, body_W, body_T], center=true);
}

module shoulder_step_transition() {
    translate([body_L + shoulder_L/2 - eps, 0, 0])
        cube([shoulder_L, shoulder_W, shoulder_T], center=true);
}

module protruding_peg_obround() {
    // Place peg so it starts at end of shoulder and protrudes outward
    translate([body_L + shoulder_L + peg_L/2 - 2*eps, 0, 0])
        peg_obround_3d(peg_L, peg_W, peg_T);
}

// --- Subtractive features ---
module internal_hole() {
    // Through-hole along Z
    translate([hole_center_from_flat_end_X, hole_axis_offset_from_center_Y, hole_axis_offset_from_center_Z])
        cylinder(d=hole_d, h=bbox_Z + 4*eps, center=true);
}

module small_alignment_notch() {
    // Small notch on bottom near shoulder end of main body
    translate([body_L - notch_L/2, 0, -body_T/2 - notch_D/2 + eps])
        cube([notch_L, notch_W, notch_D + 2*eps], center=true);
}

// --- Final model ---
module final_model() {
    difference() {
        union() {
            main_body_block();
            shoulder_step_transition();
            protruding_peg_obround();
        }
        internal_hole();
        small_alignment_notch();
    }
}

final_model();