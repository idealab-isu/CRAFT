$fn=64;

// Lichuan -80M02430B (approximate envelope model)
// Units: mm

// ---------- Parameters ----------
motor_body_w = 80;
motor_body_h = 80;
motor_body_l = 90;

front_flange_w = 80;
front_flange_h = 80;
front_flange_t = 6;

front_boss_d = 38;
front_boss_t = 2.5;

shaft_d = 19;
shaft_l = 35;

shaft_flat_depth = 2.0;   // depth of flat cut into shaft radius
shaft_flat_len = 22;      // length of flat portion from tip backwards

rear_cap_t = 4;

mount_hole_d = 6.6;       // clearance for M6
mount_hole_spacing = 63;  // typical 80mm servo pattern

// Connector bump (approx)
conn_w = 22;
conn_h = 14;
conn_l = 18;

// Cable gland / rear boss (approx)
rear_boss_d = 22;
rear_boss_l = 10;

// Edge rounding (small)
edge_r = 2.0;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1, center=false){
    // Minkowski rounded box (kept modest for performance)
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([sx-2*r, sy-2*r, sz-2*r], center=false);
        sphere(r=r);
    }
}

module mount_holes(z0, z1){
    // Through holes along Z axis
    for (x=[-mount_hole_spacing/2, mount_hole_spacing/2])
    for (y=[-mount_hole_spacing/2, mount_hole_spacing/2])
        translate([x,y,(z0+z1)/2])
            cylinder(d=mount_hole_d, h=(z1-z0)+2, center=true);
}

module shaft_with_flat(){
    // Shaft along +Z from front face
    // Flat is created by subtracting a box from the shaft
    difference(){
        cylinder(d=shaft_d, h=shaft_l, center=false);
        // Flat cut: remove a slab on +X side to create D-shaft
        // Place slab so it cuts into radius by shaft_flat_depth
        translate([shaft_d/2 - shaft_flat_depth, -shaft_d, shaft_l - shaft_flat_len])
            cube([shaft_d, 2*shaft_d, shaft_flat_len+1], center=false);
    }
}

// ---------- Model ----------
module servo_80M02430B(){
    // Coordinate system:
    // Front face at z=0, body extends to +Z
    // Shaft extends to -Z (typical), but we will place shaft to -Z for realism.
    // We'll build body from z=0..motor_body_l, shaft from z=-shaft_l..0.

    difference(){
        union(){
            // Main body
            translate([-motor_body_w/2, -motor_body_h/2, 0])
                rounded_box([motor_body_w, motor_body_h, motor_body_l], r=edge_r, center=false);

            // Front flange
            translate([-front_flange_w/2, -front_flange_h/2, -front_flange_t])
                rounded_box([front_flange_w, front_flange_h, front_flange_t], r=edge_r, center=false);

            // Front boss (pilot)
            translate([0,0,-front_boss_t])
                cylinder(d=front_boss_d, h=front_boss_t, center=false);

            // Shaft (extends forward from flange)
            translate([0,0,-front_flange_t - shaft_l])
                shaft_with_flat();

            // Rear cap (slight step)
            translate([-motor_body_w/2, -motor_body_h/2, motor_body_l])
                rounded_box([motor_body_w, motor_body_h, rear_cap_t], r=edge_r, center=false);

            // Rear boss / cable gland
            translate([0,0,motor_body_l + rear_cap_t])
                cylinder(d=rear_boss_d, h=rear_boss_l, center=false);

            // Side connector bump (approx) on right side near rear
            translate([motor_body_w/2, 0, motor_body_l*0.65])
                rotate([0,90,0])
                    rounded_box([conn_l, conn_w, conn_h], r=1.2, center=true);
        }

        // Mounting holes through flange (z from -front_flange_t to +front_flange_t/2)
        mount_holes(-front_flange_t-1, 2);

        // Center bore relief (optional) through boss/flange (small)
        translate([0,0,-front_flange_t-2])
            cylinder(d=10, h=front_flange_t+6, center=false);
    }
}

// Render
servo_80M02430B();