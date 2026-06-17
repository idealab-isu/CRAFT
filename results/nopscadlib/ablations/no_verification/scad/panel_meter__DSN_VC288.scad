// DSN-DC 100V 10A Panel Meter (approximate) - single connected solid
// No text/labels. All parts connected via calculated offsets/overlaps.

$fn = 48;

// Parameters
voltage_range_max_v = 100; //[50:200:1]
current_range_max_a = 10;  //[5:20:1]

cutout_tolerance_mm = 0.2; //[0.0:1.0:0.05]
overlap_mm = 1;            //[0.5:2:0.1]

// Overall envelope (approx DSN-DC style)
overall_x = 48; //[24:96:1]
overall_y = 29; //[15:58:1]
overall_z = 26; //[13:52:1]

// Front bezel
bezel_x = 48; //[24:96:1]
bezel_y = 29; //[15:58:1]
bezel_z = 3;  //[1.5:6:0.5]

// Rear body (insert)
body_x = 45; //[22.5:90:1]
body_y = 26; //[13:52:1]
body_z = 23; //[11.5:46:1]

// Display window
display_ap_x = 36; //[18:72:1]
display_ap_y = 14; //[7:28:1]
display_ap_corner_r = 1.5; //[0:4:0.25]
display_ap_through_z = 6;  //[3:12:0.5]

// Front "lens" recess and inner bezel lip (adds recognizable front-face detail)
lens_recess_depth = 1.2; //[0.5:2.5:0.1]
lens_lip = 1.2;          //[0.5:3:0.1]

// Button
button_enabled = 1; //[0:1:1]
button_radius = 2.2; //[1:4.5:0.1]
button_height = 1.2; //[0.6:2.4:0.1]
button_x_offset = 18; //[0:30:1]
button_y_offset = -9; //[-20:20:1]

// Mounting side tabs (ears)
tab_enabled = 1; //[0:1:1]
tab_x = 8;  //[4:16:0.5]
tab_y = 10; //[5:20:0.5]
tab_z = 2.5; //[1:5:0.25]
tab_z_offset = 10; //[5:20:1]

// Rear terminal block + pads (adds recognizable back-side connectivity)
term_block_x = 40; //[20:60:1]
term_block_y = 8;  //[5:16:0.5]
term_block_z = 6;  //[3:12:0.5]
term_block_setback = 2; //[0:6:0.5]  // from rear face of body

pad_count = 4;          // typical DSN-DC has multiple connections
pad_pitch = 10;         //[6:14:0.5]
pad_d = 3.2;            //[2:5:0.1]
pad_h = 2.2;            //[1:4:0.1]
pad_y_offset = 0;       // centered on terminal block

// Shunt-like rear protrusion (stylized)
shunt_x = 18; //[10:30:1]
shunt_y = 6;  //[3:12:0.5]
shunt_z = 4;  //[2:10:0.5]
shunt_offset_y = -(term_block_y/2 + shunt_y/2 - overlap_mm);

// Panel cutout (kept but fused to model so output is one connected solid)
panel_thickness = 3; //[1:6:0.5]
panel_margin = 12;   //[6:24:1]
rear_clearance_extra = 6; //[3:12:0.5]

// Helpers
module rounded_rect_prism(x, y, z, r, center=true) {
  r2 = min(r, min(x,y)/2);
  translate(center ? [0,0,0] : [x/2,y/2,z/2])
    linear_extrude(height=z, center=true)
      offset(r=r2)
        square([x-2*r2, y-2*r2], center=true);
}

module rounded_window_cut(x, y, z, r) {
  // A rounded-rectangle "cutter" centered at origin
  linear_extrude(height=z, center=true)
    offset(r=r)
      square([x-2*r, y-2*r], center=true);
}

module panel_meter_solid() {
  // Coordinate convention:
  // Front face of bezel at z = +bezel_z/2
  // Bezel centered at z=0, body extends to negative z.
  union() {
    // --- Main housing (bezel + body) as one connected solid ---
    // Bezel block
    translate([0,0,0])
      cube([bezel_x, bezel_y, bezel_z], center=true);

    // Rear body connected to bezel with overlap
    translate([0,0, -(bezel_z/2 + body_z/2 - overlap_mm)])
      cube([body_x, body_y, body_z], center=true);

    // Side mounting tabs (ears) connected to body
    if (tab_enabled) {
      tab_z_center = -(bezel_z/2 + tab_z_offset + tab_z/2);
      translate([-(body_x/2 + tab_x/2 - overlap_mm), 0, tab_z_center])
        cube([tab_x, tab_y, tab_z], center=true);
      translate([(body_x/2 + tab_x/2 - overlap_mm), 0, tab_z_center])
        cube([tab_x, tab_y, tab_z], center=true);
    }

    // --- Rear terminal block connected to rear of body ---
    // Rear face of body is at z = -(bezel_z/2 + body_z - overlap_mm)
    body_center_z = -(bezel_z/2 + body_z/2 - overlap_mm);
    body_rear_face_z = body_center_z - body_z/2;

    term_center_z = body_rear_face_z - term_block_z/2 + overlap_mm - term_block_setback;
    translate([0, 0, term_center_z])
      cube([term_block_x, term_block_y, term_block_z], center=true);

    // Rear pads/posts on terminal block (protrude further back)
    // Terminal block rear face:
    term_rear_face_z = term_center_z - term_block_z/2;
    pad_center_z = term_rear_face_z - pad_h/2 + overlap_mm;

    for (i = [0:pad_count-1]) {
      x_i = (i - (pad_count-1)/2) * pad_pitch;
      translate([x_i, pad_y_offset, pad_center_z])
        cylinder(d=pad_d, h=pad_h, center=true);
    }

    // Shunt-like protrusion connected under terminal block
    shunt_center_z = term_center_z; // same z as terminal block for solid connection
    translate([0, shunt_offset_y, shunt_center_z])
      cube([shunt_x, shunt_y, shunt_z], center=true);

    // Front button connected to bezel front
    if (button_enabled) {
      // Bezel front face at +bezel_z/2
      btn_center_z = (bezel_z/2) + button_height/2 - overlap_mm;
      translate([button_x_offset, button_y_offset, btn_center_z])
        cylinder(r=button_radius, h=button_height, center=true);
    }

    // Panel "sheet" fused to bezel (so output remains one connected solid)
    // Place panel behind bezel front, intersecting bezel slightly.
    panel_center_z = (bezel_z/2) - panel_thickness/2 + overlap_mm;
    translate([0,0,panel_center_z])
      cube([body_x + 2*(panel_margin + cutout_tolerance_mm),
            body_y + 2*(panel_margin + cutout_tolerance_mm),
            panel_thickness], center=true);
  }
}

module panel_meter() {
  // Carve front-face details (display window + lens recess) while keeping one solid.
  difference() {
    panel_meter_solid();

    // Display aperture through bezel (and slightly into body)
    // Centered on bezel; cut depth spans bezel and a bit behind.
    cut_z = bezel_z + 2*overlap_mm + 2; // ensure through bezel
    translate([0, 0, 0])
      rounded_window_cut(display_ap_x, display_ap_y, cut_z, display_ap_corner_r);

    // Lens recess: a shallow pocket around the display opening (bezel detail)
    // Make a larger rounded rectangle pocket, not through.
    pocket_x = display_ap_x + 2*lens_lip;
    pocket_y = display_ap_y + 2*lens_lip;
    pocket_z = lens_recess_depth + 2*overlap_mm;
    // Position pocket so it starts at front face and goes inward
    pocket_center_z = (bezel_z/2) - lens_recess_depth/2 + overlap_mm;
    translate([0, 0, pocket_center_z])
      rounded_window_cut(pocket_x, pocket_y, pocket_z, display_ap_corner_r + 0.6);

    // Panel cutout hole (remove from panel sheet only; does not disconnect model)
    // Cutout aligned with body insert size.
    panel_center_z = (bezel_z/2) - panel_thickness/2 + overlap_mm;
    translate([0,0,panel_center_z])
      cube([body_x + 2*cutout_tolerance_mm,
            body_y + 2*cutout_tolerance_mm,
            panel_thickness + 2*overlap_mm], center=true);
  }
}

panel_meter();