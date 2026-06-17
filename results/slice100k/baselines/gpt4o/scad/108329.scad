module hex_plate() {
    difference() {
        // Hexagonal block
        scale([1, 1, 0.5])
            rotate([0, 0, 30])
                cylinder(r=23.1, h=38.0, $fn=6);
        
        // Central circular through-hole
        translate([0, 0, -1])
            cylinder(r=5, h=40, $fn=64);
        
        // Rectangular steps/notches around the perimeter
        for (i = [0:5]) {
            rotate([0, 0, i * 60])
                translate([23.1, 0, 0])
                    cube([5, 10, 38], center=true);
        }
    }
}

module top_cutout() {
    // Asymmetric cutout on the top face
    translate([0, 0, 9.5])
        difference() {
            scale([1, 1, 0.25])
                rotate([0, 0, 30])
                    cylinder(r=23.1, h=38.0, $fn=6);
            translate([0, 0, -1])
                cylinder(r=10, h=40, $fn=64);
        }
}

module bottom_cutout() {
    // Asymmetric cutout on the bottom face
    translate([0, 0, -9.5])
        difference() {
            scale([1, 1, 0.25])
                rotate([0, 0, 30])
                    cylinder(r=23.1, h=38.0, $fn=6);
            translate([0, 0, -1])
                cylinder(r=8, h=40, $fn=64);
        }
}

union() {
    hex_plate();
    top_cutout();
    bottom_cutout();
}