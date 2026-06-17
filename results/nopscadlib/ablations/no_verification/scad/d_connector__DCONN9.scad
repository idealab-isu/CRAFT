// D-sub style connector (single connected solid)
// All placements are dimension-derived (no arbitrary offsets)

// ---------- Parameters ----------
shell_W = 30; //[15:60:1]
shell_H = 12; //[6:24:1]
shell_depth = 8; //[4:16:1]
shell_wall_t = 1.2; //[0.6:2.4:0.1]
face_plate_t = 2; //[1:4:0.1]

rear_body_W = 26; //[13:52:1]
rear_body_H = 10; //[5:20:1]
rear_body_L = 18; //[9:36:1]

flange_W = 40; //[20:80:1]
flange_H = 16; //[8:32:1]
flange_t = 2.5; //[1.25:5:0.1]

mount_hole_d = 3.2; //[1.6:6.4:0.1]
mount_hole_spacing = 33; //[16.5:66:0.5]

overlap = 1; //[0.5:2:0.1]

pin_cols = 5; //[2:15:1]
pin_rows = 2; //[1:3:1]
pin_pitch_x = 2.77; //[1.5:5.5:0.01]
pin_pitch_y = 2.84; //[1.5:6:0.01]
pin_d = 1; //[0.5:2:0.05]
pin_L = 6; //[3:12:0.5]

jackscrew_d = 5; //[3:8:0.1]
jackscrew_L = 10; //[5:20:0.5]

strain_relief_d = 12; //[6:24:0.5]
strain_relief_L = 10; //[5:20:0.5]

key_bump_W = 4; //[2:8:0.5]
key_bump_H = 2; //[1:4:0.25]
key_bump_L = 1.5; //[0.75:3:0.1]

chamfer_r = 0.8; //[0.4:1.6:0.1]

// ---------- Derived positions (Z axis: front = negative, rear = positive) ----------
z_flange_center      = 0;
z_flange_front       = z_flange_center - flange_t/2;
z_flange_back        = z_flange_center + flange_t/2;

z_face_center        = z_flange_front - face_plate_t/2 + overlap; // slight overlap into flange
z_face_front         = z_face_center - face_plate_t/2;

z_shell_center       = z_flange_back + shell_depth/2 - overlap;   // overlap into flange
z_shell_back         = z_shell_center + shell_depth/2;

z_rear_center        = z_shell_back + rear_body_L/2 - overlap;     // overlap into shell
z_rear_back          = z_rear_center + rear_body_L/2;

z_strain_center      = z_rear_back + strain_relief_L/2 - overlap;  // overlap into rear body

z_jackscrew_center   = z_shell_back - jackscrew_L/2 + overlap;     // overlap into shell

z_pin_center         = z_face_front - pin_L/2 + overlap;           // overlap into face plate

// ---------- 2D D-shape profile ----------
module d_profile(w, h) {
  // Flat on bottom, rounded-ish top corners (polygon approximation)
  polygon(points=[
    [-w/2, -h/2],
    [ w/2, -h/2],
    [ w/2,  0],
    [ w/2 - h/2,  h/2],
    [-w/2 + h/2,  h/2],
    [-w/2,  0]
  ]);
}

// ---------- Parts ----------
module flange_block() {
  translate([0,0,z_flange_center])
    cube([flange_W, flange_H, flange_t], center=true);
}

module mount_holes() {
  for (sx = [-1, 1])
    translate([sx*mount_hole_spacing/2, 0, z_flange_center])
      cylinder(r=mount_hole_d/2, h=flange_t + 2*overlap, center=true, $fn=48);
}

module shell_outer() {
  translate([0,0,z_shell_center])
    linear_extrude(height=shell_depth, center=true)
      d_profile(shell_W, shell_H);
}

module shell_inner_cut() {
  translate([0,0,z_shell_center])
    linear_extrude(height=shell_depth + 2*overlap, center=true)
      d_profile(shell_W - 2*shell_wall_t, shell_H - 2*shell_wall_t);
}

module d_shaped_shell() {
  difference() {
    shell_outer();
    shell_inner_cut();
  }
}

module mating_face_plate() {
  translate([0,0,z_face_center])
    cube([shell_W, shell_H, face_plate_t], center=true);
}

module rear_body_block() {
  translate([0,0,z_rear_center])
    cube([rear_body_W, rear_body_H, rear_body_L], center=true);
}

module strain_relief_cyl() {
  translate([0,0,z_strain_center])
    cylinder(r=strain_relief_d/2, h=strain_relief_L, center=true, $fn=64);
}

module jackscrews() {
  for (sx = [-1, 1])
    translate([sx*mount_hole_spacing/2, 0, z_jackscrew_center])
      cylinder(r=jackscrew_d/2, h=jackscrew_L, center=true, $fn=48);
}

module pin_proto() {
  translate([0,0,z_pin_center])
    cylinder(r=pin_d/2, h=pin_L, center=true, $fn=24);
}

module pin_array() {
  // Center the array about X=0; two rows about Y=0
  x0 = -(pin_cols-1)*pin_pitch_x/2;
  y0 = -(pin_rows-1)*pin_pitch_y/2;

  for (r = [0:pin_rows-1])
    for (c = [0:pin_cols-1])
      translate([x0 + c*pin_pitch_x, y0 + r*pin_pitch_y, 0])
        pin_proto();
}

module key_bump() {
  // Small key on the mating face (front side), overlaps into face plate
  translate([0, -shell_H/2 + key_bump_H/2, z_face_center])
    cube([key_bump_W, key_bump_H, key_bump_L], center=true);
}

// ---------- Assembly ----------
module connector_raw() {
  union() {
    // Flange with holes
    difference() {
      flange_block();
      mount_holes();
    }

    // D-shell and face
    d_shaped_shell();
    mating_face_plate();

    // Rear body + strain relief (connected via overlaps)
    rear_body_block();
    strain_relief_cyl();

    // Hardware + pins + key (all connected via overlaps)
    jackscrews();
    pin_array();
    key_bump();
  }
}

// Fillet/chamfer via Minkowski (kept small)
module connector_final() {
  minkowski() {
    connector_raw();
    sphere(r=chamfer_r, $fn=24);
  }
}

// ---------- Output ----------
connector_final();