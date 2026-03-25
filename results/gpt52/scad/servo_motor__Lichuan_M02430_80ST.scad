$fn=64;

module rounded_box(size=[10,10,10], r=1, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    rr = min(r, min(sx, min(sy, sz))/2);
    translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    minkowski(){
        cube([sx-2*rr, sy-2*rr, sz-2*rr], center=true);
        sphere(r=rr);
    }
}

module bolt_hole(d=5.5, h=20){
    cylinder(d=d, h=h, center=true);
}

module servo_80M02430B(){
    // Approximate envelope for Lichuan 80mm frame servo motor
    body_w = 80;
    body_h = 80;
    body_l = 160;

    front_flange_d = 90;
    front_flange_t = 6;

    pilot_d = 57;
    pilot_h = 2.5;

    shaft_d = 19;
    shaft_l = 40;

    key_w = 6;
    key_h = 2.8;
    key_l = 28;

    bolt_circle = 70;
    bolt_d = 6.6;

    rear_cap_t = 8;
    rear_boss_d = 50;
    rear_boss_h = 3;

    connector_w = 28;
    connector_h = 18;
    connector_l = 22;

    cable_gland_d = 12;
    cable_gland_l = 18;

    union(){
        // Main body
        color([0.15,0.15,0.15])
        rounded_box([body_l, body_w, body_h], r=2.5, center=true);

        // Front flange
        translate([body_l/2 + front_flange_t/2, 0, 0])
        color([0.75,0.75,0.78])
        difference(){
            cylinder(d=front_flange_d, h=front_flange_t, center=true);
            for(a=[45,135,225,315]){
                translate([ (bolt_circle/2)*cos(a), (bolt_circle/2)*sin(a), 0])
                    bolt_hole(d=bolt_d, h=front_flange_t+2);
            }
            cylinder(d=pilot_d-2, h=front_flange_t+2, center=true);
        }

        // Pilot (register)
        translate([body_l/2 + front_flange_t + pilot_h/2, 0, 0])
        color([0.75,0.75,0.78])
        cylinder(d=pilot_d, h=pilot_h, center=true);

        // Shaft
        translate([body_l/2 + front_flange_t + pilot_h + shaft_l/2, 0, 0])
        color([0.65,0.65,0.68])
        cylinder(d=shaft_d, h=shaft_l, center=true);

        // Key on shaft
        translate([body_l/2 + front_flange_t + pilot_h + (key_l/2) + 4, 0, shaft_d/2 - key_h/2])
        color([0.55,0.55,0.58])
        cube([key_l, key_w, key_h], center=true);

        // Rear cap
        translate([-body_l/2 - rear_cap_t/2, 0, 0])
        color([0.2,0.2,0.2])
        rounded_box([rear_cap_t, body_w*0.98, body_h*0.98], r=2, center=true);

        // Rear boss
        translate([-body_l/2 - rear_cap_t - rear_boss_h/2, 0, 0])
        color([0.2,0.2,0.2])
        cylinder(d=rear_boss_d, h=rear_boss_h, center=true);

        // Side connector block
        translate([-body_l*0.15, body_w/2 + connector_l/2, -body_h*0.15])
        color([0.1,0.1,0.1])
        rounded_box([connector_w, connector_l, connector_h], r=1.5, center=true);

        // Cable gland cylinder from connector
        translate([-body_l*0.15, body_w/2 + connector_l + cable_gland_l/2, -body_h*0.15])
        color([0.1,0.1,0.1])
        rotate([90,0,0])
        cylinder(d=cable_gland_d, h=cable_gland_l, center=true);
    }
}

difference(){
    servo_80M02430B();

    // Front face mounting holes through flange and into body (visual)
    body_l = 160;
    front_flange_t = 6;
    bolt_circle = 70;
    bolt_d = 6.6;

    translate([body_l/2 + front_flange_t/2, 0, 0])
    for(a=[45,135,225,315]){
        translate([ (bolt_circle/2)*cos(a), (bolt_circle/2)*sin(a), 0])
            cylinder(d=bolt_d, h=front_flange_t+10, center=true);
    }
}