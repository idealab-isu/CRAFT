// Flat washer: 2.0mm ID, 5.0mm OD, 0.3mm thickness

inner_diameter_mm = 2.0;
outer_diameter_mm = 5.0;
thickness_mm      = 0.3;

// Small extra height for clean boolean subtraction (not part of final dimensions)
cut_extra_mm = 0.2;

// Smooth circular appearance
$fn = 128;

module flat_washer(id_mm, od_mm, t_mm) {
    difference() {
        cylinder(d = od_mm, h = t_mm, center = true);
        cylinder(d = id_mm, h = t_mm + 2*cut_extra_mm, center = true);
    }
}

flat_washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);