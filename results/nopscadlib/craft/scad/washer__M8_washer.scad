// Flat washer parameters (mm)
inner_diameter_mm = 8.0;   // inner hole diameter
outer_diameter_mm = 17.0;  // outer diameter
thickness_mm      = 1.6;   // thickness

// Small extra height to guarantee a clean through-hole in CSG
hole_extra_mm = 0.2;

module flat_washer() {
    difference() {
        cylinder(d=outer_diameter_mm, h=thickness_mm, center=true, $fn=128);
        cylinder(d=inner_diameter_mm, h=thickness_mm + 2*hole_extra_mm, center=true, $fn=128);
    }
}

flat_washer();