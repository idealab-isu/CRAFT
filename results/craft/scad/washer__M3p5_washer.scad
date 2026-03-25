// Flat washer parameters (mm)
inner_diameter_mm = 3.5;  //[1.75:7:0.1]
outer_diameter_mm = 8.0;  //[4:16:0.1]
thickness_mm      = 0.5;  //[0.25:1:0.05]

// Smoothness
$fn = 128;

module washer(inner_d, outer_d, h) {
    difference() {
        cylinder(d=outer_d, h=h, center=true);
        // Slightly taller cutter to guarantee a clean through-hole
        cylinder(d=inner_d, h=h + 0.2, center=true);
    }
}

// Single connected solid: just the washer
washer(inner_diameter_mm, outer_diameter_mm, thickness_mm);