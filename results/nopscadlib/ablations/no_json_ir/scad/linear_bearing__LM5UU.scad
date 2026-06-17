// Linear bearing: 5.0mm bore, 10.0mm OD, 15.0mm length

bore_diameter  = 5.0;
outer_diameter = 10.0;
length         = 15.0;

// Smoothness (avoid polygonal/hex look)
$fn = 128;

module linear_bearing(bore_d=bore_diameter, od=outer_diameter, L=length) {
    difference() {
        // Outer body
        cylinder(d=od, h=L, center=true);

        // Through bore (slightly longer to guarantee clean cut)
        cylinder(d=bore_d, h=L + 0.2, center=true);
    }
}

linear_bearing();