module housing() {
    difference() {
        // Main block
        cube([0.1, 0.1, 0.1], center=true);
        
        // Through-bore
        translate([0, 0, -0.05])
            cylinder(h=0.2, d=0.05, $fn=64, center=true);
    }
}

module boss() {
    translate([0, 0.05, 0])
        cylinder(h=0.02, d=0.03, $fn=64, center=true);
}

module tabs() {
    union() {
        // Top tab
        translate([0, 0.05, 0])
            cube([0.1, 0.02, 0.02], center=true);
        
        // Bottom tab
        translate([0, -0.05, 0])
            cube([0.1, 0.02, 0.02], center=true);
    }
}

union() {
    housing();
    boss();
    tabs();
}