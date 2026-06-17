// Parameters
clip_type = 0; //[0:1:1]
open = 0.9; //[0.2:1.2:0.05]
include_spigot_hole = 1; //[0:1:1]
hole_depth_h = 0; //[0:30:1]
overlap = 1; //[0.5:2:0.1]
t = 0.8; //[0.4:1.6:0.05]
length = 45; //[25:90:1]
width = 18; //[10:36:1]
height = 16; //[8:32:1]
hinge_offset = 14; //[7:28:1]
arm_l = 16; //[8:32:1]
arm_w = 4; //[2:8:0.5]
hook_x = 10; //[5:20:1]
hook_y = 10; //[5:20:1]
spigot_x = 8; //[4:16:1]
spigot_y = 8; //[4:16:1]
spigot_z = 10; //[5:20:1]
or = 2.5; //[1.5:5:0.1]
arm_angle_deg = 35; //[5:70:1]
spigot_angle_deg = 25; //[5:60:1]
w_narrow = 10; //[6:20:1]
gusset_thickness = 0.8; //[0.4:1.6:0.05]
gusset_len = 6; //[3:12:0.5]
hole_clearance = 0.2; //[0.1:0.6:0.05]

// small guaranteed connection overlap (1-2mm)
conn = 1.2;

// --- Shared layout (single source of truth for all positions) ---
module clip_layout() {
  // Place hook stem at x=0, then build everything from that.
  x_stem = 0;

  // Hook stem (vertical)
  x_hook = x_stem + (t/2 + hook_x/2 - conn);

  // Main body (the previously floating left rectangular block)
  body_len = max(hinge_offset - spigot_x, t);
  x_body = (x_hook + hook_x/2) + (body_len/2 - conn);

  // Spigot base + stem
  sp_base_len = max(spigot_x - or, t);
  x_sp_base = (x_body + body_len/2) + (sp_base_len/2 - conn);
  x_sp_stem = (x_sp_base + sp_base_len/2) + (t/2 - conn);

  // Arm anchor (inside body by conn so rotation still intersects)
  x_arm_anchor = x_body + body_len/2 - conn;

  // Provide all computed values to children
  children(
    x_stem,
    x_hook,
    body_len,
    x_body,
    sp_base_len,
    x_sp_base,
    x_sp_stem,
    x_arm_anchor
  );
}

// Swiss Clip - complete geometry (fixed connectivity)
module swiss_clip() {
  color([0.15, 0.2, 0.35])
  union() {
    clip_layout() {
      x_stem      = $children[0];
      x_hook      = $children[1];
      body_len    = $children[2];
      x_body      = $children[3];
      sp_base_len = $children[4];
      x_sp_base   = $children[5];
      x_sp_stem   = $children[6];
      x_arm_anchor= $children[7];

      // Hook stem (vertical)
      translate([x_stem, 0, (height - 2*or)/2])
        cube([t, hook_y, height - 2*or], center=true);

      // Hook section (bottom pad) - overlaps stem by conn
      translate([x_hook, 0, 0])
        cube([hook_x, hook_y, t], center=true);

      // Hook top - overlaps stem by conn
      hook_top_len = hook_x - or;
      x_hook_top = x_stem + (t/2 + hook_top_len/2 - conn);
      translate([x_hook_top, 0, height - t/2])
        cube([hook_top_len, hook_y, t], center=true);

      // Main clip body block (ensure overlap with hook pad)
      translate([x_body, 0, 0])
        cube([body_len, width, t], center=true);

      // Hinge spigot base - attached to body with overlap
      translate([x_sp_base, 0, 0])
        cube([sp_base_len, spigot_y, t], center=true);

      // Hinge spigot stem - attached to spigot base with overlap
      translate([x_sp_stem, 0, or + (spigot_z - or)/2 - conn])
        cube([t, spigot_y, spigot_z - or], center=true);

      // --- Arms (ensure they intersect the body) ---
      arm_z = t/2;

      rotate([0, -arm_angle_deg*open, 0])
        translate([x_arm_anchor + arm_l/2, -(w_narrow/2 + arm_w/2), arm_z])
          cube([arm_l, arm_w, t], center=true);

      rotate([0, -arm_angle_deg*open, 0])
        translate([x_arm_anchor + arm_l/2,  (w_narrow/2 + arm_w/2), arm_z])
          cube([arm_l, arm_w, t], center=true);

      // --- Gussets (ensure they intersect the body/arms) ---
      x_gus_anchor = x_body + body_len/2 - conn; // inside body by conn

      rotate([0, -(spigot_angle_deg*open), 0])
        translate([x_gus_anchor + gusset_len/2, 0, t/2])
          cube([gusset_len, w_narrow, gusset_thickness], center=true);

      rotate([0, -(spigot_angle_deg*open), 0])
        translate([x_gus_anchor + gusset_len/2, -(w_narrow/2 + arm_w/2), t/2])
          cube([gusset_len, arm_w, gusset_thickness], center=true);

      rotate([0, -(spigot_angle_deg*open), 0])
        translate([x_gus_anchor + gusset_len/2,  (w_narrow/2 + arm_w/2), t/2])
          cube([gusset_len, arm_w, gusset_thickness], center=true);

      // --- Fix floating thin diagonal lever/bar + inner thin bar near circular area ---
      // Create two bars that are GUARANTEED to intersect the spigot stem and the body.
      // Use hull() between two small "pads" so the bar always touches both endpoints.
      bar_w = 1.6;
      bar_h = t;

      // Endpoint pads (overlap into solids by conn)
      // Pad A: inside body near right face
      xA = x_body + body_len/2 - conn;
      zA = t/2;

      // Pad B: inside spigot stem volume
      xB = x_sp_stem;
      zB = or + (spigot_z - or)/2 - conn;

      // Diagonal lever (upper) - touches body and spigot stem
      y_diag = 0;
      hull() {
        translate([xA, y_diag, zA])
          cube([bar_w, bar_w, bar_h], center=true);
        translate([xB, y_diag, zB])
          cube([bar_w, bar_w, bar_h], center=true);
      }

      // Inner thin bar (lower/inner) - also touches body and spigot stem
      // Slightly offset in Y/Z so it is distinct but still connected.
      y_inner = -spigot_y*0.18;
      z_innerA = t/2;
      z_innerB = zB - 1.0; // keep within stem; still overlaps due to hull pads
      hull() {
        translate([xA, y_inner, z_innerA])
          cube([bar_w, bar_w, bar_h], center=true);
        translate([xB, y_inner, z_innerB])
          cube([bar_w, bar_w, bar_h], center=true);
      }

      // --- Fix floating small rectangular piece on left side (top/bottom views) ---
      // Add a small cap/strap that overlaps the hook stem and hook top.
      // This keeps the design but guarantees it is physically attached.
      cap_len = max(hook_x*0.7, 6);
      cap_w   = hook_y;
      cap_h   = t;

      // Place it near the top of the hook, overlapping the stem by conn.
      x_cap = x_stem + (t/2 + cap_len/2 - conn);
      translate([x_cap, 0, height - t/2])
        cube([cap_len, cap_w, cap_h], center=true);

      // --- Add connecting braces (previously could appear separated in top/bottom views) ---
      // Ensure braces overlap into BOTH body and spigot base by using hull pads.
      brace_w = 1.6;
      brace_h = t;

      // Transition region between body and spigot base
      xC = x_body + body_len/2 - conn;          // inside body
      xD = x_sp_base - sp_base_len/2 + conn;    // inside spigot base
      y_off = width*0.18;
      z_br = t/2;

      // Upper brace
      hull() {
        translate([xC,  y_off, z_br]) cube([brace_w, brace_w, brace_h], center=true);
        translate([xD,  y_off, z_br]) cube([brace_w, brace_w, brace_h], center=true);
      }

      // Lower brace
      hull() {
        translate([xC, -y_off, z_br]) cube([brace_w, brace_w, brace_h], center=true);
        translate([xD, -y_off, z_br]) cube([brace_w, brace_w, brace_h], center=true);
      }
    }
  }
}

// Swiss Clip Hole - subtractive geometry ONLY (do not union as a solid)
module swiss_clip_hole() {
  if (include_spigot_hole) {
    clip_layout() {
      x_sp_stem = $children[6];

      translate([x_sp_stem, 0, or + (spigot_z - or)/2 - conn])
        rotate([90, 0, 0])
          cylinder(
            r = sqrt((spigot_y*spigot_y + (spigot_z*spigot_z))/4) + hole_clearance,
            h = max(hole_depth_h, t*4),
            center = true
          );
    }
  }
}

// Assembly: single connected solid, with optional hole as a difference
module assembly() {
  if (include_spigot_hole)
    difference() {
      swiss_clip();
      swiss_clip_hole();
    }
  else
    swiss_clip();
}

assembly();