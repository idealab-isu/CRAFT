// Parameters
pcb_length = 20.0; //[10.0:40.0:0.5]
pcb_width = 14.0; //[7.0:28.0:0.5]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
overlap = 0.8; //[0.5:2.0:0.1]
mount_hole_diameter = 2.2; //[1.6:3.6:0.1]
mount_hole_edge_margin_x = 2.5; //[1.5:5.0:0.1]
mount_hole_edge_margin_y = 2.5; //[1.5:5.0:0.1]
header_pin_pitch = 2.54; //[2.0:3.0:0.01]
header_rows = 2; //[1:2:1]
header_pins_per_row = 8; //[4:10:1]
header_plastic_height = 2.5; //[1.5:5.0:0.1]
header_plastic_thickness = 2.5; //[1.5:4.0:0.1]
header_pin_diameter = 0.7; //[0.4:1.0:0.05]
header_pin_length = 6.0; //[3.0:12.0:0.5]
ic_length = 6.0; //[3.0:12.0:0.2]
ic_width = 6.0; //[3.0:12.0:0.2]
ic_height = 1.2; //[0.6:3.0:0.1]
passive_0603_length = 1.6; //[1.0:3.2:0.1]
passive_0603_width = 0.8; //[0.5:1.6:0.05]
passive_height = 0.6; //[0.3:1.5:0.05]
heatsink_length = 8.0; //[4.0:16.0:0.5]
heatsink_width = 8.0; //[4.0:16.0:0.5]
heatsink_height = 6.0; //[3.0:12.0:0.5]
silkscreen_height = 0.15; //[0.05:0.4:0.05]
silkscreen_margin = 0.8; //[0.4:2.0:0.1]

// Geometry
module pcb_main_body() {
  color([0.0, 0.4, 0.2]) // Green PCB
  cube([pcb_length, pcb_width, pcb_thickness], center=true);
}

module mount_hole() {
  cylinder(h=pcb_thickness + 2*overlap, r=mount_hole_diameter/2, center=true);
}

module pin_header_plastic() {
  color([0.1, 0.1, 0.1]) // Black plastic
  cube([header_pin_pitch*(header_pins_per_row-1) + header_pin_pitch, header_plastic_thickness, header_plastic_height], center=true);
}

module pin_header_pin() {
  color([0.8, 0.6, 0.2]) // Brass pins
  cylinder(h=header_plastic_height + header_pin_length, r=header_pin_diameter/2, center=true);
}

module ic_package() {
  color([0.1, 0.1, 0.1]) // Black IC
  cube([ic_length, ic_width, ic_height], center=true);
}

module passive_component() {
  color([0.85, 0.85, 0.8]) // Off-white passive
  cube([passive_0603_length, passive_0603_width, passive_height], center=true);
}

module heatsink() {
  color([0.4, 0.4, 0.43]) // Steel heatsink
  cube([heatsink_length, heatsink_width, heatsink_height], center=true);
}

module silkscreen_markings() {
  color([1, 1, 1, 0.5]) // White silkscreen
  cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_height], center=true);
}

// Assembly
module complete_model() {
  difference() {
    pcb_main_body();
    union() {
      translate([-pcb_length/2 + mount_hole_edge_margin_x, -pcb_width/2 + mount_hole_edge_margin_y, 0]) mount_hole();
      translate([pcb_length/2 - mount_hole_edge_margin_x, -pcb_width/2 + mount_hole_edge_margin_y, 0]) mount_hole();
      translate([-pcb_length/2 + mount_hole_edge_margin_x, pcb_width/2 - mount_hole_edge_margin_y, 0]) mount_hole();
      translate([pcb_length/2 - mount_hole_edge_margin_x, pcb_width/2 - mount_hole_edge_margin_y, 0]) mount_hole();
    }
  }
  
  translate([0, -pcb_width/2 + header_plastic_thickness/2 - overlap, pcb_thickness/2 + header_plastic_height/2 - overlap])
    union() {
      pin_header_plastic();
      for (i = [0:header_pins_per_row-1]) {
        translate([-(header_pin_pitch*(header_pins_per_row-1))/2 + i*header_pin_pitch, 0, 0]) pin_header_pin();
      }
    }
  
  translate([0, pcb_width*0.05, pcb_thickness/2 + ic_height/2 - overlap]) ic_package();
  
  union() {
    translate([-pcb_length*0.25, pcb_width*0.20, pcb_thickness/2 + passive_height/2 - overlap]) passive_component();
    translate([-pcb_length*0.25 + passive_0603_length*1.2, pcb_width*0.20, pcb_thickness/2 + passive_height/2 - overlap]) passive_component();
    translate([-pcb_length*0.25, pcb_width*0.20 + passive_0603_width*1.8, pcb_thickness/2 + passive_height/2 - overlap]) passive_component();
    translate([pcb_length*0.25, pcb_width*0.15, pcb_thickness/2 + passive_height/2 - overlap]) passive_component();
  }
  
  translate([pcb_length*0.20, pcb_width*0.20, pcb_thickness/2 + heatsink_height/2 - overlap]) heatsink();
  
  translate([0, 0, pcb_thickness/2 + silkscreen_height/2 - overlap]) silkscreen_markings();
}

// Render the complete model
complete_model();