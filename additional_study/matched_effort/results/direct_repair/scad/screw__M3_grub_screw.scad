$fn=96;

// M3 grub screw (set screw) approximation with hex socket.
// Dimensions are typical; adjust as needed.
d_major = 3.0;          // M3 major diameter
pitch   = 0.5;          // M3 coarse pitch
len     = 6.0;          // overall length (mm)

socket_af = 1.5;        // hex socket across flats (typical for M3 set screw)
socket_depth = 2.0;     // socket depth (mm)

tip_cone_h = 0.8;       // slight cone at tip
tip_cone_d = 2.2;       // cone base diameter

// Thread approximation parameters
thread_depth = 0.18;    // radial depth of thread (mm)
thread_width = 0.28;    // tangential width of thread ridge (mm)
thread_starts = 1;

module hex_prism(af, h){
    // Regular hex with given across-flats
    r = af / (2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module helical_thread(dmaj, p, L, depth, width, starts=1){
    // Simple helical ridge thread approximation using linear_extrude twist
    // Ridge centered near major diameter, protruding slightly.
    turns = L / p;
    r_mid = dmaj/2 - depth/2;
    for(s=[0:starts-1]){
        rotate([0,0,360*s/starts])
            linear_extrude(height=L, twist=360*turns, slices=max(ceil(turns*40), 60), convexity=10)
                translate([r_mid,0,0])
                    square([depth, width], center=true);
    }
}

module grub_screw_M3(L=6){
    difference(){
        union(){
            // Core cylinder slightly under major diameter so thread ridge defines major
            cylinder(h=L, d=d_major - thread_depth*1.2);

            // Thread ridge
            helical_thread(d_major, pitch, L, thread_depth, thread_width, thread_starts);

            // Tip cone (at bottom)
            translate([0,0,0])
                cylinder(h=tip_cone_h, d1=tip_cone_d, d2=0.6);
        }

        // Hex socket at top
        translate([0,0,L - socket_depth])
            hex_prism(socket_af, socket_depth + 0.2);

        // Slight top chamfer
        translate([0,0,L-0.4])
            cylinder(h=0.5, d1=d_major+0.2, d2=d_major-0.6);
    }
}

grub_screw_M3(len);