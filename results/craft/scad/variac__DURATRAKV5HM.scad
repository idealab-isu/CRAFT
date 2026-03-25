$fn = 128;

// -------------------- Parameters --------------------
thickness = 3; //[1.5:6:0.5]
dial_enabled = 1; //[0:1:1]

// Enclosure (box-style variac form factor)
case_w = 150; //[90:240:1]
case_d = 120; //[70:200:1]
case_h = 95;  //[50:160:1]
case_corner_r = 8; //[2:20:0.5]

// Front panel / face
front_panel_th = 4; //[2:10:0.5]
front_bezel_r  = 3; //[0:10:0.5]

// Knob / dial
knob_diameter  = 85; //[40:140:1]
knob_thickness = 18; //[8:40:1]
knob_hub_d     = 28; //[12:60:0.5]
knob_hub_h     = 14; //[6:30:0.5]

// Shaft (solid, passes into case)
shaft_diameter     = 8;  //[4:16:0.5]
shaft_length_out   = 10; //[4:30:1]
shaft_length_in    = 25; //[10:60:1]

// Scale/markings area (raised plate; no text)
scale_w = 95; //[50:160:1]
scale_h = 28; //[12:60:1]
scale_th = 2.2; //[1:6:0.2]
scale_offset_y = 0; //[-20:20:1]
scale_offset_z = 0; //[-20:20:1]

// Rear terminal block
term_block_w = 70; //[40:120:1]
term_block_d = 28; //[16:60:1]
term_block_h = 26; //[14:60:1]
term_block_corner_r = 3; //[0:10:0.5]

// Terminal studs (solid posts on rear block)
stud_count = 4; //[2:6:1]
stud_d = 6; //[3:12:0.5]
stud_h = 10; //[5:20:1]
stud_spacing = 18; //[10:30:1]

// Feet (bottom)
foot_d = 14; //[8:24:1]
foot_h = 6;  //[3:15:1]
foot_inset = 14; //[6:30:1]

// Mount holes (through feet area)
mount_hole_d = 4.5; //[3:8:0.5]
mount_hole_extra = 2; //[1:6:0.5]

// General overlap for watertight unions/differences
overlap = 1; //[0.5:2:0.1]

// -------------------- Helpers --------------------
module rounded_box(size=[10,10,10], r=2, center=true) {
  sx=size[0]; sy=size[1]; sz=size[2];
  rr = min(r, min(sx,sy)/2);
  translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    hull() {
      for (x=[-1,1], y=[-1,1])
        translate([x*(sx/2-rr), y*(sy/2-rr), 0])
          cylinder(r=rr, h=sz, center=true);
    }
}

module chamfered_plate(w, h, t, r=2) {
  // Light rounded rectangle plate
  rounded_box([w, h, t], r=r, center=true);
}

// -------------------- Main solids --------------------
module case_solid() {
  // Main enclosure + front panel lip + rear terminal block + feet
  union() {
    // Main case
    rounded_box([case_w, case_d, case_h], r=case_corner_r, center=true);

    // Front panel (slight proud bezel)
    translate([0, case_d/2 + front_panel_th/2 - overlap, 0])
      rounded_box([case_w*0.96, front_panel_th, case_h*0.92], r=front_bezel_r, center=true);

    // Rear terminal block (connected to rear face)
    translate([0, -(case_d/2 + term_block_d/2 - overlap), -(case_h*0.18)])
      rounded_box([term_block_w, term_block_d, term_block_h], r=term_block_corner_r, center=true);

    // Feet (4) connected to bottom
    foot_z = -(case_h/2 + foot_h/2 - overlap);
    for (sx=[-1,1], sy=[-1,1]) {
      translate([sx*(case_w/2 - foot_inset), sy*(case_d/2 - foot_inset), foot_z])
        cylinder(r=foot_d/2, h=foot_h, center=true);
    }

    // Scale/markings area plate on front (no text)
    // Place above knob, on front panel
    scale_z = scale_offset_z + case_h*0.18;
    translate([0, case_d/2 + front_panel_th - overlap + scale_th/2, scale_z])
      chamfered_plate(scale_w, scale_h, scale_th, r=2);
  }
}

module knob_and_shaft_solid() {
  if (dial_enabled) {
    // Knob on front face, connected with overlap into front panel
    knob_y = case_d/2 + front_panel_th - overlap + knob_thickness/2;
    translate([0, knob_y, 0])
      cylinder(r=knob_diameter/2, h=knob_thickness, center=true);

    // Hub (slightly taller center boss)
    hub_y = case_d/2 + front_panel_th - overlap + knob_thickness + knob_hub_h/2;
    translate([0, hub_y, 0])
      cylinder(r=knob_hub_d/2, h=knob_hub_h, center=true);

    // Shaft: extends out a bit and into the case (solid, connected)
    shaft_total = shaft_length_out + shaft_length_in + front_panel_th;
    // Center shaft so it spans from outside to inside through the front panel
    // Front face plane is at +case_d/2; shaft axis along Y
    shaft_center_y = case_d/2 + (shaft_length_out - shaft_length_in)/2;
    translate([0, shaft_center_y, 0])
      rotate([90,0,0])
        cylinder(r=shaft_diameter/2, h=shaft_total, center=true);
  }
}

module terminal_studs_solid() {
  // Studs on rear terminal block top surface (connected)
  // Terminal block center:
  tb_y = -(case_d/2 + term_block_d/2 - overlap);
  tb_z = -(case_h*0.18);
  // Place studs on outer (rear) face side of the block, but still connected
  stud_y = tb_y - term_block_d/2 + stud_h/2 - overlap; // protrude rearward
  // Arrange studs in a row along X, centered
  total_span = (stud_count-1)*stud_spacing;
  for (i=[0:stud_count-1]) {
    x = -total_span/2 + i*stud_spacing;
    translate([x, stud_y, tb_z + term_block_h*0.15])
      cylinder(r=stud_d/2, h=stud_h, center=true);
  }
}

module mount_holes_cut() {
  // Through holes in feet (drill up through feet and into case slightly)
  hole_h = foot_h + mount_hole_extra + thickness;
  for (sx=[-1,1], sy=[-1,1]) {
    translate([sx*(case_w/2 - foot_inset), sy*(case_d/2 - foot_inset), -(case_h/2 + foot_h/2 - overlap)])
      cylinder(r=mount_hole_d/2, h=hole_h, center=true);
  }
}

module rear_terminal_recess_cut() {
  // Small recess pockets on terminal block rear face (suggest connectors)
  tb_y = -(case_d/2 + term_block_d/2 - overlap);
  tb_z = -(case_h*0.18);

  pocket_w = term_block_w*0.82;
  pocket_h = term_block_h*0.55;
  pocket_d = term_block_d*0.45;

  translate([0, tb_y - term_block_d/2 + pocket_d/2 + overlap, tb_z])
    rounded_box([pocket_w, pocket_d, pocket_h], r=2, center=true);
}

module front_knob_clearance_cut() {
  // Shallow circular recess around knob base on front panel (visual detail)
  recess_r = knob_diameter*0.58;
  recess_h = front_panel_th*0.7;
  recess_y = case_d/2 + recess_h/2 - overlap; // cut into front panel
  translate([0, recess_y, 0])
    cylinder(r=recess_r, h=recess_h, center=true);
}

// -------------------- Assembly (ONE connected solid) --------------------
module variac() {
  union() {
    difference() {
      union() {
        case_solid();
        knob_and_shaft_solid();
        terminal_studs_solid();
      }
      mount_holes_cut();
      rear_terminal_recess_cut();
      front_knob_clearance_cut();
    }
  }
}

variac();