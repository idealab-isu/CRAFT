// Parameters
thread_diameter_mm = 8.0; //[4.0:16.0:0.5]
length_mm = 10.0; //[5.0:40.0:0.5]              // shank length (under head)
head_diameter_mm = 16.0; //[8.0:32.0:0.5]
head_height_mm = 8.0; //[4.0:16.0:0.5]
socket_af_mm = 6.0; //[3.0:12.0:0.5]            // hex across flats
socket_depth_mm = 4.0; //[2.0:10.0:0.5]
tip_chamfer_height_mm = 1.0; //[0.0:3.0:0.25]
overlap_mm = 0.8; //[0.2:2.0:0.1]
washer_enabled = 0; //[0:1:1]
washer_outer_diameter_mm = 16.0; //[10.0:32.0:0.5]
washer_thickness_mm = 1.6; //[0.0:4.0:0.2]
washer_hole_clearance_mm = 0.6; //[0.2:1.5:0.1]

$fn = 96;

// Helpers
function hex_circumradius_from_af(af) = af / (2*cos(30)); // r such that across-flats = af

// Socket head cap screw (one connected solid)
module socket_head_cap_screw() {
    head_r  = head_diameter_mm/2;
    shank_r = thread_diameter_mm/2;

    // Coordinate system: underside of head at z=0, head extends +Z, shank extends -Z
    head_z0 = 0;
    head_z1 = head_height_mm;
    shank_z0 = -length_mm;
    shank_z1 = 0;

    difference() {
        union() {
            // Head (connected to shank at z=0)
            translate([0,0,(head_z0+head_z1)/2])
                cylinder(r=head_r, h=head_height_mm, center=true);

            // Shank (threaded portion approximated as cylinder)
            translate([0,0,(shank_z0+shank_z1)/2])
                cylinder(r=shank_r, h=length_mm, center=true);

            // Tip chamfer (kept connected by overlap into shank)
            if (tip_chamfer_height_mm > 0)
                translate([0,0, shank_z0 + tip_chamfer_height_mm/2 + overlap_mm/2])
                    cylinder(r1=shank_r, r2=0, h=tip_chamfer_height_mm + overlap_mm, center=true);
        }

        // Hex socket recess (subtracted from top of head; recessed, not floating)
        socket_r = hex_circumradius_from_af(socket_af_mm);
        socket_depth = min(socket_depth_mm, head_height_mm - 0.2);
        translate([0,0, head_z1 - socket_depth/2])
            cylinder(r=socket_r, h=socket_depth + 2*overlap_mm, center=true, $fn=6);
    }
}

// Optional washer (kept connected if enabled)
module washer_connected() {
    if (washer_enabled) {
        // Washer sits directly under head, overlapping slightly into head to ensure connectivity
        washer_z = -washer_thickness_mm/2 + overlap_mm/2;
        difference() {
            translate([0,0,washer_z])
                cylinder(r=washer_outer_diameter_mm/2, h=washer_thickness_mm, center=true);
            translate([0,0,washer_z])
                cylinder(r=(thread_diameter_mm + washer_hole_clearance_mm)/2,
                         h=washer_thickness_mm + 2*overlap_mm, center=true);
        }
    }
}

union() {
    socket_head_cap_screw();
    washer_connected();
}