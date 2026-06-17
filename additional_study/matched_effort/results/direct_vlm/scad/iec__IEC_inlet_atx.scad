$fn=96;

// IEC C14 panel inlet module (ATX style)
// Faceplate: 40.0mm x 27.0mm
// One connected solid: faceplate + rear housing + rear terminals (overlapped into housing)
// Front face includes recognizable IEC C14 geometry: outer opening + inner step + 3-pin cavities (2 line/neutral + earth)

module iec_c14_inlet(
    // Faceplate (overall)
    plate_w=40.0,
    plate_h=27.0,
    plate_t=3.0,
    corner_r=2.2,

    // Rear body (housing)
    body_w=30.0,
    body_h=22.0,
    body_d=22.0,
    body_corner_r=1.6,

    // Front socket opening (outer cavity)
    socket_w=28.0,
    socket_h=20.0,
    socket_r=2.0,
    socket_depth=2.4,

    // Inner step cavity (deeper, smaller) to resemble IEC inlet profile
    inner_w=24.0,
    inner_h=16.0,
    inner_r=1.6,
    inner_depth=8.0,

    // Pin cavities on front face (IEC C14: 2 vertical + 1 earth)
    blade_hole_w=2.2,     // width of each blade slot
    blade_hole_h=6.8,     // height of each blade slot (vertical)
    blade_hole_r=0.6,
    blade_pitch=10.0,     // spacing between L and N
    blade_row_y=-1.0,     // slightly below center

    earth_hole_w=6.6,     // earth slot (horizontal)
    earth_hole_h=2.2,
    earth_hole_r=0.6,
    earth_row_y=5.2,      // above center

    pin_hole_depth=plate_t + socket_depth + 0.8, // cut through plate and into cavity

    // Rear terminals (ATX style quick-connect tabs)
    tab_w=6.3,
    tab_t=0.8,
    tab_l=12.0,
    tab_pitch=10.0,
    tab_row_y=0.0,
    tab_overlap=1.4,      // overlap into body to ensure connectivity

    // Optional rear strain-relief / terminal block bump (still one solid)
    block_w=body_w-4.0,
    block_h=body_h-6.0,
    block_d=6.0,
    block_overlap=1.0,

    // Mounting holes
    hole_d=3.2,
    hole_edge_x=4.0,
    hole_edge_y=4.0
){
    // ---------- helpers ----------
    module rrect2d(w,h,r){
        rr = min(r, min(w,h)/2);
        hull(){
            for (sx=[-1,1], sy=[-1,1])
                translate([sx*(w/2-rr), sy*(h/2-rr)])
                    circle(r=rr);
        }
    }

    module rrect3d(w,h,r,t,center=false){
        linear_extrude(height=t, center=center)
            rrect2d(w,h,r);
    }

    // Z reference:
    // Front face spans z = 0 .. plate_t
    // Rear extends to negative Z

    difference(){
        union(){
            // Faceplate (40 x 27)
            rrect3d(plate_w, plate_h, corner_r, plate_t, center=false);

            // Rear body (connected to plate)
            translate([0,0,-body_d])
                rrect3d(body_w, body_h, body_corner_r, body_d, center=false);

            // Rear terminal block bump (connected; overlaps into body)
            translate([0,0,-body_d - block_d + block_overlap])
                rrect3d(block_w, block_h, body_corner_r, block_d, center=false);

            // Rear quick-connect tabs (connected by overlap into body)
            // Place tabs centered in X, protruding further rearward than body.
            for (i=[-1,0,1]){
                x = (i==0) ? 0 : (i>0 ? tab_pitch : -tab_pitch);
                translate([x, tab_row_y, -body_d - tab_l/2 + tab_overlap/2])
                    cube([tab_w, tab_t, tab_l + tab_overlap], center=true);
            }
        }

        // Front socket outer cavity (rounded rectangle)
        translate([0,0,plate_t - socket_depth])
            rrect3d(socket_w, socket_h, socket_r, socket_depth + 0.25, center=false);

        // Inner step cavity (deeper, smaller)
        translate([0,0,plate_t - inner_depth])
            rrect3d(inner_w, inner_h, inner_r, inner_depth + 0.25, center=false);

        // IEC C14 pin cavities (recognizable 3-slot pattern)
        // L and N: two vertical slots
        for (sx=[-1,1]){
            translate([sx*(blade_pitch/2), blade_row_y, plate_t - pin_hole_depth])
                linear_extrude(height=pin_hole_depth + 0.25)
                    rrect2d(blade_hole_w, blade_hole_h, blade_hole_r);
        }

        // Earth: horizontal slot above
        translate([0, earth_row_y, plate_t - pin_hole_depth])
            linear_extrude(height=pin_hole_depth + 0.25)
                rrect2d(earth_hole_w, earth_hole_h, earth_hole_r);

        // Mounting holes (4)
        for (sx=[-1,1], sy=[-1,1]){
            translate([sx*(plate_w/2 - hole_edge_x), sy*(plate_h/2 - hole_edge_y), -0.25])
                cylinder(d=hole_d, h=plate_t + 0.8, center=false);
        }
    }
}

// Render
iec_c14_inlet();