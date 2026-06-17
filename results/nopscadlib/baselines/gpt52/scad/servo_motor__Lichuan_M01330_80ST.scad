$fn=64;

module rounded_box(size=[10,10,10], r=1, center=true){
    x=size[0]; y=size[1]; z=size[2];
    r2 = min(r, min(x,y)/2);
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
    linear_extrude(height=z)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=false);
}

module bolt_hole(d=5.5, h=50){
    cylinder(d=d, h=h, center=true);
}

module servo_80M01330B(){
    // Approximate envelope for Lichuan 80mm-frame servo motor
    body_w = 80;
    body_h = 80;
    body_l = 150;

    front_flange_w = 90;
    front_flange_h = 90;
    front_flange_t = 8;

    shaft_d = 19;
    shaft_len = 35;

    pilot_d = 60;
    pilot_len = 2.5;

    // Mounting hole pattern (approx): 4 holes on 70x70 square
    hole_pitch = 70;
    hole_d = 6.6;

    // Rear connector bump (approx)
    conn_w = 28;
    conn_h = 18;
    conn_l = 12;

    // Cable gland (approx)
    gland_d = 12;
    gland_len = 10;

    // Front face at +X, rear at -X
    union(){
        // Main body
        color([0.15,0.15,0.15])
        translate([0,0,0])
            rounded_box([body_l, body_w, body_h], r=2.5, center=true);

        // Front flange
        color([0.2,0.2,0.2])
        translate([body_l/2 + front_flange_t/2, 0, 0])
        difference(){
            rounded_box([front_flange_t, front_flange_w, front_flange_h], r=2.0, center=true);

            // Mount holes through flange
            for (sy=[-1,1], sz=[-1,1]){
                translate([0, sy*hole_pitch/2, sz*hole_pitch/2])
                    rotate([0,90,0])
                        cylinder(d=hole_d, h=front_flange_t+2, center=true);
            }

            // Pilot bore clearance (not a hole, just a recess representation)
            translate([front_flange_t/2 - pilot_len/2, 0, 0])
                rotate([0,90,0])
                    cylinder(d=pilot_d, h=pilot_len+0.2, center=true);
        }

        // Pilot boss
        color([0.25,0.25,0.25])
        translate([body_l/2 + front_flange_t + pilot_len/2, 0, 0])
            rotate([0,90,0])
                cylinder(d=pilot_d, h=pilot_len, center=true);

        // Shaft
        color([0.75,0.75,0.78])
        translate([body_l/2 + front_flange_t + pilot_len + shaft_len/2, 0, 0])
            rotate([0,90,0])
                cylinder(d=shaft_d, h=shaft_len, center=true);

        // Shaft key flat (approx) as a cut on shaft (visual)
        color([0.75,0.75,0.78])
        translate([body_l/2 + front_flange_t + pilot_len + shaft_len/2, 0, 0])
        difference(){
            rotate([0,90,0])
                cylinder(d=shaft_d, h=shaft_len, center=true);
            // flat
            translate([0, shaft_d*0.35, 0])
                cube([shaft_len+2, shaft_d, shaft_d*2], center=true);
        }

        // Rear connector bump
        color([0.1,0.1,0.1])
        translate([-body_l/2 - conn_l/2 + 2, 0, -body_h/2 + conn_h/2 + 10])
            rounded_box([conn_l, conn_w, conn_h], r=1.5, center=true);

        // Cable gland cylinder
        color([0.1,0.1,0.1])
        translate([-body_l/2 - gland_len/2 + 2, 0, -body_h/2 + conn_h + 10])
            rotate([0,90,0])
                cylinder(d=gland_d, h=gland_len, center=true);
    }
}

servo_80M01330B();