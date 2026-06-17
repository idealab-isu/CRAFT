// Dimension-calibrated (target: 19.59 x 12.45 x 12.45 mm)
scale([0.809380, 1.037167, 1.249390])
{
$fn = 96;

// Parameters (kept from prompt, used consistently)
bbox_L = 19.59;
bbox_W = 12.45;
bbox_H = 12.45;

lug_od = 12.0;
lug_thk = 8.0;
hole_d = 4.0;

arm_thk = 3.0;
arm_len_from_lug = 7.0;
arm_w = 8.0;

pad_L = 6.0;
pad_W = 8.0;
pad_thk = 3.0;
pad_angle_deg = 20.0;

notch_U_width = 6.0;
notch_U_depth = 4.0;
notch_U_radius = 3.0;

overlap = 0.8;

// Derived placement (elongated along +X)
lug_x = -bbox_L/2 + lug_od/2;
lug_z = 0;

arm_z = -lug_thk/2 + arm_thk/2;                 // arm sits on bottom of lug
arm_start_x = lug_x + lug_od/2 - overlap;       // overlap into lug for connectivity
arm_len_total = arm_len_from_lug + pad_L;
arm_center_x = arm_start_x + arm_len_total/2;

pad_center_x = arm_start_x + arm_len_from_lug + pad_L/2 - overlap;

// Helper: rotate pad about its left face so it stays connected to arm
module pad_rotated_about_left_face() {
    // local pad cube centered at origin; left face at x = -pad_L/2
    translate([pad_center_x, 0, arm_z]) {
        translate([-pad_L/2, 0, 0])             // move pivot to left face
            rotate([0, pad_angle_deg, 0])       // angle relative to main body
                translate([pad_L/2, 0, 0])      // move back
                    cube([pad_L, pad_W, pad_thk], center=true);
    }
}

module lug_boss() {
    translate([lug_x, 0, lug_z])
        cylinder(r=lug_od/2, h=lug_thk, center=true);
}

module arm_base() {
    translate([arm_center_x, 0, arm_z])
        cube([arm_len_total, arm_w, arm_thk], center=true);
}

// Small blended interface at arm->pad junction (keeps one connected solid even with pad rotation)
module pad_interface_blend() {
    // A short "web" that overlaps both arm and pad near the junction
    web_len = 1.6;
    translate([arm_start_x + arm_len_from_lug - overlap + web_len/2, 0, arm_z])
        cube([web_len, arm_w, arm_thk], center=true);
}

module lug_through_hole() {
    translate([lug_x, 0, lug_z])
        cylinder(r=hole_d/2, h=lug_thk + 2*overlap, center=true);
}

// U-shaped relief/notch cut from the arm between lug and pad
module u_relief_notch() {
    // Place notch just after lug, cutting down into arm width with rounded end
    notch_center_x = arm_start_x + notch_U_depth/2;
    translate([notch_center_x, 0, arm_z]) {
        union() {
            // rectangular part
            cube([notch_U_depth, notch_U_width, arm_thk + 2*overlap], center=true);
            // rounded end (at far end of notch)
            translate([notch_U_depth/2, 0, 0])
                cylinder(r=notch_U_radius, h=arm_thk + 2*overlap, center=true);
        }
    }
}

module bracket_solid() {
    union() {
        lug_boss();
        arm_base();
        pad_interface_blend();
        pad_rotated_about_left_face();
    }
}

difference() {
    // Main connected solid
    bracket_solid();

    // Functional cuts
    u_relief_notch();
    lug_through_hole();
}
}
