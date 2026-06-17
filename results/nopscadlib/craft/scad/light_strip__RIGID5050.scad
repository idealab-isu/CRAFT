// Parameters
strip_length = 500; //[250:1000:1]
strip_width = 10; //[5:20:1]
strip_thickness = 2; //[1:4:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
led_count = 30; //[6:120:1]
segment_count = 10; //[2:40:1]
led_package_size = 5; //[3:8:0.1]
mounting_hole_diameter = 3; //[2:6:0.1]
mounting_hole_spacing = 100; //[50:200:1]
eps = 0.8; //[0.2:2:0.1]
copper_thickness = 0.15; //[0.05:0.4:0.01]
solder_pad_length = 2.5; //[1.5:5:0.1]
solder_pad_width = 2.5; //[1.5:5:0.1]
segment_mark_width = 0.3; //[0.1:1:0.05]
segment_mark_height = 0.1; //[0.05:0.3:0.01]
resistor_length = 3.2; //[2:6:0.1]
resistor_width = 1.5; //[1:3:0.1]
resistor_height = 0.6; //[0.3:1.5:0.05]
lens_height = 0.8; //[0.3:2:0.1]
lens_width_margin = 0.6; //[0.2:2:0.1]
clip_length = 20; //[10:60:1]
clip_wall = 1.5; //[0.8:3:0.1]
clip_depth = 8; //[4:20:1]
clip_clearance = 0.4; //[0.1:1:0.05]
clip_attach_x = 0; //[-200:200:1]

$fn = 64;

// Helpers
function clamp(v, lo, hi) = v < lo ? lo : (v > hi ? hi : v);

module assembly() {

  // Make the strip clearly visible in all views (avoid "paper thin" look)
  strip_t = max(strip_thickness, 3.0);
  lens_h  = max(lens_height, 1.2);

  // Clip sizing (robust)
  clip_L = max(clip_length, 12);
  clip_W = strip_width + 2*max(clip_wall, 1.2);
  clip_D = max(clip_depth, 8);

  wall   = max(clip_wall, 1.2);
  clear  = max(clip_clearance, 0.25);

  // Slot (where strip slides in)
  slot_W = min(strip_width + 2*clear, clip_W - 2*wall - 0.4);
  slot_D = max(clip_D - 2*wall, 2.0);
  slot_L = max(clip_L - 2*wall, 6.0);

  // Place clip on top of strip (Z+), centered in Y, with guaranteed overlap into strip
  overlap_z = 1.0; // ensures one connected solid
  z_strip_top = strip_t/2;
  z_clip_center = z_strip_top + clip_D/2 - overlap_z;

  // Add a small base foot under the clip to make the mount feature obvious and connected
  foot_L = clip_L * 0.75;
  foot_W = clip_W * 0.55;
  foot_T = max(2.0, strip_t * 0.7);
  z_foot_center = z_strip_top + foot_T/2 - overlap_z;

  union() {

    // Main rigid strip with mounting holes
    difference() {
      cube([strip_length, strip_width, strip_t], center=true);

      hole_x1 = clamp(-strip_length/2 + mounting_hole_spacing/2,
                      -strip_length/2 + 12, strip_length/2 - 12);
      hole_x2 = clamp( strip_length/2 - mounting_hole_spacing/2,
                      -strip_length/2 + 12, strip_length/2 - 12);

      translate([hole_x1, 0, 0])
        cylinder(h=strip_t + 2*eps, r=mounting_hole_diameter/2, center=true);

      translate([hole_x2, 0, 0])
        cylinder(h=strip_t + 2*eps, r=mounting_hole_diameter/2, center=true);
    }

    // Raised diffuser/lens (thicker for readability)
    lens_W = max(strip_width - 2*lens_width_margin, strip_width*0.6);
    translate([0, 0, z_strip_top + lens_h/2 - 0.6]) // overlap into strip
      cube([strip_length - 2*eps, lens_W, lens_h], center=true);

    // LED packages as bumps
    led_pitch = strip_length / max(led_count, 1);
    led_h = max(led_package_size*0.45, 1.4);
    led_w = min(max(led_package_size, 3.0), strip_width - 1.0);
    led_l = min(max(led_package_size, 3.0), led_pitch*0.75);

    for (i = [0:led_count-1]) {
      x = -strip_length/2 + led_pitch*(i + 0.5);
      translate([x, 0, z_strip_top + led_h/2 - 0.4]) // overlap into strip
        cube([led_l, led_w, led_h], center=true);
    }

    // Clip foot (solid, connected)
    translate([clip_attach_x, 0, z_foot_center])
      cube([foot_L, foot_W, foot_T], center=true);

    // Clip body with U-slot (no "window" that deletes the whole clip)
    translate([clip_attach_x, 0, z_clip_center])
      difference() {
        cube([clip_L, clip_W, clip_D], center=true);

        // Slot cavity: open from bottom by extending cut downward
        translate([0, 0, -wall/2])
          cube([slot_L, slot_W, slot_D + wall + eps], center=true);

        // Side entry notch (small) to suggest clip opening without removing everything
        notch_W = min(slot_W, clip_W - 2*wall);
        notch_H = clip_D * 0.55;
        notch_T = max(wall + 0.6, 1.6);
        translate([0, clip_W/2 - wall/2, -clip_D/2 + notch_H/2 + wall])
          cube([clip_L + 2*eps, notch_T, notch_H], center=true);
      }
  }
}

assembly();