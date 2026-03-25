// Linear bearing (LM4UU-style sleeve) — single connected solid
// Target: 4.0mm bore, 8.0mm outer diameter, 12.0mm length

bore_diameter_mm  = 4.0;   //[2.0:8.0:0.1]
outer_diameter_mm = 8.0;   //[4.0:16.0:0.1]
length_mm         = 12.0;  //[6.0:24.0:0.1]

connection_overlap_mm = 0.5; //[0.1:2.0:0.1]
$fn = 96;

module linear_bearing(bore_d=bore_diameter_mm, od=outer_diameter_mm, L=length_mm) {
    bore_r  = bore_d/2;
    outer_r = od/2;

    // Single cylindrical sleeve with through bore
    difference() {
        cylinder(r=outer_r, h=L, center=true);
        cylinder(r=bore_r,  h=L + 2*connection_overlap_mm, center=true);
    }
}

linear_bearing();