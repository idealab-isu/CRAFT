// Long linear bearing: 4.0mm bore, 8.0mm OD, 23.0mm length

$fn = 128;  // smooth bore and OD

// Parameters
bearing_length = 23.0; //[12.0:46.0:0.5]
outer_diameter = 8.0;  //[4.0:16.0:0.5]
bore_diameter  = 4.0;  //[2.0:8.0:0.5]

// Small edge break (not a full cone to a point)
chamfer_length = 0.8;  //[0.3:2.0:0.1]
chamfer_radial = 0.4;  //[0.1:1.2:0.1]

// Robust boolean overlap
overlap = 0.2; //[0.05:1.0:0.05]

// Derived
R  = outer_diameter/2;
r  = bore_diameter/2;
R2 = max(R - chamfer_radial, r + 0.01); // keep valid geometry

module bearing_complete() {
    difference() {
        // Outer body with small end chamfers (connected, single solid)
        union() {
            // Main cylinder shortened to make room for chamfers at both ends
            cylinder(h = bearing_length - 2*chamfer_length, r = R, center = true);

            // Top chamfer ring
            translate([0, 0, (bearing_length/2 - chamfer_length/2)])
                cylinder(h = chamfer_length, r1 = R2, r2 = R, center = true);

            // Bottom chamfer ring
            translate([0, 0, -(bearing_length/2 - chamfer_length/2)])
                cylinder(h = chamfer_length, r1 = R, r2 = R2, center = true);
        }

        // Through bore (round, smooth)
        cylinder(h = bearing_length + 2*overlap, r = r, center = true);
    }
}

bearing_complete();