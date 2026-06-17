$fn=64;

module variac() {
    difference() {
        union() {
            // Base cylinder
            cylinder(h=20, r=50, center=true);
            
            // Top cylinder
            translate([0, 0, 10])
                cylinder(h=10, r=45, center=true);
            
            // Knob
            translate([0, 0, 25])
                cylinder(h=10, r=15, center=true);
        }
        
        // Central hole
        translate([0, 0, -10])
            cylinder(h=40, r=5, center=true);
    }
}

variac();