// Linear bearing (simple sleeve) — 10mm bore, 19mm OD, 29mm length

bore_diameter_mm  = 10.0;  //[5:20:0.1]
outer_diameter_mm = 19.0;  //[10:38:0.1]
length_mm         = 29.0;  //[15:58:0.1]

overlap_mm        = 0.2;   //[0.05:1:0.05]
bore_clearance_mm = 0.0;   //[0:0.5:0.05]

$fn = 128;

module linear_bearing_sleeve() {
    difference() {
        // Outer cylinder
        cylinder(h=length_mm, r=outer_diameter_mm/2, center=true);

        // Through bore
        cylinder(h=length_mm + 2*overlap_mm,
                 r=(bore_diameter_mm + bore_clearance_mm)/2,
                 center=true);
    }
}

linear_bearing_sleeve();