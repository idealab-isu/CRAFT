module radial_body(outer_radius=10.8, inner_radius=10.8-1, height=5.3) {
    difference() {
        cylinder(h=height, r=outer_radius, $fn=100);
        cylinder(h=height, r=inner_radius, $fn=100);
    }
}

radial_body();