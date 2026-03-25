// Axial component sized to: [3.4, 1.75, 0.3]
// Interpreted as: body_length=3.4, body_diameter=1.75, lead_diameter=0.3
// Single connected solid (body + two leads)

$fn = 96;

// Parameters
body_length   = 3.4;   // along X
body_diameter = 1.75;  // body OD
lead_diameter = 0.3;   // lead OD

// Keep leads short so overall form matches the requested axial dimensions
lead_length_each = 0.6;     // per side (kept minimal to avoid long detached bars)
overlap = 0.05;             // small overlap to guarantee manifold union

module body() {
    rotate([0, 90, 0])
        cylinder(h=body_length, r=body_diameter/2, center=true);
}

module leads() {
    // Leads extend from each end of the body along X and overlap slightly into the body
    for (sx = [-1, 1]) {
        translate([sx * (body_length/2 + lead_length_each/2 - overlap), 0, 0])
            rotate([0, 90, 0])
                cylinder(h=lead_length_each + 2*overlap, r=lead_diameter/2, center=true);
    }
}

union() {
    body();
    leads();
}