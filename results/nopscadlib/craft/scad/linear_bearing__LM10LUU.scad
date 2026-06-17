// Long linear bearing: 10mm bore, 19mm OD, 55mm length
// One connected solid (single part), no side screw/shaft features.

$fn = 128;

// Parameters
bore_diameter_mm = 10;          // 10.0mm bore
outer_diameter_mm = 19;         // 19.0mm outer diameter
length_mm = 55;                 // 55.0mm length

// Optional subtle end chamfer (kept small so OD/length remain essentially as specified)
chamfer_mm = 0.6;               // set to 0 for perfectly sharp ends
connection_overlap_mm = 0.5;    // for robust boolean ops

module long_linear_bearing() {
    difference() {
        // Outer body with small end chamfers
        union() {
            // Main cylinder (reduced length to make room for chamfers)
            cylinder(r=outer_diameter_mm/2,
                     h=length_mm - 2*chamfer_mm,
                     center=true);

            // End chamfers as truncated cones, connected by overlap
            if (chamfer_mm > 0) {
                for (s = [-1, 1]) {
                    translate([0, 0, s*((length_mm/2) - chamfer_mm/2)])
                        cylinder(r1=outer_diameter_mm/2,
                                 r2=outer_diameter_mm/2 - chamfer_mm,
                                 h=chamfer_mm + connection_overlap_mm,
                                 center=true);
                }
            }
        }

        // Through bore
        cylinder(r=bore_diameter_mm/2,
                 h=length_mm + 2*connection_overlap_mm,
                 center=true);
    }
}

long_linear_bearing();