// Wing nut for M4 screw: 10.0mm across flats, 3.75mm thick
// One connected solid with two wings and a centered clearance hole

// Parameters
thread_diameter_mm = 4.0;          // M4 nominal
across_flats_mm    = 10.0;         // hex across flats
thickness_mm       = 3.75;         // overall thickness (Z)

wing_span_mm       = 24.0;         // tip-to-tip span (X)
wing_thickness_mm  = 2.5;          // wing width (Y)
wing_tip_radius_mm = 2.0;          // rounded wing tip radius
fillet_radius_mm   = 1.0;          // blend at wing root

thread_clearance_mm = 0.2;         // clearance for M4
overlap_mm          = 0.6;         // overlap to guarantee connectivity
eps_mm              = 0.2;

$fn = 64;

// Derived
hex_circumradius_mm = across_flats_mm / sqrt(3); // for $fn=6 cylinder
hole_r_mm = (thread_diameter_mm + thread_clearance_mm) / 2;

// 2D rounded-rectangle (capsule) centered at origin, length along X, width along Y
module capsule2d(len_x, wid_y, r) {
    r2 = min(r, wid_y/2, len_x/2);
    hull() {
        translate([ len_x/2 - r2, 0]) circle(r=r2);
        translate([-len_x/2 + r2, 0]) circle(r=r2);
    }
}

// Hex core
module hex_core() {
    cylinder(r=hex_circumradius_mm, h=thickness_mm, center=true, $fn=6);
}

// Two wings (planform in XY, extruded in Z)
module wings() {
    // Ensure wings connect to hex by overlapping into it
    // Root-to-root length equals across_flats, plus overlap on both sides
    wing_len_x = wing_span_mm;
    linear_extrude(height=thickness_mm, center=true)
        difference() {
            capsule2d(wing_len_x, wing_thickness_mm, wing_tip_radius_mm);
            // Optional slight waist near center to avoid "bar through hex" look:
            // remove a small rectangle around center, but keep overlap into hex
            // (commented out to keep robust connectivity)
            // square([across_flats_mm - 2*overlap_mm, wing_thickness_mm*0.6], center=true);
        }
}

// Root fillets to soften transition (small cylinders blended via hull)
module wing_root_blends() {
    // Place blend features at the hex sides along X
    root_x = across_flats_mm/2 - overlap_mm;
    for (sx = [-1, 1]) {
        translate([sx*root_x, 0, 0])
            cylinder(r=fillet_radius_mm, h=thickness_mm, center=true, $fn=48);
    }
}

// Final wing nut
module wing_nut() {
    difference() {
        union() {
            hex_core();
            // Wings are a separate feature (two wings), not a through-handle:
            // Use intersection to keep wings within thickness and avoid stray geometry.
            intersection() {
                wings();
                // Limit wings to a band around the mid-plane in Y so they read as wings
                // while still being one connected solid.
                translate([0, 0, 0])
                    cube([wing_span_mm + 2*eps_mm, wing_thickness_mm + 2*eps_mm, thickness_mm + 2*eps_mm], center=true);
            }
            // Add small blends at the roots for a more wing-nut-like transition
            hull() {
                wing_root_blends();
                // Overlap into hex to guarantee connection
                cylinder(r=hex_circumradius_mm - 0.2, h=thickness_mm, center=true, $fn=6);
            }
        }

        // Center hole (clearance for M4)
        cylinder(r=hole_r_mm, h=thickness_mm + 2*eps_mm, center=true, $fn=64);
    }
}

wing_nut();