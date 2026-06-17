$fn=96;

outer_d = 45.0;
outer_d_y = 44.6;
h = 115.0;

bore_d = 24.0;

notch_count = 8;
notch_depth = 6.0;
notch_width = 10.0;
notch_height = 22.0;

key_count = 4;
key_depth = 4.0;
key_width = 8.0;
key_height = 115.0;

module outer_shell() {
    scale([1, outer_d_y/outer_d, 1])
        cylinder(d=outer_d, h=h, center=true);
}

module bore() {
    cylinder(d=bore_d, h=h+2, center=true);
}

module radial_notch(angle_deg, zpos) {
    rotate([0,0,angle_deg])
        translate([outer_d/2 - notch_depth/2, 0, zpos])
            cube([notch_depth, notch_width, notch_height], center=true);
}

module full_height_key(angle_deg) {
    rotate([0,0,angle_deg])
        translate([outer_d/2 - key_depth/2, 0, 0])
            cube([key_depth, key_width, key_height+2], center=true);
}

module notch_set() {
    for (i = [0:notch_count-1]) {
        a = i*360/notch_count;
        radial_notch(a, -h*0.30);
        radial_notch(a, 0);
        radial_notch(a, h*0.30);
    }
}

module key_set() {
    for (i = [0:key_count-1]) {
        a = i*360/key_count + 22.5;
        full_height_key(a);
    }
}

difference() {
    outer_shell();
    bore();
    notch_set();
    key_set();
}