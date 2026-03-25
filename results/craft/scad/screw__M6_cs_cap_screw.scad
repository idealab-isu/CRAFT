$fn = 128;

// Socket head cap screw
// Shank diameter = 6.0 mm
// Head diameter  = 12.0 mm
// Length under head = 10.0 mm

// Parameters (mm)
shaft_d = 6.0;
head_d  = 12.0;
len_under_head = 10.0;

head_h = 6.0;          // typical for M6 SHCS
socket_af = 5.0;       // hex socket across flats (approx for M6)
socket_depth = 4.0;

pitch = 1.0;           // coarse M6 (visual)
thread_depth = 0.35;   // visual thread depth

overlap = 0.25;        // small overlap to ensure watertight unions/differences

// Derived
shaft_r = shaft_d/2;
head_r  = head_d/2;

z_head_bottom  = 0;
z_head_top     = head_h;
z_shank_top    = z_head_bottom;
z_shank_bottom = z_shank_top - len_under_head;

module hex_prism_af(af, h, center=false) {
    // Regular hex prism with across-flats = af
    r = (af/2)/cos(30);
    cylinder(r=r, h=h, $fn=6, center=center);
}

module external_thread_visual(major_d, pitch, length, depth) {
    // Visual helical ridge thread (not ISO-accurate), but connected and printable.
    major_r = major_d/2;
    minor_r = major_r - depth;

    union() {
        // Core at minor diameter
        cylinder(r=minor_r, h=length, center=false);

        // Helical ridge that reaches major diameter
        linear_extrude(
            height=length,
            twist=360*length/pitch,
            slices=max(ceil(length*16), 80),
            center=false
        )
            translate([minor_r, 0, 0])
                polygon(points=[
                    [0, -pitch*0.20],
                    [depth, 0],
                    [0,  pitch*0.20]
                ]);
    }
}

module screw() {
    difference() {
        union() {
            // Head
            translate([0, 0, z_head_bottom])
                cylinder(r=head_r, h=head_h, center=false);

            // Threaded shank (under head), overlapped slightly into head for a single connected solid
            translate([0, 0, z_shank_bottom - overlap])
                external_thread_visual(
                    major_d=shaft_d,
                    pitch=pitch,
                    length=len_under_head + overlap,
                    depth=thread_depth
                );
        }

        // Internal hex socket recess (subtracted from head)
        translate([0, 0, z_head_top - socket_depth])
            hex_prism_af(socket_af, socket_depth + overlap, center=false);

        // Small lead-in chamfer at socket opening (subtracted)
        socket_r = (socket_af/2)/cos(30);
        chamfer_h = 0.6;
        translate([0, 0, z_head_top - chamfer_h])
            cylinder(r1=socket_r + 0.4, r2=socket_r, h=chamfer_h + overlap, $fn=6, center=false);
    }
}

screw();