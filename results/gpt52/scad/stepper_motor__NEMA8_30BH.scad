$fn=64;

face_w = 20.0;
body_l = 30.0;
shaft_d = 5.0;
shaft_l = 12.0;

mount_spacing = 16.0;
mount_hole_d = 3.2;

front_plate_t = 2.0;
body_w = face_w;
body_h = face_w;

boss_d = 10.0;
boss_h = 1.5;

module motor_body() {
    translate([0,0,-body_l/2])
        cube([body_w, body_h, body_l], center=true);
}

module front_plate() {
    translate([0,0, body_l/2 - front_plate_t/2])
        cube([face_w, face_w, front_plate_t], center=true);
}

module mounting_holes() {
    for (x = [-mount_spacing/2, mount_spacing/2])
        for (y = [-mount_spacing/2, mount_spacing/2])
            translate([x,y, body_l/2 - front_plate_t/2])
                cylinder(d=mount_hole_d, h=front_plate_t + 0.6, center=true);
}

module boss() {
    translate([0,0, body_l/2 + boss_h/2])
        cylinder(d=boss_d, h=boss_h, center=true);
}

module shaft() {
    translate([0,0, body_l/2 + boss_h + shaft_l/2])
        cylinder(d=shaft_d, h=shaft_l, center=true);
}

difference() {
    union() {
        motor_body();
        front_plate();
        boss();
        shaft();
    }
    mounting_holes();
}