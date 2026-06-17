$fn = 96;

// Target dimensions (mm)
across_flats   = 6.4;   // hex width across flats
thickness      = 2.4;   // nut thickness
hole_diameter  = 3.0;   // through-hole for M3 screw (no clearance added)
chamfer_size   = 0.3;   // edge chamfer height
eps            = 0.02;  // tiny overlap to avoid coincident faces

// Derived: circumradius of hex from across-flats
// across_flats = 2 * R * cos(30) = R * sqrt(3)  => R = across_flats / sqrt(3)
hex_R = across_flats / sqrt(3);

module hex2d(R){
    // Flat-to-flat is along Y for this point set; rotate 30° so flats align with X/Y axes
    rotate(30)
        polygon(points=[
            [ R, 0],
            [ R/2,  R*sqrt(3)/2],
            [-R/2,  R*sqrt(3)/2],
            [-R, 0],
            [-R/2, -R*sqrt(3)/2],
            [ R/2, -R*sqrt(3)/2]
        ]);
}

module hex_prism(h, R){
    linear_extrude(height=h, center=true, convexity=10)
        hex2d(R);
}

module hex_nut(){
    difference(){
        // Outer body: true hex across flats, with hex chamfers (not circular)
        union(){
            // Middle straight section
            hex_prism(thickness - 2*chamfer_size, hex_R);

            // Top chamfer: hull between smaller and full hex
            translate([0,0, thickness/2 - chamfer_size/2])
                hull(){
                    translate([0,0, -chamfer_size/2])
                        linear_extrude(height=eps, center=true) hex2d(hex_R - chamfer_size);
                    translate([0,0,  chamfer_size/2])
                        linear_extrude(height=eps, center=true) hex2d(hex_R);
                }

            // Bottom chamfer: hull between full and smaller hex
            translate([0,0, -(thickness/2 - chamfer_size/2)])
                hull(){
                    translate([0,0, -chamfer_size/2])
                        linear_extrude(height=eps, center=true) hex2d(hex_R);
                    translate([0,0,  chamfer_size/2])
                        linear_extrude(height=eps, center=true) hex2d(hex_R - chamfer_size);
                }
        }

        // Through-hole (true through, with overlap)
        cylinder(h=thickness + 2*eps, d=hole_diameter, center=true);
    }
}

hex_nut();