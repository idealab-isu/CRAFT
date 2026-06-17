$fn = 64;

// -------------------- Parameters --------------------
faceplate_w = 86; //[60:120]
faceplate_h = 86; //[60:120]
faceplate_t = 9;  //[5:18]

// Front styling (bevel + shallow recess)
front_bevel = 1.2;        //[0.5:3]
front_recess_t = 1.2;     //[0.5:4]
front_recess_margin = 6;  //[3:12]

// Rear body (terminal housing)
rear_body_w = 52;   //[40:70]
rear_body_h = 52;   //[40:70]
rear_body_t = 28;   //[18:40]
rear_body_bevel = 2; //[0:4]

// Cable entry / strain relief bump
cable_bump_w = 34;  //[20:50]
cable_bump_h = 18;  //[10:30]
cable_bump_t = 10;  //[6:18]
cable_hole_d = 10;  //[6:16]

// Screw positions and geometry (UK 1G socket: screws on vertical centerline)
screw_pitch_y = 60.3; //[50:75]
screw_hole_d = 4.2;   //[3.5:6]
countersink_d_top = 8.5; //[6:12]
countersink_d_bottom = 4.2; //[3.5:6]
countersink_depth = 3; //[1.5:6]
screw_head_d = 8.2;   //[6:12]
screw_head_h = 1.6;   //[0.8:3]
screw_slot_w = 1.2;   //[0.6:2]
screw_slot_l = 6.0;   //[3:10]
screw_slot_h = 0.9;   //[0.4:2]

// UK socket apertures (BS 1363)
live_neutral_pitch_x = 22.2; //[18:28]
pin_y_offset = -11.1; //[-16:-6]
earth_y_offset = 11.1; //[6:16]
pin_slot_w = 7; //[5:10]
pin_slot_h = 4.5; //[3:7]
earth_slot_w = 4.5; //[3:7]
earth_slot_h = 8.5; //[6:12]
pin_cut_depth = 10; //[6:18]

// Socket module detailing (front raised module + inner recess)
module_w = 50; //[40:60]
module_h = 50; //[40:60]
module_raise = 1.6; //[0.8:3]
module_corner_r = 2.2; //[1:5]
module_recess_t = 1.2; //[0.6:3]
module_recess_margin = 6; //[3:12]

// Optional panel cutout block (kept connected if enabled)
panel_cutout_margin = 7; //[3:15]
cutout_thickness_h = 0; //[0:10]
panel_cutout_default_h = 2; //[1:6]

// Robustness
eps = 0.25; //[0.1:1]

// Structural overlap to guarantee attachment (1–2mm)
attach_ol = 1.2;

// -------------------- Helpers --------------------
module rounded_rect_prism(size=[10,10,2], r=1, center=true) {
  minkowski() {
    cube([max(eps, size[0]-2*r), max(eps, size[1]-2*r), size[2]], center=center);
    cylinder(r=r, h=eps, center=true);
  }
}

module screw_head_with_slot(d=8, h=1.6, slot_w=1.2, slot_l=6, slot_h=0.9) {
  difference() {
    cylinder(d=d, h=h, center=true);
    cube([slot_l, slot_w, h + 2*eps], center=true);
    translate([0,0, h/2 - slot_h/2])
      cube([slot_l, slot_w, slot_h + 2*eps], center=true);
  }
}

// -------------------- Main geometry --------------------
module faceplate_solid() {
  difference() {
    hull() {
      translate([0,0,-faceplate_t/2])
        cube([faceplate_w, faceplate_h, eps], center=true);
      translate([0,0, faceplate_t/2])
        cube([faceplate_w - 2*front_bevel, faceplate_h - 2*front_bevel, eps], center=true);
    }

    translate([0,0, faceplate_t/2 - front_recess_t/2 + eps/2])
      cube([faceplate_w - 2*front_recess_margin,
            faceplate_h - 2*front_recess_margin,
            front_recess_t + eps], center=true);
  }
}

module socket_front_module() {
  // Raised central module; overlap into faceplate by attach_ol
  zc = faceplate_t/2 + module_raise/2 - attach_ol;
  translate([0,0,zc])
    rounded_rect_prism([module_w, module_h, module_raise], r=module_corner_r, center=true);
}

module socket_front_module_recess_cut() {
  // Shallow recess inside the raised module (keeps a rim)
  zc = faceplate_t/2 + module_raise - module_recess_t/2 + eps/2;
  translate([0,0,zc])
    rounded_rect_prism([module_w - 2*module_recess_margin,
                        module_h - 2*module_recess_margin,
                        module_recess_t + eps],
                        r=max(0.5, module_corner_r-0.8), center=true);
}

module rear_terminal_body() {
  // Rear housing block built in-place so it is NOT floating.
  // Top face overlaps into the faceplate by attach_ol.
  z_top = -faceplate_t/2 + attach_ol;
  z_bot = z_top - rear_body_t;

  hull() {
    translate([0,0, z_bot])
      cube([rear_body_w - 2*rear_body_bevel, rear_body_h - 2*rear_body_bevel, eps], center=true);
    translate([0,0, z_top])
      cube([rear_body_w, rear_body_h, eps], center=true);
  }
}

module cable_entry_bump() {
  // Bump on rear body for cable entry, attached with overlap into rear body
  z_top = -faceplate_t/2 + attach_ol;
  z_bot = z_top - rear_body_t;

  bump_zc = z_bot + cable_bump_t/2 - attach_ol; // overlap into rear body
  bump_yc = -rear_body_h/2 + cable_bump_h/2 + 2;

  translate([0, bump_yc, bump_zc])
    rounded_rect_prism([cable_bump_w, cable_bump_h, cable_bump_t], r=2, center=true);
}

module socket_apertures_cut() {
  // Cuts through faceplate + raised module and slightly into rear body
  cut_h = faceplate_t + module_raise + rear_body_t + 4*eps;

  // Live / Neutral
  translate([-live_neutral_pitch_x/2, pin_y_offset, 0])
    cube([pin_slot_w, pin_slot_h, cut_h], center=true);
  translate([ live_neutral_pitch_x/2, pin_y_offset, 0])
    cube([pin_slot_w, pin_slot_h, cut_h], center=true);

  // Earth
  translate([0, earth_y_offset, 0])
    cube([earth_slot_w, earth_slot_h, cut_h], center=true);

  // Lead-in pocket at the very front (on the raised module face)
  lead_t = 0.9;
  lead_zc = faceplate_t/2 + module_raise - lead_t/2 + eps/2;
  translate([-live_neutral_pitch_x/2, pin_y_offset, lead_zc])
    cube([pin_slot_w+1.2, pin_slot_h+1.2, lead_t + eps], center=true);
  translate([ live_neutral_pitch_x/2, pin_y_offset, lead_zc])
    cube([pin_slot_w+1.2, pin_slot_h+1.2, lead_t + eps], center=true);
  translate([0, earth_y_offset, lead_zc])
    cube([earth_slot_w+1.0, earth_slot_h+1.0, lead_t + eps], center=true);
}

module screw_holes_and_countersink_cut() {
  for (sy = [screw_pitch_y/2, -screw_pitch_y/2]) {
    translate([0, sy, 0])
      cylinder(d=screw_hole_d, h=faceplate_t + module_raise + rear_body_t + 4*eps, center=true);

    // Countersink from very front (top of raised module)
    translate([0, sy, faceplate_t/2 + module_raise - countersink_depth/2 + eps/2])
      cylinder(d1=countersink_d_top, d2=countersink_d_bottom, h=countersink_depth + eps, center=true);
  }
}

module rear_terminal_features_cut() {
  // Terminal block cavities and cable hole on rear side (subtractive, keep solid connected)
  pocket_t = 10;
  pocket_w = 14;
  pocket_h = 10;

  z_top = -faceplate_t/2 + attach_ol;
  z_bot = z_top - rear_body_t;
  rear_z0 = (z_top + z_bot)/2;

  for (sx = [-live_neutral_pitch_x/2, live_neutral_pitch_x/2]) {
    translate([sx, 10, rear_z0])
      cube([pocket_w, pocket_h, pocket_t], center=true);
  }
  translate([0, 22, rear_z0])
    cube([pocket_w, pocket_h, pocket_t], center=true);

  bump_yc = -rear_body_h/2 + cable_bump_h/2 + 2;
  bump_zc = z_bot + cable_bump_t/2 - attach_ol;

  translate([0, bump_yc, bump_zc])
    rotate([90,0,0])
      cylinder(d=cable_hole_d, h=cable_bump_h + 6, center=true);
}

// -------------------- FIX: screw/fastener rings physically attached --------------------
module screw_fastener_rings_attached() {
  // Create annular rings that are UNIONED to the faceplate/module by overlapping
  // slightly into the raised module surface (1–2mm).
  ring_od = 12.0;
  ring_id = countersink_d_top + 0.6; // keep clear of countersink
  ring_h  = 1.6;

  // Place so bottom of ring penetrates into the raised module by attach_ol
  // Top of raised module is at z = faceplate_t/2 + module_raise
  zc = (faceplate_t/2 + module_raise) - ring_h/2 + attach_ol;

  for (sy = [screw_pitch_y/2, -screw_pitch_y/2]) {
    translate([0, sy, zc])
      difference() {
        cylinder(d=ring_od, h=ring_h, center=true);
        cylinder(d=ring_id, h=ring_h + 2*eps, center=true);
      }
  }
}

module decorative_screw_heads() {
  // Visible screw heads on the front (sit on raised module, overlap slightly)
  for (sy = [screw_pitch_y/2, -screw_pitch_y/2]) {
    // Ensure physical connection by overlapping into the raised module
    zc = (faceplate_t/2 + module_raise) - screw_head_h/2 + attach_ol;
    translate([0, sy, zc])
      screw_head_with_slot(d=screw_head_d, h=screw_head_h,
                           slot_w=screw_slot_w, slot_l=screw_slot_l, slot_h=screw_slot_h);
  }
}

module panel_cutout_block_connected() {
  h = (cutout_thickness_h > 0 ? cutout_thickness_h : panel_cutout_default_h);
  if (h > 0) {
    translate([0,0, -faceplate_t/2 - h/2 + attach_ol]) // overlap into faceplate
      cube([faceplate_w - 2*panel_cutout_margin,
            faceplate_h - 2*panel_cutout_margin,
            h], center=true);
  }
}

// -------------------- Missing part: mains socket (rear mains socket body) --------------------
module mains_socket_body() {
  // Simplified "Screwfix Essential unswitched" rear module representation:
  // rearward protruding block attached to the rear terminal body.
  socket_w = 44;
  socket_h = 36;
  socket_t = 18;
  socket_r = 2;

  z_top = -faceplate_t/2 + attach_ol;
  z_bot = z_top - rear_body_t;

  // Rear body back face is at z_bot; extend further negative and overlap by attach_ol
  zc = z_bot - socket_t/2 + attach_ol;

  translate([0, 0, zc])
    rounded_rect_prism([socket_w, socket_h, socket_t], r=socket_r, center=true);
}

module mains_socket_features_cut() {
  // Basic rear entry cavity to suggest socket internals (kept conservative)
  socket_w = 44;
  socket_h = 36;
  socket_t = 18;

  z_top = -faceplate_t/2 + attach_ol;
  z_bot = z_top - rear_body_t;
  zc = z_bot - socket_t/2 + attach_ol;

  // Shallow rear recess (does not sever attachment)
  translate([0, 0, zc - socket_t/2 + 6])
    cube([socket_w - 8, socket_h - 8, 12], center=true);
}

// -------------------- Assembly (ONE connected solid) --------------------
module assembly() {
  difference() {
    union() {
      // Front faceplate/frame
      faceplate_solid();

      // Raised socket module (front) - overlaps into faceplate
      socket_front_module();

      // Rear/back housing block - overlaps into faceplate
      rear_terminal_body();

      // Cable bump - overlaps into rear body
      cable_entry_bump();

      // Missing mains socket part - overlaps into rear body
      mains_socket_body();

      // FIX: fastener rings are now part of the same solid and overlap into module
      screw_fastener_rings_attached();

      // Decorative screw heads (also overlap into module)
      decorative_screw_heads();

      panel_cutout_block_connected();
    }

    // Front detailing cuts
    socket_front_module_recess_cut();
    socket_apertures_cut();
    screw_holes_and_countersink_cut();

    // Rear cuts
    rear_terminal_features_cut();
    mains_socket_features_cut();
  }
}

assembly();