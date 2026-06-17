// Linear bearing (standalone) — 16mm bore, 28mm OD, 37mm length
// One connected solid (a single hollow cylinder with small end chamfers)

$fn = 180;

// Target dimensions
bore_diameter_mm  = 16.0;
outer_diameter_mm = 28.0;
length_mm         = 37.0;

// Detail parameters (kept subtle and dimensionally safe)
chamfer_mm = 0.6;     // axial length of chamfer at each end
overlap_mm = 0.02;    // tiny overlap to avoid coincident faces

module linear_bearing_16x28x37() {
    difference() {
        // Outer body with end chamfers (still exactly OD and length)
        union() {
            // Main outer cylinder (reduced length to make room for chamfers)
            cylinder(r = outer_diameter_mm/2,
                     h = length_mm - 2*chamfer_mm,
                     center = true);

            // Chamfer frustums at both ends
            for (s = [-1, 1]) {
                translate([0, 0, s*((length_mm/2) - chamfer_mm/2)])
                    cylinder(r1 = outer_diameter_mm/2,
                             r2 = outer_diameter_mm/2 - chamfer_mm,
                             h  = chamfer_mm + overlap_mm,
                             center = true);
            }
        }

        // Through bore (exactly 16mm)
        cylinder(r = bore_diameter_mm/2,
                 h = length_mm + 2*overlap_mm,
                 center = true);
    }
}

linear_bearing_16x28x37();