$fn = 64;

module tht_package(body_w=4.6, body_t=2.5, body_l=2.5) {
    color([0.1,0.1,0.1])
    translate([-body_l/2, -body_w/2, 0])
        cube([body_l, body_w, body_t], center=false);
}

module leads(body_w=4.6, body_t=2.5, body_l=2.5,
             lead_d=0.6, lead_len=6.0, lead_inset=0.7) {
    lead_x = body_l/2 + lead_len/2;
    yoff = body_w/2 - lead_inset;
    for (s = [-1, 1]) {
        color([0.75,0.75,0.75])
        translate([lead_x, s*yoff, body_t/2])
            rotate([0,90,0])
                cylinder(d=lead_d, h=lead_len, center=true);
    }
}

module model() {
    union() {
        tht_package();
        leads();
    }
}

model();