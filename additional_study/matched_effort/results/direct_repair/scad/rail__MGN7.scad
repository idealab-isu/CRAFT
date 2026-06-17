$fn = 64;

rail_w = 7.0;
rail_h = 5.0;
rail_l = 100.0;

edge_r = 0.6;          // outer edge rounding
top_chamfer = 0.6;     // top edge chamfer
side_relief_w = 1.2;   // side relief width
side_relief_h = 1.2;   // side relief height
hole_d = 3.0;          // mounting hole diameter
csk_d = 5.2;           // countersink diameter
csk_h = 1.6;           // countersink depth
hole_pitch = 25.0;     // spacing
hole_margin = 12.5;    // end margin

module rounded_box(size=[10,10,10], r=1.0) {
    // Minkowski rounded rectangular prism
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=false);
        sphere(r=r);
    }
}

module rail_body() {
    difference() {
        // Outer body with rounded edges
        translate([0,0,0])
            rounded_box([rail_l, rail_w, rail_h], r=edge_r);

        // Top chamfers (approximate by subtracting wedges along both long edges)
        translate([-1, -1, rail_h - top_chamfer])
            rotate([0,45,0])
                cube([rail_l+2, rail_w+2, top_chamfer*3], center=false);

        translate([-1, rail_w+1, rail_h - top_chamfer])
            rotate([0,-45,0])
                cube([rail_l+2, rail_w+2, top_chamfer*3], center=false);

        // Side relief grooves (long shallow cutouts near bottom on both sides)
        translate([-1, 0, 0])
            cube([rail_l+2, side_relief_w, side_relief_h], center=false);

        translate([-1, rail_w - side_relief_w, 0])
            cube([rail_l+2, side_relief_w, side_relief_h], center=false);

        // Mounting holes with countersink from top
        for (x = [hole_margin : hole_pitch : rail_l - hole_margin + 0.001]) {
            // Through hole
            translate([x, rail_w/2, -1])
                cylinder(h=rail_h+2, d=hole_d);

            // Countersink
            translate([x, rail_w/2, rail_h - csk_h])
                cylinder(h=csk_h+0.5, d1=csk_d, d2=hole_d);
        }
    }
}

rail_body();