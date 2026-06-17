// Parameters
rod_diameter = 8.0; //[4.0:16.0:0.1]
rod_length = 60.0; //[30.0:120.0:1]
overall_height = 20.0; //[10.0:40.0:0.5]
bracket_width = 30.0; //[15.0:60.0:0.5]
bracket_depth = 20.0; //[10.0:50.0:0.5]
base_thickness = 6.0; //[3.0:12.0:0.5]
wall_thickness = 4.0; //[2.0:8.0:0.5]
rod_clearance = 0.2; //[0.0:0.6:0.05]
mount_hole_diameter = 4.2; //[3.0:6.5:0.1]
mount_hole_spacing = 20.0; //[10.0:40.0:0.5]
mount_hole_edge_margin = 5.0; //[3.0:12.0:0.5]
clamp_split_gap = 1.0; //[0.5:3.0:0.1]
clamp_bolt_diameter = 3.0; //[2.0:5.0:0.1]
clamp_bolt_spacing = 14.0; //[8.0:24.0:0.5]
boss_diameter = 10.0; //[6.0:18.0:0.5]
boss_height = 8.0; //[4.0:16.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
fillet_radius = 2.0; //[0.0:6.0:0.5]

// Rod - complete geometry
module rod() {
  color("Silver")
    cylinder(r=rod_diameter/2, h=rod_length, center=true, $fn=64);
}

// Bracket assembly (single connected solid)
module bracket_assembly() {

  // Common Z for rod axis / clamp features
  rod_axis_z = overall_height/2 - wall_thickness - (rod_diameter + 2*rod_clearance)/2;

  // Bosses must INTERSECT the main body by 'overlap' to guarantee fusion.
  // Cylinder is rotated so its axis is X; its length is boss_height.
  // To overlap by 'overlap', place boss center at:
  // x = (body_right_face) + (boss_len/2) - overlap
  boss_x = bracket_width/2 + boss_height/2 - overlap;

  // Add the missing opposite-side single boss/pin and ensure it also overlaps.
  boss_x_opposite = -bracket_width/2 - boss_height/2 + overlap;

  color("Silver")
  difference() {
    // POSITIVE GEOMETRY (all fused via union)
    union() {
      // Main bracket body
      cube([bracket_width, bracket_depth, overall_height], center=true);

      // Mounting base (overlaps into main body)
      translate([0, 0, -overall_height/2 + base_thickness/2 - overlap])
        cube([bracket_width, bracket_depth, base_thickness], center=true);

      // Clamp bosses (two on +X side) - forced overlap into body
      translate([boss_x,  clamp_bolt_spacing/2, rod_axis_z])
        rotate([0, 90, 0])
          cylinder(r=boss_diameter/2, h=boss_height, center=true, $fn=64);

      translate([boss_x, -clamp_bolt_spacing/2, rod_axis_z])
        rotate([0, 90, 0])
          cylinder(r=boss_diameter/2, h=boss_height, center=true, $fn=64);

      // Opposite-side single boss/pin (-X side) - added and attached
      translate([boss_x_opposite, 0, rod_axis_z])
        rotate([0, 90, 0])
          cylinder(r=boss_diameter/2, h=boss_height, center=true, $fn=64);
    }

    // NEGATIVE GEOMETRY (subtractions)
    // Rod support bore
    translate([0, 0, rod_axis_z])
      rotate([0, 90, 0])
        cylinder(r=(rod_diameter + 2*rod_clearance)/2,
                 h=bracket_width + 2*overlap, center=true, $fn=96);

    // Mounting holes (through base)
    translate([-mount_hole_spacing/2, bracket_depth/2 - mount_hole_edge_margin,
               -overall_height/2 + base_thickness/2 - overlap])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=48);

    translate([ mount_hole_spacing/2, bracket_depth/2 - mount_hole_edge_margin,
               -overall_height/2 + base_thickness/2 - overlap])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=48);

    // Clamp split cut (kept as-is, but ensure it fully spans with overlap)
    translate([bracket_width/2 - clamp_split_gap/2, 0, 0])
      cube([clamp_split_gap, bracket_depth + 2*overlap, overall_height + 2*overlap], center=true);

    // Clamp bolt holes (through the two +X bosses)
    translate([boss_x,  clamp_bolt_spacing/2, rod_axis_z])
      rotate([0, 90, 0])
        cylinder(r=clamp_bolt_diameter/2,
                 h=boss_height + bracket_width + 4*overlap, center=true, $fn=48);

    translate([boss_x, -clamp_bolt_spacing/2, rod_axis_z])
      rotate([0, 90, 0])
        cylinder(r=clamp_bolt_diameter/2,
                 h=boss_height + bracket_width + 4*overlap, center=true, $fn=48);

    // (No bolt hole on the opposite single boss, per original design intent)
  }
}

// Assembly
module assembly() {
  bracket_assembly();
  translate([0, 0, overall_height/2 - wall_thickness - (rod_diameter + 2*rod_clearance)/2])
    rod();
}

assembly();