// Parameters
base_width = 18; //[9:36:1]
base_height = 3; //[1.5:6:0.5]
base_depth = 10; //[5:20:1]
hole_diameter = 3.2; //[1.6:6.4:0.1]
hole_spacing = 12; //[6:24:1]
gap_width = 3; //[1.5:6:0.5]
gap_height = 12; //[6:24:1]
stem_width = 2.5; //[1.25:5:0.25]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_width = 22; //[11:44:1]
pcb_depth = 16; //[8:32:1]
pcb_offset_y = 6; //[0:12:1]
overlap = 1; //[0.5:2:0.1]
pcb_enabled = 1; //[0:1:1]

$fn = 48;

module photo_interrupter() {

  // Derived dimensions (formulas only)
  arm_h   = base_height + gap_height;     // total fork height above base bottom
  base_z  = base_height/2;
  body_z  = arm_h/2;

  // Fork outer dimensions
  outer_y = gap_width + 2*stem_width;
  outer_z = arm_h;

  // Top bridge (cap)
  bridge_h = max(base_height, 2);
  bridge_z = base_height + gap_height - bridge_h/2;

  // Lead pins
  lead_w = 0.8;
  lead_t = 0.5;
  lead_len = 6;
  lead_pitch = 2.54;
  lead_count = 4;
  leads_span = (lead_count-1)*lead_pitch;

  // PCB placement: fuse to underside of base with overlap
  pcb_z = -(base_height/2 + pcb_thickness/2 - overlap);
  // Place PCB so its top face slightly intersects base bottom (z=0 plane)
  pcb_y = -(base_depth/2 + pcb_depth/2 - overlap + pcb_offset_y);

  // Ensure non-degenerate geometry
  eps = 0.01;

  union() {

    // Package + leads (single solid)
    union() {

      // Mounting base with holes
      difference() {
        translate([0, 0, base_z])
          cube([base_width, base_depth, base_height], center=true);

        for (sx = [-1, 1])
          translate([sx*hole_spacing/2, 0, base_z])
            cylinder(r=hole_diameter/2, h=base_height + 2*overlap + eps, center=true);
      }

      // Fork body: outer block minus slot (U-shaped gap)
      difference() {
        translate([0, 0, body_z])
          cube([base_width, outer_y, outer_z], center=true);

        translate([0, 0, body_z])
          cube([base_width + 2*overlap + eps, gap_width, outer_z + 2*overlap + eps], center=true);
      }

      // Top bridge/cap (connected to fork)
      translate([0, 0, bridge_z])
        cube([base_width, outer_y, bridge_h], center=true);

      // Leads under base (connected to base underside with overlap)
      for (i = [0:lead_count-1]) {
        x = -leads_span/2 + i*lead_pitch;
        translate([x, 0, -(lead_len/2 - overlap)])
          cube([lead_w, lead_t, lead_len], center=true);
      }
    }

    // PCB (fused to base so whole model is one connected solid)
    if (pcb_enabled) {
      translate([0, pcb_y, pcb_z])
        cube([pcb_width, pcb_depth, pcb_thickness], center=true);
    }
  }
}

photo_interrupter();