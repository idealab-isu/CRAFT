module u_channel() {
    difference() {
        // Main block
        union() {
            // Base block
            cube([100, 50, 20], center=true);
            // Side walls
            translate([-50, -25, 0])
                linear_extrude(height=50)
                offset(r=2)
                polygon(points=[[0,0], [0,50], [10,50], [10,0]]);
            translate([40, -25, 0])
                linear_extrude(height=50)
                offset(r=2)
                polygon(points=[[0,0], [0,50], [10,50], [10,0]]);
        }
        // Central pocket
        translate([-40, -20, 0])
            cube([80, 40, 20], center=false);
        // Bottom notch
        translate([-30, -25, -10])
            cube([60, 50, 10], center=false);
    }
}

u_channel();