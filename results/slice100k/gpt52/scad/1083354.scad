$fn=96;

module outer_profile() {
    union() {
        translate([0,0,-97.5/2 + 30/2])
            cylinder(h=30, r=19.0/2);
        translate([0,0,-97.5/2 + 30 + 7.5/2])
            cylinder(h=7.5, r1=19.0/2, r2=12.0/2);
        translate([0,0,-97.5/2 + 30 + 7.5 + 30/2])
            cylinder(h=30, r=12.0/2);
        translate([0,0,-97.5/2 + 30 + 7.5 + 30 + 7.5/2])
            cylinder(h=7.5, r1=12.0/2, r2=19.0/2);
        translate([0,0,-97.5/2 + 30 + 7.5 + 30 + 7.5 + 22.5/2])
            cylinder(h=22.5, r=19.0/2);
    }
}

module bore() {
    cylinder(h=97.5 + 0.2, r=6.0/2, center=true);
}

difference() {
    outer_profile();
    bore();
}