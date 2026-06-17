// Parameters
pcb_L = 18.0; //[9.0:36.0:0.1]
pcb_W = 18.0; //[9.0:36.0:0.1]
pcb_T = 0.8; //[0.4:1.6:0.05]
copper_T = 0.035; //[0.017:0.07:0.001]
mask_T = 0.02; //[0.01:0.05:0.001]
silk_T = 0.01; //[0.005:0.03:0.001]
corner_R = 1.0; //[0.5:2.0:0.1]
edge_chamfer = 0.3; //[0.1:0.8:0.05]
mount_hole_d = 2.0; //[1.0:3.5:0.1]
mount_hole_edge_margin = 2.5; //[1.5:5.0:0.1]
hole_clearance_extra = 0.2; //[0.0:0.6:0.05]

// PCB Body with Rounded Corners
module pcb_body_rounded() {
  difference() {
    intersection() {
      cube([pcb_L, pcb_W, pcb_T], center=true);
      hull() {
        translate([pcb_L/2 - corner_R, pcb_W/2 - corner_R, 0])
          cylinder(r=corner_R, h=pcb_T + 2*(copper_T + mask_T + silk_T), center=true);
        translate([-pcb_L/2 + corner_R, pcb_W/2 - corner_R, 0])
          cylinder(r=corner_R, h=pcb_T + 2*(copper_T + mask_T + silk_T), center=true);
        translate([-pcb_L/2 + corner_R, -pcb_W/2 + corner_R, 0])
          cylinder(r=corner_R, h=pcb_T + 2*(copper_T + mask_T + silk_T), center=true);
        translate([pcb_L/2 - corner_R, -pcb_W/2 + corner_R, 0])
          cylinder(r=corner_R, h=pcb_T + 2*(copper_T + mask_T + silk_T), center=true);
      }
    }
    // Edge Chamfers
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * (pcb_L/2 - edge_chamfer/2), y * (pcb_W/2 - edge_chamfer/2), 0])
          rotate([0, 45, 0])
            cube([edge_chamfer, pcb_W + 2*edge_chamfer, pcb_T + 2*(copper_T + mask_T + silk_T) + 2*edge_chamfer], center=true);
  }
}

// Copper Layers
module copper_layers() {
  union() {
    translate([0, 0, pcb_T/2 + copper_T/2 - 0.5])
      cube([pcb_L, pcb_W, copper_T], center=true);
    translate([0, 0, -pcb_T/2 - copper_T/2 + 0.5])
      cube([pcb_L, pcb_W, copper_T], center=true);
  }
}

// Solder Mask
module solder_mask() {
  union() {
    translate([0, 0, pcb_T/2 + copper_T + mask_T/2 - 0.5])
      cube([pcb_L, pcb_W, mask_T], center=true);
    translate([0, 0, -pcb_T/2 - copper_T - mask_T/2 + 0.5])
      cube([pcb_L, pcb_W, mask_T], center=true);
  }
}

// Silkscreen
module silkscreen() {
  union() {
    translate([0, 0, pcb_T/2 + copper_T + mask_T + silk_T/2 - 0.5])
      cube([pcb_L, pcb_W, silk_T], center=true);
    translate([0, 0, -pcb_T/2 - copper_T - mask_T - silk_T/2 + 0.5])
      cube([pcb_L, pcb_W, silk_T], center=true);
  }
}

// Mounting Holes
module mounting_holes() {
  for (x = [-1, 1])
    for (y = [-1, 1])
      translate([x * (pcb_L/2 - mount_hole_edge_margin), y * (pcb_W/2 - mount_hole_edge_margin), 0])
        cylinder(r=(mount_hole_d + hole_clearance_extra)/2, h=pcb_T + 2*(copper_T + mask_T + silk_T) + 2, center=true);
}

// Complete PCB Model
module complete_model() {
  difference() {
    union() {
      pcb_body_rounded();
      copper_layers();
      solder_mask();
      silkscreen();
    }
    mounting_holes();
  }
}

// Render the complete model
color([0.0, 0.4, 0.2]) // PCB green color
complete_model();