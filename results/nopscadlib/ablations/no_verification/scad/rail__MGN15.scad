// Miniature linear guide rail — 15mm W x 10mm H x 100mm L
// One connected solid with profile steps, side raceways, and mounting holes.

$fn = 96;

// Overall dimensions
rail_L = 100;
rail_W = 15;
rail_H = 10;

// Small overlap for robust booleans
overlap = 0.25;

// Profile features (kept within overall W/H)
top_land_W  = 7.0;   // top flat width
top_land_H  = 1.2;   // top flat thickness
side_step_W = 2.0;   // inset per side above bottom step
side_step_H = 1.0;   // bottom step height

// Raceway grooves (visual cue)
groove_r     = 1.2;
groove_inset = 0.9;  // distance from outer side to groove center (must be > groove_r)
groove_z     = 0.0;  // centered vertically

// Mounting holes (through height, counterbore on top)
hole_d = 3.0;
cbore_d = 5.6;
cbore_h = 2.0;

// Hole layout: 4 holes along length, symmetric and guaranteed inside rail_L
hole_edge_margin = 10.0;
hole_pitch = 25.0;

// Derived hole positions (centered about X=0)
xs = [
    -rail_L/2 + hole_edge_margin,
    -rail_L/2 + hole_edge_margin + hole_pitch,
    -rail_L/2 + hole_edge_margin + 2*hole_pitch,
    -rail_L/2 + hole_edge_margin + 3*hole_pitch
];

// 2D profile in (Y,Z), extruded along X
module rail_profile_2d() {
    polygon(points=[
        [-rail_W/2, -rail_H/2],
        [ rail_W/2, -rail_H/2],

        [ rail_W/2, -rail_H/2 + side_step_H],
        [ rail_W/2 - side_step_W, -rail_H/2 + side_step_H],

        [ rail_W/2 - side_step_W,  rail_H/2 - top_land_H],
        [ top_land_W/2,            rail_H/2 - top_land_H],
        [ top_land_W/2,            rail_H/2],
        [-top_land_W/2,            rail_H/2],
        [-top_land_W/2,            rail_H/2 - top_land_H],
        [-rail_W/2 + side_step_W,  rail_H/2 - top_land_H],

        [-rail_W/2 + side_step_W, -rail_H/2 + side_step_H],
        [-rail_W/2,               -rail_H/2 + side_step_H]
    ]);
}

module rail_solid() {
    // Extrude along X directly (no rotate needed)
    linear_extrude(height=rail_L, center=true, convexity=10)
        rail_profile_2d();
}

module raceway_grooves() {
    // Two longitudinal grooves cut into the sides, cylinders along X
    // Place groove centers inside the side faces by groove_inset.
    for (s = [-1, 1]) {
        translate([0, s*(rail_W/2 - groove_inset), groove_z])
            rotate([0,90,0])
                cylinder(h=rail_L + 2*overlap, r=groove_r, center=true);
    }
}

module mounting_holes_and_counterbores() {
    for (xi = xs) {
        // Through hole along Z (height)
        translate([xi, 0, 0])
            cylinder(h=rail_H + 2*overlap, r=hole_d/2, center=true);

        // Counterbore from top face (downward into rail)
        translate([xi, 0, rail_H/2 - cbore_h/2])
            cylinder(h=cbore_h + 2*overlap, r=cbore_d/2, center=true);
    }
}

difference() {
    rail_solid();
    raceway_grooves();
    mounting_holes_and_counterbores();
}