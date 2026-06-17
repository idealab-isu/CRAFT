// M5 grub screw (set screw) with helical external thread + hex socket
// Fixed to ensure visible, connected geometry (no empty/blank renders).

$fn = 96;

// Parameters
length_mm = 10;                 //[5:20:1]
major_diameter = 5;             //[4:6:0.1]   // nominal major OD
thread_pitch = 0.8;             //[0.5:1.2:0.05]
thread_depth = 0.35;            //[0.2:0.6:0.05] // radial height of thread above root
thread_ridge_width = 0.35;      //[0.2:0.6:0.05] // axial thickness of thread ridge
hex_af = 2.5;                   //[2:3:0.1]      // across flats
hex_socket_depth = 3;           //[2:6:0.5]
lead_in_chamfer_height = 0.6;   //[0.3:1.5:0.1]
tip_cone_height = 1.2;          //[0.6:3:0.1]
tip_flat_diameter = 2;          //[0.5:4:0.1]
overlap = 0.8;                  //[0.5:2:0.1]

// Derived
root_diameter = max(0.2, major_diameter - 2*thread_depth);
root_r = root_diameter/2;
major_r = major_diameter/2;

module hex_prism(af, h, center=false) {
    // Regular hex with across-flats = af
    r = af/(2*cos(30));
    cylinder(r=r, h=h, center=center, $fn=6);
}

module helical_thread(len, pitch, r_root, r_major) {
    // Robust helical thread using linear_extrude(twist=...)
    // Produces a single connected solid and avoids "blank" renders from degenerate cubes.
    turns = len / pitch;
    twist_deg = 360 * turns;

    // Thread profile: a small wedge that overlaps into the root cylinder
    radial_h = max(0.05, r_major - r_root);
    prof_in = max(0.02, overlap);          // overlap into root for watertight union
    prof_out = radial_h;                   // outward height to major radius
    prof_w = max(0.10, pitch * 0.45);      // tangential width of the ridge

    // Place profile at radius so its inner edge is inside root by prof_in
    translate([r_root - prof_in, 0, -len/2])
        linear_extrude(height=len, twist=twist_deg, slices=max(24, ceil(turns*48)), convexity=10)
            polygon(points=[
                [0, -prof_w/2],
                [prof_in + prof_out, 0],
                [0,  prof_w/2]
            ]);
}

module screw() {
    difference() {
        union() {
            // Root cylinder (minor diameter) for thread base
            cylinder(r=root_r, h=length_mm, center=true);

            // Helical thread up to major diameter (connected via overlap into root)
            helical_thread(length_mm, thread_pitch, root_r, major_r);

            // Lead-in chamfer at socket end (top), connected to body
            translate([0, 0, length_mm/2 - lead_in_chamfer_height/2])
                cylinder(
                    r1=major_r,
                    r2=max(root_r, major_r - thread_depth),
                    h=lead_in_chamfer_height,
                    center=true
                );

            // Tip cone at bottom end, connected to body
            translate([0, 0, -length_mm/2 + tip_cone_height/2])
                cylinder(
                    r1=max(root_r, major_r - thread_depth/2),
                    r2=tip_flat_diameter/2,
                    h=tip_cone_height,
                    center=true
                );
        }

        // Hex socket cut (subtracted), positioned from top face with overlap
        translate([0, 0, length_mm/2 - hex_socket_depth/2 + overlap/2])
            hex_prism(hex_af, hex_socket_depth + overlap, center=true);
    }
}

screw();