// Parameters for the LED model
module led(led_type="5mm", body_color=[1, 0, 0], lead_length=20, right_angle_bend=false) {
    led_body(led_type, body_color);
    led_rim(led_type);
    leads(led_type, lead_length, right_angle_bend);
}

// LED body module
module led_body(led_type, body_color) {
    color(body_color)
    if (led_type == "5mm") {
        cylinder(h=7, d=5, center=true);
    } else if (led_type == "3mm") {
        cylinder(h=5, d=3, center=true);
    }
}

// LED rim module
module led_rim(led_type) {
    if (led_type == "5mm") {
        translate([0, 0, 3.5])
        cylinder(h=1, d=5.5, center=true);
    } else if (led_type == "3mm") {
        translate([0, 0, 2.5])
        cylinder(h=1, d=3.5, center=true);
    }
}

// Leads module
module leads(led_type, lead_length, right_angle_bend) {
    lead_diameter = 0.5;
    lead_spacing = 2.54;
    translate([-lead_spacing/2, 0, -lead_length/2])
    lead(lead_length, lead_diameter, right_angle_bend);
    translate([lead_spacing, 0, 0])
    lead(lead_length, lead_diameter, right_angle_bend);
}

// Single lead module
module lead(lead_length, lead_diameter, right_angle_bend) {
    if (right_angle_bend) {
        lead_bend_right_angle(lead_length, lead_diameter);
    } else {
        cylinder(h=lead_length, d=lead_diameter, center=true);
        translate([0, 0, -lead_length/2])
        solder_end_detail(lead_diameter);
    }
}

// Right-angle lead bend module
module lead_bend_right_angle(lead_length, lead_diameter) {
    bend_length = 5;
    cylinder(h=lead_length - bend_length, d=lead_diameter, center=true);
    translate([0, 0, -lead_length/2 + bend_length/2])
    rotate([90, 0, 0])
    cylinder(h=bend_length, d=lead_diameter, center=true);
    translate([0, -bend_length/2, 0])
    solder_end_detail(lead_diameter);
}

// Solder end detail module
module solder_end_detail(lead_diameter) {
    translate([0, 0, -lead_diameter])
    sphere(d=lead_diameter);
}

// Example usage
led(led_type="5mm", body_color=[0, 1, 0], lead_length=20, right_angle_bend=true);