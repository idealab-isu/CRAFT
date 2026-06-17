$fn=64;

// Lichuan -80M04030B (approximate envelope model)
// Units: mm

// ---------- Parameters ----------
motor_body_w = 80;
motor_body_h = 80;
motor_body_len = 90;

front_flange_w = 90;
front_flange_h = 90;
front_flange_th = 6;

rear_cap_th = 4;

shaft_d = 19;
shaft_len = 35;

pilot_d = 50;      // front locating boss
pilot_h = 2.5;

mount_hole_d = 9;  // typical M8 clearance-ish
mount_hole_pitch = 70; // square pattern

// Connector bump (approx)
conn_w = 28;
conn_h = 18;
conn_len = 22;

// Cable gland bump (approx)
gland_d = 16;
gland_len = 18;

// Edge rounding
edge_r = 2.0;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1, center=false){
    // Minkowski rounded rectangular prism
    // size is overall size
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([max(0.01,sx-2*r), max(0.01,sy-2*r), max(0.01,sz-2*r)], center=false);
        sphere(r=r);
    }
}

module hole_pattern_square(pitch=70, d=9, th=20){
    for (x=[-pitch/2, pitch/2])
        for (y=[-pitch/2, pitch/2])
            translate([x,y,0]) cylinder(d=d, h=th, center=false);
}

// ---------- Model ----------
module servo_motor(){
    // Coordinate system:
    // Z axis along motor length; front face at z=0, body extends +Z.
    // X/Y centered on motor axis.

    difference(){
        union(){
            // Front flange
            translate([0,0,0])
                rounded_box([front_flange_w, front_flange_h, front_flange_th], r=edge_r, center=true);

            // Main body
            translate([0,0,front_flange_th/2 + motor_body_len/2])
                rounded_box([motor_body_w, motor_body_h, motor_body_len], r=edge_r, center=true);

            // Rear cap
            translate([0,0,front_flange_th + motor_body_len + rear_cap_th/2])
                rounded_box([motor_body_w, motor_body_h, rear_cap_th], r=edge_r, center=true);

            // Front pilot boss
            translate([0,0,-pilot_h/2])
                cylinder(d=pilot_d, h=pilot_h, center=true);

            // Shaft
            translate([0,0,-pilot_h - shaft_len/2])
                cylinder(d=shaft_d, h=shaft_len, center=true);

            // Connector bump on side near rear (approx)
            translate([motor_body_w/2 + conn_len/2 - 2, 0, front_flange_th + motor_body_len*0.70])
                rotate([0,90,0])
                    rounded_box([conn_len, conn_w, conn_h], r=1.5, center=true);

            // Cable gland cylinder on top near rear (approx)
            translate([0, motor_body_h/2 + gland_len/2 - 2, front_flange_th + motor_body_len*0.78])
                rotate([90,0,0])
                    cylinder(d=gland_d, h=gland_len, center=true);
        }

        // Mounting holes through flange
        translate([0,0,-front_flange_th/2 - 0.1])
            hole_pattern_square(pitch=mount_hole_pitch, d=mount_hole_d, th=front_flange_th+0.2);

        // Center shaft clearance through flange (visual)
        translate([0,0,-front_flange_th/2 - 0.1])
            cylinder(d=shaft_d+2, h=front_flange_th+0.2, center=false);
    }
}

servo_motor();