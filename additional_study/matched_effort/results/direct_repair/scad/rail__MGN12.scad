$fn = 64;

// Miniature linear guide rail parameters (mm)
rail_w = 12.0;
rail_h = 8.0;
rail_l = 100.0;

// Simple rail profile details
top_flat_w = 6.0;          // flat on top
side_chamfer = 1.0;        // chamfer size
bottom_relief_w = 8.0;     // slight bottom relief width
bottom_relief_h = 1.0;     // relief depth

module rail_profile() {
    // Outer shape with chamfered top edges
    difference() {
        // Main body with chamfered top corners
        polygon(points=[
            [0, 0],
            [rail_w, 0],
            [rail_w, rail_h - side_chamfer],
            [rail_w - side_chamfer, rail_h],
            [(rail_w + top_flat_w)/2, rail_h],
            [(rail_w - top_flat_w)/2, rail_h],
            [side_chamfer, rail_h],
            [0, rail_h - side_chamfer]
        ]);

        // Bottom relief (centered)
        translate([(rail_w - bottom_relief_w)/2, 0])
            square([bottom_relief_w, bottom_relief_h], center=false);
    }
}

linear_extrude(height=rail_l, center=false, convexity=10)
    rail_profile();