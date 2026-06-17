$fn = 96;

length = 100;
size   = 20;

module extrusion2020(len=100, s=20) {
    // 20x20 T-slot extrusion, length along Z, centered on XY.
    // One connected solid: outer body minus connected slot/cavity network + center bore.
    eps = 0.25;

    // Key dimensions (mm) - approximate common 2020 profile
    slot_open_w   = 6.2;   // opening at the face
    slot_open_d   = 2.2;   // depth of the narrow opening from the face
    slot_neck_w   = 4.4;   // neck width
    slot_neck_d   = 4.8;   // neck depth from face
    slot_cav_w    = 11.0;  // inner cavity width (T area)
    slot_cav_d    = 7.6;   // cavity depth from face

    web_th        = 2.0;   // wall/web thickness
    center_bore_d = 5.2;   // typical 2020 center bore

    // Derived positions (from dimensions)
    face_y        = s/2;
    open_center_y = face_y - slot_open_d/2;
    neck_center_y = face_y - slot_neck_d/2;
    cav_center_y  = face_y - slot_cav_d/2;

    // Core void sized so cavities overlap it (ensures connected internal void network)
    core_half = max( (s/2) - slot_cav_d + web_th, 3.0 );
    core_size = 2*core_half;

    // Build as 2D profile extruded once to avoid axis/view confusion
    difference() {
        // Outer solid
        linear_extrude(height=len, center=true, convexity=10)
            square([s, s], center=true);

        // All voids (extruded together)
        linear_extrude(height=len + 2*eps, center=true, convexity=10) {
            // Center bore
            circle(d=center_bore_d);

            // Core void (connects all four slot cavities)
            square([core_size, core_size], center=true);

            // Four T-slots (2D cutouts)
            for (a = [0:90:270]) rotate(a) {
                // Opening
                translate([0, open_center_y])
                    square([slot_open_w, slot_open_d + eps], center=true);

                // Neck
                translate([0, neck_center_y])
                    square([slot_neck_w, slot_neck_d + eps], center=true);

                // Inner cavity (overlaps core)
                translate([0, cav_center_y])
                    square([slot_cav_w, slot_cav_d + eps], center=true);
            }
        }
    }
}

extrusion2020(length, size);