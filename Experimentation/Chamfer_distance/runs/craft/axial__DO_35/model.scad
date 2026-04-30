// Parameters (mm)
body_length_mm = 0.55; //[0.275:1.1:0.01]
body_diameter_mm = 0.25; //[0.125:0.5:0.01]
lead_diameter_mm = 0.1; //[0.05:0.2:0.01]
lead_pitch_mm = 2.54; //[1.27:5.08:0.01]
standoff_height_mm = 0; //[0:0.55:0.01]
lead_exit_fillets_mm = 0.05; //[0:0.1:0.005]
connect_overlap_mm = 0.01; //[0.005:0.05:0.005]
rail_pitch_mm = 1.0; //[0.5:2.0:0.1]
rail_length_mm = 5.0; //[2.5:10.0:0.1]
ttrack_pitch_mm = 1.0; //[0.5:2.0:0.1]
ttrack_length_mm = 5.0; //[2.5:10.0:0.1]

$fn=32;

// ---------- Helpers ----------
module rounded_rect_2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  hull() {
    translate([ w/2 - r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2,  h/2 - r2]) circle(r=r2);
    translate([-w/2 + r2, -h/2 + r2]) circle(r=r2);
    translate([ w/2 - r2, -h/2 + r2]) circle(r=r2);
  }
}

module hex_prism(flat_d, h) {
  // flat-to-flat = flat_d
  r = flat_d / sqrt(3);
  cylinder(r=r, h=h, center=true, $fn=6);
}

// ---------- [MANDATORY] [PRIMARY] Orientate Axial ----------
module orientate_axial() {
  // Derived from plan
  body_r = body_diameter_mm/2;
  lead_r = lead_diameter_mm/2;
  lead_len = (lead_pitch_mm - body_length_mm) + 2*connect_overlap_mm;

  collar_r = (lead_diameter_mm/2 + lead_exit_fillets_mm);
  collar_len = lead_diameter_mm + 2*connect_overlap_mm;

  // Positions from plan (kept as expressions)
  lead_left_pos_x  = -(body_length_mm/2 + (lead_len)/2 - connect_overlap_mm);
  lead_right_pos_x =  (body_length_mm/2 + (lead_len)/2 - connect_overlap_mm);

  collar_left_pos_x  = -(body_length_mm/2 - (collar_len)/2 + connect_overlap_mm);
  collar_right_pos_x =  (body_length_mm/2 - (collar_len)/2 + connect_overlap_mm);

  color([0.75, 0.55, 0.20])  // resistor-like body color
  union() {
    // Body (cylinder along X)
    translate([0, 0, standoff_height_mm])
      rotate([0, 90, 0])
        cylinder(r=body_r, h=body_length_mm, center=true);

    // Subtle end caps / paint bands (still along X)
    band_w = min(0.08, body_length_mm*0.18);
    for (sx = [-1, 1]) {
      translate([sx*(body_length_mm/2 - band_w/2), 0, standoff_height_mm])
        rotate([0, 90, 0])
          color([0.25, 0.25, 0.27])
            cylinder(r=body_r*0.98, h=band_w, center=true);
    }

    // Exit collars (reinforcement)
    translate([collar_left_pos_x, 0, standoff_height_mm])
      rotate([0, 90, 0])
        color([0.65, 0.48, 0.18])
          cylinder(r=collar_r, h=collar_len, center=true);

    translate([collar_right_pos_x, 0, standoff_height_mm])
      rotate([0, 90, 0])
        color([0.65, 0.48, 0.18])
          cylinder(r=collar_r, h=collar_len, center=true);
  }

  // Leads (metal)
  color([0.72, 0.72, 0.75])
  union() {
    translate([lead_left_pos_x, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=lead_r, h=lead_len, center=true);

    translate([lead_right_pos_x, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=lead_r, h=lead_len, center=true);

    // Small straight "tips" at ends to make lead ends visually clear
    tip_len = max(0.12, lead_diameter_mm*2);
    translate([-lead_pitch_mm/2 + tip_len/2, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=lead_r*0.95, h=tip_len, center=true);

    translate([ lead_pitch_mm/2 - tip_len/2, 0, 0])
      rotate([0, 90, 0])
        cylinder(r=lead_r*0.95, h=tip_len, center=true);
  }
}

// ---------- [MANDATORY] [SECONDARY] Screw Knob Assembly ----------
module screw_knob_assembly() {
  // A connected knob + screw passing through a small printed clamp block.
  // Attached to the axial component near +X side.
  knob_d = 6.0;
  knob_h = 3.0;
  knurl_count = 14;

  screw_d = 1.6;      // small screw
  screw_len = 10.0;

  head_d = 3.0;
  head_h = 1.2;

  block_w = 6.5;
  block_t = 3.0;
  block_h = 4.0;
  block_r = 0.8;

  // Place so it touches the axial body region (connect rule)
  attach_x = body_length_mm/2 + 0.25;
  attach_z = standoff_height_mm + body_diameter_mm/2 + block_h/2 - 0.05;

  translate([attach_x, 0, attach_z])
  union() {
    // Printed block (off-white)
    color([0.85, 0.85, 0.80])
    difference() {
      linear_extrude(height=block_h, center=true)
        rounded_rect_2d(block_w, block_t, block_r);

      // Through hole for screw (along Y)
      rotate([90, 0, 0])
        cylinder(d=screw_d + 0.2, h=block_t + 2*connect_overlap_mm, center=true, $fn=24);

      // Shallow counterbore for head on +Y side
      translate([0, block_t/2 - 0.35, 0])
        rotate([90, 0, 0])
          cylinder(d=head_d + 0.3, h=0.9, center=true, $fn=24);
    }

    // Screw (steel)
    color([0.45, 0.45, 0.48])
    union() {
      // Shaft through block (along Y)
      rotate([90, 0, 0])
        cylinder(d=screw_d, h=screw_len, center=true, $fn=24);

      // Head on +Y side
      translate([0, screw_len/2 - head_h/2, 0])
        rotate([90, 0, 0])
          cylinder(d=head_d, h=head_h, center=true, $fn=32);

      // Simple Phillips-like cross recess
      translate([0, screw_len/2 - head_h + 0.15, 0])
        rotate([90, 0, 0])
          difference() {
            cylinder(d=head_d*0.92, h=0.35, center=true, $fn=32);
            union() {
              cube([head_d*0.15, head_d*0.75, 0.6], center=true);
              cube([head_d*0.75, head_d*0.15, 0.6], center=true);
            }
          }
    }

    // Knob on -Y side (black), connected to screw shaft
    color([0.12, 0.12, 0.14])
    translate([0, -(screw_len/2 - knob_h/2), 0])
    union() {
      // Main knob body
      cylinder(d=knob_d, h=knob_h, center=true, $fn=32);

      // Knurl bumps
      for (i = [0:knurl_count-1]) {
        ang = i*360/knurl_count;
        rotate([0, 0, ang])
          translate([knob_d/2 - 0.35, 0, 0])
            cylinder(d=0.6, h=knob_h*0.9, center=true, $fn=12);
      }

      // Center boss around screw
      cylinder(d=head_d*0.9, h=knob_h*1.05, center=true, $fn=32);
    }
  }
}

// ---------- [MANDATORY] [SECONDARY] Rail Hole Positions ----------
module rail_hole_positions() {
  // Represented as a small rail strip with a line of holes (visual "positions").
  // Attached under the axial leads (connected).
  rail_w = 4.0;
  rail_t = 1.2;
  rail_hole_d = 1.0;

  // Use provided placeholders: first=0, screws=100, both_ends=true
  // We'll show a reasonable subset based on rail_length_mm and rail_pitch_mm.
  n = max(2, floor(rail_length_mm/rail_pitch_mm) + 1);

  attach_z = -rail_t/2 - lead_diameter_mm/2 + 0.02; // touch leads
  translate([0, 0, attach_z])
  color([0.75, 0.75, 0.77])
  difference() {
    cube([rail_length_mm, rail_w, rail_t], center=true);

    // Holes along X
    for (i = [0:n-1]) {
      x = -rail_length_mm/2 + i*(rail_length_mm/(n-1));
      translate([x, 0, 0])
        cylinder(d=rail_hole_d, h=rail_t + 2*connect_overlap_mm, center=true, $fn=24);
    }

    // Ensure both ends emphasized (both_ends=true): slightly larger end holes
    translate([-rail_length_mm/2, 0, 0])
      cylinder(d=rail_hole_d*1.25, h=rail_t + 2*connect_overlap_mm, center=true, $fn=24);
    translate([ rail_length_mm/2, 0, 0])
      cylinder(d=rail_hole_d*1.25, h=rail_t + 2*connect_overlap_mm, center=true, $fn=24);
  }
}

// ---------- [MANDATORY] [SECONDARY] Ttrack Hole Positions ----------
module ttrack_hole_positions() {
  // A small T-track-like bar with countersunk holes, attached to rail strip side.
  bar_l = ttrack_length_mm;
  bar_w = 6.0;
  bar_t = 1.6;

  hole_d = 1.2;
  cs_d = 2.4;
  cs_h = 0.7;

  n = max(2, floor(ttrack_length_mm/ttrack_pitch_mm) + 1);

  // Attach to +Y edge of rail strip (touching)
  attach_y = (4.0/2 + bar_w/2) - 0.05; // rail_w assumed 4.0 in rail module
  attach_z = -bar_t/2 - lead_diameter_mm/2 + 0.02;

  translate([0, attach_y, attach_z])
  color([0.55, 0.55, 0.58])
  difference() {
    cube([bar_l, bar_w, bar_t], center=true);

    for (i = [0:n-1]) {
      x = -bar_l/2 + i*(bar_l/(n-1));
      translate([x, 0, 0])
      union() {
        cylinder(d=hole_d, h=bar_t + 2*connect_overlap_mm, center=true, $fn=24);
        translate([0, 0, bar_t/2 - cs_h/2])
          cylinder(d1=cs_d, d2=hole_d, h=cs_h, center=true, $fn=32);
      }
    }
  }
}

// ---------- [MANDATORY] [SECONDARY] Ttrack Insert Hole Positions ----------
module ttrack_insert_hole_positions() {
  // A small insert plate with hex pockets (like T-nut insert positions), attached to T-track bar.
  plate_l = ttrack_length_mm * 0.8;
  plate_w = 5.0;
  plate_t = 1.4;

  pocket_flat = 2.6;
  pocket_depth = 0.9;
  thru_d = 1.2;

  n = max(2, floor(plate_l/ttrack_pitch_mm) + 1);

  // Attach above the T-track bar (touching)
  attach_y = (4.0/2 + 6.0/2) - 0.05; // rail_w + bar_w relationship
  attach_z = (-1.6 - lead_diameter_mm)/2 + 0.02 + plate_t/2 + 0.05; // sit on top of bar

  translate([0, attach_y, attach_z])
  color([0.80, 0.60, 0.20]) // brass-like inserts plate
  difference() {
    cube([plate_l, plate_w, plate_t], center=true);

    for (i = [0:n-1]) {
      x = -plate_l/2 + i*(plate_l/(n-1));
      translate([x, 0, 0]) {
        // Through hole
        cylinder(d=thru_d, h=plate_t + 2*connect_overlap_mm, center=true, $fn=24);
        // Hex pocket on top face
        translate([0, 0, plate_t/2 - pocket_depth/2])
          hex_prism(pocket_flat, pocket_depth + connect_overlap_mm);
      }
    }
  }
}

// ---------- Assembly (matches plan operations intent) ----------
module assembly() {
  union() {
    // Primary
    orientate_axial();

    // Secondary components attached to primary (no floating parts)
    screw_knob_assembly();
    rail_hole_positions();
    ttrack_hole_positions();
    ttrack_insert_hole_positions();
  }
}

assembly();