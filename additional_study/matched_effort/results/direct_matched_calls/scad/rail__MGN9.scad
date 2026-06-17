$fn = 64;

rail_w = 9.0;
rail_h = 6.0;
rail_l = 100.0;

edge_r = 0.8;

module rounded_box(size=[10,10,10], r=1.0) {
    x = size[0]; y = size[1]; z = size[2];
    r2 = min(r, x/2, y/2, z/2);
    minkowski() {
        cube([x-2*r2, y-2*r2, z-2*r2], center=false);
        sphere(r=r2);
    }
}

difference() {
    // Main rail body with softened edges
    rounded_box([rail_l, rail_w, rail_h], r=edge_r);

    // Subtle top groove to suggest a linear guide profile
    translate([0, rail_w*0.25, rail_h*0.62])
        cube([rail_l, rail_w*0.50, rail_h*0.30], center=false);

    // Small side reliefs
    translate([0, -0.01, rail_h*0.25])
        cube([rail_l, rail_w*0.18, rail_h*0.55], center=false);

    translate([0, rail_w*(1-0.18)+0.01, rail_h*0.25])
        cube([rail_l, rail_w*0.18, rail_h*0.55], center=false);
}