// Parameters
clip_type = 0; //[0:1:1]
open_amount = 0.9; //[0.1:1:0.05]
include_spigot_hole = 0; //[0:1:1]
spigot_hole_open_amount = 0.9; //[0.1:1:0.05]
spigot_hole_depth = 0; //[0:30:1]
overlap = 1; //[0.5:2:0.1]
fn = 96; //[24:360:12]
t = 0.8; //[0.4:1.6:0.1]
length = 55; //[30:110:1]
width = 18; //[10:36:1]
height = 22; //[12:44:1]
arm_l = 18; //[10:36:1]
arm_w = 4; //[2:8:0.5]
hinge_offset = 16; //[8:32:1]
bend_or = 3.2; //[1.6:6.4:0.1]
hook_x = 12; //[6:24:1]
hook_y = 10; //[6:20:1]
spigot_x = 10; //[6:20:1]
spigot_y = 8; //[5:16:1]
spigot_z = 12; //[6:24:1]
w_narrow = 10; //[6:20:1]
arm_angle_max = 35; //[10:70:1]
spigot_angle_max = 25; //[5:60:1]
hole_clearance = 0.2; //[0.05:0.6:0.05]
hole_extra_len = 60; //[20:200:5]

// Swiss Clip - complete geometry (fixed connectivity)
module swiss_clip() {
  color("DimGray")
  union() {

    // --- Main body reference positions (recalculated for guaranteed overlap) ---
    // Place the hinge plate so its LEFT face overlaps the arm/body by ~overlap.
    // Hinge spans: [hinge_cx - hinge_offset/2, hinge_cx + hinge_offset/2]
    // Arm/body spans: [arm_cx - arm_l/2, arm_cx + arm_l/2]
    // Enforce: (hinge_left) = (arm_right) - overlap
    arm_cx   = length - hinge_offset - arm_l/2;
    arm_right = arm_cx + arm_l/2;
    hinge_cx = arm_right - overlap + hinge_offset/2;

    // --- Clip Body (narrow center strip) ---
    translate([arm_cx, 0, 0])
      cube([arm_l, w_narrow, t], center=true);

    // --- Hinge Section (wide plate) ---
    translate([hinge_cx, 0, 0])
      cube([hinge_offset, width, t], center=true);

    // --- Hook Section (kept at origin side; already connected to body via overlap) ---
    // Ensure hook base overlaps the body by ~overlap (body left edge at arm_cx-arm_l/2).
    body_left = arm_cx - arm_l/2;
    hook_base_cx = body_left + overlap + hook_x/2; // overlaps into body by overlap

    union() {
      // Hook Base
      translate([hook_base_cx, 0, 0])
        cube([hook_x, hook_y, t], center=true);

      // Hook Stem
      translate([hook_base_cx - hook_x/2 + t/2, 0, height/2])
        cube([t, hook_y, height - 2*bend_or], center=true);

      // Hook Lower Bend
      translate([hook_base_cx - hook_x/2 + bend_or, 0, bend_or])
        rotate_extrude($fn=fn)
          translate([bend_or, 0])
            square([t, hook_y], center=true);

      // Hook Top
      translate([hook_base_cx - hook_x/2 + bend_or + (hook_x - bend_or)/2, 0, height - t/2])
        cube([hook_x - bend_or, hook_y, t], center=true);

      // Hook Top Bend
      translate([hook_base_cx - hook_x/2 + bend_or, 0, height - bend_or])
        rotate_extrude($fn=fn)
          translate([bend_or, 0])
            square([t, hook_y], center=true);
    }

    // --- Spigot (end block/loop) FIX: attach to hinge/body with guaranteed overlap ---
    // The spigot base is positioned so its LEFT face overlaps the hinge RIGHT face by ~overlap.
    hinge_right = hinge_cx + hinge_offset/2;
    spigot_base_len = spigot_x - bend_or;
    spigot_base_cx = hinge_right - overlap + spigot_base_len/2;

    rotate([-open_amount * spigot_angle_max, 0, 0]) {
      union() {
        // Spigot Base (attached to hinge)
        translate([spigot_base_cx, 0, 0])
          cube([spigot_base_len, spigot_y, t], center=true);

        // Spigot Stem (attached to base; shares face with base end)
        // Place stem so its X center is at base right face minus small overlap.
        spigot_base_right = spigot_base_cx + spigot_base_len/2;
        stem_cx = spigot_base_right - overlap + t/2;

        translate([stem_cx, 0, bend_or + (spigot_z - bend_or)/2])
          cube([t, spigot_y, spigot_z - bend_or], center=true);

        // Spigot Bend (attached to stem/base corner)
        // Center bend at the stem's outer corner with slight overlap.
        translate([stem_cx - t/2 + bend_or - overlap, 0, bend_or])
          rotate_extrude($fn=fn)
            translate([bend_or, 0])
              square([t, spigot_y], center=true);
      }
    }

    // --- Arms (kept; already overlap into body via overlap parameter) ---
    rotate([open_amount * arm_angle_max, 0, 0]) {
      union() {
        // Left Arm
        translate([arm_cx, -(w_narrow/2 + arm_w/2 - overlap), 0])
          cube([arm_l, arm_w, t], center=true);

        // Right Arm
        translate([arm_cx, (w_narrow/2 + arm_w/2 - overlap), 0])
          cube([arm_l, arm_w, t], center=true);
      }
    }

    // --- Gussets (kept; ensure they overlap hinge/body) ---
    union() {
      // Center Gusset: place at arm/body right edge into hinge by overlap
      translate([arm_right - overlap + t/2, 0, t/2 - overlap])
        cube([t, w_narrow, t], center=true);

      // Left Gusset
      translate([arm_right - overlap + t/2, -(w_narrow/2 + arm_w/2 - overlap), t/2 - overlap])
        cube([t, arm_w, t], center=true);

      // Right Gusset
      translate([arm_right - overlap + t/2, (w_narrow/2 + arm_w/2 - overlap), t/2 - overlap])
        cube([t, arm_w, t], center=true);
    }
  }
}

// Swiss Clip Hole - complete geometry
module swiss_clip_hole() {
  if (include_spigot_hole) {
    color("Black") {
      // Keep hole aligned to hinge center (hinge is now computed in swiss_clip; use original approx)
      translate([length - hinge_offset/2, 0, 0])
        rotate([90, 0, 0])
          cylinder(
            r = sqrt((spigot_y/2)*(spigot_y/2) + (spigot_z/2)*(spigot_z/2)) + hole_clearance,
            h = spigot_hole_depth > 0 ? spigot_hole_depth : (t + hole_extra_len),
            center = true,
            $fn = fn
          );
    }
  }
}

// Assembly
module assembly() {
  if (include_spigot_hole) {
    difference() {
      swiss_clip();
      swiss_clip_hole();
    }
  } else {
    swiss_clip();
  }
}

assembly();