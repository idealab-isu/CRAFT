$fn = 96;

// =====================
// DURATRAK V5HM variac (stylized, connected solid)
// Fixes:
// - Add recognizable variac front: prominent dial face + scale ticks + pointer
// - Add typical front-panel controls: switch, lamp, terminal posts
// - Ensure ALL parts are connected using dimension-based formulas (no floating)
// - Keep ONE connected solid (union of solids, subtract only shallow details)
// =====================

// Core dimensions (parametric)
body_L = 220; //[110:440:1]
body_W = 170; //[85:340:1]
body_H = 160; //[80:320:1]

wall_t = 2.5; //[1.2:6:0.1]
front_panel_t = 3; //[1.5:8:0.1]

overlap = 1; //[0.5:2:0.1]
edge_r = 6; //[0:12:0.5]

// Dial / scale (front)
dial_D = 120; //[60:240:1]
dial_thk = 22; //[10:44:1]
dial_center_from_left = 110; //[55:220:1]     // along Y from left edge (when looking at front)
dial_center_from_bottom = 95; //[40:160:1]    // along Z from bottom edge
dial_shaft_D = 6.35; //[3:12:0.05]
dial_shaft_len = 18; //[8:40:1]
scale_ring_thk = 4; //[2:10:0.5]
scale_ring_gap = 2; //[1:6:0.5]

// Added: dial face + scale ticks (no text)
dial_face_thk = 2.2; //[1:6:0.1]
dial_face_inset = 1.2; //[0.5:4:0.1]
tick_h = 1.2; //[0.6:3:0.1]
tick_w = 1.6; //[0.8:4:0.1]
tick_len_major = 10; //[5:20:0.5]
tick_len_minor = 6; //[3:14:0.5]
tick_count = 50; //[20:80:1]
tick_major_every = 5; //[2:10:1]

// Front controls / indicators
switch_W = 20; //[10:45:1]
switch_H = 30; //[15:60:1]
switch_depth = 18; //[8:40:1]
lamp_D = 10; //[5:20:0.5]
lamp_depth = 12; //[6:30:1]

// Output terminal block (front-right)
receptacle_block_W = 55; //[25:110:1]
receptacle_block_H = 35; //[18:80:1]
receptacle_block_depth = 25; //[10:60:1]
term_post_D = 7; //[4:14:0.5]
term_post_H = 10; //[5:20:0.5]
term_post_spacing = 18; //[10:30:1]

// Rear inlet / strain relief
rear_inlet_W = 28; //[14:60:1]
rear_inlet_H = 20; //[10:45:1]
rear_inlet_depth = 18; //[8:40:1]
strain_relief_D = 14; //[8:26:0.5]
strain_relief_len = 10; //[5:25:0.5]

// Feet
feet_D = 18; //[10:36:1]
feet_H = 6; //[3:15:0.5]
feet_inset = 15; //[6:40:1]

// Vents
vent_slot_W = 6; //[3:12:0.5]
vent_slot_H = 2.5; //[1:6:0.1]
vent_slot_depth = 6; //[3:15:0.5]
vent_rows = 3; //[1:6:1]
vent_cols = 10; //[3:18:1]
vent_margin = 18; //[8:40:1]

// Mounting ears (base flanges)
ear_L = 26; //[10:60:1]
ear_W = 18; //[8:40:1]
ear_H = 6;  //[3:15:0.5]
ear_hole_D = 6; //[3:12:0.5]

// Small front bezel lip
bezel_out = 3; //[0:8:0.5]
bezel_step = 2; //[0:6:0.5]

// =====================
// Helpers
// =====================
module rounded_box(size=[10,10,10], r=2, center=true) {
  r2 = min(r, min(size[0], min(size[1], size[2]))/2 - 0.01);
  if (r2 <= 0) cube(size, center=center);
  else minkowski() {
    cube([size[0]-2*r2, size[1]-2*r2, size[2]-2*r2], center=center);
    sphere(r=r2);
  }
}

function dialY() = (-body_W/2) + dial_center_from_left;
function dialZ() = (-body_H/2) + dial_center_from_bottom;

// =====================
// Main enclosure (solid block with bezel + ears)
// =====================
module enclosure_body() {
  union() {
    rounded_box([body_L, body_W, body_H], r=edge_r, center=true);

    // Front bezel lip (protrudes slightly)
    translate([ body_L/2 + bezel_out/2 - overlap, 0, 0 ])
      rounded_box([bezel_out, body_W - 2*bezel_step, body_H - 2*bezel_step],
                  r=max(edge_r-2,0), center=true);

    // Bottom mounting ears (left/right)
    for (sy = [-1, 1]) {
      translate([0, sy*(body_W/2 + ear_W/2 - overlap), -body_H/2 + ear_H/2 - overlap])
        rounded_box([ear_L, ear_W, ear_H], r=2, center=true);
    }
  }
}

// =====================
// Dial assembly (scale ring + dial face + ticks + knob + pointer + shaft)
// =====================
module dial_assembly() {
  x_face = body_L/2; // front face plane (approx)
  x_ring = x_face + scale_ring_thk/2 - overlap;
  x_knob = x_face + dial_thk/2 - overlap;
  x_shaft = x_face + dial_thk + dial_shaft_len/2 - overlap;

  // Dial face sits slightly behind knob front, but still connected via overlap
  x_faceplate = x_face + (dial_thk/2 - dial_face_inset) - dial_face_thk/2;

  y = dialY();
  z = dialZ();

  union() {
    // Scale ring (thin disc behind knob)
    translate([x_ring, y, z])
      rotate([0,90,0])
        difference() {
          cylinder(r=dial_D/2 + 12, h=scale_ring_thk, center=true);
          cylinder(r=dial_D/2 + scale_ring_gap, h=scale_ring_thk + 2*overlap, center=true);
        }

    // Dial face plate (gives recognizable "dial face")
    translate([x_faceplate, y, z])
      rotate([0,90,0])
        cylinder(r=dial_D/2 + 6, h=dial_face_thk, center=true);

    // Scale ticks (raised, no text). Connected to face plate by overlap.
    // Place ticks around upper ~300 degrees (leave small gap at bottom).
    tick_r = dial_D/2 + 2; // near rim of face
    for (i=[0:tick_count-1]) {
      ang = -240 + i*(300/(tick_count-1)); // degrees
      is_major = (i % tick_major_every == 0);
      tlen = is_major ? tick_len_major : tick_len_minor;

      translate([x_faceplate + dial_face_thk/2 - overlap, y, z])
        rotate([0,90,0])
          rotate([0,0,ang])
            // inner edge overlaps into face by 'overlap'
            translate([tick_r + tlen/2 - overlap, 0, 0])
              cube([tlen, tick_w, tick_h], center=true);
    }

    // Knob (stepped + ribs)
    translate([x_knob, y, z])
      rotate([0,90,0])
        union() {
          cylinder(r=dial_D/2, h=dial_thk, center=true);

          // Front grip ridge
          translate([0,0,dial_thk/2 - 4])
            cylinder(r=dial_D/2 + 3, h=6, center=true);

          // Pointer ridge on rim (small protrusion)
          rotate([0,0,25])
            translate([dial_D/2 + 2, 0, 0])
              cube([8, 10, dial_thk-6], center=true);

          // Knurl-like ribs (radial array, protruding outward)
          num_ribs = 18;
          rib_len = 6;
          rib_w = 4;
          rib_h = dial_thk - 8;
          for (j=[0:num_ribs-1]) {
            rotate([0,0,j*360/num_ribs])
              translate([dial_D/2 + rib_len/2 - 1, 0, 0]) // overlap into knob by 1
                cube([rib_len, rib_w, rib_h], center=true);
          }
        }

    // Shaft
    translate([x_shaft, y, z])
      rotate([0,90,0])
        cylinder(r=dial_shaft_D/2, h=dial_shaft_len, center=true);
  }
}

// =====================
// Front terminal block with posts (connected)
// =====================
module output_terminal_block() {
  x = body_L/2 + receptacle_block_depth/2 - overlap;
  y = body_W/2 - wall_t - receptacle_block_W/2;
  z = (-body_H/2) + wall_t + receptacle_block_H/2 + body_H*0.12;

  union() {
    translate([x, y, z])
      rounded_box([receptacle_block_depth, receptacle_block_W, receptacle_block_H], r=2, center=true);

    // Three terminal posts on the front face of the block
    x_post = (body_L/2 + receptacle_block_depth - overlap) + term_post_H/2 - overlap;
    for (i=[-1,0,1]) {
      translate([x_post, y + i*term_post_spacing, z])
        rotate([0,90,0])
          cylinder(r=term_post_D/2, h=term_post_H, center=true);
    }

    // Small cable clamp ridge on top of block
    translate([x, y, z + receptacle_block_H/2 - 3])
      cube([receptacle_block_depth, receptacle_block_W*0.7, 6], center=true);
  }
}

// =====================
// Front switch + lamp (connected)
// =====================
module front_controls() {
  x_sw = body_L/2 + switch_depth/2 - overlap;
  y_sw = (-body_W/2) + wall_t + switch_W/2 + body_W*0.12;
  z_sw = (-body_H/2) + wall_t + switch_H/2 + body_H*0.12;

  x_l = body_L/2 + lamp_depth/2 - overlap;
  y_l = (-body_W/2) + wall_t + lamp_D/2 + body_W*0.12;
  z_l = (-body_H/2) + wall_t + switch_H + lamp_D/2 + body_H*0.12;

  union() {
    translate([x_sw, y_sw, z_sw])
      rounded_box([switch_depth, switch_W, switch_H], r=2, center=true);

    translate([x_l, y_l, z_l])
      rotate([0,90,0])
        cylinder(r=lamp_D/2, h=lamp_depth, center=true);

    // Lamp bezel ring (thin)
    translate([body_L/2 + 1 - overlap, y_l, z_l])
      rotate([0,90,0])
        difference() {
          cylinder(r=lamp_D/2 + 3, h=2, center=true);
          cylinder(r=lamp_D/2 + 1, h=2 + 2*overlap, center=true);
        }
  }
}

// =====================
// Rear inlet + strain relief (connected)
// =====================
module rear_inlet() {
  x_blk = -body_L/2 - rear_inlet_depth/2 + overlap;
  y_blk = 0;
  z_blk = (-body_H/2) + wall_t + rear_inlet_H/2 + body_H*0.18;

  x_sr = -body_L/2 - rear_inlet_depth + strain_relief_len/2 + overlap;
  union() {
    translate([x_blk, y_blk, z_blk])
      rounded_box([rear_inlet_depth, rear_inlet_W, rear_inlet_H], r=2, center=true);

    translate([x_sr, y_blk, z_blk])
      rotate([0,90,0])
        cylinder(r=strain_relief_D/2, h=strain_relief_len, center=true);
  }
}

// =====================
// Feet (connected)
// =====================
module feet() {
  z = -body_H/2 - feet_H/2 + overlap;
  union() {
    translate([-body_L/2 + feet_inset, -body_W/2 + feet_inset, z])
      cylinder(r=feet_D/2, h=feet_H, center=true);
    translate([ body_L/2 - feet_inset, -body_W/2 + feet_inset, z])
      cylinder(r=feet_D/2, h=feet_H, center=true);
    translate([-body_L/2 + feet_inset,  body_W/2 - feet_inset, z])
      cylinder(r=feet_D/2, h=feet_H, center=true);
    translate([ body_L/2 - feet_inset,  body_W/2 - feet_inset, z])
      cylinder(r=feet_D/2, h=feet_H, center=true);
  }
}

// =====================
// Vent cutouts (subtractive) - side/top vents
// Keep shallow so body remains robust and single solid.
// =====================
module vents_cutouts() {
  xL = -body_L/2 + wall_t/2;
  xR =  body_L/2 - wall_t/2;
  z0 =  body_H/2 - wall_t - vent_margin;

  y_span = body_W - 2*vent_margin;
  y_step = (vent_cols > 1) ? (y_span/(vent_cols-1)) : 0;

  z_span = 22;
  z_step = (vent_rows > 1) ? (z_span/(vent_rows-1)) : 0;

  for (side=[0,1]) {
    x = (side==0) ? xL : xR;
    for (r=[0:vent_rows-1]) {
      for (c=[0:vent_cols-1]) {
        y = -body_W/2 + vent_margin + c*y_step;
        z = z0 - r*z_step;
        translate([x, y, z])
          cube([vent_slot_depth, vent_slot_W, vent_slot_H], center=true);
      }
    }
  }

  // Top vents
  x_span = body_L*0.55;
  x_step = (vent_cols > 1) ? (x_span/(vent_cols-1)) : 0;
  for (r=[0:1]) {
    for (c=[0:vent_cols-1]) {
      x = -x_span/2 + c*x_step;
      y = (r==0 ? -body_W*0.18 : body_W*0.18);
      z = body_H/2 - wall_t/2;
      translate([x, y, z])
        cube([vent_slot_W, vent_slot_depth, vent_slot_H], center=true);
    }
  }
}

// =====================
// Mounting ear holes (subtractive)
// =====================
module ear_holes_cutouts() {
  for (sy=[-1,1]) {
    translate([0, sy*(body_W/2 + ear_W/2 - overlap), -body_H/2 + ear_H/2 - overlap])
      rotate([90,0,0])
        cylinder(r=ear_hole_D/2, h=ear_W + 2*overlap, center=true);
  }
}

// =====================
// Main model (ONE connected solid)
// =====================
module variac_v5hm() {
  difference() {
    union() {
      enclosure_body();
      dial_assembly();
      output_terminal_block();
      front_controls();
      rear_inlet();
      feet();
    }
    vents_cutouts();
    ear_holes_cutouts();
  }
}

variac_v5hm();