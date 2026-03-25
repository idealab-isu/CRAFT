// Flat washer: 2.5mm ID, 5.9mm OD, 0.5mm thickness (single connected solid)

// Parameters
inner_diameter_mm = 2.5;
outer_diameter_mm = 5.9;
thickness_mm      = 0.5;

// Render quality (prevents faceted/polygonal look)
$fn = 180;

module washer(id=inner_diameter_mm, od=outer_diameter_mm, t=thickness_mm) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + 0.2, center=true); // slight overlap to guarantee clean through-hole
    }
}

washer();