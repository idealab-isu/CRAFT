$fn=64;

// Lichuan -80M03530B (approximate envelope model)
// Units: mm

// ---------- Parameters ----------
motor_body_w = 80;
motor_body_h = 80;
motor_body_l = 90;

front_flange_w = 80;
front_flange_h = 80;
front_flange_t = 6;

front_register_d = 55;   // pilot/register boss
front_register_h = 2;

shaft_d = 19;
shaft_l = 35;

shaft_flat_depth = 1.0;  // D-shaft flat depth (radial)
shaft_flat_len = 22;

rear_cap_t = 3;

mount_hole_spacing = 63; // square pattern
mount_hole_d = 6.6;      // clearance for M6
mount_hole_inset_z = 0;  // through flange

connector_block_w = 28;
connector_block_h = 22;
connector_block_l = 18;

cable_gland_d = 12;
cable_gland_l = 14;

feet_w = 0; // set >0 to add feet (not typical for this servo)

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=false){
    // Minkowski rounded box
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([sx-2*r, sy-2*r, sz-2*r], center=false);
        sphere(r=r);
    }
}

module d_shaft(d=19, len=35, flat_depth=1.0, flat_len=22){
    // Cylinder with a flat along +Y side (approx)
    difference(){
        cylinder(d=d, h=len);
        // Cut a slab to create flat
        translate([-d, d/2 - flat_depth, 0])
            cube([2*d, d, flat_len], center=false);
    }
}

module mount_holes(pattern=63, d=6.6, t=6){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*pattern/2, sy*pattern/2, -0.1])
            cylinder(d=d, h=t+0.2);
    }
}

// ---------- Model ----------
module servo_80mm(){
    // Coordinate system:
    // Front face of flange at Z=0, shaft extends +Z
    // Motor body extends -Z

    difference(){
        union(){
            // Motor body (slightly rounded)
            translate([-motor_body_w/2, -motor_body_h/2, -motor_body_l])
                rounded_box([motor_body_w, motor_body_h, motor_body_l], r=3, center=false);

            // Front flange
            translate([-front_flange_w/2, -front_flange_h/2, -front_flange_t])
                cube([front_flange_w, front_flange_h, front_flange_t], center=false);

            // Front register boss
            translate([0,0,-front_register_h])
                cylinder(d=front_register_d, h=front_register_h);

            // Shaft
            translate([0,0,0])
                d_shaft(d=shaft_d, len=shaft_l, flat_depth=shaft_flat_depth, flat_len=shaft_flat_len);

            // Rear cap lip
            translate([-motor_body_w/2, -motor_body_h/2, -motor_body_l-rear_cap_t])
                cube([motor_body_w, motor_body_h, rear_cap_t], center=false);

            // Connector block on side (right side +X)
            translate([motor_body_w/2, -connector_block_w/2, -motor_body_l*0.55])
                cube([connector_block_l, connector_block_w, connector_block_h], center=false);

            // Cable gland from connector block
            translate([motor_body_w/2 + connector_block_l, 0, -motor_body_l*0.55 + connector_block_h/2])
                rotate([0,90,0])
                    cylinder(d=cable_gland_d, h=cable_gland_l);
        }

        // Mounting holes through flange
        translate([0,0,-front_flange_t])
            mount_holes(pattern=mount_hole_spacing, d=mount_hole_d, t=front_flange_t);

        // Small center relief in flange (optional)
        translate([0,0,-front_flange_t-0.1])
            cylinder(d=22, h=front_flange_t+0.2);
    }
}

// ---------- Render ----------
servo_80mm();