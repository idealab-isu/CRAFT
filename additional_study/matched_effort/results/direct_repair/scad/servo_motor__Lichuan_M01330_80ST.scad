$fn=96;

// Lichuan -80M01330B (approximate envelope model)
// Units: mm

// ---------- Parameters ----------
servo_body_w = 80;
servo_body_h = 80;
servo_body_l = 130;

front_flange_th = 6;
front_flange_d  = 90;

shaft_d = 19;
shaft_len = 35;

pilot_d = 55;
pilot_len = 2.5;

rear_boss_d = 60;
rear_boss_len = 3;

mount_hole_circle_d = 70;
mount_hole_d = 9;
mount_hole_count = 4;

corner_r = 4;

// Connector (approx)
conn_w = 28;
conn_h = 18;
conn_l = 22;
conn_offset_y = -servo_body_w/2 - conn_l/2 + 2; // protrude from side
conn_offset_z = -servo_body_h/2 + conn_h/2 + 10;
conn_offset_x = servo_body_l*0.15;

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=2, center=true){
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
    minkowski(){
        cube([x-2*r, y-2*r, z-2*r], center=true);
        sphere(r=r);
    }
}

module bolt_holes_on_circle(d_circle, d_hole, n=4, h=20){
    for(i=[0:n-1]){
        a = 360/n*i + 45; // typical 4-hole pattern rotated
        translate([ (d_circle/2)*cos(a), (d_circle/2)*sin(a), 0 ])
            cylinder(d=d_hole, h=h, center=true);
    }
}

// ---------- Model ----------
module servo_80M01330B(){
    difference(){
        union(){
            // Main body
            translate([0,0,0])
                rounded_box([servo_body_l, servo_body_w, servo_body_h], r=corner_r, center=true);

            // Front flange
            translate([servo_body_l/2 + front_flange_th/2, 0, 0])
                cylinder(d=front_flange_d, h=front_flange_th, center=true);

            // Front pilot (register)
            translate([servo_body_l/2 + front_flange_th + pilot_len/2, 0, 0])
                cylinder(d=pilot_d, h=pilot_len, center=true);

            // Shaft
            translate([servo_body_l/2 + front_flange_th + pilot_len + shaft_len/2, 0, 0])
                cylinder(d=shaft_d, h=shaft_len, center=true);

            // Rear boss
            translate([-servo_body_l/2 - rear_boss_len/2, 0, 0])
                cylinder(d=rear_boss_d, h=rear_boss_len, center=true);

            // Connector block on side
            translate([conn_offset_x, conn_offset_y, conn_offset_z])
                rounded_box([conn_w, conn_l, conn_h], r=2, center=true);

            // Small cable strain relief nub
            translate([conn_offset_x, conn_offset_y - conn_l/2 - 6, conn_offset_z])
                rounded_box([14, 12, 10], r=2, center=true);
        }

        // Mounting holes through front flange
        translate([servo_body_l/2 + front_flange_th/2, 0, 0])
            bolt_holes_on_circle(mount_hole_circle_d, mount_hole_d, mount_hole_count, h=front_flange_th+2);

        // Optional: shallow face recess around pilot (cosmetic)
        translate([servo_body_l/2 + 0.5, 0, 0])
            cylinder(d=pilot_d+10, h=1.2, center=true);

        // Optional: rear center hole (cosmetic)
        translate([-servo_body_l/2 - rear_boss_len/2, 0, 0])
            cylinder(d=12, h=rear_boss_len+2, center=true);
    }
}

// ---------- Render ----------
servo_80M01330B();