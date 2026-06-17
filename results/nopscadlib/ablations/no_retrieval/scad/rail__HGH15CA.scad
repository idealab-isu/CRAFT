// Miniature linear guide rail (profiled) 15 x 15 x 100 mm
// One connected solid; features are cut into the body (raceways + mounting holes)

$fn = 64;

// Parameters
rail_length = 100.0; //[50.0:200.0:1]
rail_width  = 15.0;  //[7.5:30.0:0.5]
rail_height = 15.0;  //[7.5:30.0:0.5]

// Feature parameters (kept proportional to 15x15 profile)
edge_chamfer = min(0.8, min(rail_width, rail_height) * 0.06); // small corner bevel
race_r       = min(1.6, min(rail_width, rail_height) * 0.11); // raceway groove radius
race_depth   = race_r * 0.85;                                  // groove depth into side
race_z       = rail_height * 0.62;                             // groove center height

hole_d       = min(4.2, rail_width * 0.28);                    // through hole diameter
csk_d        = min(7.2, rail_width * 0.48);                    // counterbore diameter
csk_h        = min(3.0, rail_height * 0.20);                   // counterbore depth

// Hole layout along length
end_margin   = max(10, rail_length * 0.10);
hole_count   = (rail_length >= 90) ? 4 : (rail_length >= 60 ? 3 : 2);
hole_pitch   = (hole_count > 1) ? (rail_length - 2*end_margin) / (hole_count - 1) : 0;

// Helpers
module rounded_rect_prism(L, W, H, r) {
    // Minkowski rounding for a subtle profile; keeps overall size W x H x L
    minkowski() {
        cube([L - 2*r, W - 2*r, H - 2*r], center=true);
        sphere(r=r);
    }
}

module rail_body_profiled() {
    // Base body with slight edge rounding
    rounded_rect_prism(rail_length, rail_width, rail_height, edge_chamfer);
}

module raceway_groove(side=1) {
    // Long cylindrical cut along X, positioned on +/-Y side, at height race_z
    // side = +1 (positive Y), -1 (negative Y)
    translate([0,
               side * (rail_width/2 - race_depth),
               -rail_height/2 + race_z])
        rotate([0, 90, 0])
            cylinder(h=rail_length + 2, r=race_r, center=true);
}

module mounting_holes() {
    for (i = [0:hole_count-1]) {
        x = -rail_length/2 + end_margin + i*hole_pitch;

        // Through hole
        translate([x, 0, 0])
            rotate([90, 0, 0])
                cylinder(h=rail_width + 2, d=hole_d, center=true);

        // Counterbore from top face (Z+)
        translate([x, 0, rail_height/2 - csk_h/2])
            rotate([90, 0, 0])
                cylinder(h=rail_width + 2, d=csk_d, center=true);
    }
}

module rail_model() {
    color("Silver")
    difference() {
        rail_body_profiled();

        // Side raceways (both sides)
        raceway_groove(+1);
        raceway_groove(-1);

        // Mounting holes along the rail
        mounting_holes();
    }
}

// Render
rail_model();