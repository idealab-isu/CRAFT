// Dimension-calibrated (target: 0.15 x 0.13 x 0.08 mm)
scale([0.760005, 0.760012, 1.649379])
{
$fn = 96;

// Target bounding box (mm)
bbox_L = 0.2;
bbox_W = 0.1;
bbox_H = 0.1;

// Base plate (rounded rectangle)
base_L = bbox_L;
base_W = bbox_W;
base_T = 0.02;
base_corner_R = 0.015;

// Central strap-like rib (runs along base)
rib_L = 0.14;
rib_W = 0.02;
rib_H = 0.03;

// Bosses/steps near arm transition (either side of rib)
boss_L = 0.018;
boss_W = 0.012;
boss_H = 0.015;
boss_gap = 0.003;

// Hook arm + tip (strap-like, not a tube)
arm_W = 0.02;            // strap width (Y)
arm_T = 0.012;           // strap thickness (Z)
arm_inner_R = 0.02;      // inner radius of hook
arm_sweep_deg = 210;     // open hook
tip_L = 0.02;
tip_W = 0.02;
tip_H = 0.02;

// Small overlap for watertight unions (in mm; keep tiny due to tiny model)
overlap = 0.001;

// ---------- Helpers ----------
module rounded_rect_prism(L, W, H, R) {
    hull() {
        for (sx = [-1, 1], sy = [-1, 1])
            translate([sx*(L/2 - R), sy*(W/2 - R), 0])
                cylinder(r=R, h=H, center=true);
    }
}

module base_plate() {
    rounded_rect_prism(base_L, base_W, base_T, base_corner_R);
}

module rib() {
    // Rib sits on top of base, centered, runs along X
    translate([0, 0, base_T/2 + rib_H/2 - overlap])
        cube([rib_L, rib_W, rib_H], center=true);
}

module bosses() {
    // Bosses placed near the rib end where the arm starts (positive X end)
    boss_x = rib_L/2 - boss_L/2;
    boss_y = rib_W/2 + boss_gap + boss_W/2 - overlap;
    boss_z = base_T/2 + boss_H/2 - overlap;

    translate([boss_x,  boss_y, boss_z]) cube([boss_L, boss_W, boss_H], center=true);
    translate([boss_x, -boss_y, boss_z]) cube([boss_L, boss_W, boss_H], center=true);
}

module transition_block() {
    // Blend rib into hook root; ensures robust connection
    pad_L = 0.02;
    pad_W = max(rib_W * 1.6, arm_W);
    pad_H = max(arm_T * 1.2, 0.012);

    // Place pad at rib end, sitting on top of rib
    translate([rib_L/2 - pad_L/2, 0, base_T/2 + rib_H - pad_H/2 + overlap])
        cube([pad_L, pad_W, pad_H], center=true);
}

module hook_arm_and_tip() {
    // Hook root at rib end, on top of rib (strap-like section)
    hook_center_x = rib_L/2 - arm_T/2;                 // slight overlap into rib end
    hook_center_z = base_T/2 + rib_H - arm_T/2 + overlap;

    // Strap-like curved arm: rotate_extrude a rectangle (not a circle)
    // rotate_extrude revolves around Z; rotate so axis becomes world Y (hook in XZ plane)
    translate([hook_center_x, 0, hook_center_z])
        rotate([90, 0, 0])  // rotate_extrude axis -> world Y
            rotate_extrude(angle=arm_sweep_deg, convexity=10)
                translate([arm_inner_R + arm_T/2, 0, 0])
                    square([arm_T, arm_W], center=true);

    // Tip: short rectangular end with flat end face, tangent to end of sweep
    r_mid = arm_inner_R + arm_T/2;
    a = arm_sweep_deg;

    // End point in rotate_extrude's XY plane (before rotate([90,0,0])):
    end_x_local = r_mid * cos(a);
    end_y_local = r_mid * sin(a);

    // After rotate([90,0,0]): local X -> world X, local Y -> world Z
    tip_center_x = hook_center_x + end_x_local;
    tip_center_z = hook_center_z + end_y_local;

    // Tangent direction at end angle in local XY: t = [-sin(a), cos(a)]
    // Map to world XZ similarly; rotate tip so its length aligns with tangent.
    tangent_angle_world = atan2(cos(a), -sin(a)); // angle in XZ plane, degrees

    // Place tip so it overlaps into the strap end for a solid union
    translate([tip_center_x, 0, tip_center_z])
        rotate([0, -tangent_angle_world, 0]) // rotate about Y to align length in XZ
            translate([tip_L/2 - overlap, 0, 0])
                cube([tip_L, tip_W, tip_H], center=true);
}

// ---------- Assembly ----------
union() {
    base_plate();
    rib();
    bosses();
    transition_block();
    hook_arm_and_tip();
}
}
