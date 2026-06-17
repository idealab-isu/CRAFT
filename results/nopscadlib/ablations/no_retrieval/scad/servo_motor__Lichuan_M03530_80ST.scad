// Lichuan -80M03530B style servo motor (parametric, single connected solid)
// Fixes:
// - Adds recognizable servo features: front face step, pilot, 4-hole flange, shaft w/ flat,
//   rear register + center boss, rear connector/strain relief, top cap + rear cap,
//   side nameplate pad/recess, side ribs/rails, top grooves (so top view isn't a black square).
// - All translate() values are formula-based (no arbitrary offsets).
// - ONE connected solid ensured via controlled overlaps.
// - No text/labels.

$fn = 96;

// -------------------- Parameters --------------------
body_size = 80;            //[40:160:1]  // square cross-section (X,Z)
body_length = 110;         //[55:220:1]  // along Y
body_corner_r = 3;         //[1.5:6:0.5]

// Front flange / face
front_flange_size = 90;    //[45:180:1]
front_flange_thk = 6;      //[3:12:0.5]
front_face_thk = 1.5;      //[0.8:3:0.1]

// Mounting pattern (through flange)
mount_hole_spacing = 70;   //[35:140:1]
mount_hole_d = 6.6;        //[3.3:13.2:0.1]
mount_hole_csk_d = 10.5;   //[6:18:0.1]  // shallow counterbore look
mount_hole_csk_depth = 1.2;//[0:3:0.1]

// Pilot + shaft
pilot_d = 50;              //[25:100:0.5]
pilot_len = 2;             //[1:4:0.25]

shaft_d = 19;              //[9.5:38:0.5]
shaft_len = 35;            //[17.5:70:1]
shaft_shoulder_d = 28;     //[14:56:0.5]
shaft_shoulder_len = 5;    //[2.5:10:0.5]
shaft_flat_depth = 1.5;    //[0.5:3:0.1]
shaft_flat_width = 8;      //[4:16:0.5]

// Rear features
rear_register_d = 22;      //[10:40:0.5]
rear_register_len = 4;     //[2:10:0.5]
rear_center_boss_d = 12;   //[6:24:0.5]
rear_center_boss_len = 6;  //[3:16:0.5]

// Rear connector housing (cable exit)
conn_w = 22;               //[10:40:1]   // X
conn_h = 14;               //[6:30:1]    // Z
conn_len = 18;             //[8:40:1]    // Y
conn_offset_z = -body_size*0.18; // down a bit like many servos
conn_lip = 1.2;            //[0.5:3:0.1]
conn_side_offset_x = 0;    // keep centered; can be adjusted if needed

// Side rails / ribs
rail_thk = 2.2;            //[1:5:0.1]
rail_inset = 0.6;          //[0:2:0.1]

// Cooling fins (side)
fin_count = 6;             //[0:12:1]
fin_thk = 1.4;             //[0.8:3:0.1]
fin_depth = 2.2;           //[1:5:0.25]
fin_span = 0.78;           //[0.5:0.95:0.01] // fraction of body_length

// Nameplate pad/recess (no text)
plate_h = body_size*0.34;
plate_depth = 0.8;         //[0.2:2:0.1]
plate_y_span = body_length*0.22;

// Top view detail: grooves + cap
top_cap_thk = 2.0;         //[0:5:0.1]
top_cap_inset = 2.0;       //[0:6:0.1]
top_groove_count = 3;      //[0:6:1]
top_groove_w = body_size*0.10;
top_groove_d = 0.9;        //[0:2:0.1]
top_groove_len = body_length*0.62;

// Rear cap / housing step
rear_cap_thk = 2.0;        //[0:6:0.1]
rear_cap_inset = 1.5;      //[0:6:0.1]
rear_cap_height = body_size*0.55; // Z size of rear cap block

overlap = 1;               //[0.5:2:0.1]

// -------------------- Helpers --------------------
module rounded_box(size=[10,10,10], r=1, center=true) {
    // Minkowski rounded cube (keep r modest for performance)
    minkowski() {
        cube([max(size[0]-2*r, 0.01), max(size[1]-2*r, 0.01), max(size[2]-2*r, 0.01)], center=center);
        sphere(r=r);
    }
}

module mount_hole_through(x, z) {
    // Through hole along Y through flange+face
    translate([x, body_length/2 + front_flange_thk/2 - overlap, z])
        rotate([90, 0, 0])
            cylinder(r=mount_hole_d/2, h=front_flange_thk + front_face_thk + overlap*8, center=true);
}

module mount_hole_counterbore(x, z) {
    // Shallow counterbore on outer flange face (front side)
    // Place centered within flange thickness near its front face.
    translate([x,
               body_length/2 + front_flange_thk - mount_hole_csk_depth/2 - overlap,
               z])
        rotate([90, 0, 0])
            cylinder(r=mount_hole_csk_d/2, h=mount_hole_csk_depth + overlap*2, center=true);
}

module mounting_holes_pattern() {
    for (sx = [-1, 1], sz = [-1, 1]) {
        mount_hole_through(sx*mount_hole_spacing/2, sz*mount_hole_spacing/2);
        if (mount_hole_csk_depth > 0)
            mount_hole_counterbore(sx*mount_hole_spacing/2, sz*mount_hole_spacing/2);
    }
}

module shaft_flat_cut() {
    // Flat on shaft (D-shaft). Cut aligned to +Z side.
    translate([0,
               body_length/2 + front_flange_thk + shaft_shoulder_len + shaft_len/2 - overlap,
               shaft_d/2 - shaft_flat_depth])
        cube([shaft_flat_width, shaft_len*0.85, shaft_flat_depth*2 + overlap*2], center=true);
}

// -------------------- Main solids --------------------
module motor_body() {
    // Main housing
    rounded_box([body_size, body_length, body_size], r=body_corner_r, center=true);
}

module edge_rails() {
    // Long rails on left/right edges (break up silhouette)
    rail_len = body_length*0.96;
    rail_h = body_size*0.06;

    for (sx = [-1, 1]) {
        for (sz = [-1, 1]) {
            translate([sx*(body_size/2 - rail_thk/2 - rail_inset),
                       0,
                       sz*(body_size/2 - rail_h/2 - rail_inset)])
                cube([rail_thk, rail_len, rail_h], center=true);
        }
    }
}

module cooling_fins() {
    // Subtle fins on both sides, distributed along Z
    if (fin_count > 0) {
        fin_len = body_length*fin_span;
        fin_h = body_size*0.07;
        for (i = [0:fin_count-1]) {
            zpos = ((i/(max(fin_count-1,1))) - 0.5) * body_size*0.62;

            // Right side fins
            translate([ body_size/2 + fin_depth/2 - overlap, 0, zpos])
                cube([fin_depth, fin_len, fin_h], center=true);

            // Left side fins
            translate([-body_size/2 - fin_depth/2 + overlap, 0, zpos])
                cube([fin_depth, fin_len, fin_h], center=true);
        }
    }
}

module front_face_step() {
    // Slight step between body and flange
    translate([0, body_length/2 + front_face_thk/2 - overlap, 0])
        cube([body_size*0.98, front_face_thk, body_size*0.98], center=true);
}

module front_flange() {
    translate([0, body_length/2 + front_flange_thk/2 - overlap, 0])
        cube([front_flange_size, front_flange_thk, front_flange_size], center=true);
}

module pilot_boss() {
    translate([0, body_length/2 + front_flange_thk + pilot_len/2 - overlap, 0])
        rotate([90, 0, 0])
            cylinder(r=pilot_d/2, h=pilot_len, center=true);
}

module shaft_shoulder() {
    translate([0, body_length/2 + front_flange_thk + shaft_shoulder_len/2 - overlap, 0])
        rotate([90, 0, 0])
            cylinder(r=shaft_shoulder_d/2, h=shaft_shoulder_len, center=true);
}

module output_shaft() {
    translate([0, body_length/2 + front_flange_thk + shaft_shoulder_len + shaft_len/2 - overlap, 0])
        rotate([90, 0, 0])
            cylinder(r=shaft_d/2, h=shaft_len, center=true);
}

module rear_register_and_boss() {
    // Rear circular register + small center boss
    translate([0, -body_length/2 - rear_register_len/2 + overlap, 0])
        rotate([90, 0, 0])
            cylinder(r=rear_register_d/2, h=rear_register_len, center=true);

    translate([0, -body_length/2 - rear_register_len - rear_center_boss_len/2 + overlap, 0])
        rotate([90, 0, 0])
            cylinder(r=rear_center_boss_d/2, h=rear_center_boss_len, center=true);
}

module rear_connector_housing() {
    // Rectangular connector housing on rear face (offset in Z), with a small lip/strain relief
    translate([conn_side_offset_x,
               -body_length/2 - conn_len/2 + overlap,
               conn_offset_z])
        cube([conn_w, conn_len, conn_h], center=true);

    translate([conn_side_offset_x,
               -body_length/2 - (conn_len*0.35)/2 + overlap,
               conn_offset_z])
        cube([conn_w + conn_lip*2, conn_len*0.35, conn_h + conn_lip*2], center=true);
}

module side_nameplate_pad() {
    // Raised pad on +X side
    pad_thk = 1.2;
    translate([body_size/2 + pad_thk/2 - overlap, 0, 0])
        cube([pad_thk, plate_y_span, plate_h], center=true);
}

module top_cap() {
    // Slight inset cap on top surface (adds top-view features)
    if (top_cap_thk > 0) {
        translate([0, 0, body_size/2 + top_cap_thk/2 - overlap])
            rounded_box([body_size - 2*top_cap_inset,
                         body_length*0.92,
                         top_cap_thk],
                        r=max(body_corner_r*0.6, 0.6),
                        center=true);
    }
}

module rear_cap_block() {
    // Rear housing step (common on servos): a block on rear face, inset in X and limited in Z
    if (rear_cap_thk > 0) {
        translate([0,
                   -body_length/2 - rear_cap_thk/2 + overlap,
                   0])
            rounded_box([body_size - 2*rear_cap_inset,
                         rear_cap_thk,
                         rear_cap_height],
                        r=max(body_corner_r*0.6, 0.6),
                        center=true);
    }
}

// -------------------- Cuts (details) --------------------
module side_nameplate_recess_cut() {
    // Recess into the pad to create framed look
    pad_thk = 1.2;
    translate([body_size/2 + pad_thk/2 - overlap/2, 0, 0])
        cube([pad_thk + overlap*3, plate_y_span*0.82, plate_h*0.72], center=true);
}

module top_grooves_cut() {
    // Grooves cut into top cap/body so top view isn't a solid square
    if (top_groove_count > 0 && top_groove_d > 0) {
        // distribute grooves across X
        for (i = [0:top_groove_count-1]) {
            xpos = ((i/(max(top_groove_count-1,1))) - 0.5) * (body_size*0.55);
            translate([xpos, 0, body_size/2 - top_groove_d/2 + overlap*0.2])
                cube([top_groove_w, top_groove_len, top_groove_d + overlap*2], center=true);
        }
    }
}

module front_face_relief_cut() {
    // Small rectangular relief on front face (around pilot) to add recognizable face geometry
    relief_w = body_size*0.55;
    relief_h = body_size*0.55;
    relief_d = 0.8;
    translate([0,
               body_length/2 + relief_d/2 - overlap*0.2,
               0])
        cube([relief_w, relief_d + overlap*2, relief_h], center=true);
}

// -------------------- Assembly --------------------
module main_solid_pre_cuts() {
    union() {
        motor_body();

        // Body details
        edge_rails();
        cooling_fins();
        top_cap();
        rear_cap_block();

        // Front mechanical features
        front_face_step();
        front_flange();
        pilot_boss();
        shaft_shoulder();
        output_shaft();

        // Rear mechanical + connector
        rear_register_and_boss();
        rear_connector_housing();

        // Side pad (nameplate area)
        side_nameplate_pad();
    }
}

module model_with_cuts() {
    difference() {
        main_solid_pre_cuts();

        // Mounting holes through flange
        mounting_holes_pattern();

        // Shaft flat
        shaft_flat_cut();

        // Recess in side pad (no text)
        side_nameplate_recess_cut();

        // Top grooves
        top_grooves_cut();

        // Front face relief
        front_face_relief_cut();
    }
}

// Final Output (single connected solid)
model_with_cuts();