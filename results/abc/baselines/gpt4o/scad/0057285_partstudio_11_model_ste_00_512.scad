module rounded_plate() {
    difference() {
        // Main plate with rounded corners
        offset(r=0.01) {
            square([0.18, 0.08], center=true);
        }
        // Corner cutouts
        for (x = [-0.09, 0.09])
        for (y = [-0.04, 0.04])
            translate([x, y])
                rotate(45)
                    polygon(points=[[0.005, 0], [0, 0.005], [-0.005, 0], [0, -0.005]]);
    }
}

translate([0, 0, -0.001])
    linear_extrude(height=0.001)
        rounded_plate();