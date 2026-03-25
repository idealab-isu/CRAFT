// Wing nut for M4 screw
// Targets: 4.0mm screw (clearance hole), 10.0mm across flats, 3.75mm thick
$fn = 96;

// Parameters
thread_diameter   = 4.0;   // screw major diameter
thread_clearance  = 0.2;   // clearance added to hole diameter
across_flats      = 10.0;  // hex across flats
thickness         = 3.75;  // overall thickness (Z)

wing_span         = 24.0;  // overall tip-to-tip span (X)
wing_width        = 6.0;   // wing width (Y)
wing_tip_radius   = 3.0;   // rounding at wing tips (in XY)
wing_root_radius  = 2.0;   // rounding at wing roots (in XY)

eps = 0.02;

// Derived
hex_R = across_flats / (2 * cos(30));                 // circumradius for $fn=6 cylinder
hole_r = (thread_diameter + thread_clearance) / 2;
core_half = across_flats / 2;
wing_len_each = max(0, wing_span/2 - core_half);      // length beyond hex on each side

module rounded_bar_x(len, wid, r) {
    // 2D rounded rectangle (capsule-like) along X, then extruded in Z
    // Ensures r is valid
    rr = min(r, wid/2, len/2);
    hull() {
        translate([-(len/2 - rr), 0]) circle(r=rr);
        translate([ (len/2 - rr), 0]) circle(r=rr);
    }
}

module wingnut() {
    difference() {
        union() {
            // Hex core
            cylinder(r=hex_R, h=thickness, center=true, $fn=6);

            // Two wings as a single connected rounded bar across X
            // Overlaps into the hex by wing_root_radius to guarantee connectivity
            if (wing_len_each > 0) {
                linear_extrude(height=thickness, center=true)
                    rounded_bar_x(
                        len = wing_span - 2*wing_root_radius,
                        wid = wing_width,
                        r   = wing_tip_radius
                    );
            }
        }

        // Central through-hole for M4 (clearance)
        cylinder(r=hole_r, h=thickness + 2, center=true, $fn=64);
    }
}

wingnut();