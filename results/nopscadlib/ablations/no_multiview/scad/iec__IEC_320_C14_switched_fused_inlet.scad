// Parameters
panel_cutout_width = 40.0; //[20.0:80.0:0.1]
panel_cutout_height = 27.0; //[13.5:54.0:0.1]
tolerance_clearance = 0.2; //[0.0:1.0:0.05]
panel_thickness = 2.0; //[1.0:3.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
body_wall = 2.0; //[1.0:4.0:0.1]
body_depth = 30.0; //[15.0:60.0:0.5]
flange_width = 50.0; //[25.0:100.0:0.5]
flange_height = 35.0; //[17.5:70.0:0.5]
flange_thickness = 3.0; //[1.5:6.0:0.1]
bezel_width = 46.0; //[23.0:92.0:0.5]
bezel_height = 31.0; //[15.5:62.0:0.5]
bezel_thickness = 2.0; //[1.0:5.0:0.1]
switch_width = 18.0; //[9.0:36.0:0.5]
switch_height = 12.0; //[6.0:24.0:0.5]
switch_protrusion = 2.0; //[0.5:6.0:0.1]
fuse_width = 22.0; //[11.0:44.0:0.5]
fuse_height = 12.0; //[6.0:24.0:0.5]
fuse_protrusion = 2.0; //[0.5:6.0:0.1]
clip_width = 6.0; //[3.0:12.0:0.5]
clip_height = 10.0; //[5.0:20.0:0.5]
clip_depth = 8.0; //[4.0:20.0:0.5]
spade_width = 6.3; //[3.0:10.0:0.1]
spade_thickness = 0.8; //[0.5:2.0:0.05]
spade_length = 12.0; //[6.0:24.0:0.5]
spade_spacing_x = 7.0; //[3.5:14.0:0.5]
spade_spacing_y = 4.0; //[2.0:10.0:0.5]

// IEC Inlet Module (single connected solid)
module iec() {
  // Derived sizes
  body_w = panel_cutout_width + 2*body_wall;
  body_h = panel_cutout_height + 2*body_wall;

  // Z references (panel plane at z=0)
  body_z  = -panel_thickness/2 - body_depth/2 + overlap;                 // body overlaps into panel by "overlap"
  body_front_z = body_z + body_depth/2;                                   // should be at -panel_thickness/2 + overlap
  body_back_z  = body_z - body_depth/2;

  flange_z = panel_thickness/2 + flange_thickness/2 - overlap;            // overlaps into panel by "overlap"
  flange_front_z = flange_z + flange_thickness/2;

  bezel_z  = panel_thickness/2 + flange_thickness + bezel_thickness/2 - overlap;
  bezel_front_z = bezel_z + bezel_thickness/2;

  // Attach protrusions to bezel front face with overlap
  switch_z = bezel_front_z + switch_protrusion/2 - overlap;
  fuse_z   = bezel_front_z + fuse_protrusion/2 - overlap;

  // Attach clips to body sides with overlap
  clip_x = body_w/2 + clip_width/2 - overlap;
  clip_z = body_z; // centered with body so it intersects fully

  // Attach spades to body back face with overlap
  spade_z = body_back_z - spade_length/2 + overlap;

  color("Black")
  union() {
    // Main Body
    translate([0, 0, body_z])
      cube([body_w, body_h, body_depth], center=true);

    // Front Flange
    translate([0, 0, flange_z])
      cube([flange_width, flange_height, flange_thickness], center=true);

    // Bezel
    translate([0, 0, bezel_z])
      cube([bezel_width, bezel_height, bezel_thickness], center=true);

    // Switch Actuator Region (attached to bezel)
    translate([-(bezel_width/2 - switch_width/2 - overlap),
               (bezel_height/2 - switch_height/2 - overlap),
               switch_z])
      cube([switch_width, switch_height, switch_protrusion], center=true);

    // Fuse Drawer Region (attached to bezel)
    translate([(bezel_width/2 - fuse_width/2 - overlap),
               (bezel_height/2 - fuse_height/2 - overlap),
               fuse_z])
      cube([fuse_width, fuse_height, fuse_protrusion], center=true);

    // Mounting Clips (attached to body sides)
    translate([-clip_x, 0, clip_z])
      cube([clip_width, clip_height, clip_depth], center=true);
    translate([ clip_x, 0, clip_z])
      cube([clip_width, clip_height, clip_depth], center=true);

    // Rear Terminal Spades (attached to body back)
    for (p = [
      [-spade_spacing_x,  spade_spacing_y],
      [-spade_spacing_x, -spade_spacing_y],
      [ spade_spacing_x,  spade_spacing_y],
      [ spade_spacing_x, -spade_spacing_y],
      [0, 0]
    ]) {
      translate([p[0], p[1], spade_z])
        cube([spade_width, spade_thickness, spade_length], center=true);
    }
  }
}

// Panel Cutout Profile (kept separate visual/reference; does not affect IEC solidity)
module panel_cutout_profile() {
  color("Silver")
    translate([0, 0, 0])
      cube([panel_cutout_width + 2*tolerance_clearance,
            panel_cutout_height + 2*tolerance_clearance,
            panel_thickness], center=true);
}

// Final Assembly (IEC exists and is a single unioned solid)
module assembly() {
  union() {
    iec(); // required part present
    // panel_cutout_profile(); // optional reference; uncomment if desired
  }
}

assembly();