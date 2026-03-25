// Flat washer parameters (mm)
inner_diameter_mm = 2.0;  //[1.0:4.0:0.1]
outer_diameter_mm = 5.0;  //[2.5:10.0:0.1]
thickness_mm      = 0.3;  //[0.15:0.6:0.05]

// Smoothness for circular appearance
$fn = 128;

difference() {
    cylinder(d = outer_diameter_mm, h = thickness_mm, center = true);
    cylinder(d = inner_diameter_mm, h = thickness_mm + 0.2, center = true);
}