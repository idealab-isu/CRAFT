$fn = 96;

// Miniature linear guide rail parameters (mm)
rail_w = 15.0;
rail_h = 12.5;
rail_l = 100.0;

// Profile parameters
base_h = 7.0;
top_h  = rail_h - base_h;

base_w = rail_w;
top_w  = 10.0;

side_chamfer = 1.0;
top_chamfer  = 0.8;

// Mounting holes
hole_d = 4.2;
csk_d  = 7.5;
csk_h  = 2.0;
hole_pitch = 25.0;
hole_edge  = 12.5; // from each end to first/last hole

eps = 0.02;

module chamfered_block(w, h, l, c=1.0) {
    c2 = min(c, w/2 - eps, h/2 - eps);
    linear_extrude(height=l, center=false, convexity=10)
        polygon(points=[
            [ c2, 0 ],
            [ w-c2, 0 ],
            [ w, c2 ],
            [ w, h-c2 ],
            [ w-c2, h ],
            [ c2, h ],
            [ 0, h-c2 ],
            [ 0, c2 ]
        ]);
}

module rail_body() {
    union() {
        // Base
        chamfered_block(base_w, base_h, rail_l, side_chamfer);

        // Top (narrower), connected to base
        translate([(base_w-top_w)/2, base_h - eps, 0])
            chamfered_block(top_w, top_h + eps, rail_l, top_chamfer);

        // Small side lips (stylized), connected to base
        lip_h = 1.2;
        lip_w = 1.2;
        translate([0, base_h - lip_h - eps, 0])
            cube([lip_w, lip_h + eps, rail_l], center=false);
        translate([base_w - lip_w, base_h - lip_h - eps, 0])
            cube([lip_w, lip_h + eps, rail_l], center=false);
    }
}

module mounting_holes() {
    // Holes run along Z (length). Rail is built from y=0..rail_h, x=0..rail_w, z=0..rail_l.
    // Through-hole axis is Y (vertical), centered in width and length positions.
    for (zpos = [hole_edge : hole_pitch : rail_l - hole_edge + 0.0001]) {
        translate([rail_w/2, rail_h/2, zpos]) {
            // Through hole (along Y)
            rotate([90,0,0])
                cylinder(d=hole_d, h=rail_h + 2, center=true);

            // Counterbore from top face (y = rail_h) downward
            translate([0, rail_h/2 - csk_h/2 + eps, 0])
                rotate([90,0,0])
                    cylinder(d=csk_d, h=csk_h + 2*eps, center=true);
        }
    }
}

difference() {
    rail_body();
    mounting_holes();
}