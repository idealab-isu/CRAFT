// Linear bearing: 5.0mm bore, 10.0mm OD, 15.0mm length
bore_diameter_mm  = 5.0;   //[2.5:10.0:0.1]
outer_diameter_mm = 10.0;  //[5.0:20.0:0.1]
length_mm         = 15.0;  //[7.5:30.0:0.1]

// Optional small end chamfers (kept subtle; does not change main dimensions)
chamfer_mm = 0.4;          //[0:1.0:0.05]
overlap_mm = 0.2;          //[0.05:1.0:0.05]

$fn = 96;

module linear_bearing_5x10x15() {
    difference() {
        // Outer sleeve (single connected solid)
        union() {
            cylinder(d=outer_diameter_mm, h=length_mm, center=true);

            // Small end chamfers via tapered rings (connected by overlap)
            if (chamfer_mm > 0) {
                for (zsgn = [-1, 1]) {
                    translate([0, 0, zsgn*(length_mm/2 - chamfer_mm/2)])
                        cylinder(d1=outer_diameter_mm, d2=outer_diameter_mm - 2*chamfer_mm,
                                 h=chamfer_mm + overlap_mm, center=true);
                }
            }
        }

        // Through bore
        cylinder(d=bore_diameter_mm, h=length_mm + 2*overlap_mm, center=true);
    }
}

linear_bearing_5x10x15();