// Flat washer: 2.0mm ID, 5.0mm OD, 0.3mm thickness

outer_diameter = 5.0;
inner_diameter = 2.0;
thickness      = 0.3;

// High resolution for true circles (avoid polygonal/octagonal look)
$fn = 180;

module washer(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        // Slightly taller cutter ensures a clean through-hole without affecting thickness
        cylinder(d=id, h=h + 0.2, center=true);
    }
}

washer(outer_diameter, inner_diameter, thickness);