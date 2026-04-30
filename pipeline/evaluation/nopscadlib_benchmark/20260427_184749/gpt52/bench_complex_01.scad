$fn=64;

// Parameters
belt_w = 6;                 // GT2 belt width
clear = 0.25;               // general clearance
bearing_od = 22;            // 608 bearing outer diameter
bearing_id = 8;             // 608 bearing inner diameter
bearing_w  = 7;             // 608 bearing width

// Idler stack
idler_flange_od = 26;
idler_flange_th = 1.6;
idler_body_od   = bearing_od + 2.0;
idler_body_w    = bearing_w + 0.6;

axle_d = 5;                 // idler axle bolt
axle_head_d = 9.5;
axle_head_h = 3.0;

// Arm
arm_th = 8;
arm_w  = 16;
arm_len = 55;
arm_tip_r = 10;

// Pivot
pivot_boss_d = 22;
pivot_hole_d = 5.2;
pivot_boss_h = arm_th;
pivot_offset_x = -arm_len/2 + 12;

// Spring
spring_od = 10.5;           // compression spring outer diameter
spring_pocket_d = spring_od + 0.6;
spring_pocket_depth = 12;
spring_anchor_d = 3.2;      // small pin/hole for spring end
spring_anchor_depth = 6;

// Base block
base_w = 40;
base_l = 50;
base_h = 14;

mount_hole_d = 5.2;
mount_hole_spacing = 30;
mount_counterbore_d = 9.5;
mount_counterbore_h = 4.0;

pivot_post_d = 18;
pivot_post_h = 18;
pivot_post_hole_d = 5.2;

// Geometry helpers
module rounded_bar(len, w, h, r=6) {
    hull() {
        translate([-len/2 + r, 0, 0]) cylinder(d=2*r, h=h, center=false);
        translate([ len/2 - r, 0, 0]) cylinder(d=2*r, h=h, center=false);
    }
    // widen to w using intersection with a box
    intersection() {
        translate([0,0,h/2]) cube([len, w, h], center=true);
        hull() {
            translate([-len/2 + r, 0, 0]) cylinder(d=2*r, h=h, center=false);
            translate([ len/2 - r, 0, 0]) cylinder(d=2*r, h=h, center=false);
        }
    }
}

module idler_pulley() {
    difference() {
        union() {
            // body
            cylinder(d=idler_body_od, h=idler_body_w, center=true);
            // flanges
            translate([0,0, idler_body_w/2 + idler_flange_th/2])
                cylinder(d=idler_flange_od, h=idler_flange_th, center=true);
            translate([0,0,-idler_body_w/2 - idler_flange_th/2])
                cylinder(d=idler_flange_od, h=idler_flange_th, center=true);
        }
        // bearing pocket
        cylinder(d=bearing_od + clear*2, h=bearing_w + 0.8, center=true);
        // axle hole
        cylinder(d=axle_d + clear*2, h=idler_body_w + 2*idler_flange_th + 2, center=true);
    }
}

module pivot_arm() {
    difference() {
        union() {
            // main arm
            translate([0,0,-arm_th/2])
                intersection() {
                    // rounded bar footprint
                    translate([0,0,0]) hull() {
                        translate([-arm_len/2 + arm_tip_r, 0, 0]) cylinder(r=arm_tip_r, h=arm_th, center=false);
                        translate([ arm_len/2 - arm_tip_r, 0, 0]) cylinder(r=arm_tip_r, h=arm_th, center=false);
                    }
                    translate([0,0,arm_th/2]) cube([arm_len, arm_w, arm_th], center=true);
                }

            // pivot boss
            translate([pivot_offset_x, 0, 0])
                cylinder(d=pivot_boss_d, h=pivot_boss_h, center=true);

            // idler boss at tip
            translate([arm_len/2 - 10, 0, 0])
                cylinder(d=20, h=arm_th, center=true);
        }

        // pivot hole
        translate([pivot_offset_x, 0, 0])
            cylinder(d=pivot_hole_d, h=arm_th + 4, center=true);

        // idler axle hole
        translate([arm_len/2 - 10, 0, 0])
            cylinder(d=axle_d + clear*2, h=arm_th + 6, center=true);

        // spring pocket (on arm underside near pivot)
        translate([pivot_offset_x + 14, 0, -arm_th/2])
            cylinder(d=spring_pocket_d, h=spring_pocket_depth, center=false);

        // spring anchor hole (side)
        translate([pivot_offset_x + 14, arm_w/2 - 3, 0])
            rotate([90,0,0]) cylinder(d=spring_anchor_d, h=arm_w, center=true);
    }
}

module base_block() {
    difference() {
        union() {
            // base
            translate([0,0,-base_h/2])
                cube([base_l, base_w, base_h], center=true);

            // pivot post
            translate([-(base_l/2) + 14, 0, base_h/2 + pivot_post_h/2])
                cylinder(d=pivot_post_d, h=pivot_post_h, center=true);

            // spring seat boss
            translate([-(base_l/2) + 26, 0, base_h/2 + 6])
                cylinder(d=16, h=12, center=true);
        }

        // mounting holes (2x)
        for (y = [-mount_hole_spacing/2, mount_hole_spacing/2]) {
            translate([10, y, 0])
                cylinder(d=mount_hole_d, h=base_h + 2, center=true);
            translate([10, y, base_h/2 - mount_counterbore_h/2])
                cylinder(d=mount_counterbore_d, h=mount_counterbore_h + 0.5, center=true);
        }

        // pivot post hole
        translate([-(base_l/2) + 14, 0, base_h/2 + pivot_post_h/2])
            cylinder(d=pivot_post_hole_d, h=pivot_post_h + 2, center=true);

        // spring seat pocket
        translate([-(base_l/2) + 26, 0, base_h/2 + 6 - 6])
            cylinder(d=spring_pocket_d, h=spring_pocket_depth, center=false);

        // spring anchor hole in base boss
        translate([-(base_l/2) + 26, base_w/2 - 6, base_h/2 + 6])
            rotate([90,0,0]) cylinder(d=spring_anchor_d, h=base_w, center=true);
    }
}

module assembly() {
    // Base at origin
    base_block();

    // Arm positioned on pivot post
    translate([-(base_l/2) + 14, 0, base_h/2 + pivot_post_h])
        rotate([0,0,20])
            pivot_arm();

    // Idler pulley at arm tip (visual)
    translate([-(base_l/2) + 14, 0, base_h/2 + pivot_post_h])
        rotate([0,0,20])
            translate([arm_len/2 - 10, 0, 0])
                rotate([90,0,0])
                    idler_pulley();

    // Bearing (visual)
    translate([-(base_l/2) + 14, 0, base_h/2 + pivot_post_h])
        rotate([0,0,20])
            translate([arm_len/2 - 10, 0, 0])
                rotate([90,0,0])
                    difference() {
                        cylinder(d=bearing_od, h=bearing_w, center=true);
                        cylinder(d=bearing_id, h=bearing_w + 2, center=true);
                    }
}

assembly();