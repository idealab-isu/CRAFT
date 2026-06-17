// Penny washer parameters (mm)
inner_diameter_mm = 6.0;   // hole diameter
outer_diameter_mm = 26.0;  // outside diameter
thickness_mm      = 1.5;   // washer thickness
eps_mm            = 0.2;   // boolean safety overlap

$fn = 128;

module penny_washer(inner_d, outer_d, t, eps=0.2) {
    difference() {
        cylinder(d=outer_d, h=t, center=true);
        cylinder(d=inner_d, h=t + 2*eps, center=true);
    }
}

// Single connected solid: just the washer
penny_washer(inner_diameter_mm, outer_diameter_mm, thickness_mm, eps_mm);