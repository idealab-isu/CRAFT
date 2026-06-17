$fn=64;

rail_w = 7.0;
rail_h = 5.0;
rail_l = 100.0;

module rail_profile(w, h) {
    // Simple linear guide rail profile: rectangular body with two side chamfers and a shallow top groove
    difference() {
        // Base body
        square([w, h], center=true);

        // Side chamfers (45°)
        translate([-(w/2), 0]) rotate(45) square([h*1.2, h*1.2], center=false);
        translate([(w/2), 0]) rotate(45) square([h*1.2, h*1.2], center=false);

        // Top groove
        groove_w = w * 0.55;
        groove_d = h * 0.22;
        translate([0, (h/2) - groove_d/2])
            square([groove_w, groove_d], center=true);
    }
}

module linear_guide_rail(w, h, l) {
    color([0.7,0.7,0.75])
    linear_extrude(height=l, center=true, convexity=10)
        rail_profile(w, h);
}

linear_guide_rail(rail_w, rail_h, rail_l);