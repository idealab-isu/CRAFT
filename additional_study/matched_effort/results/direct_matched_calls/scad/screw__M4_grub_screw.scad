$fn=96;

// M4 grub screw (set screw), simplified but dimensionally reasonable.
// Parameters in mm.
d_major = 4.0;          // M4 major diameter
pitch   = 0.7;          // coarse pitch
len     = 8.0;          // overall length
thread_depth = 0.35;    // approximate radial thread depth
hex_af  = 2.0;          // internal hex across flats (common for M4 set screw)
hex_depth = 2.5;        // depth of hex socket
tip_cone_h = 0.8;       // slight cone at one end (dog/point-ish)
chamfer = 0.25;         // small chamfer at ends

module hex_prism_af(af, h){
    // Regular hex with given across-flats
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module helical_thread(dmaj, p, L, depth){
    // Simple triangular thread approximation via linear_extrude twist
    // Base cylinder at minor diameter + helical ridge.
    dmin = dmaj - 2*depth;
    turns = L / p;

    union(){
        // core
        cylinder(h=L, d=dmin);

        // helical ridge
        linear_extrude(height=L, twist=turns*360, slices=max(ceil(turns*40), 80), convexity=10)
            translate([dmin/2, 0, 0])
                polygon(points=[
                    [0, -p*0.22],
                    [depth, 0],
                    [0,  p*0.22]
                ]);
    }
}

module grub_screw(){
    difference(){
        union(){
            // threaded body
            helical_thread(d_major, pitch, len, thread_depth);

            // slight end chamfers by adding tiny cones then trimming later
            // (kept simple: add small chamfer cones at both ends)
            translate([0,0,0])
                cylinder(h=chamfer, d1=d_major-2*chamfer, d2=d_major);
            translate([0,0,len-chamfer])
                cylinder(h=chamfer, d1=d_major, d2=d_major-2*chamfer);

            // tip cone (one end)
            translate([0,0,0])
                cylinder(h=tip_cone_h, d1=0.6, d2=d_major-0.4);
        }

        // internal hex socket at top end
        translate([0,0,len-hex_depth])
            hex_prism_af(hex_af, hex_depth+0.2);
    }
}

grub_screw();