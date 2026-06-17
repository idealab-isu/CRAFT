// Stepper motor (NEMA17-like) - corrected, connected, verifiable dimensions

$fn = 96;

// Parameters (requested key dims)
face_W = 42.3;          // face width (X,Y)
body_L = 47.0;          // body length (Z)
shaft_D = 5.0;          // shaft diameter
mount_spacing = 31.0;   // mounting hole spacing (square pattern)

// Additional details
body_corner_R = 2.0;
shaft_L = 20.0;
boss_D = 22.0;
boss_H = 2.0;
mount_hole_D = 3.2;
face_thk = 3.0;
shaft_flat_depth = 0.5;
shaft_flat_L = 10.0;
rear_cap_thk = 2.5;
rear_cap_inset = 0.8;
cable_D = 6.0;
cable_L = 12.0;
cable_offset_Y = 10.0;
nameplate_W = 20.0;
nameplate_H = 12.0;
nameplate_thk = 0.8;
nameplate_offset_Y = 0.0;
nameplate_offset_Z = 0.0;
chamfer_D = 5.0;
chamfer_depth = 0.8;

// Robust overlap for watertight union
overlap = 0.6;

// Rounded-rectangle prism (true rounded corners)
module rounded_prism_xy(w, h, z, r) {
  linear_extrude(height=z, center=true)
    offset(r=r)
      square([w - 2*r, h - 2*r], center=true);
}

// Motor body (rounded corners)
module motor_body() {
  color("Black")
    rounded_prism_xy(face_W, face_W, body_L, body_corner_R);
}

// Front face plate with mounting holes + shallow counterbore/chamfer
module front_face_with_holes() {
  color("DimGray")
  difference() {
    translate([0, 0, body_L/2 - face_thk/2 + overlap])
      cube([face_W, face_W, face_thk], center=true);

    // Through holes
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * mount_spacing/2, y * mount_spacing/2, body_L/2 - face_thk/2 + overlap])
        cylinder(h=face_thk + 2*overlap, r=mount_hole_D/2, center=true);

      // Shallow chamfer/counterbore on the outer face
      translate([x * mount_spacing/2, y * mount_spacing/2, body_L/2 + chamfer_depth/2 - overlap])
        cylinder(h=chamfer_depth + 2*overlap, r=chamfer_D/2, center=true);
    }
  }
}

// Front boss (pilot)
module front_face_boss() {
  color("Silver")
  translate([0, 0, body_L/2 + boss_H/2 - overlap])
    cylinder(h=boss_H, r=boss_D/2, center=true);
}

// Output shaft with flat (flat cut near tip)
module shaft_with_flat() {
  color("Silver")
  difference() {
    // Shaft connected to boss with overlap
    translate([0, 0, body_L/2 + boss_H + shaft_L/2 - overlap])
      cylinder(h=shaft_L, r=shaft_D/2, center=true);

    // Flat: remove a slab along +X side over last shaft_flat_L length
    translate([shaft_D/2 - shaft_flat_depth/2, 0,
               (body_L/2 + boss_H + shaft_L) - shaft_flat_L/2 - overlap])
      cube([shaft_D, shaft_D*1.2, shaft_flat_L + 2*overlap], center=true);
  }
}

// Rear cap (slightly inset)
module rear_cap() {
  color("Black")
  translate([0, 0, -body_L/2 + rear_cap_thk/2 - overlap])
    cube([face_W - 2*rear_cap_inset, face_W - 2*rear_cap_inset, rear_cap_thk], center=true);
}

// Cable exit (connected to rear face)
module cable_exit() {
  color("Black")
  translate([0, cable_offset_Y, -body_L/2 - cable_L/2 + overlap])
    cylinder(h=cable_L, r=cable_D/2, center=true);
}

// Nameplate (connected to side)
module nameplate() {
  color("Silver")
  translate([face_W/2 + nameplate_thk/2 - overlap, nameplate_offset_Y, nameplate_offset_Z])
    cube([nameplate_thk, nameplate_W, nameplate_H], center=true);
}

// Assembly: one connected solid (union of connected parts)
module motor_assembly() {
  union() {
    motor_body();
    front_face_with_holes();
    front_face_boss();
    shaft_with_flat();
    rear_cap();
    cable_exit();
    nameplate();
  }
}

motor_assembly();