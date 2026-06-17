$fn = 64;

// Miniature linear guide rail parameters (mm)
rail_w = 15.0;
rail_h = 15.0;
rail_l = 100.0;

// Profile details
side_chamfer = 1.0;
top_flat_w = 9.0;
top_flat_h = 1.2;

center_ridge_w = 5.0;
center_ridge_h = 2.0;

bottom_relief_w = 7.0;
bottom_relief_h = 1.5;

mount_hole_d = 3.4;          // clearance for M3
mount_counterbore_d = 6.2;   // counterbore
mount_counterbore_depth = 2.2;

end_margin = 10.0;
hole_pitch = 20.0;

module rail_profile_2d() {
    // Base rectangle with corner chamfers
    difference() {
        polygon(points=[
            [0, side_chamfer],
            [0, rail_h - side_chamfer],
            [side_chamfer, rail_h],
            [rail_w - side_chamfer, rail_h],
            [rail_w, rail_h - side_chamfer],
            [rail_w, side_chamfer],
            [rail_w - side_chamfer, 0],
            [side_chamfer, 0]
        ]);

        // Bottom relief groove (centered)
        translate([(rail_w - bottom_relief_w)/2, 0])
            square([bottom_relief_w, bottom_relief_h], center=false);

        // Slight top side reliefs to suggest raceways
        // Left
        translate([1.2, rail_h - 4.2])
            rotate(45)
                square([3.0, 3.0], center=false);
        // Right
        translate([rail_w - 1.2, rail_h - 4.2])
            rotate(45)
                square([3.0, 3.0], center=false);
    }
}

module rail_body() {
    // Extruded main body
    linear_extrude(height=rail_l, center=false, convexity=10)
        rail_profile_2d();

    // Top flat (slightly raised)
    translate([(rail_w - top_flat_w)/2, rail_h - top_flat_h, 0])
        cube([top_flat_w, top_flat_h, rail_l], center=false);

    // Center ridge on top
    translate([(rail_w - center_ridge_w)/2, rail_h, 0])
        cube([center_ridge_w, center_ridge_h, rail_l], center=false);
}

module mounting_holes() {
    // Holes along length, centered in width
    x = rail_w/2;
    y = rail_h/2;

    for (z = [end_margin : hole_pitch : rail_l - end_margin + 0.001]) {
        // Through hole
        translate([x, y, z])
            rotate([90,0,0])
                cylinder(d=mount_hole_d, h=rail_h + 2, center=true);

        // Counterbore from top face
        translate([x, rail_h + center_ridge_h - mount_counterbore_depth, z])
            rotate([90,0,0])
                cylinder(d=mount_counterbore_d, h=mount_counterbore_depth + 0.5, center=false);
    }
}

difference() {
    rail_body();
    mounting_holes();
}