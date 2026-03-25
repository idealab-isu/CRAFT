// M6 Grub (Set) Screw (DIN 916 style): headless, external M6x1 thread, internal hex socket, cone point
// One connected solid (thread + core + point union, socket subtracted)

$fn = 96;

// Parameters
length_mm = 12;                 //[6:24:1]
thread_diameter_mm = 6;         //[3:12:1]  // major diameter
thread_pitch_mm = 1;            //[0.5:1.75:0.25] // M6 coarse = 1.0
hex_socket_af_mm = 3;           //[2:5:0.5] // typical M6 grub: 3mm
hex_socket_depth_mm = 3;        //[1.5:6:0.5]
tip_cone_height_mm = 1.5;       //[0.5:4:0.25]
tip_flat_radius_mm = 0.15;      //[0.0:1.5:0.05] // near-point
overlap_mm = 0.6;               //[0.2:2:0.1]

// Derived (ISO metric 60° thread approx.)
thread_major_radius_mm = thread_diameter_mm/2;
thread_depth_mm = 0.6134 * thread_pitch_mm;                 // radial depth (approx)
thread_minor_radius_mm = thread_major_radius_mm - thread_depth_mm;

// Small truncations to avoid razor edges / improve manifoldness
crest_trunc_mm = 0.10 * thread_pitch_mm;
root_trunc_mm  = 0.10 * thread_pitch_mm;

// 2D thread profile (one pitch tall in Y, radial thickness in X), swept helically
module thread_profile_2d(pitch, r_major, r_minor) {
    // Create a trapezoidal/V-ish ridge with slight truncation at crest/root
    // X=radial, Y=axial (within one pitch)
    h = pitch;
    t = r_major - r_minor;

    y0 = 0;
    y1 = h*0.5 - crest_trunc_mm;
    y2 = h*0.5 + crest_trunc_mm;
    y3 = h;

    // Root truncation keeps ridge from pinching at the core
    xr = max(0, root_trunc_mm * 0.5);
    polygon(points=[
        [xr, y0],
        [t,  y1],
        [t,  y2],
        [xr, y3]
    ]);
}

// External thread ridge added onto a minor-diameter core
module external_thread(length, pitch, r_major, r_minor) {
    turns = length / pitch;
    translate([0, 0, -length/2])
        linear_extrude(
            height=length,
            twist=turns*360,
            slices=max(ceil(turns*60), 120),
            convexity=10
        )
            translate([r_minor, 0, 0])
                thread_profile_2d(pitch, r_major, r_minor);
}

// Hex socket cutter (AF across flats)
module hex_socket_cutter(af, depth) {
    r_hex = (af/2)/cos(30); // circumradius for given across-flats
    cylinder(r=r_hex, h=depth, center=true, $fn=6);
}

module grub_screw() {
    // Ensure no "head": body is purely threaded cylinder with socket and point
    difference() {
        union() {
            // Core cylinder at minor diameter (continuous body under thread)
            cylinder(r=thread_minor_radius_mm, h=length_mm, center=true);

            // Add external helical thread ridge up to major diameter
            external_thread(length_mm, thread_pitch_mm, thread_major_radius_mm, thread_minor_radius_mm);

            // Cone point at bottom end (connected with overlap)
            translate([0, 0, -length_mm/2 - tip_cone_height_mm/2 + overlap_mm])
                cylinder(
                    r1=thread_major_radius_mm - crest_trunc_mm,
                    r2=tip_flat_radius_mm,
                    h=tip_cone_height_mm,
                    center=true
                );
        }

        // Internal hex socket cut from the top end (slight overlap into body)
        translate([0, 0, length_mm/2 - hex_socket_depth_mm/2 + overlap_mm/2])
            hex_socket_cutter(hex_socket_af_mm, hex_socket_depth_mm + overlap_mm);
    }
}

grub_screw();