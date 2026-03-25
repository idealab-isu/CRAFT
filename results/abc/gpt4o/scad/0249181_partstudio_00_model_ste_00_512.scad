module hex_cutout(size, height) {
    rotate([0, 0, 30])
    linear_extrude(height)
    polygon(points=[[0, size], [size * cos(PI/3), size * sin(PI/3)], [size * cos(2*PI/3), size * sin(2*PI/3)], 
                    [0, -size], [-size * cos(PI/3), -size * sin(PI/3)], [-size * cos(2*PI/3), -size * sin(2*PI/3)]]);
}

module triangular_web(size, height) {
    linear_extrude(height)
    polygon(points=[[0, size], [size * cos(PI/3), size * sin(PI/3)], [-size * cos(PI/3), size * sin(PI/3)]]);
}

module disk_with_features() {
    difference() {
        union() {
            // Base flange
            cylinder(h=2, r=50, $fn=64);
            // Raised boss
            translate([0, 0, 2])
            cylinder(h=3, r=30, $fn=64);
        }
        // Hexagonal cutouts
        translate([0, 0, 1])
        hex_cutout(10, 4);
        translate([20, 0, 1])
        hex_cutout(10, 4);
        translate([-20, 0, 1])
        hex_cutout(10, 4);
    }
    
    // Triangular webs
    translate([0, 0, 1])
    union() {
        for (angle = [0, 120, 240]) {
            rotate([0, 0, angle])
            triangular_web(20, 1);
        }
    }
}

disk_with_features();