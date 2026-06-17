$fn = 96;

// Requested main dimensions
body_diameter_mm = 6.86; //[3.43:13.72:0.01]
body_height_mm   = 12.7; //[6.35:25.4:0.01]

// Lever (actuator)
toggle_diameter_mm = 2.5; //[1.25:5:0.01]
toggle_height_mm   = 8;   //[4:16:0.01]

// Small overlap to guarantee a single connected solid
overlap_mm = 0.6; //[0.2:2:0.1]

// Derived
body_r = body_diameter_mm/2;

// Simple toggle-switch details (kept connected and dimension-driven)
bushing_d_mm = body_diameter_mm * 0.78;   // slightly smaller than body
bushing_h_mm = body_height_mm * 0.18;

nut_flat_d_mm = body_diameter_mm * 1.15;  // hex across flats
nut_h_mm      = body_height_mm * 0.12;

base_flange_d_mm = body_diameter_mm * 1.05;
base_flange_h_mm = body_height_mm * 0.10;

terminal_w_mm = body_diameter_mm * 0.22;
terminal_t_mm = body_diameter_mm * 0.10;
terminal_h_mm = body_height_mm * 0.22;
terminal_spacing_mm = body_diameter_mm * 0.28;

module hex_prism(flat_d, h, center=true) {
    // Regular hex with given across-flats distance
    // across flats = sqrt(3) * R  => R = flat_d / sqrt(3)
    cylinder(h=h, r=flat_d/sqrt(3), $fn=6, center=center);
}

module toggle_switch() {
    // Ensure a single connected solid and avoid "blank" renders by
    // keeping everything dimension-driven and centered consistently.
    union() {
        // Main body (exact requested diameter and height)
        cylinder(r=body_r, h=body_height_mm, center=true);

        // Base flange (bottom) - overlaps into body
        translate([0, 0, -body_height_mm/2 + base_flange_h_mm/2 + overlap_mm/2])
            cylinder(r=base_flange_d_mm/2, h=base_flange_h_mm, center=true);

        // Threaded bushing (top) - overlaps into body
        translate([0, 0, body_height_mm/2 - bushing_h_mm/2 - overlap_mm/2])
            cylinder(r=bushing_d_mm/2, h=bushing_h_mm, center=true);

        // Hex nut on bushing (top) - overlaps into bushing
        translate([0, 0, body_height_mm/2 + nut_h_mm/2 - overlap_mm/2])
            hex_prism(nut_flat_d_mm, nut_h_mm, center=true);

        // Toggle lever with rounded tip (connected into bushing)
        union() {
            // Shaft: bottom slightly inside bushing
            translate([0, 0, body_height_mm/2 + toggle_height_mm/2 - overlap_mm/2])
                cylinder(r=toggle_diameter_mm/2, h=toggle_height_mm, center=true);

            // Rounded tip: overlaps into shaft
            translate([0, 0, body_height_mm/2 + toggle_height_mm - overlap_mm/2])
                sphere(r=toggle_diameter_mm*0.55);
        }

        // Terminals (3) on bottom, connected into body
        for (i = [-1, 0, 1]) {
            translate([i*terminal_spacing_mm, 0,
                       -body_height_mm/2 - terminal_h_mm/2 + overlap_mm/2])
                cube([terminal_w_mm, terminal_t_mm, terminal_h_mm], center=true);
        }
    }
}

toggle_switch();