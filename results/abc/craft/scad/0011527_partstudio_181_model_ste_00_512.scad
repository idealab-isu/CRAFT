// Dimension-calibrated (target: 0.03 x 0.03 x 0.00 mm)
scale([0.900000, 0.900000, 2.000000])
{
// Thin circular plate with central round through-hole and 8 hex through-holes on a bolt circle

$fn = 180;

// Parameters (meters -> 0.03 m = 30 mm)
plate_od        = 0.03;    // outer diameter
plate_thk       = 0.001;   // thickness
center_hole_d   = 0.015;   // central through-hole diameter
bolt_circle_d   = 0.022;   // bolt circle diameter (for hex hole centers)
hex_hole_af     = 0.004;   // hex across-flats
hole_count      = 8;
hex_rotation_deg = 0.0;
overlap         = 0.0005;  // extra height for clean through-cuts

// Ensure non-zero Z scale so geometry is visible
scale_xy = 1.0;
scale_z  = 1.0;

// Helpers
function clamp(x, lo, hi) = x < lo ? lo : (x > hi ? hi : x);

// Hex radius (circumradius) from across-flats: AF = sqrt(3) * R
hex_R = hex_hole_af / sqrt(3);

// Keep holes inside the plate (simple safety clamp)
bc_r_nom = bolt_circle_d / 2;
bc_r_max = plate_od/2 - hex_R - 0.0002;
bc_r     = clamp(bc_r_nom, 0, bc_r_max);

// Base shapes
module outer_disk() {
    cylinder(r = plate_od/2, h = plate_thk, center = true);
}

module center_through_hole() {
    cylinder(r = center_hole_d/2, h = plate_thk + 2*overlap, center = true);
}

module hex_through_hole() {
    // Use built-in 6-sided cylinder for a true hex profile
    rotate([0, 0, hex_rotation_deg])
        cylinder(r = hex_R, h = plate_thk + 2*overlap, center = true, $fn = 6);
}

module hex_holes_radial() {
    for (i = [0 : hole_count-1]) {
        rotate([0, 0, i * 360 / hole_count])
            translate([bc_r, 0, 0])
                hex_through_hole();
    }
}

module plate_with_holes() {
    difference() {
        outer_disk();
        center_through_hole();
        hex_holes_radial();
    }
}

// Final
scale([scale_xy, scale_xy, scale_z]) plate_with_holes();
}
