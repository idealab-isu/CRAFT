// Flat washer: 4.0mm ID, 9.0mm OD, 0.8mm thickness

inner_diameter_mm = 4.0;   //[2:8:0.1]
outer_diameter_mm = 9.0;   //[5:18:0.1]
thickness_mm      = 0.8;   //[0.4:1.6:0.05]

$fn = 128;

difference() {
    cylinder(d=outer_diameter_mm, h=thickness_mm, center=true);
    cylinder(d=inner_diameter_mm, h=thickness_mm + 0.2, center=true);
}