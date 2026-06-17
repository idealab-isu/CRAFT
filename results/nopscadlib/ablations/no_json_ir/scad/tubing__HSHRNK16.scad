// Heatshrink sleeving (hollow tube with open ends)

// Parameters
length = 50;            // Overall length
outer_diameter = 10;    // Outer diameter
inner_diameter = 8;     // Inner diameter
material_color = "red"; // Color

$fn = 96;

// Main module
module heatshrink_sleeving() {
    // Robustness to avoid blank/degenerate geometry
    od = max(outer_diameter, 0.01);
    id = min(max(inner_diameter, 0.01), od - 0.02); // ensure wall thickness > 0
    eps = 0.2; // extend bore slightly to guarantee open ends after boolean

    color(material_color)
    difference() {
        cylinder(h = length, d = od, center = true);
        cylinder(h = length + 2*eps, d = id, center = true);
    }
}

// Example usage
heatshrink_sleeving();