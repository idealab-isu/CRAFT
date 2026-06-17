$fn=64;

// Lichuan -80M01330B (approximate envelope model)
// Units: mm

// ---------- Parameters ----------
motor_body_w = 80;
motor_body_h = 80;
motor_body_l = 130;

front_flange_w = 90;
front_flange_h = 90;
front_flange_t = 6;

front_face_z = 0;                 // front face of flange at z=0
flange_back_z = front_face_z + front_flange_t;
body_front_z  = flange_back_z;    // body starts behind flange
body_back_z   = body_front_z + motor_body_l;

shaft_d = 19;
shaft_l = 35;

pilot_d = 55;     // centering boss
pilot_l = 2;

mount_hole_spacing = 70; // square pattern
mount_hole_d = 6.6;      // clearance for M6
mount_hole_depth = front_flange_t + 2;

corner_r = 4;

// rear features (approx)
rear_boss_d = 50;
rear_boss_l = 6;

cable_box_w = 55;
cable_box_h = 35;
cable_box_l = 25;
cable_box_offset_x = motor_body_w/2 - cable_box_w/2 - 5;
cable_box_offset_y = 0;
cable_box_offset_z = body_front_z + motor_body_l*0.55;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=false){
    // size = [x,y,z]
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [-x/2,-y/2,-z/2] : [0,0,0])
    linear_extrude(height=z)
        offset(r=r)
            square([x-2*r, y-2*r], center=false);
}

module hole_pattern_square(spacing=70, d=6.6, depth=10){
    for (sx=[-1,1], sy=[-1,1]){
        translate([sx*spacing/2, sy*spacing/2, -0.01])
            cylinder(d=d, h=depth+0.02);
    }
}

// ---------- Model ----------
module servo_80M01330B(){
    difference(){
        union(){
            // Front flange
            translate([-front_flange_w/2, -front_flange_h/2, front_face_z])
                rounded_box([front_flange_w, front_flange_h, front_flange_t], r=corner_r, center=false);

            // Motor body
            translate([-motor_body_w/2, -motor_body_h/2, body_front_z])
                rounded_box([motor_body_w, motor_body_h, motor_body_l], r=corner_r, center=false);

            // Front pilot (centering boss)
            translate([0,0,front_face_z - pilot_l])
                cylinder(d=pilot_d, h=pilot_l);

            // Shaft
            translate([0,0,front_face_z - pilot_l - shaft_l])
                cylinder(d=shaft_d, h=shaft_l);

            // Rear boss
            translate([0,0,body_back_z])
                cylinder(d=rear_boss_d, h=rear_boss_l);

            // Cable/connector box (approx)
            translate([cable_box_offset_x - cable_box_w/2,
                       cable_box_offset_y - cable_box_h/2,
                       cable_box_offset_z])
                rounded_box([cable_box_w, cable_box_h, cable_box_l], r=2, center=false);
        }

        // Mounting holes through flange
        translate([0,0,front_face_z])
            hole_pattern_square(spacing=mount_hole_spacing, d=mount_hole_d, depth=mount_hole_depth);

        // Optional shaft key flat (approx) - small cut on shaft
        translate([shaft_d/2 - 2.0, 0, front_face_z - pilot_l - shaft_l - 0.1])
            cube([4.0, shaft_d, shaft_l + 0.2], center=true);
    }
}

servo_80M01330B();