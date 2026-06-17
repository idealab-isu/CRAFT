module h_shape_connector() {
    difference() {
        union() {
            // Left block
            translate([-7, -4.5, -1.8])
                cube([4, 9, 3.6]);
            // Right block
            translate([3, -4.5, -1.8])
                cube([4, 9, 3.6]);
            // Central web
            translate([-3, -1.5, -1.8])
                cube([6, 3, 3.6]);
        }
        // Top notch
        translate([-3, -4.5, 0.9])
            cube([6, 9, 0.9]);
        // Bottom notch
        translate([-3, -4.5, -1.8])
            cube([6, 9, 0.9]);
    }
}

h_shape_connector();