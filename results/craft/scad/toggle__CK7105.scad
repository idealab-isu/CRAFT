$fn = 96;

// Target overall body: 6.86mm diameter, 12.7mm tall
body_diameter_mm = 6.86;
body_height_mm   = 12.7;

// Visual/feature parameters (kept small and connected)
overlap_mm = 0.35; // slightly larger to guarantee manifold overlap

// Bushing + nut (typical toggle switch top hardware)
bushing_d_mm = 4.8;
bushing_h_mm = 2.2;

nut_flat_d_mm = 6.2;     // across flats
nut_h_mm      = 1.6;

// Toggle lever
lever_d_mm      = 1.6;
lever_len_mm    = 9.0;   // from pivot to tip
lever_angle_deg = 20;    // tilted like a toggle
tip_d_mm        = 2.6;
tip_h_mm        = 3.0;

// Small pivot boss on top of body
pivot_d_mm = 3.0;
pivot_h_mm = 1.2;

// Bottom terminals block (simplified) + pins
term_block_w_mm = 6.0;
term_block_d_mm = 3.2;
term_block_h_mm = 2.2;

pin_d_mm = 0.8;
pin_h_mm = 3.0;
pin_spacing_mm = 2.54;

// Helpers
module hex_prism(af, h, center=false) {
    // across-flats af => circumradius r = af / sqrt(3)
    r = af / sqrt(3);
    cylinder(r=r, h=h, center=center, $fn=6);
}

module body() {
    cylinder(d=body_diameter_mm, h=body_height_mm, center=true);
}

module top_hardware_and_pivot() {
    z_top = body_height_mm/2;

    // Bushing: bottom slightly inside body
    translate([0,0, z_top + bushing_h_mm/2 - overlap_mm])
        cylinder(d=bushing_d_mm, h=bushing_h_mm, center=true);

    // Nut: bottom slightly inside bushing top
    translate([0,0, z_top + bushing_h_mm + nut_h_mm/2 - 2*overlap_mm])
        hex_prism(nut_flat_d_mm, nut_h_mm, center=true);

    // Pivot boss: bottom slightly inside nut top
    translate([0,0, z_top + bushing_h_mm + nut_h_mm + pivot_h_mm/2 - 3*overlap_mm])
        cylinder(d=pivot_d_mm, h=pivot_h_mm, center=true);
}

module lever() {
    z_top = body_height_mm/2;

    // Pivot boss top surface (accounting for overlaps used above)
    z_pivot_top = z_top + bushing_h_mm + nut_h_mm + pivot_h_mm - 3*overlap_mm;

    // Place lever so its base end intersects the pivot boss volume
    translate([0,0, z_pivot_top - overlap_mm]) {
        rotate([0, lever_angle_deg, 0]) {
            // Shaft: shift so near end is at pivot (with overlap)
            translate([0,0, lever_len_mm/2 - overlap_mm])
                cylinder(d=lever_d_mm, h=lever_len_mm, center=true);

            // Tip: attached to far end of shaft with overlap
            translate([0,0, lever_len_mm + tip_h_mm/2 - 2*overlap_mm])
                cylinder(d=tip_d_mm, h=tip_h_mm, center=true);
        }
    }
}

module bottom_terminals() {
    z_bot = -body_height_mm/2;

    // Terminal block: top slightly inside body bottom
    translate([0,0, z_bot - term_block_h_mm/2 + overlap_mm])
        cube([term_block_w_mm, term_block_d_mm, term_block_h_mm], center=true);

    // Pins: top slightly inside terminal block bottom
    for (x = [-pin_spacing_mm, 0, pin_spacing_mm]) {
        translate([x, 0, z_bot - term_block_h_mm - pin_h_mm/2 + 2*overlap_mm])
            cylinder(d=pin_d_mm, h=pin_h_mm, center=true);
    }
}

union() {
    body();
    top_hardware_and_pivot();
    lever();
    bottom_terminals();
}