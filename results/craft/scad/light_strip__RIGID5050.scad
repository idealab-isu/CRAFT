// Parameters
length = 300; //[150:600:1]
width = 10; //[5:20:1]
overall_depth = 3; //[2:6:0.1]
housing_thickness = 1; //[0.5:2:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
aperture_width = 8; //[4:16:0.5]
led_count = 30; //[6:120:1]
segment_count = 10; //[2:40:1]
segment_length = 30; //[10:100:1]
mount_hole_diameter = 3; //[2:6:0.1]
mount_hole_spacing = 100; //[50:300:1]
overlap = 1; //[0.5:2:0.1]
body_corner_radius = 0.6; //[0.2:2:0.1]
led_pkg_x = 5; //[3:7:0.1]
led_pkg_y = 5; //[3:7:0.1]
led_height = 1.6; //[0.8:3:0.1]
led_lens_diameter = 3.5; //[2:6:0.1]
pad_size_x = 2.5; //[1.5:4:0.1]
pad_size_y = 2.5; //[1.5:4:0.1]
pad_thickness = 0.2; //[0.05:0.5:0.05]
cut_mark_thickness = 0.2; //[0.05:0.5:0.05]
cut_mark_width_x = 0.6; //[0.2:2:0.1]
clip_length = 18; //[10:40:1]
clip_wall = 1.5; //[1:3:0.1]
clip_depth = 8; //[4:20:1]
clip_clearance = 0.4; //[0.2:1:0.1]

$fn = 64;

// Rounded rectangular prism (3D) using hull of corner cylinders
module rounded_box(size=[10,10,3], r=0.6, center=true) {
  sx = size[0]; sy = size[1]; sz = size[2];
  rr = min(r, sx/2, sy/2);
  translate(center ? [0,0,0] : [sx/2, sy/2, sz/2])
    hull() {
      for (x = [-1, 1], y = [-1, 1])
        translate([x*(sx/2-rr), y*(sy/2-rr), 0])
          cylinder(r=rr, h=sz, center=true);
    }
}

// Light Strip - rigid body with defined thickness and mounting clip features
module light_strip_rigid() {
  // Guard against degenerate dimensions
  L = max(1, length);
  W = max(1, width);
  D = max(1, overall_depth);

  // Make a rigid "channel" style housing (not a through-slot that removes most material)
  // Outer shell
  outer = [L, W, D];

  // Inner cavity (opens from the top only), leaving a bottom and side walls
  // Keep at least 0.8mm bottom for rigidity
  bottom_t = max(0.8, housing_thickness);
  side_t   = max(0.8, housing_thickness);

  inner_L = max(0.1, L - 2*side_t);
  inner_W = max(0.1, W - 2*side_t);
  inner_D = max(0.1, D - bottom_t); // cavity height from bottom up to top

  // Top aperture is a shallow recess (diffuser seat), not a full cut-through
  ap_w = min(aperture_width, W - 2*side_t);
  ap_d = min(D*0.45, max(0.6, D - bottom_t - 0.2)); // shallow recess depth

  // Connector/control bump in the center (well-defined)
  bump_L = min(26, L*0.2);
  bump_W = min(W + 6, W*1.8);
  bump_H = max(2.5, D*0.9);

  union() {
    // Housing with internal cavity + top recess + mounting holes
    difference() {
      rounded_box(outer, r=body_corner_radius, center=true);

      // Internal cavity: open from top (so translate upward)
      // Center of cavity is at: bottom face + inner_D/2
      cavity_cz = -D/2 + bottom_t + inner_D/2;
      translate([0, 0, cavity_cz])
        rounded_box([inner_L, inner_W, inner_D + 2*overlap], r=max(0.2, body_corner_radius-0.2), center=true);

      // Top recess/aperture seat (shallow, not through)
      recess_cz = D/2 - ap_d/2;
      translate([0, 0, recess_cz])
        cube([L + 2*overlap, ap_w, ap_d + 2*overlap], center=true);

      // Mount holes (through Z, typical for clips/screws)
      // Keep them within length
      hole_span = min(mount_hole_spacing, L - 2*(mount_hole_diameter + 2));
      for (sx = [-1, 1]) {
        translate([sx*hole_span/2, 0, 0])
          cylinder(r=mount_hole_diameter/2, h=D + 2*overlap, center=true);
      }
    }

    // Central bump/control module on top, connected with overlap
    bump_cz = D/2 + bump_H/2 - overlap;
    translate([0, 0, bump_cz])
      rounded_box([bump_L, bump_W, bump_H], r=min(2, body_corner_radius+0.6), center=true);

    // Internal "PCB support rib" (solid) to avoid thin-line appearance and add rigidity
    // Sits inside cavity, connected to bottom
    rib_H = max(0.8, min(pcb_thickness, inner_D*0.6));
    rib_W = max(0.1, inner_W - 2*clip_clearance);
    rib_L = max(0.1, inner_L - 4);
    rib_cz = -D/2 + bottom_t + rib_H/2 - overlap;
    translate([0, 0, rib_cz])
      cube([rib_L, rib_W, rib_H + overlap], center=true);
  }
}

// Light Strip Clip - U-clip that wraps around the strip, connected as one solid
module light_strip_clip_rigid() {
  L = max(1, length);
  W = max(1, width);
  D = max(1, overall_depth);

  // Clip inner opening sized to strip width/depth with clearance
  inner_w = W + 2*clip_clearance;
  inner_d = D + clip_clearance;

  // Clip outer size
  outer_w = inner_w + 2*clip_wall;
  outer_d = inner_d + clip_wall;

  // Place clip centered at X=0, around the strip, with a small overlap into strip for guaranteed union
  // Clip center Z aligns so its inner opening straddles the strip
  clip_cz = 0; // centered on strip for wrap

  // Add a base foot under the strip for mounting (connected to clip)
  foot_L = clip_length;
  foot_W = outer_w;
  foot_H = max(2.0, clip_wall + 0.8);

  // Foot sits below strip bottom and overlaps clip
  foot_cz = -D/2 - foot_H/2 + overlap;

  union() {
    // U-clip body (difference to create opening)
    translate([0, 0, clip_cz])
      difference() {
        cube([clip_length, outer_w, outer_d], center=true);

        // Inner opening: shifted slightly upward so bottom has more material (rigid)
        // Inner opening center Z: raise by clip_wall/2
        inner_cz = clip_wall/2;
        translate([0, 0, inner_cz])
          cube([clip_length + 2*overlap, inner_w, inner_d + 2*overlap], center=true);

        // Front slot to allow snap-on (remove a thin slit on one side)
        slit_w = max(0.8, clip_wall*0.8);
        translate([0, outer_w/2 - slit_w/2, 0])
          cube([clip_length + 2*overlap, slit_w + 2*overlap, outer_d + 2*overlap], center=true);
      }

    // Mounting foot (solid), connected to clip and overlapping strip slightly
    translate([0, 0, foot_cz])
      rounded_box([foot_L, foot_W, foot_H], r=min(1.2, body_corner_radius+0.4), center=true);

    // Small gussets to strengthen clip-to-foot connection (both sides), guaranteed connected
    gus_L = clip_length;
    gus_W = max(1.2, clip_wall);
    gus_H = max(1.2, clip_wall);
    gus_x = 0;
    gus_z = (-D/2) - clip_wall/2; // around strip bottom region
    for (sy = [-1, 1]) {
      gus_y = sy*(outer_w/2 - gus_W/2);
      translate([gus_x, gus_y, gus_z])
        cube([gus_L, gus_W, gus_H], center=true);
    }
  }
}

// Assembly: ONE connected solid
union() {
  light_strip_rigid();

  // Place clip at center under the strip, overlapping for connectivity
  // Clip wraps around strip; ensure overlap by keeping it centered and dimensions include clearance
  light_strip_clip_rigid();
}