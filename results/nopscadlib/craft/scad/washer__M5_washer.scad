// Flat washer: 5.0mm inner diameter, 10.0mm outer diameter, 1.0mm thickness

inner_diameter_mm = 5.0;
outer_diameter_mm = 10.0;
thickness_mm      = 1.0;

$fn = 128; // smooth circular hole and OD

difference() {
    cylinder(d = outer_diameter_mm, h = thickness_mm, center = true);
    cylinder(d = inner_diameter_mm, h = thickness_mm + 0.2, center = true); // slight extra to ensure clean cut
}