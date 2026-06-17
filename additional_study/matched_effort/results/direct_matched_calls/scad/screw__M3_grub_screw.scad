$fn = 96;

// Simple parametric M3 grub screw (set screw) approximation.
// Not a standards-perfect thread; uses a helical triangular thread form.

module grub_screw_M3(
    L = 6,                 // length (mm)
    d_major = 3.0,         // major diameter (mm)
    pitch = 0.5,           // thread pitch (mm)
    thread_depth = 0.18,   // radial thread depth (mm) (approx)
    hex_af = 1.5,          // hex socket across flats (mm) (common for M3)
    hex_depth = 2.0,       // socket depth (mm)
    chamfer = 0.25         // end chamfer (mm)
){
    r_major = d_major/2;
    r_minor = r_major - thread_depth;

    // Thread profile (2D) in X-Y plane, to be twisted along Z.
    // A simple triangular ridge centered around r_minor..r_major.
    module thread_profile(){
        // Place profile near +X axis; rotate_extrude with twist will sweep it.
        // Triangle points: (r_minor, -pitch/2), (r_major, 0), (r_minor, +pitch/2)
        polygon(points=[
            [r_minor, -pitch/2],
            [r_major, 0],
            [r_minor,  pitch/2]
        ]);
    }

    module helical_thread(){
        turns = L / pitch;
        linear_extrude(height=L, twist=turns*360, slices=max(ceil(turns*40), 80), convexity=10)
            thread_profile();
    }

    module core_cylinder(){
        cylinder(h=L, r=r_minor, center=false);
    }

    module end_chamfers(){
        // Chamfer both ends by subtracting cones
        // Bottom chamfer
        translate([0,0,0])
            cylinder(h=chamfer, r1=r_major+0.01, r2=max(r_major-chamfer, 0), center=false);
        // Top chamfer
        translate([0,0,L-chamfer])
            cylinder(h=chamfer, r1=max(r_major-chamfer, 0), r2=r_major+0.01, center=false);
    }

    module hex_socket_cut(){
        // Hex prism cut from top
        // Convert across-flats to circumradius: R = AF / (2*cos(30))
        R = hex_af / (2*cos(30));
        translate([0,0,L-hex_depth])
            cylinder(h=hex_depth+0.2, r=R, $fn=6);
    }

    difference(){
        union(){
            // Core + thread ridge
            core_cylinder();
            helical_thread();
        }
        // Chamfer by subtracting outside cones from a slightly larger envelope
        // Implement chamfer by intersecting with a chamfered envelope:
        // Easier: subtract nothing; instead intersect union with chamfered cylinder.
        // We'll do it via intersection here.
        // (Handled below by wrapping in intersection)
    }

    // Wrap with chamfered envelope and subtract hex socket
    difference(){
        intersection(){
            union(){
                core_cylinder();
                helical_thread();
            }
            // Chamfered envelope
            union(){
                // Main body
                cylinder(h=L, r=r_major, center=false);
                // Add chamfer volumes (as hull between radii)
                // Bottom chamfer envelope
                translate([0,0,0])
                    cylinder(h=chamfer, r1=r_major, r2=max(r_major-chamfer, 0), center=false);
                // Top chamfer envelope
                translate([0,0,L-chamfer])
                    cylinder(h=chamfer, r1=max(r_major-chamfer, 0), r2=r_major, center=false);
            }
        }
        hex_socket_cut();
    }
}

// Render a typical M3x6 grub screw
grub_screw_M3(L=6);