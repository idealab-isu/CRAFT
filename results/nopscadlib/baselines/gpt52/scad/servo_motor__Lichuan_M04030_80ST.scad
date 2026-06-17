$fn=64;

module rounded_box(size=[10,10,10], r=1, center=true){
    sx=size[0]; sy=size[1]; sz=size[2];
    rr = min(r, sx/2, sy/2, sz/2);
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([sx-2*rr, sy-2*rr, sz-2*rr], center=false);
        sphere(r=rr);
    }
}

module bolt_hole(d=5.5, h=20){
    cylinder(d=d, h=h, center=true);
}

module servo_80m04030b(){
    // Approximate envelope for Lichuan 80mm frame servo motor
    body_w = 80;
    body_h = 80;
    body_l = 160;

    front_flange_t = 6;
    front_flange_w = 90;
    front_flange_h = 90;

    shaft_d = 19;
    shaft_len = 35;

    pilot_d = 55;
    pilot_len = 2.5;

    bolt_circle = 70;
    bolt_d = 6.6;

    rear_cap_t = 6;
    rear_boss_d = 40;
    rear_boss_len = 2.5;

    connector_w = 28;
    connector_h = 18;
    connector_l = 20;

    union(){
        // Main body
        color([0.15,0.15,0.15])
        rounded_box([body_l, body_w, body_h], r=2.0, center=true);

        // Front flange
        color([0.2,0.2,0.2])
        translate([body_l/2 + front_flange_t/2, 0, 0])
        difference(){
            rounded_box([front_flange_t, front_flange_w, front_flange_h], r=2.0, center=true);

            // Bolt holes (4)
            for(a=[45,135,225,315]){
                translate([0,
                           (bolt_circle/2)*cos(a),
                           (bolt_circle/2)*sin(a)])
                    rotate([0,90,0]) bolt_hole(d=bolt_d, h=front_flange_t+4);
            }

            // Pilot recess/through
            rotate([0,90,0]) cylinder(d=pilot_d, h=front_flange_t+4, center=true);
        }

        // Pilot boss (front)
        color([0.25,0.25,0.25])
        translate([body_l/2 + front_flange_t + pilot_len/2, 0, 0])
            rotate([0,90,0]) cylinder(d=pilot_d, h=pilot_len, center=true);

        // Shaft
        color([0.75,0.75,0.75])
        translate([body_l/2 + front_flange_t + pilot_len + shaft_len/2, 0, 0])
            rotate([0,90,0]) cylinder(d=shaft_d, h=shaft_len, center=true);

        // Rear cap
        color([0.18,0.18,0.18])
        translate([-body_l/2 - rear_cap_t/2, 0, 0])
            rounded_box([rear_cap_t, body_w, body_h], r=2.0, center=true);

        // Rear boss
        color([0.22,0.22,0.22])
        translate([-body_l/2 - rear_cap_t - rear_boss_len/2, 0, 0])
            rotate([0,90,0]) cylinder(d=rear_boss_d, h=rear_boss_len, center=true);

        // Side connector block (approx)
        color([0.05,0.05,0.05])
        translate([-body_l/2 + 25, body_w/2 + connector_l/2, -body_h/2 + 22])
            rounded_box([connector_w, connector_l, connector_h], r=1.2, center=true);
    }
}

servo_80m04030b();