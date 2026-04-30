$fn = 64;

// Define the body of the axial component
module axial_body() {
    cylinder(h = 0.55, d = 2, center = true);
}

// Define the leads of the axial component
module lead() {
    cylinder(h = 10, d = 0.2, center = true);
}

// Assemble the axial component with leads
module axial_component() {
    union() {
        axial_body();
        translate([0, 0, -5.275]) lead();
        translate([0, 0, 5.275]) lead();
    }
}

// Render the axial component
axial_component();