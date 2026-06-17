$fn = 96;

// Miniature linear guide rail (overall envelope)
rail_w = 15.0;   // X
rail_h = 10.0;   // Z
rail_l = 100.0;  // Y

// Profile details (kept within overall envelope)
side_step_h = 2.0;
side_step_inset = 2.0;
top_chamfer = 1.0;

// Raceway grooves (visual detail)
race_r = 1.2;                 // groove radius
race_z = rail_h * 0.55;       // groove center height from bottom
race_x = rail_w/2 - 2.2;      // groove center inset from side

// Mounting holes (typical small rail)
hole_d = 3.2;
hole_csk_d = 6.0;
hole_csk_h = 2.0;
hole_pitch = 25.0;
hole_edge_margin = 12.5;      // from each end along Y

// Small overlap to ensure robust booleans
eps = 0.02;

module rail_profile_2d() {
    // X-Z polygon, centered on X=0, bottom at Z=0
    polygon(points=[
        [-rail_w/2, 0],
        [ rail_w/2, 0],
        [ rail_w/2, rail_h - side_step_h],
        [ rail_w/2 - side_step_inset, rail_h - side_step_h],
        [ rail_w/2 - side_step_inset, rail_h - top_chamfer],
        [ rail_w/2 - side_step_inset - top_chamfer, rail_h],
        [-(rail_w/2 - side_step_inset - top_chamfer), rail_h],
        [-(rail_w/2 - side_step_inset), rail_h - top_chamfer],
        [-(rail_w/2 - side_step_inset), rail_h - side_step_h],
        [-rail_w/2, rail_h - side_step_h]
    ]);
}

module rail_body() {
    // Extrude along Y directly (no rotation), centered in Y for predictable views
    translate([0, -rail_l/2, 0])
        linear_extrude(height=rail_l, center=false, convexity=10)
            rail_profile_2d();
}

module mounting_holes_and_counterbores() {
    // Holes run along Z (vertical), placed along Y, centered in X
    for (y = [-rail_l/2 + hole_edge_margin : hole_pitch : rail_l/2 - hole_edge_margin]) {
        // Through hole
        translate([0, y, rail_h/2])
            cylinder(d=hole_d, h=rail_h + 2*eps, center=true);

        // Counterbore from top (recess)
        translate([0, y, rail_h - hole_csk_h/2 + eps])
            cylinder(d=hole_csk_d, h=hole_csk_h + 2*eps, center=true);
    }
}

module raceway_grooves() {
    // Two longitudinal grooves along Y, cut into the sides (visual raceways)
    for (sx = [-1, 1]) {
        translate([sx * race_x, 0, race_z])
            rotate([90, 0, 0])
                cylinder(r=race_r, h=rail_l + 2*eps, center=true);
    }
}

difference() {
    rail_body();
    mounting_holes_and_counterbores();
    raceway_grooves();
}