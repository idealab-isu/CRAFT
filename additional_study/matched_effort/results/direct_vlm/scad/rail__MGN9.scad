$fn = 64;

rail_w = 9.0;
rail_h = 6.0;
rail_l = 100.0;

edge_r = 0.6;          // outer edge rounding
top_chamfer = 0.6;     // top edge chamfer
bottom_relief = 0.8;   // small bottom relief width
bottom_relief_h = 0.6; // small bottom relief height

mount_hole_d = 3.2;
mount_csk_d = 5.8;
mount_csk_h = 1.6;
mount_pitch = 25.0;
mount_end = 12.5;

module rounded_box(size=[10,10,10], r=1.0) {
    // Minkowski rounded rectangular prism
    minkowski() {
        cube([size[0]-2*r, size[1]-2*r, size[2]-2*r], center=false);
        sphere(r=r);
    }
}

module rail_body() {
    // Base rounded block
    difference() {
        // Outer body with rounded edges
        translate([0,0,0])
            rounded_box([rail_w, rail_l, rail_h], r=edge_r);

        // Top chamfers (approx) by subtracting two long wedges
        translate([-1, -1, rail_h - top_chamfer])
            rotate([0,0,0])
                linear_extrude(height=rail_l+2)
                    polygon(points=[
                        [0,0],
                        [rail_w+2,0],
                        [rail_w+2, top_chamfer+2],
                        [0, top_chamfer+2]
                    ]);

        // Create chamfered top edges by cutting two side wedges
        // Left top chamfer
        translate([-1, -1, rail_h - top_chamfer])
            rotate([90,0,90])
                linear_extrude(height=rail_l+2)
                    polygon(points=[
                        [0,0],
                        [top_chamfer,0],
                        [0, top_chamfer]
                    ]);

        // Right top chamfer
        translate([rail_w+1, -1, rail_h - top_chamfer])
            rotate([90,0,-90])
                linear_extrude(height=rail_l+2)
                    polygon(points=[
                        [0,0],
                        [top_chamfer,0],
                        [0, top_chamfer]
                    ]);

        // Bottom relief channel (small undercut look)
        translate([bottom_relief, -1, -1])
            cube([rail_w-2*bottom_relief, rail_l+2, bottom_relief_h+1], center=false);

        // Mounting holes with counterbore/countersink-like recess
        for (y = [mount_end : mount_pitch : rail_l - mount_end + 0.001]) {
            // Through hole
            translate([rail_w/2, y, -1])
                cylinder(d=mount_hole_d, h=rail_h+2);

            // Top recess
            translate([rail_w/2, y, rail_h - mount_csk_h])
                cylinder(d=mount_csk_d, h=mount_csk_h+1);
        }
    }
}

module rail() {
    // Orient: X=width, Y=length, Z=height
    rail_body();
}

rail();