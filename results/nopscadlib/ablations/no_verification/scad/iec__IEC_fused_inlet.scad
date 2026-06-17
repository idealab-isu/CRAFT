// IEC fused inlet module (JR-101-1F style) - overall panel cutout 36.0mm x 27.0mm
// One connected solid, no floating parts, all translates derived from dimensions.

$fn = 72;

// -------------------- Parameters --------------------
cutout_width_mm  = 36.0;   //[18:72:0.5]
cutout_height_mm = 27.0;   //[13.5:54:0.5]

panel_thickness_mm = 2.0;  //[1:6:0.5]

flange_width_mm  = 50.0;   //[30:100:0.5]
flange_height_mm = 35.0;   //[20:70:0.5]
flange_thickness_mm = 3.0; //[1.5:8:0.5]
bezel_radius_mm = 3.0;     //[0.5:8:0.5]

body_depth_mm  = 45.0;     //[25:90:0.5]
body_width_mm  = 38.0;     //[20:76:0.5]
body_height_mm = 29.0;     //[15:58:0.5]

mounting_hole_diameter_mm = 3.2; //[2:6.5:0.1]
mounting_hole_pitch_x_mm  = 40.0;  //[25:80:0.5]
mounting_hole_pitch_y_mm  = 0.0;   //[0:20:0.5]

fuse_drawer_projection_mm = 12.0;  //[6:30:0.5]
fuse_drawer_width_mm  = 18.0;      //[10:30:0.5]
fuse_drawer_height_mm = 12.0;      //[8:20:0.5]

terminal_clearance_depth_mm  = 18.0; //[8:40:0.5]
terminal_clearance_width_mm  = 30.0; //[15:60:0.5]
terminal_clearance_height_mm = 22.0; //[12:44:0.5]

overlap_mm = 1.0;          //[0.5:2:0.1]

// -------------------- Helpers --------------------
module rounded_rect_2d(x, y, r) {
    rr = min(r, x/2, y/2);
    offset(r=rr) square([x-2*rr, y-2*rr], center=true);
}

module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
    x=size[0]; y=size[1]; z=size[2];
    translate(center ? [0,0,0] : [x/2,y/2,z/2])
        linear_extrude(height=z, center=true)
            rounded_rect_2d(x,y,r);
}

module capsule_2d(len, dia) {
    r = dia/2;
    hull() {
        translate([-(len/2-r),0]) circle(r=r);
        translate([ (len/2-r),0]) circle(r=r);
    }
}

module capsule_prism(len, dia, h, center=true) {
    translate(center ? [0,0,0] : [0,0,h/2])
        linear_extrude(height=h, center=true)
            capsule_2d(len, dia);
}

// -------------------- IEC Module Solid --------------------
module iec_fused_inlet_solid() {

    // Coordinate system:
    // Z=0 is panel mid-plane. +Z is front (user side), -Z is rear (inside enclosure).

    // Derived Z positions (ensure overlap so everything is one connected solid)
    z_flange_center = panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm;
    z_body_center   = -panel_thickness_mm/2 - body_depth_mm/2 + overlap_mm;

    // Front face bezel thickness (visual)
    face_thickness = max(2.0, flange_thickness_mm*0.7);
    z_face_center  = panel_thickness_mm/2 + face_thickness/2 - overlap_mm;

    // Front feature protrusion depth (fuse drawer / switch / inlet bezel)
    front_feature_depth = max(3.0, face_thickness*1.0);
    z_front_feature_center = panel_thickness_mm/2 + face_thickness - overlap_mm + front_feature_depth/2;

    // --- Front functional openings (approx JR-101-1F layout) ---
    // IEC C14 inlet opening (approx)
    c14_w = 27.5;
    c14_h = 20.0;
    c14_r = 2.0;

    // Fuse drawer opening (approx) above inlet
    fuse_open_w = fuse_drawer_width_mm;
    fuse_open_h = fuse_drawer_height_mm;
    fuse_open_r = 1.2;

    // Rocker switch opening (approx) below inlet
    sw_w = 19.0;
    sw_h = 13.0;
    sw_r = 1.2;

    // Layout in Y: fuse top, inlet middle, switch bottom
    total_stack_h = fuse_open_h + c14_h + sw_h;
    gap_total = max(1.0, cutout_height_mm - total_stack_h);
    gap = gap_total/2;

    y_fuse_center =  cutout_height_mm/2 - fuse_open_h/2;
    y_sw_center   = -cutout_height_mm/2 + sw_h/2;

    // Place inlet between fuse and switch with derived spacing
    y_c14_center_nom = (y_fuse_center - fuse_open_h/2 - gap) - c14_h/2;
    y_c14_center =
        max(y_sw_center + sw_h/2 + gap + c14_h/2,
        min(y_fuse_center - fuse_open_h/2 - gap - c14_h/2, y_c14_center_nom));

    // Fuse drawer protrusion block (front) - connected to face
    fuse_proj_w = fuse_drawer_width_mm + 6;
    fuse_proj_h = fuse_drawer_height_mm + 6;

    // Switch bezel protrusion (front)
    sw_bez_w = sw_w + 6;
    sw_bez_h = sw_h + 6;

    // IEC inlet bezel protrusion (front)
    c14_bez_w = c14_w + 6;
    c14_bez_h = c14_h + 6;

    // Rear terminal block (visual) - connected to body
    term_w = min(body_width_mm - 4, 30);
    term_h = min(body_height_mm - 4, 18);
    term_d = min(terminal_clearance_depth_mm, body_depth_mm*0.55);

    z_body_rear_face = z_body_center - body_depth_mm/2;
    z_term_center = z_body_rear_face - term_d/2 + overlap_mm;

    // --- C14 pin holes (visual) ---
    // Three pin holes inside the C14 opening (approx positions)
    pin_d = 4.8;
    pin_pitch_x = 10.0;
    pin_pitch_y = 7.0;

    // --- Fuse drawer finger notch (visual) ---
    notch_d = 6.0;
    notch_w = fuse_open_w * 0.65;

    // --- Switch rocker relief (visual) ---
    sw_relief_w = sw_w * 0.85;
    sw_relief_h = sw_h * 0.55;
    sw_relief_r = 1.0;

    difference() {
        union() {
            // Rear body
            translate([0,0,z_body_center])
                rounded_rect_prism([body_width_mm, body_height_mm, body_depth_mm], r=1.5, center=true);

            // Front flange (mounting plate)
            translate([0,0,z_flange_center])
                rounded_rect_prism([flange_width_mm, flange_height_mm, flange_thickness_mm], r=bezel_radius_mm, center=true);

            // Front face bezel (slightly smaller than flange)
            translate([0,0,z_face_center])
                rounded_rect_prism([flange_width_mm-2, flange_height_mm-2, face_thickness],
                                   r=max(1, bezel_radius_mm-1), center=true);

            // Fuse drawer protrusion (front)
            translate([0, y_fuse_center, z_front_feature_center])
                rounded_rect_prism([fuse_proj_w, fuse_proj_h, front_feature_depth], r=1.2, center=true);

            // Switch bezel protrusion (front)
            translate([0, y_sw_center, z_front_feature_center])
                rounded_rect_prism([sw_bez_w, sw_bez_h, front_feature_depth], r=1.2, center=true);

            // IEC inlet bezel protrusion (front)
            translate([0, y_c14_center, z_front_feature_center])
                rounded_rect_prism([c14_bez_w, c14_bez_h, front_feature_depth], r=1.6, center=true);

            // Rear terminal block (visual)
            translate([0, 0, z_term_center])
                rounded_rect_prism([term_w, term_h, term_d], r=1.0, center=true);
        }

        // Mounting holes through flange+panel thickness (cut)
        hole_h = flange_thickness_mm + panel_thickness_mm + 4*overlap_mm;
        z_hole_center = panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm;

        y_pitch = (mounting_hole_pitch_y_mm == 0) ? 0 : mounting_hole_pitch_y_mm/2;

        for (sx = [-1, 1]) {
            translate([sx*mounting_hole_pitch_x_mm/2, y_pitch, z_hole_center])
                cylinder(d=mounting_hole_diameter_mm, h=hole_h, center=true);
        }

        // Main panel cutout (36x27) through flange+face (cut)
        cut_h = flange_thickness_mm + face_thickness + panel_thickness_mm + 6*overlap_mm;
        z_cut_center = panel_thickness_mm/2 + (flange_thickness_mm + face_thickness)/2 - overlap_mm;

        translate([0,0,z_cut_center])
            rounded_rect_prism([cutout_width_mm, cutout_height_mm, cut_h], r=1.0, center=true);

        // Front feature openings cut through face + protrusion + slightly into body
        open_h = face_thickness + front_feature_depth + 2*overlap_mm;

        // IEC C14 opening
        translate([0, y_c14_center, z_face_center + face_thickness/2 - overlap_mm])
            rounded_rect_prism([c14_w, c14_h, open_h], r=c14_r, center=true);

        // Fuse drawer opening
        translate([0, y_fuse_center, z_face_center + face_thickness/2 - overlap_mm])
            rounded_rect_prism([fuse_open_w, fuse_open_h, open_h], r=fuse_open_r, center=true);

        // Switch opening
        translate([0, y_sw_center, z_face_center + face_thickness/2 - overlap_mm])
            rounded_rect_prism([sw_w, sw_h, open_h], r=sw_r, center=true);

        // C14 pin holes (three circles) cut slightly into the body behind the face
        pin_h = face_thickness + front_feature_depth + 4*overlap_mm;
        z_pin_center = z_face_center + face_thickness/2 - overlap_mm; // start at face, go inward
        for (px = [-pin_pitch_x/2, pin_pitch_x/2]) {
            translate([px, y_c14_center - pin_pitch_y/2, z_pin_center])
                cylinder(d=pin_d, h=pin_h, center=true);
        }
        translate([0, y_c14_center + pin_pitch_y/2, z_pin_center])
            cylinder(d=pin_d, h=pin_h, center=true);

        // Fuse drawer finger notch (capsule) at top edge of fuse opening
        // Positioned relative to fuse opening dimensions (no arbitrary offsets)
        notch_h = face_thickness + front_feature_depth + 2*overlap_mm;
        y_notch = y_fuse_center + fuse_open_h/2 - notch_d/2;
        translate([0, y_notch, z_face_center + face_thickness/2 - overlap_mm])
            capsule_prism(len=notch_w, dia=notch_d, h=notch_h, center=true);

        // Switch rocker relief (shallow) inside switch opening (visual)
        // Cut only through face+protrusion (already within open_h), but smaller than switch opening
        translate([0, y_sw_center, z_face_center + face_thickness/2 - overlap_mm])
            rounded_rect_prism([sw_relief_w, sw_relief_h, open_h], r=sw_relief_r, center=true);

        // Rear terminal clearance pocket (cut) - shallow recess on rear
        pocket_d = min(terminal_clearance_depth_mm, body_depth_mm*0.6);
        z_pocket_center = z_body_rear_face + pocket_d/2 + overlap_mm; // inside body near rear face
        translate([0, 0, z_pocket_center])
            rounded_rect_prism([terminal_clearance_width_mm, terminal_clearance_height_mm, pocket_d], r=1.0, center=true);
    }
}

// -------------------- Assembly (single connected solid) --------------------
iec_fused_inlet_solid();