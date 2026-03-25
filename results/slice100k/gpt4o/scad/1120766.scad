module cross_hub() {
    // Central cylinder
    cylinder(h=6.3, d=6.3, $fn=64);
    
    // Rectangular prismatic lugs
    translate([-5.85, -1.575, -3.15])
        cube([11.7, 3.15, 6.3]);
    translate([-1.575, -5.85, -3.15])
        cube([3.15, 11.7, 6.3]);
}

cross_hub();