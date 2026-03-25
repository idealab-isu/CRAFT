$fn=64;

module rounded_box(size=[10,10,10], r=1, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    rr = min(r, sx/2, sy/2, sz/2);
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    minkowski(){
        cube([sx-2*rr, sy-2*rr, sz-2*rr], center=true);
        sphere(r=rr);
    }
}

module bolt_hole(d=5.5, h=20){
    cylinder(d=d, h=h, center=true);
}

module servo_80mm_body(){
    // Approximate dimensions for an 80mm-frame servo motor
    body_w = 80;
    body_h = 80;
    body_l = 160;

    front_flange_w = 90;
    front_flange_h = 90;
    front_flange_t = 6;

    shaft_d = 19;
    shaft_len = 35;

    pilot_d = 60;
    pilot_len = 2.5;

    // Mounting hole pattern (approx. 80mm frame)
    hole_spacing = 70;
    hole_d = 6.6;

    // Rear connector bulge
    rear_bulge_w = 40;
    rear_bulge_h = 30;
    rear_bulge_l = 18;

    // Side cable gland
    gland_d = 14;
    gland_len = 18;

    difference(){
        union(){
            // Main body
            translate([0,0,0])
                rounded_box([body_l, body_w, body_h], r=2.0, center=true);

            // Front flange
            translate([-(body_l/2 + front_flange_t/2), 0, 0])
                rounded_box([front_flange_t, front_flange_w, front_flange_h], r=1.5, center=true);

            // Front pilot
            translate([-(body_l/2 + front_flange_t + pilot_len/2), 0, 0])
                cylinder(d=pilot_d, h=pilot_len, center=true);

            // Shaft
            translate([-(body_l/2 + front_flange_t + pilot_len + shaft_len/2), 0, 0])
                cylinder(d=shaft_d, h=shaft_len, center=true);

            // Rear bulge (connector area)
            translate([(body_l/2 - rear_bulge_l/2), 0, -(body_h/2 - rear_bulge_h/2)])
                rounded_box([rear_bulge_l, rear_bulge_w, rear_bulge_h], r=2.0, center=true);

            // Side gland
            translate([(body_l/2 - 35), (body_w/2 + gland_len/2), 0])
                rotate([90,0,0]) cylinder(d=gland_d, h=gland_len, center=true);
        }

        // Front flange mounting holes (through flange)
        for (yy=[-hole_spacing/2, hole_spacing/2])
        for (zz=[-hole_spacing/2, hole_spacing/2]){
            translate([-(body_l/2 + front_flange_t/2), yy, zz])
                rotate([0,90,0]) cylinder(d=hole_d, h=front_flange_t+2, center=true);
        }

        // Small shaft center dimple
        translate([-(body_l/2 + front_flange_t + pilot_len + shaft_len - 2), 0, 0])
            cylinder(d=6, h=6, center=true);

        // Rear face shallow recess
        translate([(body_l/2 - 1.5), 0, 0])
            cube([3, 50, 50], center=true);
    }
}

module servo_80mm_details(){
    body_l = 160;
    body_w = 80;
    body_h = 80;

    // Side ribs
    rib_t = 2.0;
    rib_h = 10;
    rib_l = 120;
    rib_offset_z = 22;

    for (side=[-1,1]){
        translate([0, side*(body_w/2 - rib_t/2), rib_offset_z])
            rounded_box([rib_l, rib_t, rib_h], r=0.8, center=true);
        translate([0, side*(body_w/2 - rib_t/2), -rib_offset_z])
            rounded_box([rib_l, rib_t, rib_h], r=0.8, center=true);
    }

    // Nameplate
    translate([10, 0, body_h/2 + 0.6])
        rounded_box([60, 30, 1.2], r=1.0, center=true);
}

union(){
    servo_80mm_body();
    servo_80mm_details();
}