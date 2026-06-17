// Linear bearing: 3.0mm bore, 7.0mm OD, 10.0mm length
bore_diameter_mm  = 3.0;   //[1.5:6:0.1]
outer_diameter_mm = 7.0;   //[3.5:14:0.1]
length_mm         = 10.0;  //[5:20:0.1]
fit_clearance_mm  = 0.0;   //[0:0.4:0.05]

// Smoothness (ensure circular bore/OD)
$fn = 96;

module linear_bearing() {
    difference() {
        // Outer sleeve
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

        // Through bore (slightly extended to guarantee clean cut)
        cylinder(h=length_mm + 0.2, r=(bore_diameter_mm + fit_clearance_mm)/2, center=true);
    }
}

linear_bearing();