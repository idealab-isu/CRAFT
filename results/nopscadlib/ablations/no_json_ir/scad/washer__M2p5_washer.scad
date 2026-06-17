module washer(inner_d=2.5, outer_d=5.9, thickness=0.5, fn=180) {
    difference() {
        cylinder(h=thickness, d=outer_d, center=true, $fn=fn);
        cylinder(h=thickness + 0.2, d=inner_d, center=true, $fn=fn);
    }
}

washer();