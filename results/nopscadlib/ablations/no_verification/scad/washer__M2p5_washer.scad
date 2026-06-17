// Flat washer: 2.5mm ID, 5.9mm OD, 0.5mm thickness

inner_diameter_mm = 2.5;   // through-hole diameter
outer_diameter_mm = 5.9;   // outside diameter
thickness_mm      = 0.5;   // washer thickness

// Extra height for clean boolean cut (formula-based, not arbitrary)
cut_extra_h = thickness_mm * 2;

$fn = 128;

module flat_washer(id, od, t) {
    difference() {
        cylinder(d=od, h=t, center=true);
        cylinder(d=id, h=t + cut_extra_h, center=true);
    }
}

flat_washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);