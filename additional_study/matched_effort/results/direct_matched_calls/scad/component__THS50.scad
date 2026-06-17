$fn=96;

module component() {
    // Simple generic component: base plate with two mounting holes and a central boss
    difference() {
        union() {
            // Base
            translate([0,0,0])
                cube([60, 30, 6], center=true);

            // Central boss
            translate([0,0,6/2])
                cylinder(h=14, r=10, center=false);

            // Small top cap
            translate([0,0,6/2 + 14])
                cylinder(h=4, r=6, center=false);
        }

        // Mounting holes through base
        for (x = [-20, 20]) {
            translate([x, 0, -20])
                cylinder(h=60, r=3.2, center=false);
        }

        // Counterbore on top side
        for (x = [-20, 20]) {
            translate([x, 0, 2])
                cylinder(h=6, r=6, center=false);
        }

        // Central through hole in boss
        translate([0,0,-20])
            cylinder(h=80, r=4, center=false);
    }
}

component();