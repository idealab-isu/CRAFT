// Penny washer: 4.0mm ID, 14.0mm OD, 0.8mm thickness

outer_diameter = 14.0;   // mm
inner_diameter = 4.0;    // mm
thickness      = 0.8;    // mm

// Make circles truly round in preview/renders
$fa = 2;     // max angle per fragment (deg)
$fs = 0.2;   // max fragment size (mm)

overlap = 0.2; // ensures clean subtraction

difference() {
    cylinder(d=outer_diameter, h=thickness, center=true);
    cylinder(d=inner_diameter, h=thickness + 2*overlap, center=true);
}