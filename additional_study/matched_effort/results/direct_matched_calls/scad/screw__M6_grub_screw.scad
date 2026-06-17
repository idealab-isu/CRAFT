$fn=96;

// M6 grub screw (set screw) approximation with hex socket.
// Dimensions (typical): M6xL, coarse pitch 1.0mm, hex socket 3mm AF, cup point.
L = 12;                 // length (mm)
d_major = 6.0;          // major diameter (mm)
pitch = 1.0;            // thread pitch (mm)
thread_depth = 0.65;    // radial thread depth (mm) (approx)
socket_af = 3.0;        // hex key size across flats (mm)
socket_depth = 3.0;     // socket depth (mm)
cup_depth = 0.8;        // cup point depth (mm)
cup_d = 3.2;            // cup point diameter (mm)

module hex_prism_af(af, h){
    // Hex prism defined by across-flats
    r = af / sqrt(3); // circumradius
    cylinder(h=h, r=r, $fn=6);
}

module helical_thread(dmaj, p, len, depth){
    // Simple helical ridge using linear_extrude twist
    // Base cylinder at minor diameter + helical triangular ridge to major.
    dmin = dmaj - 2*depth;
    turns = len / p;
    twist_deg = 360 * turns;

    union(){
        cylinder(h=len, d=dmin);
        // Ridge: a thin triangular "tooth" at radius dmin/2, extruded with twist
        linear_extrude(height=len, twist=twist_deg, slices=max(ceil(turns*40), 80), convexity=10)
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
        // Body with thread
        helical_thread(d_major, pitch, L, thread_depth);

        // Hex socket at top
        translate([0,0,L - socket_depth])
            hex_prism_af(socket_af, socket_depth + 0.2);

        // Cup point at bottom (concave)
        translate([0,0,0])
            difference(){
                // remove a spherical cap-ish using a cylinder+ sphere intersection
                // (approx cup point)
                translate([0,0,-(cup_d/2 - cup_depth)])
                    sphere(d=cup_d);
                // keep only the part that intersects the screw end region
                translate([0,0,-1])
                    cylinder(h=cup_depth+1.5, d=d_major+2);
            }
    }
}

grub_screw();