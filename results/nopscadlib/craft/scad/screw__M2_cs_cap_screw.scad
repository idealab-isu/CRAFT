$fn = 96;

// Parameters (mm)
nominal_diameter_mm = 2.0;      // shank major diameter
length_mm = 10.0;               // under-head length
head_diameter_mm = 3.8;         // cylindrical head diameter
head_height_mm = 2.0;           // head height

socket_hex_af_mm = 1.5;         // internal hex across flats
socket_depth_mm = 1.2;          // socket depth

thread_pitch_mm = 0.4;          // visual thread pitch
thread_depth_mm = 0.12;         // visual thread depth (radial)
thread_length_mm = 10.0;        // threaded length (cap screw typically fully threaded here)

overlap_mm = 0.2;               // small overlap to ensure watertight unions/differences

// Helpers
function hex_circumradius_from_af(af) = af / sqrt(3); // for 6-sided polygon: AF = sqrt(3)*R

module socket_head_cap_screw() {
    shank_r = nominal_diameter_mm/2;
    head_r  = head_diameter_mm/2;

    // Place head on top of shank: shank spans z=[0..length], head spans z=[length..length+head_h]
    difference() {
        union() {
            // Shank (base cylinder)
            cylinder(r=shank_r, h=length_mm, center=false);

            // Head (cylindrical)
            translate([0, 0, length_mm - overlap_mm])
                cylinder(r=head_r, h=head_height_mm + overlap_mm, center=false);

            // Visual thread: helical ridge added onto shank (kept connected by union)
            // Use a triangular-ish profile extruded with twist.
            // Ridge starts slightly above bottom to avoid a razor edge.
            translate([0, 0, 0])
                linear_extrude(height=thread_length_mm, twist=360*thread_length_mm/thread_pitch_mm, slices=max(60, ceil(thread_length_mm/thread_pitch_mm)*24), center=false)
                    translate([shank_r - thread_depth_mm, 0, 0])
                        polygon(points=[
                            [0, -thread_pitch_mm*0.18],
                            [thread_depth_mm*2, 0],
                            [0,  thread_pitch_mm*0.18]
                        ]);
        }

        // Internal hex socket recess in head
        // Cut from top face downward by socket_depth
        translate([0, 0, length_mm + head_height_mm - socket_depth_mm])
            cylinder(r=hex_circumradius_from_af(socket_hex_af_mm),
                     h=socket_depth_mm + overlap_mm,
                     center=false,
                     $fn=6);
    }
}

socket_head_cap_screw();