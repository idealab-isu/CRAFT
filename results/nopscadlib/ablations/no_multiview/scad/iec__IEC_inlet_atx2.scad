// Parameters
component_type = 0; //[0:0:1]
orientation = 0; //[0:0:1]
include_spades_or_lugs = 0; //[0:0:1]
overlap = 1; //[0.5:2:0.1]
flange_w = 50; //[25:100:1]
flange_h = 40; //[20:80:1]
flange_t = 3; //[1.5:6:0.5]
bezel_w = 44; //[22:88:1]
bezel_h = 34; //[17:68:1]
bezel_t = 2.5; //[1.5:5:0.5]
body_w = 32; //[16:64:1]
body_h = 24; //[12:48:1]
body_depth_front = 12; //[6:24:1]
rear_body_depth = 18; //[9:36:1]
socket_w = 24.5; //[12.25:49:0.5]
socket_h = 16.34; //[8.17:32.68:0.1]
socket_cut_depth = 40; //[20:80:1]
socket_offset_y = 0; //[-6:6:0.5]
screw_pitch_x = 36; //[18:72:1]
screw_pitch_y = 28; //[14:56:1]
screw_hole_d = 3.5; //[2:7:0.1]

// Corner feature parameters (the "four small blue corner features")
corner_feat_w = 6;
corner_feat_h = 6;
corner_feat_t = 2.5;   // thickness in Z
corner_inset = 1.0;    // keep them slightly inside the flange outline
corner_z_overlap = 1.2; // ensure they intersect the flange/bezel stack

// IEC Connector - complete geometry (single connected solid)
module iec() {

  // Z reference planes (all centered geometry)
  z_flange = flange_t/2;
  z_bezel  = flange_t + bezel_t/2 - overlap;
  z_front  = flange_t + bezel_t + body_depth_front/2 - overlap;
  z_rear   = flange_t + bezel_t + body_depth_front + rear_body_depth/2 - overlap;

  // Place corner features so they physically intersect the flange (and slightly the bezel)
  // Put them near the flange corners in X/Y, and in Z straddling the flange top.
  z_corner = flange_t - corner_feat_t/2 - (corner_z_overlap); // pushes into flange by ~corner_z_overlap

  // Corner positions (near flange corners, inset a bit so they are not outside)
  x_corner = flange_w/2 - corner_feat_w/2 - corner_inset;
  y_corner = flange_h/2 - corner_feat_h/2 - corner_inset;

  // Build solid with cutouts removed
  difference() {
    union() {
      // Main black body (unioned so everything is one connected solid)
      color("Black")
      union() {
        // Flange
        translate([0, 0, z_flange])
          cube([flange_w, flange_h, flange_t], center=true);

        // Bezel (overlaps flange by 'overlap')
        translate([0, 0, z_bezel])
          cube([bezel_w, bezel_h, bezel_t], center=true);

        // Front Body (overlaps bezel by 'overlap')
        translate([0, 0, z_front])
          cube([body_w, body_h, body_depth_front], center=true);

        // Rear Body (overlaps front by 'overlap')
        translate([0, 0, z_rear])
          cube([body_w, body_h, rear_body_depth], center=true);
      }

      // Four small blue corner features - now ATTACHED (overlapping flange by ~1-2mm)
      color("SteelBlue")
      union() {
        for (sx = [-1, 1])
          for (sy = [-1, 1])
            translate([sx*x_corner, sy*y_corner, z_corner])
              cube([corner_feat_w, corner_feat_h, corner_feat_t], center=true);
      }
    }

    // Cutouts (subtract from the union above)
    union() {
      // Socket Opening
      translate([0, socket_offset_y, flange_t + bezel_t + (body_depth_front + rear_body_depth)/2])
        cube([socket_w, socket_h, socket_cut_depth], center=true);

      // Screw Mount Holes
      for (x = [-screw_pitch_x/2, screw_pitch_x/2])
        for (y = [-screw_pitch_y/2, screw_pitch_y/2])
          translate([x, y, (flange_t + bezel_t + body_depth_front + rear_body_depth)/2])
            cylinder(r=screw_hole_d/2,
                     h=flange_t + bezel_t + body_depth_front + rear_body_depth + 2*overlap,
                     center=true);
    }
  }
}

// Assembly
module assembly() {
  iec();
}

assembly();