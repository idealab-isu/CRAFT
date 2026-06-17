// Flat washer: 2.5mm ID, 5.9mm OD, 0.5mm thickness

outer_diameter = 5.9;   //[3:12:0.1]
inner_diameter = 2.5;   //[1.2:6:0.1]
thickness      = 0.5;   //[0.25:2:0.05]

// Ensure smooth circular profiles (fix polygonal look)
$fn = 180;

// Small extra height so the hole is guaranteed through
hole_extra = 0.2;

difference() {
    cylinder(d=outer_diameter, h=thickness, center=true);
    cylinder(d=inner_diameter, h=thickness + 2*hole_extra, center=true);
}