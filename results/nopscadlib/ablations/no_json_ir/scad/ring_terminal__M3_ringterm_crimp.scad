// Parameters
terminal_type = "crimp"; // Options: "crimp", "bent"
ring_diameter = 20;      // Outer diameter of the ring pad
hole_diameter = 5;       // Diameter of the central bolt hole
barrel_length = 15;      // Length of the crimp barrel
barrel_diameter = 8;     // Outer diameter of the crimp barrel
bent_length = 20;        // Length of the bent tongue
bent_width = 10;         // Width of the bent tongue
neck_length = 5;         // Length of the transition neck
neck_width = 6;          // Width of the transition neck

// Added/derived parameters
pad_thickness = 2;
part_thickness = pad_thickness; // keep consistent thickness for pad/neck/tongue
overlap = 0.6;                  // small overlap to guarantee connectivity
$fn = 96;

// Main assembly (single connected solid with a hole)
module ring_terminal_assembly() {
    difference() {
        union() {
            ring_pad_solid();
            wire_termination_solid();
        }
        // Central bolt hole through the pad
        translate([0, 0, -1])
            cylinder(h = pad_thickness + 2, d = hole_diameter);
    }
}

// Ring pad (solid; hole cut in assembly)
module ring_pad_solid() {
    cylinder(h = pad_thickness, d = ring_diameter);
}

// Wire termination section connected to pad edge via neck
module wire_termination_solid() {
    // Place neck so its near end overlaps into the pad edge
    // Pad spans z=[0..pad_thickness], neck is centered at z=pad_thickness/2
    // Pad radius = ring_diameter/2, neck extends along +Y
    translate([0, ring_diameter/2 + neck_length/2 - overlap, pad_thickness/2])
        transition_neck_solid();

    // Attach termination to far end of neck (also overlapping slightly)
    if (terminal_type == "crimp") {
        // Barrel axis along +Y, centered at pad mid-thickness
        translate([0,
                   ring_diameter/2 + neck_length - overlap + barrel_length/2,
                   pad_thickness/2])
            crimp_barrel_solid();
    } else if (terminal_type == "bent") {
        translate([0,
                   ring_diameter/2 + neck_length - overlap + bent_length/2,
                   pad_thickness/2])
            bent_tongue_solid();
    }
}

// Transition neck (rectangular strap)
module transition_neck_solid() {
    cube([neck_width, neck_length, part_thickness], center = true);
}

// Crimp barrel (tube-like barrel with inner bore)
module crimp_barrel_solid() {
    inner_d = max(0.1, barrel_diameter - 2.0); // simple wall thickness ~1mm
    rotate([90, 0, 0])  // make cylinder axis along Y
        difference() {
            cylinder(h = barrel_length, d = barrel_diameter, center = true);
            cylinder(h = barrel_length + 2, d = inner_d, center = true);
        }
}

// Bent tongue (flat strap)
module bent_tongue_solid() {
    cube([bent_width, bent_length, part_thickness], center = true);
}

// Render
ring_terminal_assembly();