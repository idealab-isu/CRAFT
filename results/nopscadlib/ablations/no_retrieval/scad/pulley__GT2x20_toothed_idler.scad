$fn = 220;

// Parameters
tooth_count = 20; //[10:60:1]
pitch_diameter = 12.22; //[6.11:24.44:0.01]
pulley_width = 10; //[5:20:0.5]
body_od = 14.5; //[10:29:0.1]
tooth_height = 1.2; //[0.6:2.4:0.05]
tooth_top_width = 0.8; //[0.4:1.6:0.05]
tooth_root_width = 1.6; //[0.8:3.2:0.05]
bore_diameter = 5; //[2.5:10:0.1]
hub_diameter = 18; //[9:36:0.1]
hub_length = 12; //[6:24:0.5]
flange_diameter = 20; //[10:40:0.1]
flange_thickness = 1.5; //[0.8:3:0.1]
set_screw_diameter = 3; //[2:6:0.1]
set_screw_z_offset = 0; //[-6:6:0.5]
keyway_width = 2; //[1:4:0.1]
keyway_depth = 1; //[0.5:2:0.1]
keyway_length = 10; //[5:20:0.5]
overlap = 1.2; //[0.5:2:0.1]

// Derived
pitch_r = pitch_diameter/2;
body_r  = body_od/2;

// --- Timing tooth geometry (simple/blocky but recognizable) ---
// Place tooth so its midline sits on the pitch circle (pitch diameter meaningful).
tooth_radial_len = tooth_height;
tooth_center_r   = pitch_r;

tooth_inner_r = tooth_center_r - tooth_radial_len/2;
tooth_outer_r = tooth_center_r + tooth_radial_len/2;

// Ensure tooth inner edge overlaps into the body for a single connected solid.
body_r_eff = max(body_r, tooth_inner_r + overlap);

// Base Shapes
module pulley_body() {
    cylinder(r=body_r_eff, h=pulley_width, center=true);
}

module tooth() {
    // Trapezoid prism extruded along Z.
    // Built in XY plane (tangent = X, radial = Y), then rotated so radial points outward (+X).
    // Positioned so tooth centerline is at pitch radius.
    rotate([0,0,-90])
        translate([tooth_center_r, 0, 0])
            linear_extrude(height=pulley_width, center=true)
                polygon(points=[
                    [-tooth_root_width/2, -tooth_radial_len/2],
                    [ tooth_root_width/2, -tooth_radial_len/2],
                    [ tooth_top_width/2,   tooth_radial_len/2],
                    [-tooth_top_width/2,   tooth_radial_len/2]
                ]);
}

module teeth_array() {
    for (i = [0:tooth_count-1])
        rotate([0, 0, i*360/tooth_count])
            tooth();
}

module hub() {
    cylinder(r=hub_diameter/2, h=hub_length, center=true);
}

module flange_top() {
    // Touch/overlap the pulley body by 'overlap'
    translate([0, 0, pulley_width/2 + flange_thickness/2 - overlap])
        cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

module flange_bottom() {
    translate([0, 0, -pulley_width/2 - flange_thickness/2 + overlap])
        cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

module center_bore() {
    // Long enough to cut through hub + flanges with margin
    cylinder(r=bore_diameter/2, h=hub_length + 2*flange_thickness + 6*overlap, center=true);
}

module set_screw_hole() {
    translate([0, 0, set_screw_z_offset])
        rotate([0, 90, 0])
            cylinder(r=set_screw_diameter/2, h=hub_diameter + 4*overlap, center=true);
}

module keyway() {
    translate([bore_diameter/2 - keyway_depth/2, 0, 0])
        cube([keyway_depth + 2*overlap, keyway_width, keyway_length], center=true);
}

// Assembly
module pulley_solid() {
    union() {
        // Main toothed section (recognizable timing pulley)
        union() {
            pulley_body();
            teeth_array();
        }
        // Hub and flanges (overlap ensures single connected solid)
        hub();
        flange_top();
        flange_bottom();
    }
}

module complete_model() {
    difference() {
        pulley_solid();
        center_bore();
        set_screw_hole();
        keyway();
    }
}

complete_model();