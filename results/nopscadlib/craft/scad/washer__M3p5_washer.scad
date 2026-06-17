// Flat washer parameters (mm)
inner_hole_diameter_mm = 3.5;  //[1.75:7:0.1]
outer_diameter_mm      = 8.0;  //[4:16:0.1]
thickness_mm           = 0.5;  //[0.25:1:0.05]
eps_mm                 = 0.2;  //[0.05:0.5:0.05]

// Smoothness (avoid faceted look)
$fn = 128;

module washer() {
    difference() {
        cylinder(d=outer_diameter_mm, h=thickness_mm, center=true);
        cylinder(d=inner_hole_diameter_mm, h=thickness_mm + 2*eps_mm, center=true);
    }
}

// ONE connected solid: just the washer
washer();