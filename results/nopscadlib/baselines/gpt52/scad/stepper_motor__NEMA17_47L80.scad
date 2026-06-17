$fn=96;

face_w = 42.3;
body_len = 47.0;
shaft_d = 5.0;
shaft_len = 22.0;

mount_spacing = 31.0;
mount_hole_d = 3.2;

front_boss_d = 22.0;
front_boss_len = 2.0;

corner_r = 4.0;

module rounded_square_prism(w, h, r, len, center=true) {
    linear_extrude(height=len, center=center)
        offset(r=r)
            offset(delta=-r)
                square([w, h], center=true);
}

module motor_body() {
    rounded_square_prism(face_w, face_w, corner_r, body_len, center=true);
}

module front_boss() {
    translate([0,0, body_len/2 + front_boss_len/2])
        cylinder(d=front_boss_d, h=front_boss_len, center=true);
}

module shaft() {
    translate([0,0, body_len/2 + front_boss_len + shaft_len/2])
        cylinder(d=shaft_d, h=shaft_len, center=true);
}

module mounting_holes_through() {
    for (x = [-mount_spacing/2, mount_spacing/2])
        for (y = [-mount_spacing/2, mount_spacing/2])
            translate([x,y,0])
                cylinder(d=mount_hole_d, h=body_len + 2*front_boss_len + 2*shaft_len + 10, center=true);
}

difference() {
    union() {
        motor_body();
        front_boss();
        shaft();
    }
    mounting_holes_through();
}