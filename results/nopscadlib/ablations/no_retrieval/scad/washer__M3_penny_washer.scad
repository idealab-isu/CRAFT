// Penny washer: 3.0mm ID, 12.0mm OD, 0.8mm thickness

outer_diameter = 12.0;   // mm
inner_diameter = 3.0;    // mm
thickness      = 0.8;    // mm

// Smoothness (prevents faceted/polygonal circles)
$fa = 2;
$fs = 0.05;

module washer(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h + 0.2, center=true); // slight extra height ensures clean through-hole
    }
}

washer(outer_diameter, inner_diameter, thickness);