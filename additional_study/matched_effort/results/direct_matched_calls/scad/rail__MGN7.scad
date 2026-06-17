$fn = 64;

rail_w = 7.0;
rail_h = 5.0;
rail_l = 100.0;

edge_r = 0.6;

module rounded_box(size=[10,10,10], r=1.0) {
    x = size[0]; y = size[1]; z = size[2];
    r2 = min(r, x/2, y/2, z/2);
    minkowski() {
        cube([x-2*r2, y-2*r2, z-2*r2], center=true);
        sphere(r=r2);
    }
}

module linear_guide_rail(w=7, h=5, l=100) {
    // Simple miniature rail profile: rounded rectangular body with a shallow top groove
    difference() {
        translate([0,0,h/2])
            rounded_box([w, l, h], r=edge_r);

        // Top groove (runs along length)
        groove_w = w * 0.55;
        groove_d = h * 0.22;
        translate([0,0,h - groove_d/2 + 0.01])
            cube([groove_w, l + 2, groove_d], center=true);

        // Small side reliefs near top edges (suggests rail shoulders)
        relief_w = w * 0.18;
        relief_d = h * 0.18;
        xoff = (w/2) - (relief_w/2) - 0.25;
        translate([ xoff, 0, h - relief_d/2 + 0.01])
            cube([relief_w, l + 2, relief_d], center=true);
        translate([-xoff, 0, h - relief_d/2 + 0.01])
            cube([relief_w, l + 2, relief_d], center=true);
    }
}

linear_guide_rail(rail_w, rail_h, rail_l);