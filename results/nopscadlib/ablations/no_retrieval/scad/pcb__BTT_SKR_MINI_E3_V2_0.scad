// Parameters
pcb_length = 100.75; //[50.375:201.5:0.25]
pcb_width = 70.25; //[35.125:140.5:0.25]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 3.0; //[1.0:8.0:0.5]
hole_diameter = 3.2; //[2.0:6.0:0.1]
hole_edge_offset = 5.0; //[3.0:12.0:0.5]
hole_cut_extra_z = 0.6; //[0.2:2.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
connector_height = 10.0; //[5.0:20.0:0.5]
connector_depth = 12.0; //[6.0:25.0:0.5]
connector_wall_overlap = 0.8; //[0.5:2.0:0.1]
heatsink_size_x = 14.0; //[8.0:28.0:0.5]
heatsink_size_y = 14.0; //[8.0:28.0:0.5]
heatsink_height = 8.0; //[3.0:20.0:0.5]
mask_thickness = 0.2; //[0.05:0.6:0.05]
mask_margin = 2.0; //[0.5:6.0:0.5]

// Mainboard PCB with rounded corners and mounting holes
module pcb_mainboard() {
  color([0.0, 0.4, 0.2]) // Green for PCB
  difference() {
    intersection() {
      // Main PCB rectangle
      cube([pcb_length, pcb_width, pcb_thickness], center=true);
      
      // Corner rounding
      union() {
        translate([pcb_length/2 - corner_radius, pcb_width/2 - corner_radius, 0])
          cylinder(r=corner_radius, h=pcb_thickness + 2*overlap, center=true);
        translate([-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius, 0])
          cylinder(r=corner_radius, h=pcb_thickness + 2*overlap, center=true);
        translate([-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius, 0])
          cylinder(r=corner_radius, h=pcb_thickness + 2*overlap, center=true);
        translate([pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius, 0])
          cylinder(r=corner_radius, h=pcb_thickness + 2*overlap, center=true);
      }
    }
    
    // Mounting holes
    union() {
      translate([pcb_length/2 - hole_edge_offset, pcb_width/2 - hole_edge_offset, 0])
        cylinder(r=hole_diameter/2, h=pcb_thickness + hole_cut_extra_z, center=true);
      translate([-pcb_length/2 + hole_edge_offset, pcb_width/2 - hole_edge_offset, 0])
        cylinder(r=hole_diameter/2, h=pcb_thickness + hole_cut_extra_z, center=true);
      translate([-pcb_length/2 + hole_edge_offset, -pcb_width/2 + hole_edge_offset, 0])
        cylinder(r=hole_diameter/2, h=pcb_thickness + hole_cut_extra_z, center=true);
      translate([pcb_length/2 - hole_edge_offset, -pcb_width/2 + hole_edge_offset, 0])
        cylinder(r=hole_diameter/2, h=pcb_thickness + hole_cut_extra_z, center=true);
    }
  }
}

// Connectors
module connectors() {
  color([0.85, 0.85, 0.8]) // Off-white for connectors
  union() {
    translate([-pcb_length*0.20, pcb_width/2 - connector_depth/2 + connector_wall_overlap, pcb_thickness/2 + connector_height/2 - connector_wall_overlap])
      cube([pcb_length*0.22, connector_depth, connector_height], center=true);
    translate([pcb_length*0.18, pcb_width/2 - connector_depth/2 + connector_wall_overlap, pcb_thickness/2 + (connector_height*0.9)/2 - connector_wall_overlap])
      cube([pcb_length*0.18, connector_depth, connector_height*0.9], center=true);
    translate([pcb_length/2 - (pcb_length*0.20)/2 + connector_wall_overlap, -pcb_width*0.10, pcb_thickness/2 + (connector_height*0.8)/2 - connector_wall_overlap])
      cube([pcb_length*0.20, connector_depth*0.9, connector_height*0.8], center=true);
  }
}

// Heatsinks
module heatsinks() {
  color([0.4, 0.4, 0.43]) // DimGray for heatsinks
  union() {
    translate([-pcb_length*0.10, -pcb_width*0.10, pcb_thickness/2 + heatsink_height/2 - overlap])
      cube([heatsink_size_x, heatsink_size_y, heatsink_height], center=true);
    translate([pcb_length*0.18, -pcb_width*0.18, pcb_thickness/2 + (heatsink_height*0.9)/2 - overlap])
      cube([heatsink_size_x*0.9, heatsink_size_y*0.9, heatsink_height*0.9], center=true);
  }
}

// Solder mask detail
module solder_mask_detail() {
  color([0.1, 0.1, 0.6]) // Blue for solder mask
  translate([0, 0, pcb_thickness/2 + mask_thickness/2 - overlap])
    cube([pcb_length - 2*mask_margin, pcb_width - 2*mask_margin, mask_thickness], center=true);
}

// Complete mainboard model
module complete_mainboard_model() {
  union() {
    pcb_mainboard();
    connectors();
    heatsinks();
    solder_mask_detail();
  }
}

// Render the complete model
complete_mainboard_model();