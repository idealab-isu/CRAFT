$fn = 64;

// Parameters
faceplate_width = 86; //[60:172:1]
faceplate_height = 86; //[60:172:1]
faceplate_thickness = 3; //[2:6:0.5]
overall_depth = 28; //[18:56:1]
edge_fillet_radius = 2; //[0:6:0.5]

pin_hole_offset_x = 0; //[-3:3:0.5]
pin_hole_offset_y = 0; //[-3:3:0.5]

live_neutral_slot_spacing = 22.2; //[18:30:0.1]
earth_slot_offset_y = 11.1; //[8:16:0.1]
ln_slot_offset_y = 11.1; //[8:16:0.1]

ln_slot_width_y = 4.5; //[3.5:7:0.1]
ln_slot_height_x = 7; //[5:9:0.1]
earth_slot_width_x = 4.5; //[3.5:7:0.1]
earth_slot_height_y = 8.5; //[6:11:0.1]

pin_aperture_depth = 8; //[5:14:0.5]

mounting_screw_spacing_y = 60.3; //[45:80:0.1]
mounting_hole_diameter = 3.6; //[3:5:0.1]
counterbore_diameter = 7.5; //[6:12:0.1]
counterbore_depth = 2; //[1:4:0.1]

back_hollow_wall_thickness = 2.5; //[1.5:5:0.1]
back_hollow_front_keep = 1.5; //[0.8:4:0.1]
cavity_relief_width = 50; //[30:80:1]
cavity_relief_height = 50; //[30:80:1]
cavity_relief_depth_extra = 2; //[1:6:0.5]

top_entry_relief_width = 78; //[60:86:1]
top_entry_relief_height = 13; //[8:20:0.5]

overlap = 1; //[0.5:2:0.1]

// ---------- Helpers ----------
module rounded_rect_2d(x, y, r) {
    rr = min(r, x/2, y/2);
    offset(r=rr) square([x-2*rr, y-2*rr], center=true);
}

module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            rounded_rect_2d(x, y, r);
}

module slot_cut(size=[7,4.5,8], r=1.2) {
    x=size[0]; y=size[1]; z=size[2];
    rr = min(r, x/2, y/2);
    linear_extrude(height=z, center=true)
        rounded_rect_2d(x, y, rr);
}

// ---------- Main solid ----------
module socket_solid() {
    body_depth = overall_depth - faceplate_thickness;

    // Z references (front face at z=0)
    z_face_center = faceplate_thickness/2;
    z_face_front  = 0;
    z_face_back   = faceplate_thickness;

    union() {
        // Faceplate: front at z=0
        translate([0,0,z_face_center])
            rounded_rect_prism([faceplate_width, faceplate_height, faceplate_thickness],
                               r=edge_fillet_radius, center=true);

        // Back body: fused into faceplate with overlap
        translate([0,0,faceplate_thickness + body_depth/2 - overlap/2])
            rounded_rect_prism([faceplate_width-2, faceplate_height-2, body_depth + overlap],
                               r=max(0, edge_fillet_radius-0.5), center=true);

        // ---------- FIX: Orange "insert/bars" made as ONE connected frame ----------
        // This resolves:
        // - top horizontal bar floating (front view)
        // - bottom horizontal bar floating (back view)
        // - left/right vertical bars floating (side views)
        // - faceplate/insert perimeter not connected
        //
        // Strategy: create a shallow raised rectangular frame on the FRONT face,
        // and push it slightly INTO the faceplate by 'overlap' so it intersects.

        frame_outer_w = faceplate_width - 2*edge_fillet_radius - 4;   // keep inside rounded corners
        frame_outer_h = faceplate_height - 2*edge_fillet_radius - 4;
        frame_band    = 12;                                           // bar thickness (in X/Y)
        frame_t       = 2;                                            // raised thickness (Z)
        frame_r       = 1.2;

        // Ensure inner opening stays valid
        frame_inner_w = max(1, frame_outer_w - 2*frame_band);
        frame_inner_h = max(1, frame_outer_h - 2*frame_band);

        // Place on front, intersecting faceplate by 'overlap'
        // Front of frame at z=0, but sunk in by overlap to guarantee union.
        z_frame_center = (frame_t/2) - overlap;

        translate([0,0,z_frame_center])
        difference() {
            // Outer
            rounded_rect_prism([frame_outer_w, frame_outer_h, frame_t + overlap],
                               r=frame_r, center=true);
            // Inner cutout (slightly deeper to avoid coplanar faces)
            translate([0,0,0])
                rounded_rect_prism([frame_inner_w, frame_inner_h, frame_t + overlap + 0.2],
                                   r=max(0, frame_r-0.6), center=true);
        }
    }
}

// ---------- Subtractions (holes/cavities) ----------
module socket_cuts() {
    body_depth = overall_depth - faceplate_thickness;

    // Plug apertures: UK layout (earth at top, L/N below)
    z_slot_center = pin_aperture_depth/2; // measured from front face z=0 into model

    // Earth (vertical slot) at +Y
    translate([pin_hole_offset_x,
               pin_hole_offset_y + earth_slot_offset_y,
               z_slot_center])
        slot_cut([earth_slot_width_x, earth_slot_height_y, pin_aperture_depth + overlap],
                 r=min(earth_slot_width_x, earth_slot_height_y)/4);

    // Neutral (left) and Live (right): horizontal slots at -Y
    for (sx = [-live_neutral_slot_spacing/2, live_neutral_slot_spacing/2]) {
        translate([pin_hole_offset_x + sx,
                   pin_hole_offset_y - ln_slot_offset_y,
                   z_slot_center])
            slot_cut([ln_slot_height_x, ln_slot_width_y, pin_aperture_depth + overlap],
                     r=min(ln_slot_width_y, ln_slot_height_x)/4);
    }

    // Mounting screw holes (two vertical screws)
    screw_y = mounting_screw_spacing_y/2;
    screw_r = mounting_hole_diameter/2;
    cb_r = counterbore_diameter/2;

    // Through hole depth: through faceplate and slightly into body
    through_h = faceplate_thickness + back_hollow_front_keep + overlap;

    for (sy = [-screw_y, screw_y]) {
        // Through hole from front
        translate([0, sy, through_h/2])
            cylinder(h=through_h + overlap, r=screw_r, center=true);

        // Counterbore on front face
        translate([0, sy, counterbore_depth/2])
            cylinder(h=counterbore_depth + overlap, r=cb_r, center=true);
    }

    // Back hollow cavity (from back), leaving walls and a front keep thickness
    cavity_w = min(cavity_relief_width, faceplate_width - 2*back_hollow_wall_thickness);
    cavity_h = min(cavity_relief_height, faceplate_height - 2*back_hollow_wall_thickness);

    cavity_depth = max(0, body_depth - back_hollow_front_keep) + cavity_relief_depth_extra;
    cavity_z_center = faceplate_thickness + back_hollow_front_keep + cavity_depth/2;

    translate([0,0,cavity_z_center])
        rounded_rect_prism([cavity_w, cavity_h, cavity_depth + overlap],
                           r=max(0, edge_fillet_radius-0.5), center=true);

    // Top cable entry relief on back body (shallow notch) at +Y (top edge)
    relief_w = min(top_entry_relief_width, faceplate_width - 2*back_hollow_wall_thickness);
    relief_h = top_entry_relief_height;
    relief_d = max(2, back_hollow_wall_thickness + 1);

    relief_y = faceplate_height/2 - relief_h/2 - back_hollow_wall_thickness;
    relief_z = faceplate_thickness + body_depth - relief_d/2;

    translate([0, relief_y, relief_z])
        rounded_rect_prism([relief_w, relief_h, relief_d + overlap], r=1, center=true);
}

// ---------- Assembly ----------
difference() {
    union() {
        socket_solid();
    }
    socket_cuts();
}