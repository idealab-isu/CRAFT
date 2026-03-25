module stepped_bar() {
    // Define the dimensions of the segments
    segment_lengths = [0.05, 0.03, 0.04, 0.02, 0.06];
    segment_widths = [0.1, 0.15, 0.1, 0.15, 0.1];
    segment_heights = [0.1, 0.15, 0.1, 0.15, 0.1];
    
    // Initialize position
    position = 0;
    
    // Create the stepped bar
    for (i = [0 : len(segment_lengths) - 1]) {
        translate([position, 0, 0])
            cube([segment_lengths[i], segment_widths[i], segment_heights[i]], center = true);
        position += segment_lengths[i];
    }
}

// Center the object at the origin
translate([-0.1, 0, 0])
    stepped_bar();