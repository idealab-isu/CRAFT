$fn = 64;

rail_w = 7.0;
rail_h = 5.0;
rail_l = 100.0;

edge_r = 0.6;

module rounded_box(size=[10,10,10], r=1.0) {
    x = size[0]; y = size[1]; z = size[2];
    r2 = min(r, x/2, y/2);
    linear_extrude(height=z)
        offset(r=r2)
            square([x-2*r2, y-2*r2], center=true);
}

module linear_guide_rail(w=7.0, h=5.0, l=100.0) {
    // Main body with slightly rounded edges
    translate([0,0,h/2])
        rounded_box([l, w, h], r=edge_r);

    // Subtle top running surface ridge
    ridge_w = w * 0.55;
    ridge_h = h * 0.18;
    translate([0,0,h - ridge_h/2])
        rounded_box([l, ridge_w, ridge_h], r=edge_r*0.6);

    // Side relief grooves (suggestive profile)
    groove_w = w * 0.18;
    groove_h = h * 0.45;
    groove_zc = h * 0.55;

    for (s = [-1, 1]) {
        translate([0, s*(w/2 - groove_w/2 - 0.15), groove_zc])
            difference() {
                // subtract a rounded groove
                translate([0,0,0])
                    rounded_box([l+0.2, groove_w, groove_h], r=edge_r*0.5);
            }
    }
}

difference() {
    linear_guide_rail(rail_w, rail_h, rail_l);

    // Cut the side grooves out of the main body
    groove_w = rail_w * 0.18;
    groove_h = rail_h * 0.45;
    groove_zc = rail_h * 0.55;

    for (s = [-1, 1]) {
        translate([0, s*(rail_w/2 - groove_w/2 - 0.15), groove_zc])
            rounded_box([rail_l+0.4, groove_w, groove_h], r=edge_r*0.5);
    }

    // Optional mounting holes along centerline (small, evenly spaced)
    hole_d = 2.2;
    hole_depth = rail_h + 0.2;
    hole_count = 6;
    margin = 10;

    for (i = [0:hole_count-1]) {
        x = -rail_l/2 + margin + i*( (rail_l - 2*margin) / (hole_count-1) );
        translate([x, 0, rail_h/2])
            rotate([90,0,0])
                cylinder(d=hole_d, h=rail_w+0.6, center=true);
    }
}