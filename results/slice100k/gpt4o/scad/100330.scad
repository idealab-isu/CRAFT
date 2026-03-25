module dog_bone_link_plate() {
    difference() {
        union() {
            // Left rounded-end tab
            translate([-15.95, 0, 0])
            union() {
                cylinder(h=5.5, r=15.95, $fn=64);
                translate([-15.95, -15.95, 0])
                cube([31.9, 31.9, 5.5]);
            }
            
            // Right rounded-end tab
            translate([15.95, 0, 0])
            union() {
                cylinder(h=5.5, r=15.95, $fn=64);
                translate([-15.95, -15.95, 0])
                cube([31.9, 31.9, 5.5]);
            }
            
            // Central web
            translate([-15.95, -5, 0])
            cube([31.9, 10, 5.5]);
        }
        
        // Left square through-hole
        translate([-15.95, 10, -1])
        cube([5, 5, 7.5]);
        
        // Right square through-hole
        translate([10.95, 10, -1])
        cube([5, 5, 7.5]);
        
        // Left rectangular recess
        translate([-15.95, -5, 0])
        cube([5, 10, 1]);
        
        // Right rectangular recess
        translate([10.95, -5, 0])
        cube([5, 10, 1]);
    }
}

dog_bone_link_plate();