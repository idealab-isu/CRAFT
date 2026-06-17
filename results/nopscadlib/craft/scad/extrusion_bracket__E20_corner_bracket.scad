// A extrusion bracket target overall size: [28, 28, 20]
// Standalone bracket only (no extrusions, no floating markers). One connected solid.

footprint_x = 28;          // overall X
footprint_y = 28;          // overall Y
height_z    = 20;          // overall Z

leg_thickness = 6;         // wall/leg thickness (in X and Y)
hole_diameter = 5.5;
hole_edge_margin = 7;      // from outer edge along the leg length
hole_spacing = 14;         // spacing along Z between the two holes per face
overlap = 0.6;             // small overlap for robust booleans

// Internal relief (corner clearance)
internal_relief_margin = 2;
internal_relief_depth  = 12;
internal_relief_height = 16;

$fn = 64;

module bracket_body() {
    // L-shaped solid that fits within [footprint_x, footprint_y, height_z]
    // Built from two legs that overlap in the corner to ensure connectivity.
    union() {
        // X-leg: runs along +X from the corner, thickness in Y
        translate([footprint_x/2, leg_thickness/2, height_z/2])
            cube([footprint_x, leg_thickness, height_z], center=true);

        // Y-leg: runs along +Y from the corner, thickness in X
        translate([leg_thickness/2, footprint_y/2, height_z/2])
            cube([leg_thickness, footprint_y, height_z], center=true);
    }
}

module internal_relief_cut() {
    // Remove material near the inside corner (top portion), leaving a connected bracket.
    // Positioned from the inside corner at (leg_thickness, leg_thickness).
    translate([
        leg_thickness + internal_relief_margin + internal_relief_depth/2,
        leg_thickness + internal_relief_margin + internal_relief_depth/2,
        height_z - internal_relief_height/2
    ])
        cube([internal_relief_depth, internal_relief_depth, internal_relief_height + 2*overlap], center=true);
}

module holes_cut() {
    // Two holes through the Y-thickness of the X-leg (drill along Y)
    for (zpos = [height_z/2 - hole_spacing/2, height_z/2 + hole_spacing/2]) {
        translate([hole_edge_margin, leg_thickness/2, zpos])
            rotate([90, 0, 0])
                cylinder(h=leg_thickness + 2*overlap, r=hole_diameter/2, center=true);
    }

    // Two holes through the X-thickness of the Y-leg (drill along X)
    for (zpos = [height_z/2 - hole_spacing/2, height_z/2 + hole_spacing/2]) {
        translate([leg_thickness/2, hole_edge_margin, zpos])
            rotate([0, 90, 0])
                cylinder(h=leg_thickness + 2*overlap, r=hole_diameter/2, center=true);
    }
}

difference() {
    bracket_body();
    internal_relief_cut();
    holes_cut();
}