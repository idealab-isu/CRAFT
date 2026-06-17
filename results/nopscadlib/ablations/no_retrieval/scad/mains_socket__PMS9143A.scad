// Screwfix Essential (style) UK 13A unswitched socket (BS1363) - improved geometry
// One connected solid, no floating parts, all translations derived from dimensions.

$fn = 72;

// -------------------- Parameters --------------------
plate_W = 86;
plate_H = 86;
plate_T = 7;
corner_R = 6;

// Front recess / inner "module" area
recess_W = 52;
recess_H = 52;
recess_D = 1.6;

// Front raised module (around apertures)
module_proud_W = 50;
module_proud_H = 50;
module_proud_T = 2.2;
module_proud_corner_R = 2;

// Back terminal housing (rear body)
backbox_W = 60;
backbox_H = 60;
backbox_D = 28;
backbox_corner_R = 3;

// Rear "terminal block" bulge (suggests Screwfix Essential rear features)
termblock_W = 52;
termblock_H = 34;
termblock_D = 10;
termblock_corner_R = 2.5;

// Cable entry boss (rear)
cable_boss_W = 22;
cable_boss_H = 14;
cable_boss_D = 6;
cable_boss_corner_R = 2;

// Cable entry hole (rear)
cable_hole_d = 10;

// Terminal clamp bosses (rear detail)
clamp_boss_d = 8;
clamp_boss_h = 4;
clamp_hole_d = 3.2;

// Pin apertures (UK BS1363)
earth_slot_W = 6.5;
earth_slot_H = 12.5;
live_slot_W  = 6.5;
live_slot_H  = 10.5;
neutral_slot_W = 6.5;
neutral_slot_H = 10.5;

// Slot spacing (BS1363 characteristic)
slot_spacing_X = 22;
slot_spacing_Y = 18;

// Mounting screws (UK faceplate: vertical)
screw_hole_d = 3.8;
screw_countersink_d = 8.5;
screw_countersink_depth = 2.2;
screw_spacing_Y = 60;

// Backbox fixing bosses aligned with faceplate screws
boss_d = 10;
boss_h = 7;
boss_hole_d = 3.2;

// Shutter suggestion (shallow relief; remains one solid)
shutter_T = 0.6;
shutter_inset = 0.5;
shutter_margin = 1.2;

// General
eps = 0.01;
overlap = 0.8; // intentional overlap to guarantee connectivity

// -------------------- Helpers --------------------
module rounded_rect_prism(w, h, t, r, center=true) {
  translate(center ? [0,0,0] : [w/2, h/2, t/2])
    hull() {
      for (sx = [-1, 1], sy = [-1, 1])
        translate([sx*(w/2 - r), sy*(h/2 - r), 0])
          cylinder(r=r, h=t, center=true);
    }
}

module countersunk_hole(thru_h, hole_d, cs_d, cs_h) {
  union() {
    cylinder(d=hole_d, h=thru_h + 2*eps, center=true);
    translate([0,0, thru_h/2 - cs_h/2])
      cylinder(d=cs_d, h=cs_h + 2*eps, center=true);
  }
}

module pin_apertures_cut(total_cut_h) {
  // BS1363: Earth at top, L/N at bottom
  union() {
    translate([0, slot_spacing_Y/2, 0])
      cube([earth_slot_W, earth_slot_H, total_cut_h], center=true);

    translate([-slot_spacing_X/2, -slot_spacing_Y/2, 0])
      cube([neutral_slot_W, neutral_slot_H, total_cut_h], center=true);

    translate([ slot_spacing_X/2, -slot_spacing_Y/2, 0])
      cube([live_slot_W, live_slot_H, total_cut_h], center=true);
  }
}

module shutter_relief() {
  // Shallow raised plates behind apertures (still one solid)
  z = plate_T/2 - recess_D - shutter_inset - shutter_T/2;
  union() {
    translate([0, slot_spacing_Y/2, z])
      cube([earth_slot_W + 2*shutter_margin, earth_slot_H + 2*shutter_margin, shutter_T], center=true);
    translate([-slot_spacing_X/2, -slot_spacing_Y/2, z])
      cube([neutral_slot_W + 2*shutter_margin, neutral_slot_H + 2*shutter_margin, shutter_T], center=true);
    translate([ slot_spacing_X/2, -slot_spacing_Y/2, z])
      cube([live_slot_W + 2*shutter_margin, live_slot_H + 2*shutter_margin, shutter_T], center=true);
  }
}

// -------------------- Main Solid --------------------
module socket_solid() {
  // Z reference: plate centered at Z=0, front is +Z, back is -Z
  union() {
    // Faceplate
    rounded_rect_prism(plate_W, plate_H, plate_T, corner_R, center=true);

    // Inner raised module on front (proud)
    translate([0,0, plate_T/2 + module_proud_T/2 - overlap])
      rounded_rect_prism(module_proud_W, module_proud_H, module_proud_T, module_proud_corner_R, center=true);

    // Backbox (rear body)
    translate([0,0, -(plate_T/2 + backbox_D/2 - overlap)])
      rounded_rect_prism(backbox_W, backbox_H, backbox_D, backbox_corner_R, center=true);

    // Rear terminal block bulge (attached to backbox rear face)
    translate([0,0,
      -(plate_T/2 + backbox_D - overlap) - termblock_D/2 + overlap])
      rounded_rect_prism(termblock_W, termblock_H, termblock_D, termblock_corner_R, center=true);

    // Cable entry boss on rear terminal block (attached)
    translate([0,0,
      -(plate_T/2 + backbox_D - overlap) - termblock_D + overlap - cable_boss_D/2 + overlap])
      rounded_rect_prism(cable_boss_W, cable_boss_H, cable_boss_D, cable_boss_corner_R, center=true);

    // Screw bosses inside backbox aligned with faceplate screws
    for (sy = [-1, 1]) {
      translate([0, sy*screw_spacing_Y/2, -(plate_T/2 + boss_h/2 - overlap)])
        cylinder(d=boss_d, h=boss_h, center=true);
    }

    // Rear terminal clamp bosses (3) on terminal block face (suggests L/N/E terminals)
    // Positioned to correspond to BS1363 layout (E top, N left, L right)
    clamp_face_z = -(plate_T/2 + backbox_D - overlap) - termblock_D/2 + overlap; // center of termblock
    clamp_front_z = clamp_face_z + termblock_D/2 - clamp_boss_h/2 - 1.0; // slightly inset from termblock front face
    union() {
      translate([0,  slot_spacing_Y/2, clamp_front_z])
        cylinder(d=clamp_boss_d, h=clamp_boss_h, center=true);
      translate([-slot_spacing_X/2, -slot_spacing_Y/2, clamp_front_z])
        cylinder(d=clamp_boss_d, h=clamp_boss_h, center=true);
      translate([ slot_spacing_X/2, -slot_spacing_Y/2, clamp_front_z])
        cylinder(d=clamp_boss_d, h=clamp_boss_h, center=true);
    }

    // Shutter relief (raised, not separate)
    shutter_relief();
  }
}

module socket_cuts() {
  // Front recess
  translate([0,0, plate_T/2 - recess_D/2])
    cube([recess_W, recess_H, recess_D + 2*eps], center=true);

  // Pin apertures: cut through plate + proud module + a bit into backbox
  total_cut_h = plate_T + module_proud_T + 8;
  // Center the cut so it starts at the front and extends inward
  cut_center_z = (plate_T/2 + module_proud_T - overlap) - total_cut_h/2 + 0.5;
  translate([0,0, cut_center_z])
    pin_apertures_cut(total_cut_h);

  // Mounting screw holes + countersinks (front)
  for (sy = [-1, 1]) {
    translate([0, sy*screw_spacing_Y/2, 0])
      countersunk_hole(plate_T + 2*eps, screw_hole_d, screw_countersink_d, screw_countersink_depth);
  }

  // Boss pilot holes (within bosses only)
  for (sy = [-1, 1]) {
    translate([0, sy*screw_spacing_Y/2, -(plate_T/2 + boss_h/2 - overlap)])
      cylinder(d=boss_hole_d, h=boss_h + 2*eps, center=true);
  }

  // Rear cable entry hole (through cable boss + into terminal block slightly)
  cable_boss_center_z =
    -(plate_T/2 + backbox_D - overlap) - termblock_D + overlap - cable_boss_D/2 + overlap;
  translate([0,0, cable_boss_center_z])
    cylinder(d=cable_hole_d, h=cable_boss_D + 4, center=true);

  // Rear terminal clamp screw holes (shallow, do not pass through front)
  clamp_face_z = -(plate_T/2 + backbox_D - overlap) - termblock_D/2 + overlap;
  clamp_front_z = clamp_face_z + termblock_D/2 - clamp_boss_h/2 - 1.0;
  for (p = [
      [0,  slot_spacing_Y/2, clamp_front_z],
      [-slot_spacing_X/2, -slot_spacing_Y/2, clamp_front_z],
      [ slot_spacing_X/2, -slot_spacing_Y/2, clamp_front_z]
    ]) {
    translate(p)
      cylinder(d=clamp_hole_d, h=clamp_boss_h + 2*eps, center=true);
  }
}

// -------------------- Final Output (ONE connected solid) --------------------
difference() {
  socket_solid();
  socket_cuts();
}