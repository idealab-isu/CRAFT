// Hex nut: 6.0mm screw, 7.7mm across flats, 7.9mm thick
// One connected solid, clean cylindrical bore

$fn = 128;

// Parameters (mm)
across_flats   = 7.7;
thickness      = 7.9;
hole_diameter  = 6.0;   // clean bore for 6.0mm screw
chamfer        = 0.4;   // edge chamfer height
overlap        = 0.2;   // boolean robustness

// Derived
R_outer = across_flats / sqrt(3);                 // circumradius for given across-flats
R_inner = max(0.01, (across_flats - 2*chamfer) / sqrt(3));

module hex2d(R) {
    polygon(points=[
        [ R, 0],
        [ R/2,  R*sqrt(3)/2],
        [-R/2,  R*sqrt(3)/2],
        [-R, 0],
        [-R/2, -R*sqrt(3)/2],
        [ R/2, -R*sqrt(3)/2]
    ]);
}

module nut_body_with_chamfers() {
    // Build as: middle prism + top frustum + bottom frustum (all connected)
    union() {
        // Middle straight section
        translate([0,0,0])
            linear_extrude(height = max(0.01, thickness - 2*chamfer), center=true)
                hex2d(R_outer);

        // Top chamfer (taper inwards)
        translate([0,0, (thickness/2 - chamfer/2)])
            linear_extrude(height = chamfer + overlap, center=true, scale = R_inner/R_outer)
                hex2d(R_outer);

        // Bottom chamfer (taper inwards)
        translate([0,0, -(thickness/2 - chamfer/2)])
            linear_extrude(height = chamfer + overlap, center=true, scale = R_inner/R_outer)
                hex2d(R_outer);
    }
}

module through_hole() {
    cylinder(d = hole_diameter, h = thickness + 2*overlap, center=true);
}

difference() {
    nut_body_with_chamfers();
    through_hole();
}