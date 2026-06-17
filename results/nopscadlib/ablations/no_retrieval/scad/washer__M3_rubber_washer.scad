// Rubber washer: 3.0mm ID, 10.0mm OD, 1.5mm thickness

$fn = 180;  // high resolution for perfectly round circles

outer_diameter = 10.0;
inner_diameter = 3.0;
thickness      = 1.5;

overlap = 0.02; // tiny overlap to ensure clean boolean results

module washer(od, id, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h + 2*overlap, center=true);
    }
}

color([0.2, 0.2, 0.2])
washer(outer_diameter, inner_diameter, thickness);