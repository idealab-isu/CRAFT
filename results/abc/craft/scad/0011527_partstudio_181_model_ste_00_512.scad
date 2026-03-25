// Dimension-calibrated (target: 0.03 x 0.03 x 0.00 mm)
scale([0.900036, 0.900036, 2.502565])
{
// Thin circular plate with central round through-hole and 8 hex through-holes on a bolt circle
// Units: meters (values are small; scale up if your viewer expects mm)

$fn = 180;

// Parameters
plate_d = 0.03;                 // outer diameter
plate_t = 0.0008;               // thickness (increased so it renders reliably)
center_hole_d = 0.015;          // central circular through-hole diameter
bolt_circle_d = 0.022;          // bolt circle diameter for the 8 hex holes
hex_flat_to_flat = 0.004;       // hex hole size (flat-to-flat)
hex_rotation_deg = 0;           // rotation of hex holes
hole_count = 8;                 // number of hex holes
eps = 1e-5;                     // robust boolean epsilon

// Helpers
function hex_R_from_F(F) = F / sqrt(3); // circumradius from flat-to-flat

module outer_disk() {
    cylinder(r = plate_d/2, h = plate_t, center = true);
}

module center_through_hole() {
    cylinder(r = center_hole_d/2, h = plate_t + 2*eps, center = true);
}

module hex_through_hole() {
    rotate([0,0,hex_rotation_deg])
        cylinder(r = hex_R_from_F(hex_flat_to_flat), h = plate_t + 2*eps, center = true, $fn = 6);
}

module hex_holes_on_bolt_circle() {
    for (i = [0:hole_count-1]) {
        rotate([0,0, i*360/hole_count])
            translate([bolt_circle_d/2, 0, 0])
                hex_through_hole();
    }
}

difference() {
    outer_disk();
    center_through_hole();
    hex_holes_on_bolt_circle();
}
}
