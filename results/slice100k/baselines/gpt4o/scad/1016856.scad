$fn=64;

module rounded_rectangle_plate() {
    difference() {
        union() {
            // Base plate with rounded corners
            translate([-20, -20, 0])
                offset(r=3) 
                    square([40, 40]);

            // L-shaped profile
            translate([-20, -20, 0])
                cube([40, 20, 16]);
            translate([-20, 0, 0])
                cube([40, 20, 8]);
        }
        
        // Keyhole slots
        for (x = [-10, 0, 10]) {
            for (y = [-10, 0, 10]) {
                translate([x, y, -1])
                    keyhole_slot();
            }
        }

        // Edge notches
        for (x = [-20, 20]) {
            translate([x, 0, 0])
                rotate([0, 0, 90])
                    edge_notch();
        }
        for (y = [-20, 20]) {
            translate([0, y, 0])
                edge_notch();
        }
    }
    
    // Circular recesses
    for (x = [-15, 15]) {
        for (y = [-15, 15]) {
            translate([x, y, 0.5])
                circular_recess();
        }
    }
}

module keyhole_slot() {
    difference() {
        union() {
            translate([-2, -1, 0])
                offset(r=1)
                    square([4, 2]);
            translate([0, 0, 0])
                cylinder(h=2, r=1);
        }
        translate([0, 0, 0])
            cylinder(h=2, r=0.5);
    }
}

module edge_notch() {
    translate([-1, -1, 0])
        cube([2, 2, 16]);
}

module circular_recess() {
    difference() {
        cylinder(h=1, r=3);
        translate([0, 0, -0.1])
            cylinder(h=1.2, r=2.5);
    }
}

rounded_rectangle_plate();