module tapered_plate() {
    difference() {
        // Main trapezoidal plate
        polygon(points=[[50, 0], [-50, 0], [-40, 100], [40, 100]]);
        
        // Semicircular cutout
        translate([0, 0])
            circle(r=50, $fn=64);
        
        // Rectangular slots
        translate([-30, 10])
            square([5, 20], center=true);
        translate([30, 10])
            square([5, 20], center=true);
        translate([-30, 40])
            square([5, 20], center=true);
        translate([30, 40])
            square([5, 20], center=true);
        
        // Stencil-style text
        translate([-20, 70])
            linear_extrude(height=0.1)
                text("EEZYbot ARM MK2", size=10, halign="center", valign="center");
    }
}

module mounting_feet() {
    translate([-40, 0, -5])
        cube([10, 10, 5], center=false);
    translate([30, 0, -5])
        cube([10, 10, 5], center=false);
}

translate([0, 0, 0.05])
    linear_extrude(height=0.1)
        tapered_plate();

mounting_feet();