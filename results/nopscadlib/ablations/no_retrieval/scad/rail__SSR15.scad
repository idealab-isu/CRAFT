$fn = 96;

// Target overall dimensions
rail_L = 100.0;
rail_W = 15.0;
rail_H = 12.5;

// Robust boolean overlap
overlap = 0.6;

// Mounting holes (through) + counterbore (top)
mount_hole_d = 4.0;
counterbore_d = 7.0;
counterbore_depth = 3.0;

// Hole layout (3 holes)
hole_edge_margin = 12.0;

// Profile features (visual linear-rail look)
side_relief_w = 1.6;          // side undercut width
side_relief_h = 3.0;          // side undercut height from bottom
top_land_w = 9.0;             // raised top land width
top_land_h = 1.2;             // raised top land height
raceway_r = 1.6;              // ball track radius
raceway_inset = 1.2;          // inset from side faces
raceway_drop = 2.2;           // drop from top surface to raceway center

// Small edge breaks
edge_chamfer = 0.7;
end_chamfer = 1.0;

module rail_blank() {
    // Base body at exact overall size
    cube([rail_L, rail_W, rail_H], center=true);
}

module top_land_add() {
    // Raised land on top (still within overall height by subtracting elsewhere)
    translate([0, 0, rail_H/2 - top_land_h/2])
        cube([rail_L, top_land_w, top_land_h], center=true);
}

module side_reliefs_cut() {
    // Undercuts on both sides near the bottom to create a recognizable rail profile
    for (s = [-1, 1]) {
        translate([0,
                   s*(rail_W/2 - side_relief_w/2),
                   -rail_H/2 + side_relief_h/2])
            cube([rail_L + 2*overlap, side_relief_w, side_relief_h + overlap], center=true);
    }
}

module raceways_cut() {
    // Two longitudinal ball tracks near the top, one on each side
    zc = rail_H/2 - raceway_drop;
    yc = rail_W/2 - raceway_inset - raceway_r;
    for (s = [-1, 1]) {
        translate([0, s*yc, zc])
            rotate([0, 90, 0])
                cylinder(h=rail_L + 2*overlap, r=raceway_r, center=true);
    }
}

module mounting_holes_cut() {
    // Through holes along Z (vertical), placed along length
    xs = [-rail_L/2 + hole_edge_margin, 0, rail_L/2 - hole_edge_margin];
    for (x = xs) {
        translate([x, 0, 0])
            cylinder(h=rail_H + 2*overlap, r=mount_hole_d/2, center=true);
    }
}

module counterbores_cut() {
    // Counterbores from top face down
    xs = [-rail_L/2 + hole_edge_margin, 0, rail_L/2 - hole_edge_margin];
    for (x = xs) {
        translate([x, 0, rail_H/2 - counterbore_depth/2 + overlap/2])
            cylinder(h=counterbore_depth + overlap, r=counterbore_d/2, center=true);
    }
}

module edge_chamfers_cut() {
    // Simple edge breaks using subtractive wedges (cubes rotated 45°)
    // Along the long top edges
    for (s = [-1, 1]) {
        translate([0, s*(rail_W/2 - edge_chamfer/2), rail_H/2 - edge_chamfer/2])
            rotate([45*s, 0, 0])
                cube([rail_L + 2*overlap, edge_chamfer*2, edge_chamfer*2], center=true);
    }
    // Along the long bottom edges
    for (s = [-1, 1]) {
        translate([0, s*(rail_W/2 - edge_chamfer/2), -rail_H/2 + edge_chamfer/2])
            rotate([45*s, 0, 0])
                cube([rail_L + 2*overlap, edge_chamfer*2, edge_chamfer*2], center=true);
    }
}

module end_chamfers_cut() {
    // End chamfers on all four long edges using rotated cubes
    for (sx = [-1, 1]) {
        translate([sx*(rail_L/2 - end_chamfer/2), 0, 0])
            rotate([0, 45*sx, 0])
                cube([end_chamfer*2, rail_W + 2*overlap, rail_H + 2*overlap], center=true);
    }
}

module rail_solid() {
    // Keep ONE connected solid: start from exact bounding box, then sculpt
    difference() {
        union() {
            rail_blank();
            // Add top land, then remove equivalent volume elsewhere via side reliefs/raceways
            // (still results in a single connected solid)
            top_land_add();
        }
        side_reliefs_cut();
        raceways_cut();
        mounting_holes_cut();
        counterbores_cut();
        edge_chamfers_cut();
        end_chamfers_cut();
    }
}

rail_solid();