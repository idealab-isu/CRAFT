// Rubber washer: 3.0mm inner hole, 10.0mm outer diameter, 1.5mm thickness

inner_diameter_mm = 3.0;
outer_diameter_mm = 10.0;
thickness_mm      = 1.5;

overlap_mm = 0.2;   // ensures clean through-cut
$fn = 128;

module washer(id, od, h) {
    difference() {
        cylinder(d=od, h=h, center=true);
        cylinder(d=id, h=h + 2*overlap_mm, center=true);
    }
}

color([0.2, 0.2, 0.2])
washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);