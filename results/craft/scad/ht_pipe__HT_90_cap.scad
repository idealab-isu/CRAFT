$fn = 128;

// Parameters
nominal_diameter_mm    = 90;  //[45:180:1]
outer_diameter_mm      = 90;  //[45:180:1]
wall_thickness_mm      = 3;   //[1.5:6:0.1]
cap_length_mm          = 50;  //[25:100:1]
socket_depth_mm        = 35;  //[15:70:1]
end_face_thickness_mm  = 4;   //[2:8:0.5]
clearance_mm           = 0.3; //[0.1:1:0.05]
chamfer_mm             = 1;   //[0.5:3:0.1]
overlap_mm             = 1;   //[0.5:2:0.1]
pipe_stub_length_mm    = 60;  //[30:120:1]

// Derived
od        = outer_diameter_mm;
r_od      = od/2;

r_pipe_od = nominal_diameter_mm/2;
r_pipe_id = r_pipe_od - wall_thickness_mm;

r_socket  = r_pipe_od + clearance_mm;

// External rim/lip (subtle)
rim_h      = max(1.5, wall_thickness_mm);
rim_radial = max(1.5, wall_thickness_mm);
r_rim      = r_od + rim_radial;

// Safety clamps
socket_depth = min(socket_depth_mm, cap_length_mm - end_face_thickness_mm);
end_face_t   = min(end_face_thickness_mm, cap_length_mm - 0.1);

// Cap: single coherent solid, hollow socket + closed end face
module ht90_cap() {
    difference() {
        union() {
            // Main outer body (centered)
            cylinder(h=cap_length_mm, r=r_od, center=true);

            // External rim/lip at open end (bottom), fused with overlap
            // Bottom face of main body is at z = -cap_length_mm/2
            translate([0, 0, -cap_length_mm/2 + rim_h/2 - overlap_mm/2])
                cylinder(h=rim_h + overlap_mm, r=r_rim, center=true);

            // Explicitly create a CLOSED END FACE (top disc) and overlap into body
            // Top face of main body is at z = +cap_length_mm/2
            translate([0, 0, cap_length_mm/2 - end_face_t/2 + overlap_mm/2])
                cylinder(h=end_face_t + overlap_mm, r=r_od, center=true);

            // Explicitly create a small OPEN-END RING (bottom "disc/plug" artifact fixer)
            // This is a thin collar that overlaps the body so it cannot float.
            bottom_collar_h = max(1.0, overlap_mm);
            translate([0, 0, -cap_length_mm/2 + bottom_collar_h/2 - overlap_mm/2])
                cylinder(h=bottom_collar_h + overlap_mm, r=r_od, center=true);
        }

        // Socket cavity from open end upward (leave end_face_t at top)
        // Open end plane is at z = -cap_length_mm/2
        socket_center_z = -cap_length_mm/2 + socket_depth/2 - overlap_mm/2;
        translate([0, 0, socket_center_z])
            cylinder(h=socket_depth + overlap_mm, r=r_socket, center=true);

        // Lead-in chamfer at open end (inside)
        chamfer_h = min(chamfer_mm, socket_depth);
        chamfer_center_z = -cap_length_mm/2 + chamfer_h/2 - overlap_mm/2;
        translate([0, 0, chamfer_center_z])
            cylinder(h=chamfer_h + overlap_mm,
                     r1=r_socket + chamfer_h,
                     r2=r_socket,
                     center=true);
    }
}

// Optional pipe stub (hollow), fused into socket with overlap
module ht_pipe_stub() {
    difference() {
        cylinder(h=pipe_stub_length_mm, r=r_pipe_od, center=true);
        cylinder(h=pipe_stub_length_mm + overlap_mm, r=r_pipe_id, center=true);
    }
}

// Assembly: one connected solid (cap + stub fused)
module assembly() {
    union() {
        ht90_cap();

        // Cap open end plane at z = -cap_length_mm/2
        // Place stub so its top penetrates into cap by overlap_mm (guaranteed intersection)
        translate([0, 0, -cap_length_mm/2 - pipe_stub_length_mm/2 + overlap_mm])
            ht_pipe_stub();
    }
}

assembly();