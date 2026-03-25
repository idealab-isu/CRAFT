$fn=64;

module variac() {
    union() {
        // Base cylinder
        cylinder(h=10, r=50, center=true);
        
        // Top knob
        translate([0, 0, 10])
            cylinder(h=5, r=20, center=true);
        
        // Central shaft
        translate([0, 0, -5])
            cylinder(h=20, r=5, center=true);
        
        // Dial markings
        for (i = [0:30:330]) {
            rotate([0, 0, i])
                translate([40, 0, 10])
                    cube([2, 5, 1], center=true);
        }
    }
}

variac();