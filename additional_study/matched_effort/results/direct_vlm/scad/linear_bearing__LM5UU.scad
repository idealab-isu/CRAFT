$fn = 128;

bore_d = 5.0;   // mm
od_d   = 10.0;  // mm
len    = 15.0;  // mm

eps = 0.05;     // small overlap to ensure clean boolean

// Linear bearing: hollow cylinder (annulus) with through-bore
difference() {
    cylinder(d = od_d, h = len, center = true);
    translate([0, 0, 0])
        cylinder(d = bore_d, h = len + 2*eps, center = true);
}