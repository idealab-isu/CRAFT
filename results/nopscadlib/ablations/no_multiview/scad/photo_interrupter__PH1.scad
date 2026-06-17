// Parameters
type = 0; //[0:3:1]
base_width = 12; //[6:24:1]
base_height = 3; //[1.5:6:0.5]
hole_diameter = 3; //[1.5:6:0.5]
hole_spacing = 20; //[10:40:1]
gap_width = 5; //[2.5:10:0.5]
gap_height = 10; //[5:20:1]
stem_width = 3; //[1.5:6:0.5]
stem_depth_x = 14; //[7:28:1]
overlap = 1; //[0.5:2:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_width_x = 26; //[13:52:1]
pcb_depth_y = 18; //[9:36:1]
pcb_offset_y = 10; //[5:20:1]
pcb_overlap_into_base = 0.8; //[0.4:1.6:0.1]

// Photo Interrupter - complete geometry (now a single connected solid)
module photo_interrupter() {

  // Derived placement so PCB is physically attached to the base with overlap
  // Base is centered at z=0 with thickness base_height.
  // Place PCB so its top face penetrates into the base by pcb_overlap_into_base.
  pcb_z = -(base_height/2 + pcb_thickness/2 - pcb_overlap_into_base);

  // Place PCB in Y so its top edge penetrates into the base footprint by pcb_overlap_into_base.
  // Base spans y = [-base_width/2, +base_width/2].
  // PCB spans y = [pcb_y - pcb_depth_y/2, pcb_y + pcb_depth_y/2].
  // Enforce: pcb_y + pcb_depth_y/2 = base_width/2 + pcb_overlap_into_base
  pcb_y = (base_width/2 + pcb_overlap_into_base) - pcb_depth_y/2;

  union() {

    // Dark blue interrupter body (base + stems) with U-slot cutout
    color([0.15, 0.2, 0.35])
    difference() {
      union() {
        // Mounting base (capsule)
        difference() {
          union() {
            translate([-hole_spacing/2, 0, 0])
              cylinder(r=base_width/2, h=base_height, center=true);
            translate([ hole_spacing/2, 0, 0])
              cylinder(r=base_width/2, h=base_height, center=true);
            translate([0, 0, 0])
              cube([hole_spacing, base_width, base_height], center=true);
          }
          union() {
            translate([-hole_spacing/2, 0, 0])
              cylinder(r=hole_diameter/2, h=base_height + 2*overlap, center=true);
            translate([ hole_spacing/2, 0, 0])
              cylinder(r=hole_diameter/2, h=base_height + 2*overlap, center=true);
          }
        }

        // Sensor stems (attached to base; overlap already built into y placement)
        translate([0, -(gap_width/2 + stem_width/2 - overlap), gap_height/2])
          cube([stem_depth_x, stem_width, gap_height + base_height], center=true);
        translate([0,  (gap_width/2 + stem_width/2 - overlap), gap_height/2])
          cube([stem_depth_x, stem_width, gap_height + base_height], center=true);
      }

      // U-slot gap (cutout)
      translate([0, 0, base_height/2 + gap_height/2])
        cube([stem_depth_x + 2*overlap, gap_width, gap_height + overlap], center=true);
    }

    // Green PCB (now physically attached to the base with overlap in Y and Z)
    color([0.0, 0.4, 0.2])
      translate([0, pcb_y, pcb_z])
        cube([pcb_width_x, pcb_depth_y, pcb_thickness], center=true);
  }
}

// Assembly
module assembly() {
  union() {
    photo_interrupter();
  }
}

assembly();