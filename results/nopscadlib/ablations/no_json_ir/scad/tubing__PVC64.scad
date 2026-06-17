// Parameters for the PVC aquarium tubing
outer_diameter = 20; // Outer diameter of the tube
inner_diameter = 15; // Inner diameter of the tube
length = 100;        // Length of the tube
centered = true;     // Center the tube on the origin

// Function to create the tubing body
module tubing_body() {
    cylinder(d=outer_diameter, h=length, center=centered);
}

// Function to create the hollow bore
module hollow_bore() {
    cylinder(d=inner_diameter, h=length, center=centered);
}

// Function to create the complete tubing
module tubing() {
    difference() {
        tubing_body();
        hollow_bore();
    }
}

// Render the tubing
tubing();