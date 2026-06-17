$fn = 64;

// Target overall envelope (must match)
rail_L = 100.0; //[50.0:200.0:1.0]
rail_W = 12.0;  //[6.0:24.0:0.5]
rail_H = 8.0;   //[4.0:16.0:0.5]

// Mounting holes
hole_d = 3.0;          //[1.5:6.0:0.1]
hole_pitch = 25.0;     //[10.0:50.0:1.0]
hole_edge_offset = 12.5; //[5.0:20.0:0.5]  // ensures 4 holes fit on 100mm with 25mm pitch
hole_count = 4;        //[2:8:1]
hole_center_offset_W = 0.0; //[-3.0:3.0:0.1]

// Rail profile features (miniature guide-rail-like)
side_relief_w = 1.2;   //[0.5:2.5:0.1]  // side shoulders
side_relief_h = 1.0;   //[0.5:2.0:0.1]
race_r = 1.15;         //[0.6:1.8:0.05] // raceway groove radius
race_depth = 0.55;     //[0.2:1.2:0.05]
race_z = 1.6;          //[0.8:3.0:0.1]  // height of raceway center above bottom

// Chamfers (implemented as bevel cuts)
edge_chamfer = 0.6;    //[0.2:1.5:0.1]
end_chamfer = 1.0;     //[0.5:3.0:0.1]

// Robust boolean overlap
overlap = 0.6;         //[0.2:2.0:0.1]

// Helpers
function clamp(x, a, b) = min(max(x, a), b);

// Derived / constrained to keep a valid connected solid
srw = clamp(side_relief_w, 0, rail_W/2 - 0.2);
srh = clamp(side_relief_h, 0, rail_H - 0.2);

race_center_x = rail_W/2 - srw - race_r; // keep groove inside shoulder
race_center_x2 = -race_center_x;
race_center_z = clamp(-rail_H/2 + race_z, -rail_H/2 + race_r + 0.2, rail_H/2 - race_r - 0.2);
race_cut_r = race_r;
race_cut_offset = race_cut_r - clamp(race_depth, 0.05, race_cut_r - 0.05); // how far circle center is from surface

module rail_blank() {
    // Base envelope
    cube([rail_W, rail_L, rail_H], center=true);
}

module side_reliefs() {
    // Create shoulders by removing material along both sides near the bottom
    // These cuts are fully inside the envelope and run the full length.
    for (sx = [-1, 1]) {
        translate([sx*(rail_W/2 - srw/2), 0, -rail_H/2 + srh/2])
            cube([srw + 2*overlap, rail_L + 2*overlap, srh + 2*overlap], center=true);
    }
}

module raceways() {
    // Two longitudinal concave grooves (raceways) on the side faces
    // Use cylinders along Y, positioned so they cut into the side faces by race_depth.
    // Right side groove
    translate([ rail_W/2 + race_cut_offset, 0, race_center_z])
        rotate([90, 0, 0])
            cylinder(h=rail_L + 2*overlap, r=race_cut_r, center=true);

    // Left side groove
    translate([-rail_W/2 - race_cut_offset, 0, race_center_z])
        rotate([90, 0, 0])
            cylinder(h=rail_L + 2*overlap, r=race_cut_r, center=true);
}

module mounting_hole(posY) {
    translate([hole_center_offset_W, posY, 0])
        cylinder(h=rail_H + 2*overlap, r=hole_d/2, center=true);
}

module mounting_holes_pattern() {
    for (i = [0:hole_count-1]) {
        mounting_hole(-rail_L/2 + hole_edge_offset + i*hole_pitch);
    }
}

module edge_bevel_cuts() {
    // Bevel all 4 long edges using rotated cubes (45°)
    // Each cut is positioned at the corresponding edge and overlaps slightly.
    for (sx = [-1, 1], sz = [-1, 1]) {
        translate([sx*(rail_W/2), 0, sz*(rail_H/2)])
            rotate([0, 45*sz, 0])
                cube([edge_chamfer*2, rail_L + 2*overlap, edge_chamfer*2], center=true);
    }
}

module end_bevel_cuts() {
    // Bevel the 4 vertical edges at both ends (Y = +/- rail_L/2)
    for (sy = [-1, 1], sx = [-1, 1]) {
        translate([sx*(rail_W/2), sy*(rail_L/2), 0])
            rotate([0, 0, 45*sx])
                cube([end_chamfer*2, end_chamfer*2, rail_H + 2*overlap], center=true);
    }
}

module rail_complete() {
    color("Silver")
    difference() {
        rail_blank();

        // Functional features
        mounting_holes_pattern();
        side_reliefs();
        raceways();

        // Cosmetic/edge features
        edge_bevel_cuts();
        end_bevel_cuts();
    }
}

rail_complete();