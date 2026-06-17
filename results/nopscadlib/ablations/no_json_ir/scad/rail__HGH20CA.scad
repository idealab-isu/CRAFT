$fn = 96;

// Miniature linear guide rail envelope (X width, Z height, Y length)
rail_w = 20.0;
rail_h = 17.5;
rail_l = 100.0;

// Profile features (kept within envelope)
base_h   = 6.0;                 // bottom base thickness
neck_w   = 12.0;                // narrow waist width
head_w   = 16.0;                // top head width
head_h   = rail_h - base_h;     // top head height

// Small chamfers to read as a rail (2D profile chamfers)
ch_base  = 1.0;                 // base outer chamfer
ch_head  = 0.8;                 // head outer chamfer

// Mounting holes (along length, vertical through Z)
hole_d     = 4.2;
csk_d      = 7.5;
csk_h      = 2.2;
hole_pitch = 25.0;
hole_edge  = 12.5;

// Raceway relief grooves (subtractive, along Y)
groove_r = 1.25;
groove_z = base_h + head_h*0.62;          // near upper head
groove_x = head_w/2 - 1.2;                // near head sides

// Carriage block (kept connected to rail with a small overlap)
car_l     = 28.0;
car_w     = 26.0;
car_h     = 12.0;
car_clear = 0.6;
overlap   = 0.6;                           // ensures one connected solid

module rail_profile_2d() {
    // Symmetric stepped profile with chamfers, within 20 x 17.5 envelope.
    // Coordinates are in X (width) and Z (height), with Z=0 at bottom.
    polygon(points=[
        // Bottom base with chamfered outer corners
        [-rail_w/2 + ch_base, 0],
        [ rail_w/2 - ch_base, 0],
        [ rail_w/2,           ch_base],
        [ rail_w/2,           base_h - ch_base],
        [ rail_w/2 - ch_base, base_h],

        // Step in to neck
        [ neck_w/2 + ch_head, base_h],
        [ neck_w/2,           base_h + ch_head],
        [ neck_w/2,           rail_h - ch_head],

        // Step out to head with chamfered top corners
        [ head_w/2 - ch_head, rail_h],
        [-head_w/2 + ch_head, rail_h],

        // Mirror down other side
        [-neck_w/2,           rail_h - ch_head],
        [-neck_w/2,           base_h + ch_head],
        [-neck_w/2 - ch_head, base_h],
        [-rail_w/2 + ch_base, base_h],
        [-rail_w/2,           base_h - ch_base],
        [-rail_w/2,           ch_base]
    ]);
}

module rail_solid() {
    // Extrude along Y, keep X=width, Z=height
    rotate([90,0,0])
        linear_extrude(height=rail_l, center=true, convexity=10)
            rail_profile_2d();
}

module rail_mount_holes() {
    // Vertical holes through Z, with counterbore from top.
    for (y = [-rail_l/2 + hole_edge : hole_pitch : rail_l/2 - hole_edge]) {
        // Through hole (Z axis)
        translate([0, y, rail_h/2])
            cylinder(h=rail_h + 2, d=hole_d, center=true);

        // Counterbore from top (partial depth)
        translate([0, y, rail_h - csk_h/2])
            cylinder(h=csk_h + 0.2, d=csk_d, center=true);
    }
}

module rail_raceway_reliefs() {
    // Side grooves along full length (Y axis), subtractive
    for (sx = [-1, 1]) {
        translate([sx*groove_x, 0, groove_z])
            rotate([90,0,0])
                cylinder(h=rail_l + 2, r=groove_r, center=true);
    }
}

module carriage_block() {
    // Place carriage centered on rail length, sitting over head with overlap to ensure connectivity.
    car_z = rail_h - car_h/2 + overlap;

    difference() {
        translate([0, 0, car_z])
            cube([car_w, car_l, car_h], center=true);

        // Pocket for rail head (slightly oversized)
        pocket_w = head_w + 2*car_clear;
        pocket_h = head_h + 2*car_clear;
        pocket_z_center = base_h + head_h/2;

        translate([0, 0, pocket_z_center])
            cube([pocket_w, car_l + 2, pocket_h], center=true);

        // Underside relief to avoid base corners (kept shallow)
        translate([0, 0, base_h/2])
            cube([rail_w + 2, car_l + 2, base_h + 0.4], center=true);
    }
}

module linear_guide_rail() {
    union() {
        difference() {
            rail_solid();
            rail_mount_holes();
            rail_raceway_reliefs();
        }
        carriage_block();
    }
}

linear_guide_rail();