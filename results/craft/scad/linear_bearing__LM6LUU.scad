// Long linear bearing (LM6LUU-style) — single connected solid
bore_diameter_mm  = 6.0;   //[3.0:12.0:0.1]
outer_diameter_mm = 12.0;  //[6.0:24.0:0.1]
length_mm         = 35.0;  //[18.0:70.0:0.5]

eps_mm     = 0.2;  //[0.05:0.5:0.05]
overlap_mm = 0.6;  //[0.2:2.0:0.1]

$fn = 96;

module linear_bearing_long() {
    // Optional subtle end chamfers to look more like a real bearing
    chamfer_mm = min(0.6, outer_diameter_mm/10);

    difference() {
        // Outer body with small chamfers (still OD=outer_diameter_mm, L=length_mm)
        union() {
            // Main cylinder (slightly shortened to make room for chamfers)
            cylinder(d=outer_diameter_mm, h=length_mm - 2*chamfer_mm, center=true);

            // End chamfers as truncated cones, connected with overlap
            for (zsgn = [-1, 1]) {
                translate([0, 0, zsgn*((length_mm - chamfer_mm)/2 - overlap_mm/2)])
                    cylinder(d1=outer_diameter_mm, d2=outer_diameter_mm - 2*chamfer_mm,
                             h=chamfer_mm + overlap_mm, center=true);
            }
        }

        // Through bore
        cylinder(d=bore_diameter_mm, h=length_mm + 2*eps_mm, center=true);
    }
}

linear_bearing_long();