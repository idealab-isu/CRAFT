$fn = 64;

// -------------------- Parameters --------------------
cutout_width_mm = 36; //[18:72:0.5]
cutout_height_mm = 27; //[13.5:54:0.5]
cutout_corner_radius_mm = 1.5; //[0:5:0.5]
panel_thickness_mm = 2; //[1:6:0.5]

flange_overhang_x_mm = 6; //[0:15:0.5]
flange_overhang_y_mm = 5; //[0:15:0.5]
flange_thickness_mm = 3; //[1:8:0.5]

rear_body_depth_mm = 45; //[20:90:1]
rear_body_clearance_x_mm = 40; //[20:80:0.5]
rear_body_clearance_y_mm = 30; //[15:60:0.5]

fuse_drawer_width_mm = 18; //[10:30:0.5]
fuse_drawer_height_mm = 12; //[6:24:0.5]
fuse_drawer_depth_mm = 12; //[6:30:0.5]
include_fuse_drawer_envelope = 1; //[0:1:1]

include_terminal_spades_envelope = 1; //[0:1:1]
spade_block_width_mm = 28; //[0:60:0.5]
spade_block_height_mm = 18; //[0:40:0.5]
spade_block_depth_mm = 10; //[0:30:0.5]

mounting_method = 0; //[0:1:1]
screw_hole_diameter_mm = 3.2; //[0:6:0.1]
screw_hole_pitch_x_mm = 40; //[0:80:0.5]
screw_hole_pitch_y_mm = 0; //[0:40:0.5]

clip_tab_width_mm = 8; //[0:20:0.5]
clip_tab_height_mm = 6; //[0:20:0.5]
clip_tab_depth_mm = 4; //[0:15:0.5]

overlap_mm = 1; //[0.5:2:0.1]
panel_size_x_mm = 60; //[40:120:1]
panel_size_y_mm = 50; //[35:120:1]

// -------------------- Helpers --------------------
module rrect2d(w, h, r) {
  r2 = min(r, min(w, h)/2);
  if (r2 <= 0)
    square([w, h], center=true);
  else
    offset(r=r2) offset(delta=-r2) square([w, h], center=true);
}

module rrect3d(w, h, t, r) {
  linear_extrude(height=t, center=true)
    rrect2d(w, h, r);
}

// -------------------- IEC fused inlet (approximate JR-101-1F) --------------------
module iec_inlet_module() {
  // Derived sizes
  flange_w = cutout_width_mm + 2*flange_overhang_x_mm;
  flange_h = cutout_height_mm + 2*flange_overhang_y_mm;

  // Main body behind panel
  body_w = min(rear_body_clearance_x_mm, cutout_width_mm + 8);
  body_h = min(rear_body_clearance_y_mm, cutout_height_mm + 8);
  body_d = rear_body_depth_mm;

  // Front face "C14 mouth" recess (more recognizable)
  mouth_w = cutout_width_mm - 8;
  mouth_h = cutout_height_mm - 8;
  mouth_r = 2.2;
  mouth_d = min(9, flange_thickness_mm + panel_thickness_mm + 5);

  // Inner "step" recess to suggest IEC profile depth
  step_w = mouth_w - 4;
  step_h = mouth_h - 4;
  step_r = 1.6;
  step_d = min(4.5, mouth_d - 1);

  // Pin openings (approx)
  pin_slot_w = 6.6;
  pin_slot_h = 4.2;
  pin_slot_depth = mouth_d + 2*overlap_mm;
  pin_pitch_x = 10.0;
  pin_y = -2.0;

  // Earth opening (approx)
  earth_w = 5.2;
  earth_h = 4.8;
  earth_y = pin_y + 7.2;

  // Fuse drawer (front top-right typical)
  fuse_w = fuse_drawer_width_mm;
  fuse_h = fuse_drawer_height_mm;
  fuse_d = fuse_drawer_depth_mm;

  // Terminal block at rear
  term_w = spade_block_width_mm;
  term_h = spade_block_height_mm;
  term_d = spade_block_depth_mm;

  // Spade tabs (3)
  tab_w = 6.3;
  tab_t = 0.9;
  tab_l = 10.0;
  tab_pitch_x = 10.0;

  // Z placements (formulas)
  // Panel centered at z=0, front is +Z, rear is -Z
  flange_z = panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm; // overlap into panel
  body_total_t = panel_thickness_mm + body_d;                            // includes panel thickness for guaranteed connection
  body_z   = -body_d/2 + overlap_mm;                                     // spans from +panel/2 into rear
  mouth_z  = panel_thickness_mm/2 + flange_thickness_mm - mouth_d/2;     // starts at front face, goes inward
  step_z   = panel_thickness_mm/2 + flange_thickness_mm - step_d/2;      // shallow step at front
  term_z   = (-body_d - panel_thickness_mm/2) + term_d/2 + overlap_mm;   // attached to rear end of body
  tab_z    = term_z - term_d/2 - tab_l/2 + overlap_mm;                   // protrude further rear

  // Fuse drawer placement: on front face, upper-right quadrant
  fuse_x = cutout_width_mm/2 - fuse_w/2;
  fuse_y = cutout_height_mm/2 - fuse_h/2;
  fuse_z = panel_thickness_mm/2 + flange_thickness_mm - fuse_d/2 + overlap_mm;

  // Clip tabs on sides (rear side of panel)
  clip_z = -panel_thickness_mm/2 - clip_tab_depth_mm/2 + overlap_mm;

  // Fuse drawer "pull lip" notch
  notch_w = max(6, fuse_w - 4);
  notch_h = max(4, fuse_h - 5);
  notch_d = min(4, fuse_d);

  // Small fuse finger recess (semi-cyl) to read as drawer
  finger_r = min(2.2, notch_h/2);
  finger_d = min(2.5, notch_d);

  color("Black")
  union() {
    difference() {
      union() {
        // Front flange/bezel
        translate([0, 0, flange_z])
          rrect3d(flange_w, flange_h, flange_thickness_mm, cutout_corner_radius_mm);

        // Main body behind panel (guaranteed connected to panel by spanning through it)
        translate([0, 0, body_z])
          rrect3d(body_w, body_h, body_total_t, max(0, cutout_corner_radius_mm-0.5));

        // Fuse drawer housing (protruding feature on the front)
        if (include_fuse_drawer_envelope)
          translate([fuse_x, fuse_y, fuse_z])
            rrect3d(fuse_w, fuse_h, fuse_d, 1.2);

        // Rear terminal block
        if (include_terminal_spades_envelope)
          translate([0, 0, term_z])
            rrect3d(term_w, term_h, term_d, 1.2);

        // Spade tabs (3) protruding from rear terminal block
        if (include_terminal_spades_envelope) {
          for (i = [-1, 0, 1]) {
            translate([i*tab_pitch_x, 0, tab_z])
              cube([tab_w, tab_t, tab_l], center=true);
          }
        }

        // Clip tabs (snap-in) on left/right, attached near panel plane
        if (mounting_method == 0) {
          translate([-cutout_width_mm/2 - clip_tab_width_mm/2 + overlap_mm, 0, clip_z])
            cube([clip_tab_width_mm, clip_tab_height_mm, clip_tab_depth_mm], center=true);
          translate([ cutout_width_mm/2 + clip_tab_width_mm/2 - overlap_mm, 0, clip_z])
            cube([clip_tab_width_mm, clip_tab_height_mm, clip_tab_depth_mm], center=true);
        }
      }

      // Carve inlet mouth recess (C14-ish)
      translate([0, 0, mouth_z])
        rrect3d(mouth_w, mouth_h, mouth_d, mouth_r);

      // Carve inner step recess to suggest IEC face geometry
      translate([0, 0, step_z])
        rrect3d(step_w, step_h, step_d + 2*overlap_mm, step_r);

      // Carve pin openings (3)
      translate([-pin_pitch_x/2, pin_y, mouth_z])
        rrect3d(pin_slot_w, pin_slot_h, pin_slot_depth, 0.8);
      translate([ pin_pitch_x/2, pin_y, mouth_z])
        rrect3d(pin_slot_w, pin_slot_h, pin_slot_depth, 0.8);
      translate([0, earth_y, mouth_z])
        rrect3d(earth_w, earth_h, pin_slot_depth, 0.8);

      // Carve fuse drawer front notch + finger recess
      if (include_fuse_drawer_envelope) {
        notch_z = panel_thickness_mm/2 + flange_thickness_mm - notch_d/2 + overlap_mm;
        translate([fuse_x, fuse_y, notch_z])
          rrect3d(notch_w, notch_h, notch_d + 2*overlap_mm, 0.9);

        // Finger recess (half-cylinder) centered in notch
        finger_z = panel_thickness_mm/2 + flange_thickness_mm - finger_d/2 + overlap_mm;
        translate([fuse_x, fuse_y, finger_z])
          rotate([90, 0, 0])
            cylinder(r=finger_r, h=notch_w + 2*overlap_mm, center=true);
      }

      // Mounting screw holes (if selected) through flange+panel
      if (mounting_method == 1) {
        pitch_y = (screw_hole_pitch_y_mm <= 0) ? (cutout_height_mm + flange_overhang_y_mm) : screw_hole_pitch_y_mm;
        for (x = [-screw_hole_pitch_x_mm/2, screw_hole_pitch_x_mm/2])
          for (y = [-pitch_y/2, pitch_y/2])
            translate([x, y, panel_thickness_mm/2 + flange_thickness_mm/2 - overlap_mm])
              cylinder(r=screw_hole_diameter_mm/2,
                       h=flange_thickness_mm + panel_thickness_mm + 4*overlap_mm,
                       center=true);
      }
    }
  }
}

// -------------------- Panel (kept connected by overlap) --------------------
module panel_with_cutout() {
  color("Silver")
  difference() {
    cube([panel_size_x_mm, panel_size_y_mm, panel_thickness_mm], center=true);
    translate([0, 0, 0])
      rrect3d(cutout_width_mm, cutout_height_mm, panel_thickness_mm + 2*overlap_mm, cutout_corner_radius_mm);
  }
}

// -------------------- Assembly: ONE connected solid --------------------
union() {
  panel_with_cutout();
  iec_inlet_module();
}