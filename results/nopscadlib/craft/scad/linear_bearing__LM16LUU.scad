// Long Linear Bearing (single connected solid)
// Target: 16.0mm bore, 28.0mm outer diameter, 70.0mm length

bore_diameter_mm  = 16.0;  //[8.0:32.0:0.5]
outer_diameter_mm = 28.0;  //[14.0:56.0:0.5]
length_mm         = 70.0;  //[35.0:140.0:1]
centered          = 1;     //[0:1:1]
eps_mm            = 0.6;   //[0.2:2.0:0.1]
$fn = 96;

module long_linear_bearing() {
    bore_r  = bore_diameter_mm/2;
    outer_r = outer_diameter_mm/2;

    // Centering control (no arbitrary translations)
    z0 = (centered == 1) ? 0 : length_mm/2;

    // One connected solid: outer cylinder minus inner bore
    difference() {
        translate([0,0,z0])
            cylinder(r=outer_r, h=length_mm, center=(centered==1));
        translate([0,0,z0])
            cylinder(r=bore_r, h=length_mm + 2*eps_mm, center=(centered==1));
    }
}

long_linear_bearing();