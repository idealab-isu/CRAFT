module led() {
    // LED body
    difference() {
        cylinder(h=5, r=2.5, $fn=64);
        translate([0, 0, 5])
            sphere(r=2.5, $fn=64);
    }
    
    // LED legs
    translate([-1, 0, -10])
        cylinder(h=10, r=0.5, $fn=32);
    translate([1, 0, -10])
        cylinder(h=10, r=0.5, $fn=32);
}

led();