// Long linear bearing (simple): 6mm bore, 12mm OD, 35mm length
bore_diameter_mm  = 6.0;
outer_diameter_mm = 12.0;
length_mm         = 35.0;

centered = 1;          // 1 = centered on origin, 0 = sits on Z=0
overlap_mm = 0.2;      // small overlap to ensure clean boolean

$fn = 128;

module linear_bearing_simple() {
    zc = centered ? 0 : length_mm/2;

    translate([0, 0, zc])
    difference() {
        // Outer body (OD = 12mm, L = 35mm)
        cylinder(d=outer_diameter_mm, h=length_mm, center=true);

        // Through-bore (ID = 6mm) cut fully through with overlap
        cylinder(d=bore_diameter_mm, h=length_mm + 2*overlap_mm, center=true);
    }
}

linear_bearing_simple();