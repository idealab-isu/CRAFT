// Socket head cap screw (single connected solid)
// Dimensions:
// - Shank diameter: 2.0 mm
// - Head diameter: 3.8 mm
// - Head height: 2.0 mm
// - Overall length (under head): 10.0 mm

$fn = 96;

// Parameters
shank_diameter_mm = 2.0;      //[1.0:4.0:0.1]
length_mm = 10.0;             //[5.0:20.0:0.5]   // under-head length
head_diameter_mm = 3.8;       //[2.0:7.6:0.1]
head_height_mm = 2.0;         //[1.0:4.0:0.1]
hex_socket_af_mm = 1.5;       //[1.0:3.0:0.05]   // across flats
hex_socket_depth_mm = 1.2;    //[0.6:2.4:0.05]
overlap_mm = 0.2;             //[0.05:1.0:0.05]
socket_clearance_mm = 0.05;   //[0.0:0.2:0.01]

// Hex polygon points from across-flats (AF)
function hex_points_from_af(af) =
    let(R = af / sqrt(3))  // circumradius for regular hex given AF
    [ for (i = [0:5]) [ R*cos(60*i), R*sin(60*i) ] ];

module socket_head_cap_screw() {
    shank_r = shank_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Place underside of head at z=0, head extends to +head_height, shank to -length
    difference() {
        union() {
            // Head
            translate([0, 0, head_height_mm/2])
                cylinder(r=head_r, h=head_height_mm, center=true);

            // Shank (slight overlap into head to ensure connectivity)
            translate([0, 0, -length_mm/2 + overlap_mm/2])
                cylinder(r=shank_r, h=length_mm + overlap_mm, center=true);
        }

        // Hex socket cut (from top face down)
        translate([0, 0, head_height_mm - hex_socket_depth_mm/2])
            linear_extrude(height=hex_socket_depth_mm + overlap_mm, center=true)
                polygon(points=hex_points_from_af(hex_socket_af_mm + socket_clearance_mm));
    }
}

socket_head_cap_screw();