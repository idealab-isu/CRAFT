// PTFE Tubing Model (connected solid with hollow bore)

// Parameters
length = 100;          // mm
outer_diameter = 4;    // mm
inner_diameter = 2;    // mm

// Optional parameter for forced internal diameter
forced_inner_diameter = -1; // Set to -1 to use default inner diameter

// Resolution
$fn = 120;

// Small overlap to ensure robust boolean operations
eps = 0.2;

// Function to determine the actual inner diameter (clamped to be < outer)
function get_inner_diameter() =
    let(id = (forced_inner_diameter > 0) ? forced_inner_diameter : inner_diameter)
    min(id, outer_diameter - 2*eps);

// Main module to create the PTFE tubing
module tubing() {
    difference() {
        // Outer body (centered for consistent views)
        cylinder(h = length, d = outer_diameter, center = true);

        // Hollow bore (slightly longer to guarantee through-cut)
        cylinder(h = length + 2*eps, d = get_inner_diameter(), center = true);
    }
}

// Render the tubing
tubing();