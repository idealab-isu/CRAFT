$fn = 96;

// Miniature linear guide rail (mm)
rail_w = 12.0;
rail_h = 8.0;
rail_l = 100.0;

// Profile details (kept within overall 12x8 envelope)
top_chamfer = 1.0;          // top corner chamfer
bottom_relief_w = 8.0;      // bottom relief width
bottom_relief_h = 1.0;      // bottom relief depth

// Typical rail features
hole_d = 3.5;               // mounting hole diameter
csk_d  = 6.5;               // counterbore diameter
csk_h  = 2.0;               // counterbore depth
end_margin = 10.0;          // first/last hole offset from ends
hole_pitch = 20.0;          // spacing between holes

race_r = 1.2;               // side raceway groove radius
race_z = 5.2;               // groove center height from bottom (within 0..rail_h)
race_inset = 0.9;           // how far groove center is inset from side face

eps = 0.02;

module rail_profile_2d() {
    // 2D profile in XY (X=width, Y=height), extruded along Z (length)
    difference() {
        // Outer body with chamfered top corners
        polygon(points=[
            [0, 0],
            [rail_w, 0],
            [rail_w, rail_h - top_chamfer],
            [rail_w - top_chamfer, rail_h],
            [top_chamfer, rail_h],
            [0, rail_h - top_chamfer]
        ]);

        // Bottom relief (centered)
        translate([(rail_w - bottom_relief_w)/2, 0])
            square([bottom_relief_w, bottom_relief_h], center=false);
    }
}

module rail_body() {
    linear_extrude(height=rail_l, center=false, convexity=10)
        rail_profile_2d();
}

module mounting_holes() {
    // Through holes + counterbores from the top face
    for (zpos = [end_margin : hole_pitch : rail_l - end_margin + eps]) {
        // Through hole
        translate([rail_w/2, rail_h/2, zpos])
            rotate([90, 0, 0])
                cylinder(d=hole_d, h=rail_h + 2*eps, center=true);

        // Counterbore (from top)
        translate([rail_w/2, rail_h - csk_h/2, zpos])
            rotate([90, 0, 0])
                cylinder(d=csk_d, h=csk_h + 2*eps, center=true);
    }
}

module raceways() {
    // Two longitudinal grooves on the side faces (subtractive)
    // Left groove
    translate([race_inset, race_z, rail_l/2])
        rotate([90, 0, 0])
            cylinder(r=race_r, h=rail_l + 2*eps, center=true);

    // Right groove
    translate([rail_w - race_inset, race_z, rail_l/2])
        rotate([90, 0, 0])
            cylinder(r=race_r, h=rail_l + 2*eps, center=true);
}

difference() {
    rail_body();
    mounting_holes();
    raceways();
}