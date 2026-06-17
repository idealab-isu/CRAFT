$fn = 96;

// M6 grub screw (set screw) - simplified but renderable
// Parameters
d = 6;                 // nominal thread diameter (mm)
pitch = 1.0;           // coarse pitch for M6 (mm)
len = 12;              // screw length (mm)
thread_depth = 0.65;   // approximate radial thread depth (mm)
hex_af = 3.0;          // hex socket across flats (mm) typical for M6 set screw
hex_depth = 3.0;       // socket depth (mm)
tip_cone_h = 1.2;      // slight cone at tip
chamfer_h = 0.6;       // chamfer at top edge

// Derived
r_major = d/2;
r_minor = r_major - thread_depth;

// Helpers
module hex_prism(af, h){
    // across flats af -> circumradius
    r = af / (2*cos(30));
    cylinder(h=h, r=r, $fn=6);
}

module helical_thread(len, r_base, depth, pitch){
    // Creates a triangular-ish thread ridge by twisting a small wedge profile
    // around the Z axis using linear_extrude with twist.
    turns = len / pitch;
    twist_deg = 360 * turns;

    // Wedge profile positioned at radius r_base
    // Profile is a small triangle in XY plane, then twisted along Z.
    linear_extrude(height=len, twist=twist_deg, slices=max(ceil(turns*40), 80), convexity=10)
        polygon(points=[
            [r_base, -pitch*0.18],
            [r_base + depth, 0],
            [r_base,  pitch*0.18]
        ]);
}

module grub_screw(){
    difference(){
        union(){
            // Core cylinder at minor diameter
            cylinder(h=len, r=r_minor);

            // Thread ridge
            helical_thread(len=len, r_base=r_minor, depth=thread_depth, pitch=pitch);

            // Top chamfer (slight)
            translate([0,0,len-chamfer_h])
                cylinder(h=chamfer_h, r1=r_major, r2=r_major-0.4);

            // Tip cone (slight point)
            cylinder(h=tip_cone_h, r1=r_major-0.2, r2=0.6);
        }

        // Hex socket
        translate([0,0,len-hex_depth])
            hex_prism(hex_af, hex_depth + 0.2);

        // Slight countersink at socket mouth
        translate([0,0,len-0.8])
            cylinder(h=0.9, r1=(hex_af/(2*cos(30)))+0.2, r2=(hex_af/(2*cos(30)))+0.6, $fn=48);
    }
}

grub_screw();