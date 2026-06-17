$fn = 64;

rail_w = 5.0;
rail_h = 3.6;
rail_l = 100.0;

// Simple miniature linear guide rail profile:
// - Rectangular base with slightly chamfered top edges
// - Two shallow side relief grooves
// - Two mounting holes along length (counterbored)
module linear_guide_rail(w=rail_w, h=rail_h, l=rail_l) {
    chamfer = min(0.5, h*0.22);          // top edge chamfer
    groove_depth = min(0.35, w*0.10);    // side relief
    groove_h = h*0.55;
    groove_z0 = h*0.20;

    hole_d = 2.2;        // through hole
    cbore_d = 4.0;       // counterbore
    cbore_depth = 1.2;   // counterbore depth
    hole_x = w/2;
    hole_y_positions = [l*0.25, l*0.75];

    difference() {
        // Main body with chamfered top edges
        linear_extrude(height=l)
            polygon(points=[
                [0,0],
                [w,0],
                [w,h-chamfer],
                [w-chamfer,h],
                [chamfer,h],
                [0,h-chamfer]
            ]);

        // Side relief grooves (run full length)
        translate([0, groove_z0, 0])
            cube([groove_depth, groove_h, l], center=false);
        translate([w-groove_depth, groove_z0, 0])
            cube([groove_depth, groove_h, l], center=false);

        // Mounting holes (through + counterbore from top)
        for (yy = hole_y_positions) {
            // Through hole
            translate([hole_x, h/2, yy])
                rotate([90,0,0])
                    cylinder(d=hole_d, h=w+2, center=true);

            // Counterbore from top
            translate([hole_x, h - cbore_depth/2, yy])
                rotate([90,0,0])
                    cylinder(d=cbore_d, h=w+2, center=true);
        }
    }
}

// Orient length along Y for typical rail placement
rotate([-90,0,0]) linear_guide_rail();