// Parameters
outer_diameter = 50;
thickness = 10;
inner_diameter = 20;

// Main radial body
module radial_main_body() {
    difference() {
        cylinder(h = thickness, d = outer_diameter, center = true);
        center_bore();
    }
}

// Center bore
module center_bore() {
    cylinder(h = thickness + 2, d = inner_diameter, center = true);
}

// Render the model
radial_main_body();