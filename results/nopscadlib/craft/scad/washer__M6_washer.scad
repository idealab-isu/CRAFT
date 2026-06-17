// Flat Washer Parameters (mm)
inner_diameter_mm = 6.0;
outer_diameter_mm = 12.5;
thickness_mm      = 1.5;

// Smoothness (increase for smoother circles)
$fn = 128;

module flat_washer(id, od, t) {
    difference() {
        cylinder(d=od, h=t, center=true);
        // Slightly taller cut to guarantee a clean through-hole
        cylinder(d=id, h=t + 0.2, center=true);
    }
}

flat_washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);