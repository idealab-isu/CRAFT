// Parameters
pcb_L = 51.0; //[25.5:102.0:0.5]
pcb_W = 21.0; //[10.5:42.0:0.5]
pcb_T = 1.6; //[0.8:3.2:0.1]
corner_R = 2.0; //[0.5:4.0:0.1]
chamfer_C = 0.6; //[0.2:1.2:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
placeholder_eps = 0.01; //[0.001:0.1:0.001]

// Base PCB with rounded corners
module pcb_base() {
  difference() {
    union() {
      translate([0, 0, 0])
        cube([pcb_L, pcb_W, pcb_T], center=true);
      translate([-pcb_L/2 + corner_R, pcb_W/2 - corner_R, 0])
        cylinder(r=corner_R, h=pcb_T, center=true);
      translate([pcb_L/2 - corner_R, pcb_W/2 - corner_R, 0])
        cylinder(r=corner_R, h=pcb_T, center=true);
      translate([-pcb_L/2 + corner_R, -pcb_W/2 + corner_R, 0])
        cylinder(r=corner_R, h=pcb_T, center=true);
      translate([pcb_L/2 - corner_R, -pcb_W/2 + corner_R, 0])
        cylinder(r=corner_R, h=pcb_T, center=true);
    }
    // Chamfered edges
    translate([pcb_L/2 - chamfer_C/2, 0, 0])
      rotate([0, 0, 45])
      cube([chamfer_C, pcb_W + 2*overlap, pcb_T + 2*overlap], center=true);
    translate([-pcb_L/2 + chamfer_C/2, 0, 0])
      rotate([0, 0, 45])
      cube([chamfer_C, pcb_W + 2*overlap, pcb_T + 2*overlap], center=true);
    translate([0, pcb_W/2 - chamfer_C/2, 0])
      rotate([0, 0, 45])
      cube([pcb_L + 2*overlap, chamfer_C, pcb_T + 2*overlap], center=true);
    translate([0, -pcb_W/2 + chamfer_C/2, 0])
      rotate([0, 0, 45])
      cube([pcb_L + 2*overlap, chamfer_C, pcb_T + 2*overlap], center=true);
  }
}

// Placeholders for zero-impact cuts
module placeholders() {
  translate([0, 0, pcb_T/2 - placeholder_eps/2])
    cylinder(r=corner_R/2, h=placeholder_eps, center=true);
  translate([0, 0, pcb_T/2 - placeholder_eps/2])
    cube([pcb_L/4, pcb_W/6, placeholder_eps], center=true);
  translate([0, 0, pcb_T/2 - placeholder_eps/2])
    cube([pcb_L/5, pcb_W/4, placeholder_eps], center=true);
  translate([0, 0, pcb_T/2 - placeholder_eps/2])
    cube([pcb_L/3, pcb_W/10, placeholder_eps], center=true);
}

// Final PCB with all features
module final_pcb() {
  difference() {
    pcb_base();
    placeholders();
  }
}

// Render the final PCB
color([0.0, 0.4, 0.2]) // PCB green color
final_pcb();