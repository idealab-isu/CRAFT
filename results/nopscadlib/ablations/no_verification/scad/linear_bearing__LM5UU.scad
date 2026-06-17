// Linear bearing (single connected solid) — 5mm bore, 10mm OD, 15mm length

$fn = 128;

// Requested dimensions
bore_diameter_mm  = 5.0;
outer_diameter_mm = 10.0;
length_mm         = 15.0;

// Optional cosmetic features (kept subtle and fully connected)
chamfer_mm = 0.4;   // small end chamfer
overlap_mm = 0.02;  // tiny overlap to avoid coincident faces

module linear_bearing_5x10x15() {
    difference() {
        // Outer body with slight end chamfers (still a single solid)
        union() {
            // Main cylinder
            cylinder(d=outer_diameter_mm, h=length_mm - 2*chamfer_mm, center=true);

            // End chamfers as short frustums
            translate([0, 0,  (length_mm/2 - chamfer_mm/2)])
                cylinder(d1=outer_diameter_mm - 2*chamfer_mm, d2=outer_diameter_mm, h=chamfer_mm, center=true);

            translate([0, 0, -(length_mm/2 - chamfer_mm/2)])
                cylinder(d1=outer_diameter_mm, d2=outer_diameter_mm - 2*chamfer_mm, h=chamfer_mm, center=true);
        }

        // Through bore (exact 5.0mm)
        cylinder(d=bore_diameter_mm, h=length_mm + 2*overlap_mm, center=true);
    }
}

linear_bearing_5x10x15();