// Timing pulley: 16 teeth, 9.65mm pitch diameter
// Structural fixes applied:
// - Add clearly visible timing teeth (16x) around circumference
// - Construct teeth so pitch diameter is respected (pitch circle at mid-tooth height)
// - Ensure all parts are connected with small overlaps (1–2mm)
// - Recalculate all translate() values from dimensions (no arbitrary offsets)
// - Single connected solid; only final difference removes holes/features

$fn = 180;

// -------------------- Parameters --------------------
tooth_count     = 16;
pitch_diameter  = 9.65;
pitch_radius    = pitch_diameter/2;

pulley_width    = 10;

// Tooth geometry (simple, blocky timing-tooth silhouette)
tooth_height     = 1.2;   // radial height (root->tip)
tooth_tip_width  = 1.0;   // tangential width at tip
tooth_root_width = 1.8;   // tangential width at root
tooth_overlap    = 1.0;   // overlap into body for robust union

// Hub / flanges
bore_diameter     = 5.0;
hub_diameter      = 14.0;
hub_length        = 12.0;
flange_thickness  = 1.0;
flange_diameter   = 16.0;

// Features
set_screw_diameter = 2.5;
set_screw_axis_z   = 0.0;
keyway_width       = 2.0;
keyway_depth       = 1.0;
keyway_length      = 12.0;

// Robustness / connectivity
union_overlap = 1.0;   // 1–2mm overlap
chamfer_size  = 0.6;

// -------------------- Derived radii --------------------
// Pitch circle at mid-tooth height => pitch_radius = (r_root + r_tip)/2
r_root = pitch_radius - tooth_height/2;
r_tip  = pitch_radius + tooth_height/2;

// Keep radii valid
min_r = 0.2;
r_root_safe = max(r_root, min_r);
r_tip_safe  = max(r_tip,  r_root_safe + 0.01);

// Body cylinder radius slightly under root so teeth are obvious
body_r = max(r_root_safe - 0.15, min_r);

// Tooth pitch
tooth_pitch_angle = 360/tooth_count;

// Valley angular width (must be < pitch)
valley_angle_raw = tooth_pitch_angle * 0.55;
valley_angle     = min(valley_angle_raw, tooth_pitch_angle - 4);
valley_angle     = max(valley_angle, 6);

// Valley cutter radius: must reach into tooth region to create visible gaps,
// but not so deep it erases the body cylinder.
valley_r = max(r_root_safe + 0.05, body_r + 0.10);

// -------------------- 2D/3D helpers --------------------
module tooth_2d() {
    // Local coords: X radial, Y tangential; centered about Y=0
    // Trapezoid tooth profile (blocky but recognizable)
    polygon(points=[
        [r_root_safe - tooth_overlap, -tooth_root_width/2],
        [r_root_safe - tooth_overlap,  tooth_root_width/2],
        [r_tip_safe,                   tooth_tip_width/2],
        [r_tip_safe,                  -tooth_tip_width/2]
    ]);
}

module tooth_solid() {
    linear_extrude(height=pulley_width, center=true, convexity=10)
        tooth_2d();
}

// Valley cutter: wedge prism intersected with a cylinder to carve between teeth.
module valley_cutter() {
    intersection() {
        cylinder(r=valley_r, h=pulley_width + 2*union_overlap, center=true);

        linear_extrude(height=pulley_width + 2*union_overlap, center=true, convexity=10)
            polygon(points=[
                [0,0],
                [valley_r*2, 0],
                [valley_r*2*cos(valley_angle/2),  valley_r*2*sin(valley_angle/2)],
                [valley_r*2*cos(valley_angle/2), -valley_r*2*sin(valley_angle/2)]
            ]);
    }
}

module pulley_root_cylinder() {
    cylinder(r=body_r, h=pulley_width, center=true);
}

// Hub and flanges (overlap to ensure connectivity)
module hub() {
    cylinder(r=hub_diameter/2, h=hub_length, center=true);
}

module flange_top() {
    // Touches pulley at +pulley_width/2, overlaps by union_overlap
    translate([0,0, pulley_width/2 + flange_thickness/2 - union_overlap])
        cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

module flange_bottom() {
    // Touches pulley at -pulley_width/2, overlaps by union_overlap
    translate([0,0, -pulley_width/2 - flange_thickness/2 + union_overlap])
        cylinder(r=flange_diameter/2, h=flange_thickness, center=true);
}

// Bore and features
module center_bore() {
    cylinder(r=bore_diameter/2,
             h=hub_length + pulley_width + 2*flange_thickness + 6*union_overlap,
             center=true);
}

module set_screw_hole() {
    // Through hub radially (X axis), centered in Z by set_screw_axis_z
    translate([0,0,set_screw_axis_z])
        rotate([0,90,0])
            cylinder(r=set_screw_diameter/2,
                     h=hub_diameter + 6*union_overlap,
                     center=true);
}

module keyway() {
    // Slot intersects bore; positioned tangent-ish to bore
    translate([bore_diameter/2 - keyway_depth/2 + union_overlap, 0, 0])
        cube([keyway_depth + 2*union_overlap, keyway_width, keyway_length], center=true);
}

// Chamfers on hub ends (subtractive cones)
module chamfer_top_cut() {
    translate([0,0, hub_length/2 - chamfer_size/2 + union_overlap/2])
        cylinder(h=chamfer_size + union_overlap,
                 r1=hub_diameter/2 + chamfer_size,
                 r2=hub_diameter/2 - 0.01,
                 center=true);
}

module chamfer_bottom_cut() {
    translate([0,0, -hub_length/2 + chamfer_size/2 - union_overlap/2])
        cylinder(h=chamfer_size + union_overlap,
                 r1=hub_diameter/2 - 0.01,
                 r2=hub_diameter/2 + chamfer_size,
                 center=true);
}

// -------------------- Teeth / valleys --------------------
module teeth_array() {
    for (i=[0:tooth_count-1]) {
        rotate([0,0, i*tooth_pitch_angle])
            tooth_solid();
    }
}

module valleys_cut() {
    for (i=[0:tooth_count-1]) {
        rotate([0,0, i*tooth_pitch_angle + tooth_pitch_angle/2])
            valley_cutter();
    }
}

module pulley_with_teeth() {
    // Start from root cylinder, add teeth, then cut valleys to reveal tooth shape.
    difference() {
        union() {
            pulley_root_cylinder();
            teeth_array();
        }
        valleys_cut();
    }
}

module pulley_complete_solid() {
    // Ensure hub overlaps pulley body in Z (hub_length >= pulley_width already),
    // and flanges overlap pulley body by union_overlap.
    union() {
        pulley_with_teeth();
        hub();
        flange_top();
        flange_bottom();
    }
}

module pulley_final() {
    // Single connected solid; only subtractive features here.
    difference() {
        difference() {
            pulley_complete_solid();
            chamfer_top_cut();
            chamfer_bottom_cut();
        }
        center_bore();
        set_screw_hole();
        keyway();
    }
}

// -------------------- Output --------------------
pulley_final();