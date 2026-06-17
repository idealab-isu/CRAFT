$fn = 96;

// Socket head cap screw
// Shank Ø = 5.0 mm
// Head Ø  = 10.0 mm
// Length  = 10.0 mm (under head)

thread_diameter = 5.0;          // shank major diameter
length = 10.0;                  // under-head length
head_diameter = 10.0;           // cylindrical head diameter
head_height = 5.0;              // typical for M5 SHCS

hex_socket_af = 4.0;            // across flats (approx for M5)
hex_socket_depth = 3.0;         // socket depth

underhead_chamfer_h = 0.8;      // small under-head chamfer height
underhead_chamfer_r = 0.4;      // small under-head chamfer radial reduction

thread_minor_diameter_factor = 0.85; // visual-only thread core
thread_ridge_count = 12;
thread_ridge_width = 0.55;
thread_ridge_height = 0.25;
thread_runout_length = 1.0;

tip_chamfer_h = 0.8;            // small tip chamfer

// Structural overlap to guarantee watertight connections (1–2mm as required)
overlap = 1.2;

module hex_prism(af, h, center=false) {
    r = af / (2*cos(30)); // across-flats -> circumradius
    cylinder(h=h, r=r, $fn=6, center=center);
}

module socket_head_cap_screw() {
    shank_r_major = thread_diameter/2;
    shank_r_minor = (thread_diameter * thread_minor_diameter_factor)/2;

    // Coordinate system:
    // Under-head plane at z=0
    // Head spans z=[0, head_height]
    // Shank spans z=[-length, 0]
    difference() {
        union() {
            // Head cylinder (base slightly below z=0 to overlap collar)
            translate([0,0, head_height/2 - overlap/2])
                cylinder(h=head_height + overlap, r=head_diameter/2, center=true);

            // Under-head conical/frustum collar:
            // Ensure it overlaps BOTH head (above) and shank (below) by overlap/2 each.
            // Collar spans z=[-underhead_chamfer_h - overlap/2, +overlap/2]
            translate([0,0, (-underhead_chamfer_h/2)])
                cylinder(h=underhead_chamfer_h + overlap,
                         r1=head_diameter/2 - underhead_chamfer_r,
                         r2=shank_r_major,
                         center=true);

            // Shank core (minor diameter), extend slightly into collar to avoid any gap
            // Shank spans z=[-length, 0] but extended to z=+overlap/2
            translate([0,0, (-length/2 + overlap/4)])
                cylinder(h=length + overlap/2, r=shank_r_minor, center=true);

            // Visual thread ridges (kept within shank length; they sit on the shank core)
            for (i = [0:thread_ridge_count-1]) {
                z0 = -length + thread_runout_length;
                usable = length - thread_runout_length;
                zpos = z0 + (i + 0.5) * usable / thread_ridge_count;
                translate([0,0,zpos])
                    cylinder(h=thread_ridge_width,
                             r=shank_r_minor + thread_ridge_height,
                             center=true);
            }

            // Tip chamfer (overlaps shank end slightly)
            translate([0,0, -length + tip_chamfer_h/2])
                cylinder(h=tip_chamfer_h + overlap,
                         r1=shank_r_minor,
                         r2=max(shank_r_minor - underhead_chamfer_r, 0.01),
                         center=true);
        }

        // Hex socket recess cut into top of head (slightly deeper for clean subtraction)
        translate([0,0, head_height - hex_socket_depth/2])
            hex_prism(hex_socket_af, hex_socket_depth + overlap, center=true);
    }
}

socket_head_cap_screw();