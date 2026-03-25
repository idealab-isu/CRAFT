$fn = 96;

// Requested dimensions
thread_diameter_mm = 4.0;
length_mm          = 10.0;   // shank length under head
head_diameter_mm   = 7.6;
head_height_mm     = 2.2;

// Simple hex socket (kept, but does not change outer dimensions)
drive_socket_af_mm     = 3.0;
drive_socket_depth_mm  = 1.4;

// Small overlap to guarantee a single connected solid
connection_overlap_mm = 0.2;

module dome_head_screw(
    d = thread_diameter_mm,
    L = length_mm,
    hd = head_diameter_mm,
    hh = head_height_mm,
    af = drive_socket_af_mm,
    sd = drive_socket_depth_mm,
    ov = connection_overlap_mm
) {
    r_shank = d/2;
    r_head  = hd/2;

    // Place underside of head at z=0, shank extends to -L, head extends to +hh
    difference() {
        union() {
            // Shank (cylinder)
            translate([0,0,-L/2])
                cylinder(h=L + ov, r=r_shank, center=true);

            // Dome head: spherical cap clipped to exact head height
            // Sphere center at z = hh - r_head so top is at z=hh and max diameter is hd
            intersection() {
                translate([0,0,hh - r_head])
                    sphere(r=r_head);
                translate([0,0,hh/2])
                    cylinder(h=hh + ov, r=r_head, center=true);
            }
        }

        // Hex socket cut from top, limited to socket depth
        // Hex across flats = af => circumradius = af/(2*cos(30))
        socket_r = af/(2*cos(30));
        translate([0,0,hh - sd/2])
            cylinder(h=sd + ov, r=socket_r, center=true, $fn=6);
    }
}

dome_head_screw();