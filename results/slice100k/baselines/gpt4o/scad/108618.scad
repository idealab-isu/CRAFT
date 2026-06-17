module faceplate() {
    difference() {
        // Main rounded rectangle faceplate
        offset(r=2) {
            square([65, 20], center=true);
        }
        
        // Large rectangular window openings
        translate([-15, 0, 0])
            offset(r=1) {
                square([28, 16], center=true);
            }
        translate([15, 0, 0])
            offset(r=1) {
                square([28, 16], center=true);
            }
        
        // Small circular holes centered between windows
        translate([-7.5, 0, 0])
            cylinder(h=4, r=1.5, center=true, $fn=64);
        translate([7.5, 0, 0])
            cylinder(h=4, r=1.5, center=true, $fn=64);
        
        // Small circular mounting holes near each end
        translate([-30, 0, 0])
            cylinder(h=4, r=1.5, center=true, $fn=64);
        translate([30, 0, 0])
            cylinder(h=4, r=1.5, center=true, $fn=64);
    }
}

faceplate();