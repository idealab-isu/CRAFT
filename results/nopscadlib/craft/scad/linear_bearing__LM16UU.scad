// Linear bearing (standalone sleeve)
// 16.0mm bore, 28.0mm outer diameter, 37.0mm length

$fn = 128;

// Parameters (mm)
bore_diameter_mm  = 16.0;
outer_diameter_mm = 28.0;
length_mm         = 37.0;

// Small overlap to ensure robust boolean operations
connect_overlap_mm = 0.2;

module linear_bearing(bore_d=bore_diameter_mm, od=outer_diameter_mm, L=length_mm) {
    difference() {
        // Outer sleeve
        cylinder(d=od, h=L, center=true);

        // Through-bore (extend beyond ends so it always cuts through)
        cylinder(d=bore_d, h=L + 2*connect_overlap_mm, center=true);
    }
}

linear_bearing();