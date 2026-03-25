$fn = 96;

// Requested dimensions (mm)
thread_diameter_mm = 6.0;
length_mm          = 10.0;   // under-head length
head_diameter_mm   = 10.5;
head_height_mm     = 3.3;

// Detail controls
overlap_mm         = 0.15;
thread_relief_mm   = 0.15;   // slight relief so threads don't exceed major dia
thread_pitch_mm    = 1.0;    // visual approximation for M6
thread_depth_mm    = 0.45;   // visual approximation
thread_fn          = 24;

// Optional hex socket (kept subtle; set socket_depth_mm=0 to remove)
socket_af_mm       = 4.0;
socket_depth_mm    = 2.0;
socket_clearance_mm= 0.15;

module hex_prism(af, h, center=false) {
    // across-flats -> circumradius
    r = af/(2*cos(30));
    cylinder(r=r, h=h, $fn=6, center=center);
}

module dome_head_screw(d=6, L=10, hd=10.5, hh=3.3) {
    r_shank = d/2;
    r_head  = hd/2;

    // Place underside of head at z=0, shank extends to negative z
    z_underhead = 0;
    z_tip       = -L;

    // Dome shaping: spherical cap blended into a short cylindrical skirt
    // Choose a sphere radius that guarantees a dome within head height.
    // For a spherical cap of height hh and base radius r_head:
    // R = (r^2 + h^2) / (2h)
    R = (r_head*r_head + hh*hh) / (2*hh);
    z_sphere_center = z_underhead + hh - R;

    difference() {
        union() {
            // Shank core (minor-ish diameter)
            translate([0,0,(z_tip + z_underhead)/2])
                cylinder(r=r_shank - thread_relief_mm, h=L + overlap_mm, center=true);

            // Simple helical thread approximation (adds material, stays within major dia)
            // Thread exists along most of the shank, leaving a tiny unthreaded tip.
            thread_len = max(0, L - 0.6);
            if (thread_len > 0)
                translate([0,0,z_underhead - thread_len + 0.3])
                    linear_extrude(height=thread_len, twist=360*thread_len/thread_pitch_mm, slices=ceil(thread_len*8), convexity=10)
                        difference() {
                            circle(r=r_shank, $fn=thread_fn);
                            circle(r=max(0.01, r_shank - thread_depth_mm), $fn=thread_fn);
                        }

            // Dome head: intersection of cylinder and sphere to form a clean cap
            intersection() {
                translate([0,0,z_underhead + hh/2])
                    cylinder(r=r_head, h=hh + overlap_mm, center=true);
                translate([0,0,z_sphere_center])
                    sphere(r=R);
            }

            // Small fillet-like blend at underhead (tiny cone) to avoid a sharp edge
            blend_h = 0.35;
            translate([0,0,z_underhead - blend_h/2 + overlap_mm/2])
                cylinder(r1=r_shank, r2=r_head*0.98, h=blend_h + overlap_mm, center=true);
        }

        // Hex socket recess (optional)
        if (socket_depth_mm > 0) {
            translate([0,0,z_underhead + hh - socket_depth_mm/2])
                hex_prism(socket_af_mm + 2*socket_clearance_mm, socket_depth_mm + overlap_mm, center=true);
        }
    }
}

dome_head_screw(thread_diameter_mm, length_mm, head_diameter_mm, head_height_mm);