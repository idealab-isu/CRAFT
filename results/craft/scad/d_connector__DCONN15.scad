$fn = 64;

// Parameters
shell_width = 30; //[15:60:1]
shell_height = 12; //[6:24:1]
shell_depth = 18; //[9:36:1]
shell_wall_thickness = 1.5; //[0.8:3:0.1]
mating_face_thickness = 2.5; //[1.2:5:0.1]
rear_body_width = 26; //[13:52:1]
rear_body_height = 10; //[5:20:1]
rear_body_depth = 20; //[10:40:1]
flange_width = 40; //[20:80:1]
flange_height = 16; //[8:32:1]
flange_thickness = 2.5; //[1.2:5:0.1]
mount_hole_diameter = 3.2; //[2:6:0.1]
mount_hole_spacing = 33; //[16:66:1]
pin_field_width = 18; //[9:36:1]
pin_field_height = 6; //[3:12:1]
pin_field_depth = 4; //[2:10:1]
overlap = 1; //[0.5:2:0.1]
jackscrew_diameter = 5; //[3:10:0.1]
jackscrew_length = 10; //[5:25:1]
pin_diameter = 1; //[0.5:2:0.1]
pin_length = 3; //[1.5:8:0.1]
strain_relief_diameter = 12; //[6:24:1]
strain_relief_length = 10; //[5:25:1]
chamfer_size = 1; //[0.5:3:0.1]

// Derived / helpers
eps = 0.01;
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

// Inner dims (safe)
inner_w = shell_width - 2*shell_wall_thickness;
inner_h = shell_height - 2*shell_wall_thickness;

inner_w_safe = clamp(inner_w, 0.1, 1e9);
inner_h_safe = clamp(inner_h, 0.1, 1e9);

pin_pitch_x = pin_field_width/5;
pin_pitch_y = pin_field_height/2;

// --- D-SUB STYLE PROFILE (symmetric D: flat-ish top/bottom, rounded sides) ---
// This fixes the semantic mismatch: the silhouette is clearly D-shaped in front/back views.
module dsub_profile_2d(w, h) {
  // Build a "capsule" (rounded left/right) then flatten top/bottom slightly.
  // Keep it simple and robust.
  r = h/2;
  flat = clamp(h*0.18, 0.4, r-0.2); // amount to shave off top/bottom to suggest D-sub flats

  difference() {
    // Capsule: rectangle + two semicircles (left/right)
    union() {
      square([w - 2*r, 2*r], center=true);
      translate([-(w/2 - r), 0]) circle(r=r);
      translate([ (w/2 - r), 0]) circle(r=r);
    }
    // Flatten top/bottom a bit (gives the classic D-sub "flatter" top/bottom)
    translate([0,  r - flat/2]) square([w + 2, flat], center=true);
    translate([0, -r + flat/2]) square([w + 2, flat], center=true);
  }
}

module d_shell_outer() {
  linear_extrude(height=shell_depth, center=true)
    dsub_profile_2d(shell_width, shell_height);
}

module d_shell_inner() {
  inner_depth = clamp(shell_depth - 2*shell_wall_thickness, 0.1, 1e9);
  linear_extrude(height=inner_depth, center=true)
    dsub_profile_2d(inner_w_safe, inner_h_safe);
}

module d_shaped_shell() {
  difference() {
    d_shell_outer();
    d_shell_inner();
  }
}

module mating_face_plate() {
  // Front face plate, fused into shell
  zc = -shell_depth/2 + mating_face_thickness/2 + overlap;
  translate([0, 0, zc])
    linear_extrude(height=mating_face_thickness, center=true)
      dsub_profile_2d(shell_width, shell_height);
}

module mounting_flange_with_holes() {
  // Flange at very front, overlapping into shell
  zc = -shell_depth/2 + flange_thickness/2 + overlap;
  translate([0, 0, zc])
  difference() {
    cube([flange_width, flange_height, flange_thickness], center=true);

    for (sx = [-1, 1]) {
      translate([sx*mount_hole_spacing/2, 0, 0])
        cylinder(d=mount_hole_diameter, h=flange_thickness + 2*overlap, center=true);
    }
  }
}

module rear_body_block() {
  // Rear body attaches to back of shell with overlap
  zc = shell_depth/2 + rear_body_depth/2 - overlap;
  translate([0, 0, zc])
    cube([rear_body_width, rear_body_height, rear_body_depth], center=true);
}

module strain_relief() {
  // Strain relief attaches to back of rear body with overlap
  rear_back_z = shell_depth/2 + rear_body_depth - overlap; // rear body's back face (with overlap)
  zc = rear_back_z + strain_relief_length/2 - overlap;
  translate([0, 0, zc])
    cylinder(d=strain_relief_diameter, h=strain_relief_length, center=true);
}

module pin_field_block() {
  // Pin field sits just behind the mating face, inside the shell, fused
  zc = (-shell_depth/2 + mating_face_thickness) + pin_field_depth/2 + overlap;
  translate([0, 0, zc])
    cube([pin_field_width, pin_field_height, pin_field_depth], center=true);
}

module pins_array() {
  // Pins protrude forward from the pin field, fused into it
  pinfield_front_z = (-shell_depth/2 + mating_face_thickness) + pin_field_depth + overlap;
  zc = pinfield_front_z + pin_length/2 - overlap;

  union() {
    for (i = [-1, 0, 1]) {
      translate([i*pin_pitch_x, pin_pitch_y/2, zc])
        cylinder(d=pin_diameter, h=pin_length, center=true);
    }
    for (i = [-0.5, 0.5]) {
      translate([i*pin_pitch_x, -pin_pitch_y/2, zc])
        cylinder(d=pin_diameter, h=pin_length, center=true);
    }
  }
}

module jackscrews() {
  // Jackscrews protrude forward from the flange, fused into it
  flange_front_z = (-shell_depth/2) + flange_thickness + overlap; // flange front face (with overlap)
  zc = flange_front_z + jackscrew_length/2 - overlap;

  for (sx = [-1, 1]) {
    translate([sx*mount_hole_spacing/2, 0, zc])
      cylinder(d=jackscrew_diameter, h=jackscrew_length, center=true);
  }
}

module chamfer_cutters() {
  // Small chamfers on top/bottom edges of the shell
  xw = shell_width + shell_height;
  zw = shell_depth + 2;

  translate([0, shell_height/2 - chamfer_size/2, 0])
    rotate([0, 0, 45])
      cube([xw, chamfer_size, zw], center=true);

  translate([0, -shell_height/2 + chamfer_size/2, 0])
    rotate([0, 0, 45])
      cube([xw, chamfer_size, zw], center=true);
}

// Recessed mating opening (socket cavity) from the front
module mating_opening_cutter() {
  open_w = clamp(inner_w_safe - 1.0, 0.1, 1e9);
  open_h = clamp(inner_h_safe - 1.0, 0.1, 1e9);
  open_d = clamp(mating_face_thickness + pin_field_depth + 0.8, 0.1, 1e9);

  // Start at the front face and go inward
  zc = -shell_depth/2 + open_d/2 + eps;
  translate([0, 0, zc])
    linear_extrude(height=open_d + 2*eps, center=true)
      dsub_profile_2d(open_w, open_h);
}

module connector_main() {
  difference() {
    union() {
      // Core recognizable D-sub features
      d_shaped_shell();
      mounting_flange_with_holes();
      mating_face_plate();

      // Mating face details
      pin_field_block();
      pins_array();
      jackscrews();

      // Rear body / cable end
      rear_body_block();
      strain_relief();
    }
    chamfer_cutters();
    mating_opening_cutter();
  }
}

// Final Output
connector_main();