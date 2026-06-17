$fn=64;

outer_w = 50.8;
outer_h = 38.1;
wall = 3.0;
len = 100;

inner_w = outer_w - 2*wall;
inner_h = outer_h - 2*wall;

module box_section(w, h, t, l) {
    difference() {
        cube([w, h, l], center=true);
        cube([w-2*t, h-2*t, l+0.2], center=true);
    }
}

box_section(outer_w, outer_h, wall, len);