// Linear bearing (simple, standard) — 6mm ID, 12mm OD, 19mm length
// One connected solid (single part), no side features.

bore_diameter_mm  = 6.0;   //[3.0:12.0:0.1]
outer_diameter_mm = 12.0;  //[6.0:24.0:0.1]
length_mm         = 19.0;  //[10.0:38.0:0.1]

eps_mm = 0.05;             //[0.01:0.2:0.01]
$fn = 128;                 // ensure smooth cylindrical bore/OD

module linear_bearing_simple() {
    difference() {
        // Outer cylinder (OD)
        cylinder(d=outer_diameter_mm, h=length_mm, center=true);

        // Inner bore (ID) - slightly extended to guarantee clean subtraction
        cylinder(d=bore_diameter_mm, h=length_mm + 2*eps_mm, center=true);
    }
}

linear_bearing_simple();