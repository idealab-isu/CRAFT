// Parameters
clip_type = 0; //[0:2:1]
open_ratio = 0.9; //[0.1:1:0.05]
include_spigot_hole = 1; //[0:1:1]
hole_depth = 0; //[0:50:1]
t = 1.2; //[0.6:2.4:0.1]
length = 45; //[25:90:1]
width = 18; //[10:36:1]
height = 22; //[12:44:1]
arm_l = 18; //[10:36:1]
arm_w = 4; //[2:8:0.5]
hinge_offset = 14; //[8:28:1]
hook_x = 12; //[6:24:1]
hook_y = 10; //[6:20:1]
spigot_x = 10; //[6:20:1]
spigot_y = 8; //[5:16:1]
spigot_z = 14; //[8:28:1]
bend_r = 3; //[1.5:6:0.5]
overlap = 1; //[0.5:2:0.1]
arm_angle_deg = 55; //[10:80:1]
spigot_angle_deg = 35; //[5:60:1]
hole_clearance = 0.2; //[0.05:0.6:0.05]
hole_tool_h = 30; //[10:80:1]

// Swiss Clip - complete geometry
module swiss_clip() {
  color([0.85, 0.85, 0.8]) {
    union() {
      // Swiss Clip Body
      translate([(-t - (bend_r - t))/2 + ((hinge_offset - spigot_x + (length - hinge_offset - arm_l)) / 2), 0, -height + t/2])
        cube([hinge_offset - spigot_x + (length - hinge_offset - arm_l), width, t], center=true);

      // Hook Section
      translate([(-t - (bend_r - t)) + hook_x/2, 0, -height + t/2])
        cube([hook_x, hook_y, t], center=true);
      translate([(-t - (bend_r - t)) + t/2, 0, -height + t + (height - 2*bend_r)/2])
        cube([t, hook_y, height - 2*bend_r], center=true);
      translate([(-t - (bend_r - t)) + bend_r + (hook_x - bend_r)/2, 0, -t/2])
        cube([hook_x - bend_r, hook_y, t], center=true);

      // Spigot Hinge
      rotate([0, -(spigot_angle_deg*open_ratio), 0]) {
        translate([(-t - (bend_r - t)) + (length - spigot_x) + (spigot_x - bend_r)/2, 0, -height + t/2])
          cube([spigot_x - bend_r, spigot_y, t], center=true);
        translate([(-t - (bend_r - t)) + (length - t) + t/2 - t/2, 0, -height + t + (spigot_z - bend_r)/2])
          cube([t, spigot_y, spigot_z - bend_r], center=true);
        translate([(-t - (bend_r - t)) + (length - bend_r), 0, -height + t + bend_r])
          rotate_extrude() square([t, spigot_y], center=true);
      }

      // Clip Arms
      rotate([0, arm_angle_deg*open_ratio, 0]) {
        translate([(-t - (bend_r - t)) + (length - hinge_offset) - arm_l/2 + overlap, -(width/2 - arm_w/2), -height + t/2 + t])
          cube([arm_l, arm_w, t], center=true);
        translate([(-t - (bend_r - t)) + (length - hinge_offset) - arm_l/2 + overlap, (width/2 - arm_w/2), -height + t/2 + t])
          cube([arm_l, arm_w, t], center=true);
      }

      // Gussets Stiffeners
      translate([(-t - (bend_r - t)) + (length - hinge_offset) - t/2 + overlap, 0, -height + t + t/2])
        cube([t, width - 2*arm_w, t], center=true);
      translate([(-t - (bend_r - t)) + (length - hinge_offset) - t/2 + overlap, -(width/2 - arm_w/2), -height + t + t/2])
        cube([t, arm_w, t], center=true);
      translate([(-t - (bend_r - t)) + (length - hinge_offset) - t/2 + overlap, (width/2 - arm_w/2), -height + t + t/2])
        cube([t, arm_w, t], center=true);
    }
  }
}

// Swiss Clip Hole - complete geometry
module swiss_clip_hole() {
  if (include_spigot_hole) {
    color([0.2, 0.2, 0.2]) {
      translate([(-t - (bend_r - t)) + (length - hinge_offset) + (hinge_offset - t)*cos((spigot_angle_deg*open_ratio)*3.141592653589793/180) - (spigot_z - t)*sin((spigot_angle_deg*open_ratio)*3.141592653589793/180), 0, -height + t/2])
        cylinder(r=(sqrt((spigot_z*sin((spigot_angle_deg*open_ratio)*3.141592653589793/180))^2 + (spigot_y)^2)/2) + hole_clearance, h=(hole_depth > 0 ? hole_depth : hole_tool_h), center=true);
    }
  }
}

// Assembly
module assembly() {
  swiss_clip();
  swiss_clip_hole();
}

assembly();