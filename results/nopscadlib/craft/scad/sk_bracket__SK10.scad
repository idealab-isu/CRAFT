// Parameters
rod_diameter = 10.0; //[5.0:20.0:0.1]
rod_length = 60.0; //[30.0:120.0:1]
bracket_height = 20.0; //[10.0:40.0:0.5]
rod_clearance = 0.2; //[0.0:0.6:0.05]
wall_thickness = 4.0; //[2.0:8.0:0.5]
base_thickness = 5.0; //[2.5:10.0:0.5]
base_width = 30.0; //[15.0:60.0:1]
base_length = 40.0; //[20.0:80.0:1]
mount_hole_diameter = 5.0; //[3.0:8.0:0.1]
mount_hole_spacing = 24.0; //[12.0:48.0:1]
clamp_gap = 2.0; //[0.5:5.0:0.5]
clamp_bolt_hole_diameter = 4.0; //[2.0:6.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]

// Derived placement (recalculated to guarantee contact/overlap)
rod_outer_d = rod_diameter + rod_clearance + 2*wall_thickness;

// Place rod axis so collar sits within bracket height and intersects the support body.
// Keep the collar centered within the upper body region.
upper_body_h = max(0.01, bracket_height - base_thickness + overlap);
upper_body_center_z = base_thickness/2 + upper_body_h/2 - overlap;
rod_center_z = upper_body_center_z;  // ensures collar intersects the upper body

// Rod - solid geometry (used as "shaft" in the assembly)
module rod_solid() {
  // Along X after rotation in assembly
  cylinder(r=rod_diameter/2, h=rod_length, center=true, $fn=64);
}

// Bracket - solid geometry (with bore and features removed)
module bracket_solid() {
  difference() {
    union() {
      // Mounting base
      cube([base_width, base_length, base_thickness], center=true);

      // Support body (overlaps base by 'overlap' to ensure fusion)
      translate([0, 0, upper_body_center_z])
        cube([base_width, base_length/2, upper_body_h], center=true);

      // Support collar outer (centered on rod axis) - MUST intersect support body
      translate([0, 0, rod_center_z])
        rotate([0, 90, 0])
          cylinder(r=rod_outer_d/2, h=base_width, center=true, $fn=64);
    }

    // Rod seat / bore (slightly longer to fully cut through collar)
    translate([0, 0, rod_center_z])
      rotate([0, 90, 0])
        cylinder(r=(rod_diameter + rod_clearance)/2, h=base_width + 2*overlap, center=true, $fn=64);

    // Mounting holes
    translate([0,  mount_hole_spacing/2, 0])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=64);
    translate([0, -mount_hole_spacing/2, 0])
      cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=64);

    // Clamp split
    translate([0, 0, rod_center_z])
      cube([base_width + 2*overlap, clamp_gap, rod_outer_d + 2*overlap], center=true);

    // Clamp bolt hole
    translate([0,
               rod_outer_d/2 - clamp_gap/2 - clamp_bolt_hole_diameter/2,
               rod_center_z])
      rotate([0, 90, 0])
        cylinder(r=clamp_bolt_hole_diameter/2, h=base_width + 2*overlap, center=true, $fn=64);
  }
}

// Assembly: single connected solid.
// Fixes:
// - Rod is no longer a separate floating body: it is physically fused to the bracket
//   via a small external "weld collar" that overlaps BOTH the rod and the bracket by 1-2mm.
// - All parts are combined with union().
module assembly() {
  union() {
    bracket_solid();

    // Shaft positioned through the bracket (same axis as bore)
    translate([0, 0, rod_center_z])
      rotate([0, 90, 0])
        rod_solid();

    // External weld collar (adds minimal geometry) to guarantee fusion:
    // - Inner radius slightly smaller than rod radius => overlaps rod
    // - Outer radius slightly larger than bracket collar radius => overlaps bracket
    // - Short length (2*overlap) centered on bracket => overlaps bracket material
    translate([0, 0, rod_center_z])
      rotate([0, 90, 0])
        difference() {
          cylinder(r=rod_outer_d/2 + overlap, h=2*overlap, center=true, $fn=64);
          cylinder(r=rod_diameter/2 - overlap, h=2*overlap + 0.2, center=true, $fn=64);
        }
  }
}

assembly();