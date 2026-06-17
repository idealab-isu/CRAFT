$fn = 180;

bore_d  = 16.0;
outer_d = 28.0;
length  = 70.0;

eps = 0.2;

// Bearing axis along X so TOP/BOTTOM views show the bore opening
rotate([0, 90, 0])
difference() {
    cylinder(d = outer_d, h = length, center = true);
    cylinder(d = bore_d,  h = length + eps, center = true);
}