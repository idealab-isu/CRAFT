$fn = 128;

// Requested dimensions
d_shank = 8.0;     // shank major diameter
d_head  = 16.0;    // head diameter
L       = 10.0;    // shank length (under head)

// Head + socket (kept typical, but fully connected and clearly recessed)
head_h        = 8.0;
socket_af     = 6.0;   // hex across flats
socket_depth  = 5.0;

// Simple visual thread approximation (helical ridge) to avoid a plain smooth shank
thread_pitch  = 1.25;
thread_height = 0.35;  // radial height of ridge
thread_turns  = L / thread_pitch;

module hex_prism(af, h){
    r = af / sqrt(3); // circumradius for regular hex
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

module threaded_shank(d_major, len, pitch, h_ridge){
    r0 = d_major/2 - h_ridge; // base radius so ridge reaches d_major
    union() {
        // core
        cylinder(r=r0, h=len);

        // helical ridge (visual thread)
        linear_extrude(height=len, twist=360*(len/pitch), slices=max(ceil(len*12), 60))
            translate([r0, 0, 0])
                circle(r=h_ridge);
    }
}

module socket_head_cap_screw(){
    difference(){
        union(){
            // threaded shank (0..L)
            threaded_shank(d_shank, L, thread_pitch, thread_height);

            // head (L..L+head_h) with slight overlap to guarantee manifold union
            translate([0,0,L - 0.2])
                cylinder(d=d_head, h=head_h + 0.2);
        }

        // hex socket cut from top of head downward
        translate([0,0,L + head_h - socket_depth])
            hex_prism(socket_af, socket_depth + 0.3);
    }
}

socket_head_cap_screw();