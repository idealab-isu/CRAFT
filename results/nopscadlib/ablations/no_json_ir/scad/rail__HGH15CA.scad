// Miniature linear guide rail: 15mm wide, 15mm tall, 100mm long
// One connected solid; no text; all features derived from dimensions.

$fn = 64;

L = 100;
W = 15;
H = 15;

module linear_guide_rail() {
    difference() {
        rail_solid();
        rail_cuts();
    }
}

module rail_solid() {
    // Centered for easier feature placement
    translate([0, 0, 0])
        cube([L, W, H], center=true);
}

module rail_cuts() {
    // Side raceway grooves (V-ish channels) along full length
    groove_depth = 1.2;
    groove_height = 4.2;
    groove_y = W/2 - 0.6; // near side faces
    groove_z = 0;         // centered vertically

    for (sy = [-1, 1]) {
        translate([0, sy*groove_y, groove_z])
            rotate([0, 90, 0])
                linear_extrude(height=L + 0.4, center=true, convexity=10)
                    polygon(points=[
                        [0,  groove_height/2],
                        [groove_depth, 0],
                        [0, -groove_height/2]
                    ]);
    }

    // Top center relief groove (shallow)
    top_groove_w = 4.0;
    top_groove_d = 0.8;
    translate([0, 0, H/2 - top_groove_d/2])
        cube([L + 0.4, top_groove_w, top_groove_d], center=true);

    // Mounting holes with counterbores (3 holes)
    hole_d = 3.0;
    cbore_d = 6.0;
    cbore_depth = 2.2;

    // Place holes along length with margins derived from L
    x_margin = 20;
    xs = [ -L/2 + x_margin, 0, L/2 - x_margin ];

    for (x = xs) {
        // Through hole (Z axis)
        translate([x, 0, 0])
            cylinder(h=H + 0.6, d=hole_d, center=true);

        // Counterbore from top face
        translate([x, 0, H/2 - cbore_depth/2])
            cylinder(h=cbore_depth + 0.2, d=cbore_d, center=true);
    }

    // End chamfers (small) to avoid razor edges
    cham = 0.8;
    for (sx = [-1, 1]) {
        translate([sx*(L/2 - cham/2), 0, 0])
            rotate([0, 90, 0])
                linear_extrude(height=cham + 0.2, center=true, convexity=10)
                    polygon(points=[
                        [-W/2, -H/2],
                        [ W/2, -H/2],
                        [ W/2,  H/2],
                        [ W/2 - cham, H/2],
                        [ W/2,  H/2 - cham],
                        [-W/2,  H/2]
                    ]);
    }
}

linear_guide_rail();