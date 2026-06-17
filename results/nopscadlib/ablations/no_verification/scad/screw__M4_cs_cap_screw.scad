// Socket Head Cap Screw (M4 x 10) - single connected solid
// Requested: 4.0mm shank diameter, 8.0mm head diameter, 10.0mm overall length

$fn = 96;

// Parameters
thread_diameter_mm = 4.0;          // shank diameter
length_mm = 10.0;                  // overall length (head + shank)
head_diameter_mm = 8.0;            // head diameter
head_height_mm = 4.0;              // head height
hex_socket_across_flats_mm = 3.0;  // typical for M4
hex_socket_depth_mm = 2.5;         // typical
chamfer_mm = 0.6;                  // tip chamfer height
overlap_mm = 0.2;                  // overlap to avoid coincident faces

// Derived
shank_len_mm = max(0, length_mm - head_height_mm);
shank_r = thread_diameter_mm / 2;
head_r  = head_diameter_mm / 2;

// Hex geometry: across flats -> circumradius
hex_R = hex_socket_across_flats_mm / (2 * cos(30));

module socket_head_cap_screw() {
    // Place the whole screw so it spans z=[0..length_mm] for predictable viewing
    translate([0, 0, length_mm/2])
    difference() {
        union() {
            // Shank: z=[-length_mm/2 .. -length_mm/2 + shank_len_mm]
            if (shank_len_mm > 0)
                translate([0, 0, -length_mm/2 + shank_len_mm/2])
                    cylinder(h = shank_len_mm, r = shank_r, center = true);

            // Head: directly on top of shank with slight overlap
            translate([0, 0, -length_mm/2 + shank_len_mm + head_height_mm/2 - overlap_mm/2])
                cylinder(h = head_height_mm + overlap_mm, r = head_r, center = true);

            // Tip chamfer: attached to shank bottom with slight overlap
            if (shank_len_mm > 0 && chamfer_mm > 0)
                translate([0, 0, -length_mm/2 + chamfer_mm/2 - overlap_mm/2])
                    cylinder(
                        h = chamfer_mm + overlap_mm,
                        r1 = max(0, shank_r - chamfer_mm),
                        r2 = shank_r,
                        center = true
                    );
        }

        // Hex socket recess: cut from top of head downward
        translate([0, 0, length_mm/2 - hex_socket_depth_mm/2])
            cylinder(h = hex_socket_depth_mm + overlap_mm, r = hex_R, center = true, $fn = 6);
    }
}

socket_head_cap_screw();