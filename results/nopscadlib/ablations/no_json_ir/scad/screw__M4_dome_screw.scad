$fn = 120;

// Target dimensions (mm)
shaft_diameter = 4.0;     // major diameter
shaft_length   = 10.0;    // overall length (under head + head)
head_diameter  = 7.6;
head_height    = 2.2;

// Simple thread approximation (visual)
thread_pitch   = 0.7;     // mm (approx for M4)
thread_depth   = 0.25;    // mm radial depth (visual)
thread_start_z = 0.2;     // leave a tiny unthreaded tip
thread_end_clearance = 0.3; // stop threads slightly before head

// Hex socket (optional feature; keep small and shallow)
hex_socket_af    = 2.5;   // across flats
hex_socket_depth = 1.5;

// Small overlaps to ensure watertight unions/differences
eps = 0.02;

// Derived
shaft_r = shaft_diameter/2;
head_r  = head_diameter/2;
under_head_len = shaft_length - head_height;

// 2D hex for socket (across flats = 2*apothem)
module hex2d(af){
    r = af / sqrt(3); // circumradius
    polygon([for(i=[0:5]) [r*cos(60*i), r*sin(60*i)]]);
}

// Dome head as a spherical cap with exact height and diameter at base
module dome_head_cap(){
    // Spherical cap radius that yields base radius=head_r and cap height=head_height
    // R = (a^2 + h^2) / (2h)
    a = head_r;
    h = head_height;
    R = (a*a + h*h) / (2*h);

    // Place sphere so that cap base plane is at z=0 and cap extends to z=h
    // Sphere center is at z = -(R - h)
    translate([0,0, -(R - h)])
        intersection(){
            sphere(r=R);
            // Keep only z in [0, h]
            translate([0,0, h/2])
                cube([2*(a+R), 2*(a+R), h], center=true);
        }
}

// Threaded shaft approximation using a helical triangular ridge
module threaded_shaft(){
    thread_len = max(0, under_head_len - thread_start_z - thread_end_clearance);
    turns = thread_len / thread_pitch;

    union(){
        // Core cylinder (minor diameter approx)
        cylinder(h=under_head_len, r=shaft_r - thread_depth, center=false);

        // Helical ridge
        if (thread_len > 0){
            translate([0,0, thread_start_z])
                linear_extrude(height=thread_len, twist=turns*360, slices=max(ceil(turns*24), 24), convexity=10)
                    translate([shaft_r - thread_depth, 0, 0])
                        polygon([
                            [0, -thread_pitch*0.22],
                            [thread_depth, 0],
                            [0,  thread_pitch*0.22]
                        ]);
        }
    }
}

// Full screw
module dome_head_screw(){
    union(){
        // Shaft from z=0 to z=under_head_len
        threaded_shaft();

        // Head sits on top of shaft: base plane at z=under_head_len
        translate([0,0, under_head_len - eps])
            difference(){
                dome_head_cap();

                // Hex socket recess from top down
                translate([0,0, head_height - hex_socket_depth + eps])
                    linear_extrude(height=hex_socket_depth + 2*eps, center=false, convexity=10)
                        hex2d(hex_socket_af);
            }
    }
}

dome_head_screw();