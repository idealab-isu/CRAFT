$fn=64;

module t_bracket(body_len=80, body_w=30, body_h=10, stem_len=50, stem_w=14, stem_h=10, hole_d=10) {
    difference() {
        union() {
            translate([0, 0, 0])
                cube([body_len, body_w, body_h], center=true);
            translate([0, -(body_w/2 + stem_len/2), 0])
                cube([stem_w, stem_len, stem_h], center=true);
        }
        translate([0, 0, 0])
            cylinder(h=body_h+2, d=hole_d, center=true);
    }
}

t_bracket();