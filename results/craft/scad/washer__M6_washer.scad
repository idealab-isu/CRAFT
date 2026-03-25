// Flat washer: 6.0mm ID, 12.5mm OD, 1.5mm thickness

inner_diameter_mm = 6.0;
outer_diameter_mm = 12.5;
thickness_mm      = 1.5;

$fn = 128;

module washer(id, od, t) {
    difference() {
        cylinder(d=od, h=t, center=true);
        // Make the cut slightly taller to guarantee a clean through-hole
        cylinder(d=id, h=t + 0.2, center=true);
    }
}

washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);