module rounded_rectangular_block() {
    // Dimensions
    length = 8.0;
    width = 2.6;
    height = 1.1;
    radius = 1.3; // Large fillet radius for long edges
    end_radius = 0.55; // Slightly radiused ends

    // Main block with rounded edges
    hull() {
        // Create the four corner spheres
        translate([length/2 - end_radius, width/2 - end_radius, height/2])
            sphere(r=end_radius, $fn=64);
        translate([-length/2 + end_radius, width/2 - end_radius, height/2])
            sphere(r=end_radius, $fn=64);
        translate([length/2 - end_radius, -width/2 + end_radius, height/2])
            sphere(r=end_radius, $fn=64);
        translate([-length/2 + end_radius, -width/2 + end_radius, height/2])
            sphere(r=end_radius, $fn=64);

        // Create the four edge cylinders
        translate([0, width/2 - end_radius, height/2])
            cylinder(h=length - 2*end_radius, r=end_radius, center=true, $fn=64);
        translate([0, -width/2 + end_radius, height/2])
            cylinder(h=length - 2*end_radius, r=end_radius, center=true, $fn=64);
        translate([length/2 - end_radius, 0, height/2])
            rotate([0, 90, 0])
            cylinder(h=width - 2*end_radius, r=end_radius, center=true, $fn=64);
        translate([-length/2 + end_radius, 0, height/2])
            rotate([0, 90, 0])
            cylinder(h=width - 2*end_radius, r=end_radius, center=true, $fn=64);
    }
}

rounded_rectangular_block();