// Socket head cap screw (single connected solid)
// Target: shank Ø2.5mm, length 10mm; head Ø4.5mm, height 2.5mm; hex socket recess

$fn = 96;

// Parameters (mm)
shaft_diameter_mm = 2.5;
overall_length_mm = 10;

head_diameter_mm = 4.5;
head_height_mm   = 2.5;

thread_pitch_mm  = 0.45;          // visual thread pitch
thread_depth_mm  = 0.12;          // small, for M2.5-like look
thread_length_mm = overall_length_mm;

socket_across_flats_mm = 2.0;
socket_depth_mm        = 1.5;

overlap_mm = 0.05;

// Helpers
function hex_circumradius_from_af(af) = (af/2)/cos(30);

// Simple helical thread approximation (visual)
module simple_thread(major_d, length, pitch, depth) {
    major_r = major_d/2;
    minor_r = max(0.01, major_r - depth);

    // Core
    union() {
        cylinder(h=length, r=minor_r);

        // Helical ridge
        linear_extrude(height=length, twist=360*length/pitch, slices=max(24, ceil(length/pitch)*24))
            translate([minor_r, 0, 0])
                circle(r=depth, $fn=24);
    }
}

// Screw model: head + threaded shank, with hex socket cut
module socket_head_cap_screw() {
    difference() {
        union() {
            // Shank (threaded) from z=0 to z=overall_length_mm
            simple_thread(
                major_d = shaft_diameter_mm,
                length  = thread_length_mm,
                pitch   = thread_pitch_mm,
                depth   = thread_depth_mm
            );

            // Head sits on top of shank: from z=overall_length_mm to z=overall_length_mm+head_height_mm
            translate([0, 0, overall_length_mm - overlap_mm])
                cylinder(h=head_height_mm + overlap_mm, r=head_diameter_mm/2);
        }

        // Hex socket recess cut into head from the top
        hex_r = hex_circumradius_from_af(socket_across_flats_mm);
        translate([0, 0, overall_length_mm + head_height_mm - socket_depth_mm])
            cylinder(h=socket_depth_mm + overlap_mm, r=hex_r, $fn=6);
    }
}

socket_head_cap_screw();