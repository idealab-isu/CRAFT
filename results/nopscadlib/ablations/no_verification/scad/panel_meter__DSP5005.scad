// Ruideng-style panel meter / power supply module (panel-mount)
// One connected solid with distinct front bezel + recessed screen, buttons, rear terminal block, and PCB-like rear details.
// All placements are formula-based (no arbitrary floating).

$fn = 64;

// -------------------- Parameters --------------------
overall_width  = 48;   //[24:96:1]  // body width (behind panel)
overall_height = 29;   //[15:58:1]  // body height (behind panel)
overall_depth  = 24;   //[12:48:1]  // total depth behind panel (body + rear features)

bezel_width     = 50;  //[25:100:1]
bezel_height    = 31;  //[16:62:1]
bezel_thickness = 3;   //[1.5:8:0.5]
bezel_corner_radius = 2.5; //[0:8:0.5]

display_aperture_width  = 36; //[18:72:1]
display_aperture_height = 14; //[7:28:1]
display_aperture_corner_radius = 1; //[0:5:0.5]

body_wall_thickness = 1.6; //[0.8:4:0.1]
body_depth_behind_panel = 21; //[10:42:1] // main body depth (not including bezel thickness)

tab_enabled = 1; //[0:1:1]
tab_width = 6; //[3:12:1]
tab_height = 10; //[5:20:1]
tab_thickness = 2; //[1:5:0.5]
tab_offset_from_front = 10; //[0:25:1]

pcb_enabled = 1; //[0:1:1]
pcb_width = 44; //[22:88:1]
pcb_height = 25; //[13:50:1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_offset_from_front = 18; //[5:40:1]

cutout_clearance = 0.2; //[0:1:0.05]
cutout_extrude_height = 3; //[0:20:1]

button_diameter = 4; //[2:8:0.5]
button_height = 1.5; //[0.5:5:0.5]
button_offset_x = 18; //[0:30:1]
button_offset_y = -10; //[-20:20:1]

eps = 0.25; //[0.05:1:0.05]

// -------------------- Derived --------------------
front_z = 0; // panel/front face reference plane at z=0 (bezel sits in +z, body in -z)

bezel_zc = front_z + bezel_thickness/2;
body_depth = body_depth_behind_panel;
body_zc = front_z - body_depth/2; // body spans from z=-body_depth .. 0

// -------------------- Helpers --------------------
module rounded_box_xy(size=[10,10,2], r=1, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = max(0, min(r, min(sx,sy)/2 - 0.01));
  if (rr <= 0) {
    cube(size, center=center);
  } else {
    minkowski() {
      cube([sx-2*rr, sy-2*rr, sz], center=center);
      cylinder(r=rr, h=0.01, center=true);
    }
  }
}

module rounded_rect_cut(w,h,corner_r,th) {
  rounded_box_xy([w,h,th], r=corner_r, center=true);
}

// -------------------- Main Solid Model --------------------
module panel_meter_solid() {

  // --- Front bezel with recessed screen pocket + button area ---
  module bezel_solid() {
    // Bezel plate
    translate([0,0,bezel_zc])
      rounded_box_xy([bezel_width, bezel_height, bezel_thickness], r=bezel_corner_radius, center=true);

    // Raised rim around screen (distinct front feature)
    rim_t = 1.2;
    rim_h = 1.0;
    rim_outer_w = display_aperture_width + 3.2;
    rim_outer_h = display_aperture_height + 3.2;

    translate([0,0, front_z + bezel_thickness - rim_h/2])
      difference() {
        rounded_box_xy([rim_outer_w, rim_outer_h, rim_h], r=display_aperture_corner_radius+0.8, center=true);
        rounded_rect_cut(display_aperture_width, display_aperture_height, display_aperture_corner_radius, rim_h + 2*eps);
      }

    // Button boss pad integrated into bezel
    boss_d = button_diameter + 2.2;
    boss_h = 0.9;
    translate([button_offset_x, button_offset_y, front_z + bezel_thickness - boss_h/2])
      cylinder(d=boss_d, h=boss_h, center=true);

    // Small secondary "key" pad (common on these modules) near opposite side
    key_pad_w = 7;
    key_pad_h = 5;
    key_pad_t = 0.7;
    key_x = -bezel_width*0.28;
    key_y = button_offset_y;
    translate([key_x, key_y, front_z + bezel_thickness - key_pad_t/2])
      rounded_box_xy([key_pad_w, key_pad_h, key_pad_t], r=1.0, center=true);
  }

  // --- Body shell with internal cavity + screen pocket (so front isn't a plain block) ---
  module body_shell() {
    difference() {
      // Outer body block connected to bezel (overlap by eps)
      translate([0,0, body_zc - eps/2])
        cube([overall_width, overall_height, body_depth + eps], center=true);

      // Inner cavity
      inner_w = overall_width - 2*body_wall_thickness;
      inner_h = overall_height - 2*body_wall_thickness;
      inner_d = body_depth - body_wall_thickness; // keep a back wall

      // Shift cavity rearward so front wall is thicker
      cavity_zc = (front_z - body_depth) + inner_d/2 + body_wall_thickness*0.7;
      translate([0,0, cavity_zc])
        cube([inner_w, inner_h, inner_d], center=true);

      // Screen window cut through bezel + front wall
      cut_d = bezel_thickness + body_wall_thickness + 2*eps;
      cut_zc = front_z + (bezel_thickness - cut_d)/2;
      translate([0,0, cut_zc])
        rounded_rect_cut(display_aperture_width, display_aperture_height, display_aperture_corner_radius, cut_d);

      // Recess pocket behind the window (gives recognizable "display cavity")
      pocket_w = display_aperture_width + 2.0;
      pocket_h = display_aperture_height + 2.0;
      pocket_d = min(6, body_depth - 2*body_wall_thickness);
      pocket_zc = front_z - pocket_d/2 - body_wall_thickness*0.2;
      translate([0,0, pocket_zc])
        rounded_rect_cut(pocket_w, pocket_h, display_aperture_corner_radius+0.6, pocket_d + 2*eps);
    }
  }

  // --- Panel retention clips/tabs (integrated, not floating) ---
  module retention_tabs() {
    if (tab_enabled) {
      tab_zc = front_z - tab_offset_from_front - tab_thickness/2;
      tab_zc_clamped = max(front_z - body_depth + tab_thickness/2, min(front_z - tab_thickness/2, tab_zc));

      x_left  = -(overall_width/2 + tab_width/2 - eps);
      x_right =  (overall_width/2 + tab_width/2 - eps);

      translate([x_left, 0, tab_zc_clamped])
        cube([tab_width, tab_height, tab_thickness], center=true);

      translate([x_right, 0, tab_zc_clamped])
        cube([tab_width, tab_height, tab_thickness], center=true);

      // Hook lips toward front, connected to tabs
      lip_t = 1.2;
      lip_h = tab_height*0.55;
      lip_w = tab_width*0.9;
      lip_zc = tab_zc_clamped + (tab_thickness/2 + lip_t/2 - eps);

      translate([x_left, 0, lip_zc])
        cube([lip_w, lip_h, lip_t], center=true);

      translate([x_right, 0, lip_zc])
        cube([lip_w, lip_h, lip_t], center=true);
    }
  }

  // --- Rear connector/terminal block (distinct back geometry) ---
  module rear_connectors() {
    rear_face_z = front_z - body_depth;

    // Terminal block protruding from rear face
    term_w = overall_width * 0.70;
    term_h = overall_height * 0.46;
    term_d = 7;

    term_zc = rear_face_z - term_d/2 + eps; // touches rear face with overlap
    term_y  = -overall_height*0.14;

    translate([0, term_y, term_zc])
      cube([term_w, term_h, term_d], center=true);

    // Screw boss cylinders protruding further back (aligned to terminal block)
    boss_d = 5.4;
    boss_len = 3.0;
    boss_zc = (rear_face_z - term_d) - boss_len/2 + eps; // connected to terminal block
    boss_x = term_w*0.24;

    for (sx = [-1, 1]) {
      translate([sx*boss_x, term_y, boss_zc])
        rotate([90,0,0])
          cylinder(d=boss_d, h=boss_len, center=true);
    }

    // Small cable strain relief ridge under terminal block (connected)
    ridge_w = term_w*0.92;
    ridge_h = term_h*0.18;
    ridge_d = 2.2;
    ridge_zc = (rear_face_z - term_d) + ridge_d/2 - eps; // overlaps into terminal block
    ridge_y  = term_y - term_h/2 + ridge_h/2;
    translate([0, ridge_y, ridge_zc])
      cube([ridge_w, ridge_h, ridge_d], center=true);
  }

  // --- PCB slab + rear ribs (connected via standoffs) ---
  module pcb_and_features() {
    if (pcb_enabled) {
      pcb_zc = front_z - pcb_offset_from_front - pcb_thickness/2;
      pcb_zc_clamped = max(front_z - body_depth + pcb_thickness/2 + 0.6,
                           min(front_z - pcb_thickness/2 - 0.6, pcb_zc));

      // PCB
      translate([0,0, pcb_zc_clamped])
        cube([pcb_width, pcb_height, pcb_thickness], center=true);

      // Standoffs connecting PCB toward rear (overlap PCB by eps)
      st_d = 3.2;
      st_h = 4.2;
      st_zc = pcb_zc_clamped - (pcb_thickness/2 + st_h/2 - eps);

      st_x = pcb_width*0.42;
      st_y = pcb_height*0.38;

      for (sx = [-1,1], sy = [-1,1]) {
        translate([sx*st_x, sy*st_y, st_zc])
          cylinder(d=st_d, h=st_h, center=true);
      }

      // Rear rib block connected to body rear
      rear_face_z = front_z - body_depth;
      rib_w = overall_width*0.82;
      rib_h = overall_height*0.20;
      rib_d = 3.2;
      rib_zc = rear_face_z - rib_d/2 + eps;
      rib_y = overall_height*0.28;

      translate([0, rib_y, rib_zc])
        cube([rib_w, rib_h, rib_d], center=true);

      // Fins protruding further back, connected to rib block
      rib_count = 6;
      fin_w = rib_w/(rib_count*1.7);
      fin_h = rib_h*1.25;
      fin_d = 2.2;
      fin_zc = (rear_face_z - rib_d) - fin_d/2 + eps;

      for (i=[0:rib_count-1]) {
        x = -rib_w/2 + (i+0.5)*rib_w/rib_count;
        translate([x, rib_y, fin_zc])
          cube([fin_w, fin_h, fin_d], center=true);
      }

      // Small side "PCB rail" bumps on inner walls (adds recognizable internal structure)
      rail_w = body_wall_thickness*1.2;
      rail_h = overall_height*0.55;
      rail_d = 2.0;
      rail_zc = pcb_zc_clamped + (pcb_thickness/2 + rail_d/2 - eps); // touches PCB
      rail_x = overall_width/2 - body_wall_thickness/2; // inside wall
      for (sx=[-1,1]) {
        translate([sx*rail_x, 0, rail_zc])
          cube([rail_w, rail_h, rail_d], center=true);
      }
    }
  }

  // --- Front buttons (two caps) integrated into bezel bosses/pads ---
  module button_caps() {
    cap_zc = front_z + bezel_thickness - button_height/2 + eps;

    // Main round button
    translate([button_offset_x, button_offset_y, cap_zc])
      cylinder(d=button_diameter, h=button_height, center=true);

    // Secondary smaller button (common on RD modules)
    b2_d = button_diameter*0.85;
    b2_h = button_height*0.95;
    b2_x = button_offset_x - (button_diameter*1.2 + 4);
    b2_y = button_offset_y;
    translate([b2_x, b2_y, cap_zc])
      cylinder(d=b2_d, h=b2_h, center=true);
  }

  // --- Assemble as one connected solid ---
  union() {
    bezel_solid();
    body_shell();
    retention_tabs();
    rear_connectors();
    pcb_and_features();
    button_caps();
  }
}

// -------------------- Panel Cutout (connected via bridge so final is ONE solid) --------------------
module panel_cutout_connected() {
  cut_w = overall_width + 2*cutout_clearance;
  cut_h = overall_height + 2*cutout_clearance;
  cut_d = max(cutout_extrude_height, eps);

  // Put cutout in front of bezel
  cut_zc = front_z + bezel_thickness + cut_d/2 + eps;

  // Bridge from bezel top edge to cutout (touching both)
  bridge_t = 0.9;
  bridge_w = 2.2;

  // Z span between bezel front surface and cutout back surface
  z0 = front_z + bezel_thickness;      // bezel front surface
  z1 = cut_zc - cut_d/2;               // cutout back surface
  bridge_len = (z1 - z0) + 2*eps;
  bridge_zc  = (z0 + z1)/2;

  // Place bridge near top edge; y uses formula (no arbitrary)
  bridge_y = bezel_height/2 - bridge_w/2 - (bezel_corner_radius + 0.6);
  bridge_x = 0;

  union() {
    translate([0,0,cut_zc])
      cube([cut_w, cut_h, cut_d], center=true);

    translate([bridge_x, bridge_y, bridge_zc])
      cube([bridge_t, bridge_w, bridge_len], center=true);
  }
}

// -------------------- Final Assembly (ONE connected solid) --------------------
union() {
  panel_meter_solid();
  panel_cutout_connected();
}