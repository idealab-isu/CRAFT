// Shaft support bracket for 12.0mm rod, 23.0mm tall
// One connected solid (bracket only). No separate rod preview.

// Parameters
rod_diameter = 12; //[6:24:0.1]
overall_height = 23; //[12:46:0.1]
base_length = 40; //[20:80:0.1]
base_width = 20; //[10:40:0.1]
base_thickness = 6; //[3:12:0.1]
cradle_wall_thickness = 4; //[2:8:0.1]
mount_hole_count = 2; //[1:4:1]
mount_hole_diameter = 5; //[3:10:0.1]
mount_hole_spacing = 28; //[14:56:0.1]
mount_hole_edge_margin = 6; //[3:12:0.1]
clamp_enabled = 1; //[0:1:1]
clamp_screw_diameter = 4; //[2:8:0.1]
clamp_screw_head_clearance_diameter = 8; //[4:16:0.1]
clamp_slot_width = 2; //[1:5:0.1]
tolerance_clearance = 0.2; //[0:0.6:0.05]
overlap = 1; //[0.5:2:0.1]

$fn = 96;

// Derived
rod_r   = rod_diameter/2;
inner_r = rod_r + tolerance_clearance;
outer_r = inner_r + cradle_wall_thickness;

cradle_h = max(0.1, overall_height - base_thickness); // height of cradle above base

// Z placement (base sits on Z=0)
base_z0   = 0;
base_zc   = base_z0 + base_thickness/2;
cradle_z0 = base_z0 + base_thickness - overlap;       // overlap into base for connectivity
cradle_zc = cradle_z0 + cradle_h/2;

module bracket() {
  difference() {
    union() {
      // Base plate (bottom at Z=0)
      translate([0, 0, base_zc])
        cube([base_length, base_width, base_thickness], center=true);

      // Ring cradle (connected to base via overlap)
      translate([0, 0, cradle_zc])
        difference() {
          cylinder(r=outer_r, h=cradle_h, center=true);
          cylinder(r=inner_r, h=cradle_h + 2*overlap, center=true);
        }
    }

    // Mounting holes through base (Z axis)
    if (mount_hole_count <= 1) {
      translate([0, 0, base_zc])
        cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=48);
    } else {
      for (i = [0:mount_hole_count-1]) {
        x = (mount_hole_count==2)
            ? (i==0 ? -mount_hole_spacing/2 : mount_hole_spacing/2)
            : (-mount_hole_spacing/2 + i*(mount_hole_spacing/(mount_hole_count-1)));
        translate([x, 0, base_zc])
          cylinder(r=mount_hole_diameter/2, h=base_thickness + 2*overlap, center=true, $fn=48);
      }
    }

    // Clamp split + screw features (cut through cradle)
    if (clamp_enabled) {
      // Split slot (cuts ring to make clamp)
      translate([0, 0, cradle_zc])
        cube([clamp_slot_width, 2*outer_r + 2*overlap, cradle_h + 2*overlap], center=true);

      // Screw through-hole across Y (perpendicular to rod axis)
      translate([0, 0, cradle_zc])
        rotate([90, 0, 0])
          cylinder(r=clamp_screw_diameter/2, h=2*outer_r + 2*overlap, center=true, $fn=48);

      // Screw head clearance pocket from +Y side (ensure it reaches the outside face)
      translate([0, outer_r/2, cradle_zc])
        rotate([90, 0, 0])
          cylinder(r=clamp_screw_head_clearance_diameter/2,
                   h=outer_r + 2*overlap, center=true, $fn=48);
    }
  }
}

bracket();