module mechanical_part() {
    difference() {
        // Main rectangular body
        cube([22, 22, 37.6], center=true);
        
        // Central cylindrical bore
        translate([0, 0, -18.8])
            cylinder(h=37.6, d=10, $fn=64, center=true);
    }
    
    // Top and bottom tabs
    translate([0, 0, 18.8])
        cube([10, 22, 2], center=true);
    translate([0, 0, -18.8])
        cube([10, 22, 2], center=true);
    
    // Left and right lateral protrusions
    translate([-11, 0, 0])
        cube([2, 10, 37.6], center=true);
    translate([11, 0, 0])
        cube([2, 10, 37.6], center=true);
}

mechanical_part();