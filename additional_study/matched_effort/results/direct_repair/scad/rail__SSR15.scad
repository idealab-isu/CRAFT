$fn = 64;

// Miniature linear guide rail
// Overall: 15.0mm wide (X), 12.5mm tall (Z), 100mm long (Y)

rail_w = 15.0;
rail_h = 12.5;
rail_l = 100.0;

// Profile details (approximate, stylized)
top_w = 9.0;          // top land width
top_h = 2.0;          // top land height
side_chamfer = 1.2;   // outer edge chamfer size
groove_w = 3.2;       // side groove width
groove_h = 2.2;       // side groove height
groove_z = 6.2;       // groove center height from bottom

// Mounting holes (stylized)
hole_d = 3.4;
csk_d  = 6.2;
csk_h  = 1.6;
end_margin = 10.0;
hole_pitch = 20.0;

module rail_profile_2d() {
    // Build a chamfered rectangle with a slightly raised top land
    // Base outline with chamfers
    difference() {
        union() {
            // Main body with chamfers via offset trick
            offset(delta = 0)
            polygon(points=[
                [ -rail_w/2 + side_chamfer, 0 ],
                [  rail_w/2 - side_chamfer, 0 ],
                [  rail_w/2, side_chamfer ],
                [  rail_w/2, rail_h - side_chamfer ],
                [  rail_w/2 - side_chamfer, rail_h ],
                [ -rail_w/2 + side_chamfer, rail_h ],
                [ -rail_w/2, rail_h - side_chamfer ],
                [ -rail_w/2, side_chamfer ]
            ]);

            // Slight top land (centered)
            translate([0, rail_h - top_h])
                square([top_w, top_h], center=true);
        }

        // Side grooves (left and right)
        for (sx = [-1, 1]) {
            translate([sx*(rail_w/2 - groove_w/2 - 0.8), groove_z - groove_h/2])
                square([groove_w, groove_h], center=true);
        }
    }
}

module rail_body() {
    linear_extrude(height = rail_l, center = false, convexity = 10)
        rail_profile_2d();
}

module mounting_holes() {
    // Through holes along length (Y axis), centered in X, drilled from top
    // Place holes from end_margin to rail_l - end_margin at hole_pitch
    for (y = [end_margin : hole_pitch : rail_l - end_margin + 0.001]) {
        // Through hole
        translate([0, y, rail_h/2])
            rotate([90,0,0])
                cylinder(d=hole_d, h=rail_h+2, center=true);

        // Counterbore/countersink from top (simple conical)
        translate([0, y, rail_h - csk_h/2])
            rotate([90,0,0])
                cylinder(d1=csk_d, d2=hole_d, h=csk_h, center=true);
    }
}

difference() {
    // Orient: length along Y, width along X, height along Z
    // rail_body extrudes along Y from 0..rail_l; profile is in X-Z plane
    // So we rotate profile extrusion to align Z as vertical:
    // Our profile is defined in X (horizontal) and Z (vertical) already,
    // but linear_extrude uses Z as extrusion axis. We'll instead extrude along Y by rotating.
    rotate([-90,0,0])  // move extrusion axis from Z to Y
        rail_body();

    // Subtract mounting holes (already aligned with Y length and Z height)
    mounting_holes();
}