$fn=96;

// Heat-set insert (simplified) for M2.5 screw
// Outer diameter: 4.0 mm
// Length: 4.6 mm
// Internal thread: approximated as a clearance/tap hole cylinder (no helical thread)

outer_d = 4.0;
length  = 4.6;

// Typical M2.5 internal thread minor diameter is ~2.05-2.15 mm.
// Use a slightly generous hole for modeling/printing.
inner_d = 2.2;

// Simple knurl/ring features (approximation of heat-set insert texture)
ring_count = 7;
ring_depth = 0.25;     // radial depth of grooves
ring_width = 0.35;     // axial width of each groove
ring_gap   = (length - ring_count*ring_width) / (ring_count+1);

module insert_body() {
    difference() {
        // Outer body
        cylinder(d=outer_d, h=length);

        // Inner hole
        translate([0,0,-0.2])
            cylinder(d=inner_d, h=length+0.4);

        // Ring grooves
        for (i = [0:ring_count-1]) {
            z0 = ring_gap + i*(ring_width + ring_gap);
            translate([0,0,z0])
                cylinder(d=outer_d + 0.02, h=ring_width); // subtract full OD slice
            // Add back a slightly smaller OD to create a groove
            // (implemented by subtracting a larger cylinder below)
        }

        // Create grooves by subtracting a slightly larger cylinder over each ring band
        for (i = [0:ring_count-1]) {
            z0 = ring_gap + i*(ring_width + ring_gap);
            translate([0,0,z0])
                cylinder(d=outer_d + 2*ring_depth, h=ring_width);
        }

        // Small lead-in chamfers (approximated by conical cuts)
        translate([0,0,-0.01])
            cylinder(d1=inner_d+0.6, d2=inner_d, h=0.5);
        translate([0,0,length-0.49])
            cylinder(d1=inner_d, d2=inner_d+0.6, h=0.5);
    }
}

insert_body();