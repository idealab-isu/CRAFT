// Parameters
thermistor_diameter = 3; // Diameter of the thermistor body in mm
thermistor_thickness = 1.5; // Thickness of the thermistor body in mm
lead_diameter = 0.5; // Diameter of the leads in mm
lead_length = 20; // Length of the leads in mm
lead_spacing = 2.5; // Spacing between the leads in mm
fillet_radius = 0.3; // Fillet radius for the body edges in mm

// Thermistor body
module thermistor_body() {
    translate([0, 0, lead_diameter/2])
        cylinder(h = thermistor_thickness, d = thermistor_diameter, $fn=50);
}

// Lead
module lead() {
    cylinder(h = lead_length, d = lead_diameter, $fn=20);
}

// Lead bend region
module lead_bend_region() {
    translate([0, 0, lead_length - 5])
        cylinder(h = 5, d = lead_diameter + 0.2, $fn=20);
}

// Lead tinning tip detail
module lead_tinning_tip_detail() {
    translate([0, 0, lead_length - 1])
        cylinder(h = 1, d = lead_diameter + 0.1, $fn=20);
}

// Small body fillet
module small_body_fillet() {
    translate([0, 0, lead_diameter/2])
        cylinder(h = thermistor_thickness, d1 = thermistor_diameter, d2 = thermistor_diameter - 2*fillet_radius, $fn=50);
}

// Body marking (simplified as a small indentation)
module body_marking() {
    translate([0, 0, lead_diameter/2 + thermistor_thickness/2])
        cylinder(h = 0.1, d = thermistor_diameter - 1, $fn=50);
}

// Complete thermistor model
module thermistor() {
    // Thermistor body with fillet
    small_body_fillet();
    // Body marking
    body_marking();
    // Leads
    translate([-lead_spacing/2, 0, 0]) {
        lead();
        lead_bend_region();
        lead_tinning_tip_detail();
    }
    translate([lead_spacing/2, 0, 0]) {
        lead();
        lead_bend_region();
        lead_tinning_tip_detail();
    }
}

// Render the thermistor
thermistor();