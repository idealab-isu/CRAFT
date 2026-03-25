module stepped_bar() {
    // Dimensions
    central_length = 0.15;
    end_length = 0.075;
    total_length = central_length + 2 * end_length;
    central_width = 0.1;
    end_width = 0.15;
    height = 0.1;
    mid_thickness = 0.12;

    // Central rectangular prism
    translate([-central_length/2, -central_width/2, -height/2])
        cube([central_length, central_width, height]);

    // End blocks
    translate([-total_length/2, -end_width/2, -height/2])
        cube([end_length, end_width, height]);
    translate([central_length/2, -end_width/2, -height/2])
        cube([end_length, end_width, height]);

    // Mid-body section
    translate([-mid_thickness/2, -end_width/2, -height/2])
        cube([mid_thickness, end_width, height]);
}

stepped_bar();