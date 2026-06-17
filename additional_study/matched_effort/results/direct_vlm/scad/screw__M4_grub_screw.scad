$fn = 128;

// M4 grub screw (set screw) with external threads + hex socket + cup point
// Default length L=6mm (common sizes: 3,4,6,8,10,12)

d_major = 4.0;          // M4 major diameter
pitch   = 0.7;          // M4 coarse pitch
L       = 6.0;          // overall length

// Thread profile (approx ISO metric 60°)
thread_depth = 0.38;    // ~0.54*pitch; slightly reduced for robustness
d_minor = d_major - 2*thread_depth;

chamfer = 0.35;         // end chamfer height

socket_af    = 2.0;     // hex key size (M4 set screw)
socket_depth = 2.2;     // socket depth

tip_cup   = true;       // cup-point style
cup_d     = 2.6;        // cup diameter
cup_depth = 0.6;        // cup depth

eps = 0.02;

module hex_prism(af, h){
    r = af / sqrt(3); // circumradius for across-flats = af
    linear_extrude(height=h)
        polygon([ for(i=[0:5]) [ r*cos(60*i), r*sin(60*i) ] ]);
}

module chamfered_cylinder(d, h, c){
    c2 = min(c, h/2);
    hull(){
        translate([0,0,0])       cylinder(d=d-2*c2, h=eps);
        translate([0,0,c2])      cylinder(d=d,       h=h-2*c2);
        translate([0,0,h-eps])   cylinder(d=d-2*c2, h=eps);
    }
}

// Helical external thread (approx) using linear_extrude twist of a triangular tooth
module metric_thread_external(dmaj, dmin, p, len){
    rmaj = dmaj/2;
    rmin = dmin/2;
    depth = rmaj - rmin;

    // Tooth width along Z within one pitch (keep < p to avoid self-intersection)
    w = 0.55*p;

    // Build a ring of triangular teeth and twist it along length
    // The 2D profile is in (radius, z) plane; we revolve it around Z.
    linear_extrude(height=len, twist=360*len/p, slices=max(ceil(len*24/p), 60), convexity=10)
        rotate([0,0,0])
            polygon([
                [rmin, -w/2],
                [rmaj,  0   ],
                [rmin,  w/2]
            ]);
}

module grub_screw_M4(L=6){
    difference(){
        union(){
            // Core cylinder (minor diameter) with chamfers
            chamfered_cylinder(d_minor, L, chamfer);

            // External thread added on top of core (connected solid)
            // Slightly inset from ends to preserve chamfers
            thread_len = max(L - 2*chamfer, pitch);
            translate([0,0,chamfer])
                metric_thread_external(d_major, d_minor, pitch, thread_len);
        }

        // Hex socket cut from top face
        translate([0,0, L - socket_depth - eps])
            hex_prism(socket_af, socket_depth + 2*eps);

        // Cup point cut into bottom face
        if (tip_cup){
            translate([0,0,0])
                cylinder(d1=cup_d, d2=0.6, h=cup_depth + eps);
        }
    }
}

grub_screw_M4(L);