// Stepped axisymmetric flanged hub (no holes/cutouts), sized to 8.6 x 8.6 x 6.2 mm

// Parameters
OD_flange = 8.6;   //[4.3:17.2:0.01]
H_total   = 6.19;  //[3.095:12.38:0.01]
OD_boss   = 5.6;   //[2.8:11.2:0.01]
H_boss    = 4.5;   //[2.25:9:0.01]
H_flange  = 1.69;  //[0.845:3.38:0.01]

// Quality
$fn = 128;

// Derived (ensure exact connectivity and total height)
H_flange_eff = H_total - H_boss;  // keeps overall height = H_total

module flange_disk() {
    // Flange at bottom, boss on top; model centered about Z=0
    translate([0, 0, -H_total/2 + H_flange_eff/2])
        cylinder(h=H_flange_eff, r=OD_flange/2, center=true);
}

module boss_cylinder() {
    translate([0, 0,  H_total/2 - H_boss/2])
        cylinder(h=H_boss, r=OD_boss/2, center=true);
}

union() {
    flange_disk();
    boss_cylinder();
}