$fn = 180;

// Pulley parameters
outer_d = 40;          // overall flange diameter
groove_d = 30;         // diameter at groove bottom (belt rides here)
width = 16;            // total pulley width
bore_d = 5;            // center bore
hub_d = 16;            // hub diameter
hub_len = 10;          // hub length (centered)
flange_th = 2.2;       // flange thickness each side
groove_depth = (outer_d - groove_d)/2;
groove_half_w = (width - 2*flange_th)/2;

// Set screw (optional)
set_screw = true;
set_screw_d = 3;
set_screw_z = 0;       // centered along width
set_screw_offset = hub_d/2 - 1.2; // radial position from center

module pulley_body() {
    // Main pulley with V-groove profile via rotate_extrude
    rotate_extrude(convexity=10)
        polygon(points=[
            // Start at inner radius near bore (hub region)
            [bore_d/2, -width/2],
            [hub_d/2,  -width/2],
            [hub_d/2,  -hub_len/2],
            [outer_d/2, -hub_len/2],

            // Left flange outer face
            [outer_d/2, -width/2],
            [outer_d/2, -width/2 + flange_th],

            // V-groove down to bottom
            [groove_d/2, -groove_half_w],
            [groove_d/2,  groove_half_w],

            // Right flange
            [outer_d/2,  width/2 - flange_th],
            [outer_d/2,  width/2],
            [outer_d/2,  hub_len/2],

            // Hub region back to center
            [hub_d/2,   hub_len/2],
            [hub_d/2,   width/2],
            [bore_d/2,  width/2]
        ]);
}

module pulley() {
    difference() {
        union() {
            pulley_body();

            // Add a centered hub cylinder to ensure solid hub volume
            cylinder(d=hub_d, h=hub_len, center=true);
        }

        // Bore
        cylinder(d=bore_d, h=width + 2, center=true);

        // Set screw hole (radial)
        if (set_screw) {
            translate([0,0,set_screw_z])
                rotate([0,90,0])
                    translate([0,0,set_screw_offset])
                        cylinder(d=set_screw_d, h=outer_d, center=true);
        }
    }
}

pulley();