$fn = 128;

// Ball bearing dimensions (mm)
bore_d = 5.0;
od_d   = 9.0;
width  = 2.5;

// Simple stylized bearing geometry
// (Two races + a ring of balls + cage-like clearance)
race_wall = 0.7;          // radial thickness of each race
race_lip  = 0.35;         // axial lip thickness
ball_d    = 1.0;          // ball diameter
ball_count = 8;

module bearing() {
    difference() {
        // Outer envelope
        cylinder(d=od_d, h=width, center=true);

        // Bore
        cylinder(d=bore_d, h=width + 0.2, center=true);

        // Create a central groove to suggest raceway/cage space
        // Leaves lips near both faces
        cylinder(d=od_d - 2*race_wall, h=width - 2*race_lip, center=true);
    }

    // Balls
    r_ball_path = (bore_d/2 + od_d/2)/2;
    for (i = [0:ball_count-1]) {
        rotate([0,0, i*360/ball_count])
            translate([r_ball_path, 0, 0])
                sphere(d=ball_d);
    }
}

bearing();