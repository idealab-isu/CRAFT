$fn = 96;

// Target bounding box (approx): 47.8 x 47.8 x 14.3 mm
bbox_X = 47.81;
bbox_Y = 47.81;
bbox_Z = 14.35;

// Thicknesses
plate_t = 10.0;          // main plate thickness
peg_h   = bbox_Z - plate_t;

// Center features
hub_d = 18.0;            // rounded hub diameter (blends into arms)
junction_X = 12.0;       // central rectangular junction size
junction_Y = 12.0;

// Arm geometry (loop/teardrop with big internal cutout)
arm_tip_r = 7.0;         // outer rounded tip radius
arm_root_r = 7.0;        // outer rounded root radius (near center)
arm_center_to_tip = bbox_X/2 - 0.2;   // keep within bbox with small margin
arm_outer_len = arm_center_to_tip - arm_tip_r; // distance from center to tip-circle center

arm_outer_w = 14.0;      // outer arm width (diameter of root circle)
arm_cutout_w = 8.0;      // inner cutout width
arm_cutout_tip_r = 4.0;  // inner cutout tip radius
arm_cutout_root_r = 4.0; // inner cutout root radius

// Ensure cutout stays inside outer loop and leaves material at both ends
arm_cutout_len = arm_outer_len - (arm_root_r + arm_tip_r) + (arm_cutout_root_r + arm_cutout_tip_r) - 2.0;

// Peg/boss
peg_d = 6.0;
peg_taper_scale = 0.92;

// Small overlap for robust unions/differences
overlap = 0.6;

// ---------- Helpers ----------
module capsule2d(len, r1, r2) {
    // 2D capsule/teardrop-like shape along +X, with different end radii
    // End centers at x=0 and x=len
    hull() {
        translate([0, 0]) circle(r=r1);
        translate([len, 0]) circle(r=r2);
    }
}

module arm_outer_2d() {
    // Outer loop arm: capsule with same radii at both ends for a rounded loop member
    capsule2d(arm_outer_len, arm_root_r, arm_tip_r);
}

module arm_cutout_2d() {
    // Inner void: smaller capsule, shifted slightly outward so it doesn't eat the center junction
    // Place root of cutout a bit away from center to preserve the rectangular junction.
    cutout_root_offset = junction_X/2 + 1.2; // formula-based clearance from center block
    cutout_len_eff = max(arm_cutout_len, 6); // safety

    translate([cutout_root_offset, 0])
        capsule2d(cutout_len_eff, arm_cutout_root_r, arm_cutout_tip_r);
}

module one_arm_solid() {
    // Extruded arm with internal cutout
    linear_extrude(height=plate_t, center=true)
        difference() {
            arm_outer_2d();
            arm_cutout_2d();
        }
}

module arms_4x() {
    // Four identical arms at 90° increments
    for (a = [0:90:270])
        rotate([0,0,a]) one_arm_solid();
}

module central_features() {
    union() {
        // Central rounded hub
        cylinder(d=hub_d, h=plate_t, center=true);

        // Central rectangular junction (where arms meet)
        cube([junction_X, junction_Y, plate_t], center=true);
    }
}

module center_peg_boss() {
    // Peg protrudes from one side (top)
    translate([0, 0, plate_t/2 + peg_h/2 - overlap])
        scale([peg_taper_scale, peg_taper_scale, 1])
            cylinder(d=peg_d, h=peg_h, center=true);
}

// ---------- Main solid ----------
module main_part() {
    union() {
        // Make one connected solid: arms + central hub/junction overlap naturally
        union() {
            arms_4x();
            central_features();
        }
        center_peg_boss();
    }
}

main_part();