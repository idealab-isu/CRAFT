$fn=96;

// M5 grub screw (set screw) - simplified but dimensionally reasonable
// Parameters
d_thread = 5.0;          // nominal major diameter
pitch    = 0.8;          // M5 coarse
len      = 10.0;         // overall length
hex_af   = 2.5;          // internal hex across flats (typical for M5 set screw)
hex_depth= 3.0;          // depth of hex socket
chamfer  = 0.35;         // end chamfer size
thread_depth = 0.35;     // radial thread depth (approx)
thread_turns = len / pitch;

module hex_socket(af=2.5, depth=3.0){
    // Regular hex sized by across-flats
    r = af / (2*cos(30)); // circumradius
    linear_extrude(height=depth)
        polygon([ for(i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

module helical_thread(d=5, pitch=0.8, length=10, depth=0.35){
    // Approximate external thread using a helical triangular ridge
    // Base cylinder at minor diameter + helical ridge to major diameter
    d_minor = d - 2*depth;
    union(){
        cylinder(d=d_minor, h=length);
        // Helical ridge
        linear_extrude(height=length, twist=360*length/pitch, slices=max(ceil(12*length/pitch), 60))
            translate([d_minor/2, 0, 0])
                polygon([
                    [0, -pitch*0.22],
                    [depth, 0],
                    [0,  pitch*0.22]
                ]);
    }
}

module grub_screw(){
    difference(){
        // Body with chamfers
        union(){
            // Main threaded body
            helical_thread(d=d_thread, pitch=pitch, length=len, depth=thread_depth);

            // Chamfer both ends (add then subtract cones via hull-like union)
            // Add slight end cones to mimic chamfered ends
            cylinder(d1=d_thread-2*chamfer, d2=d_thread, h=chamfer);
            translate([0,0,len-chamfer])
                cylinder(d1=d_thread, d2=d_thread-2*chamfer, h=chamfer);
        }

        // Internal hex socket at top end
        translate([0,0,len-hex_depth])
            hex_socket(af=hex_af, depth=hex_depth+0.2);

        // Slight lead-in chamfer for socket
        translate([0,0,len-0.6])
            cylinder(d1=hex_af*1.25, d2=hex_af*1.05, h=0.6);
    }
}

grub_screw();