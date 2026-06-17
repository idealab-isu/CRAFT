// Penny washer (single part)
// 4.0mm inner hole, 14.0mm outer diameter, 0.8mm thickness

inner_diameter_mm = 4.0;
outer_diameter_mm = 14.0;
thickness_mm      = 0.8;

$fn = 128;

difference() {
    cylinder(d = outer_diameter_mm, h = thickness_mm, center = true);
    cylinder(d = inner_diameter_mm, h = thickness_mm + 0.2, center = true);
}