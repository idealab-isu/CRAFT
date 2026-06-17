// Parameters
pcb_length = 102.0; //[51.0:204.0:0.5]
pcb_width = 90.25; //[45.0:180.5:0.25]
pcb_thickness = 1.6; //[0.8:3.2:0.1]
corner_radius = 4.0; //[2.0:8.0:0.5]
mount_hole_diameter = 3.2; //[2.0:5.0:0.1]
mount_hole_edge_offset_x = 6.0; //[3.0:12.0:0.5]
mount_hole_edge_offset_y = 6.0; //[3.0:12.0:0.5]
hole_cut_extra_z = 2.0; //[1.0:5.0:0.5]
overlap = 1.0; //[0.5:2.0:0.1]
silkscreen_thickness = 0.2; //[0.1:0.6:0.05]
silkscreen_margin = 3.0; //[1.0:8.0:0.5]
connector_height = 10.0; //[5.0:20.0:0.5]
connector_depth = 12.0; //[6.0:25.0:0.5]
connector_wall = 2.0; //[1.0:4.0:0.5]
chip_height = 2.0; //[1.0:6.0:0.25]
chip_size_x = 14.0; //[7.0:28.0:0.5]
chip_size_y = 14.0; //[7.0:28.0:0.5]
heatsink_height = 8.0; //[4.0:20.0:0.5]
heatsink_size_x = 18.0; //[10.0:36.0:0.5]
heatsink_size_y = 18.0; //[10.0:36.0:0.5]
component_overlap_into_pcb = 0.6; //[0.3:1.2:0.1]

// Base Shapes
module corner_cylinder(x, y) {
  translate([x, y, 0])
    cylinder(r=corner_radius, h=pcb_thickness, center=true);
}

module mount_hole(x, y) {
  translate([x, y, 0])
    cylinder(r=mount_hole_diameter/2, h=pcb_thickness + hole_cut_extra_z, center=true);
}

module silkscreen_border() {
  translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
    cube([pcb_length - 2*silkscreen_margin, pcb_width - 2*silkscreen_margin, silkscreen_thickness], center=true);
}

module connector(x, y, z) {
  translate([x, y, z])
    cube([connector_wall, connector_depth, connector_height], center=true);
}

module chip(x, y, z, sx, sy) {
  translate([x, y, z])
    cube([sx, sy, chip_height], center=true);
}

module heatsink(x, y, z) {
  translate([x, y, z])
    cube([heatsink_size_x, heatsink_size_y, heatsink_height], center=true);
}

// Operations
module pcb_main_body() {
  difference() {
    hull() {
      corner_cylinder(pcb_length/2 - corner_radius, pcb_width/2 - corner_radius);
      corner_cylinder(-pcb_length/2 + corner_radius, pcb_width/2 - corner_radius);
      corner_cylinder(-pcb_length/2 + corner_radius, -pcb_width/2 + corner_radius);
      corner_cylinder(pcb_length/2 - corner_radius, -pcb_width/2 + corner_radius);
    }
    union() {
      mount_hole(-pcb_length/2 + mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y);
      mount_hole(pcb_length/2 - mount_hole_edge_offset_x, -pcb_width/2 + mount_hole_edge_offset_y);
      mount_hole(pcb_length/2 - mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y);
      mount_hole(-pcb_length/2 + mount_hole_edge_offset_x, pcb_width/2 - mount_hole_edge_offset_y);
    }
  }
}

module complete_mainboard() {
  union() {
    pcb_main_body();
    silkscreen_border();
    union() {
      connector(-pcb_length/2 - connector_wall/2 + overlap, 0, pcb_thickness/2 + connector_height/2 - component_overlap_into_pcb);
      connector(pcb_length/2 + connector_wall/2 - overlap, 0, pcb_thickness/2 + connector_height/2 - component_overlap_into_pcb);
      translate([0, pcb_width/2 + connector_wall/2 - overlap, pcb_thickness/2 + connector_height/2 - component_overlap_into_pcb])
        cube([pcb_length/4, connector_wall, connector_height], center=true);
    }
    union() {
      chip(0, 0, pcb_thickness/2 + chip_height/2 - component_overlap_into_pcb, chip_size_x, chip_size_y);
      chip(-pcb_length/4, pcb_width/4, pcb_thickness/2 + chip_height/2 - component_overlap_into_pcb, chip_size_x*0.7, chip_size_y*0.5);
      chip(pcb_length/4, -pcb_width/4, pcb_thickness/2 + chip_height/2 - component_overlap_into_pcb, chip_size_x*0.6, chip_size_y*0.6);
    }
    heatsink(pcb_length/6, pcb_width/6, pcb_thickness/2 + heatsink_height/2 - component_overlap_into_pcb);
  }
}

// Final Output
color([0.0, 0.4, 0.2]) complete_mainboard();