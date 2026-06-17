// Parameters
base_width = 20; //[10:40:1]
base_depth = 8; //[4:16:1]
base_height = 3; //[1.5:6:0.1]
gap_width = 5; //[2.5:10:0.1]
gap_height = 10; //[5:20:0.5]
stem_width = 3; //[1.5:6:0.1]
stem_wall = 2; //[1:4:0.1]
stem_overlap = 1; //[0.5:2:0.1]
hole_diameter = 2.2; //[1.1:4.4:0.1]
hole_spacing = 10; //[5:20:0.5]
hole_edge_margin = 3; //[1.5:6:0.1]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_margin = 2; //[1:4:0.1]
pcb_overlap = 0.8; //[0.5:2:0.1]
gap_clearance_x = 0.5; //[0.2:1.5:0.1]
gap_clearance_y = 0.5; //[0.2:1.5:0.1]
gap_clearance_z = 0.5; //[0.2:1.5:0.1]

// Photo Interrupter - complete geometry
module photo_interrupter() {
  color([0.15, 0.15, 0.17]) {
    // Base Plate
    translate([0, 0, 0])
      cube([base_width, base_depth, base_height], center=true);

    // Sensor Stems
    union() {
      // Left Stem
      translate([-(base_width/2) + (stem_wall/2), -(gap_width/2) - (stem_width/2), (gap_height + base_height + stem_overlap)/2 - (base_height/2) + (stem_overlap/2)])
        cube([stem_wall, stem_width, gap_height + base_height + stem_overlap], center=true);
      // Right Stem
      translate([(base_width/2) - (stem_wall/2), (gap_width/2) + (stem_width/2), (gap_height + base_height + stem_overlap)/2 - (base_height/2) + (stem_overlap/2)])
        cube([stem_wall, stem_width, gap_height + base_height + stem_overlap], center=true);
      // Left Inner Stem
      translate([-(stem_wall/2), -(gap_width/2) - (stem_width/2), (gap_height + base_height + stem_overlap)/2 - (base_height/2) + (stem_overlap/2)])
        cube([base_width - stem_wall, stem_width, gap_height + base_height + stem_overlap], center=true);
      // Right Inner Stem
      translate([(stem_wall/2), (gap_width/2) + (stem_width/2), (gap_height + base_height + stem_overlap)/2 - (base_height/2) + (stem_overlap/2)])
        cube([base_width - stem_wall, stem_width, gap_height + base_height + stem_overlap], center=true);
    }

    // U-Slot Gap
    difference() {
      cube([base_width, base_depth, base_height], center=true);
      translate([0, 0, (gap_height + base_height)/2 - (base_height/2)])
        cube([base_width + 2*gap_clearance_x, gap_width + 2*gap_clearance_y, gap_height + base_height + 2*gap_clearance_z], center=true);
    }

    // Mounting Holes
    difference() {
      cube([base_width, base_depth, base_height], center=true);
      translate([-(hole_spacing/2), 0, 0])
        cylinder(h=base_height + 2*gap_clearance_z, r=hole_diameter/2, center=true);
      translate([(hole_spacing/2), 0, 0])
        cylinder(h=base_height + 2*gap_clearance_z, r=hole_diameter/2, center=true);
    }
  }

  // PCB
  color([0.0, 0.4, 0.2]) {
    translate([0, 0, -(base_height/2) - (pcb_thickness/2) + pcb_overlap])
      cube([base_width + 2*pcb_margin, base_depth + 2*pcb_margin, pcb_thickness], center=true);
  }
}

// Assembly
module assembly() {
  photo_interrupter();
}

assembly();