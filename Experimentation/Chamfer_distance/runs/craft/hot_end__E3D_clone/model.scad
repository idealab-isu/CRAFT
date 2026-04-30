// Parameters
total_length_mm = 66; //[33:132:1]
mount_inset_mm = 6.8; //[3.4:13.6:0.1]
insulator_diameter_mm = 16; //[8:32:0.5]
insulator_length_mm = 46; //[23:92:1]
mounting_groove_diameter_mm = 12; //[6:24:0.5]
mounting_groove_length_mm = 5.6; //[2.8:11.2:0.1]
overlap_mm = 1; //[0.5:2:0.1]
top_flange_diameter_mm = 20; //[10:40:0.5]
top_flange_thickness_mm = 6.8; //[3.4:13.6:0.1]
fin_outer_diameter_mm = 24; //[12:48:0.5]
fin_thickness_mm = 1.6; //[0.8:3.2:0.1]
fin_count = 6; //[3:10:1]
heater_block_size_x_mm = 18; //[9:36:0.5]
heater_block_size_y_mm = 16; //[8:32:0.5]
heater_block_height_mm = 12; //[6:24:0.5]
nozzle_hex_diameter_mm = 8; //[4:16:0.5]
nozzle_hex_height_mm = 4; //[2:8:0.5]
nozzle_tip_height_mm = 6; //[3:12:0.5]
resistor_wire_radius_mm = 2; //[1:4:0.1]
resistor_wire_thickness_mm = 1.2; //[0.6:2.4:0.1]
resistor_wire_offset_x_mm = 6; //[3:12:0.5]

// Hot End - complete geometry
module hot_end() {
  color("Silver") {
    // Top Flange
    translate([0, 0, total_length_mm/2 - top_flange_thickness_mm/2])
      difference() {
        cylinder(r=top_flange_diameter_mm/2, h=top_flange_thickness_mm, center=true);
        translate([0, 0, 0])
          cylinder(r=mounting_groove_diameter_mm/2, h=mounting_groove_length_mm + 2*overlap_mm, center=true);
      }
    
    // Insulator Body
    translate([0, 0, total_length_mm/2 - mount_inset_mm - insulator_length_mm/2 + overlap_mm])
      cylinder(r=insulator_diameter_mm/2, h=insulator_length_mm, center=true);
    
    // Fins
    for (i = [0:fin_count-1]) {
      translate([0, 0, total_length_mm/2 - mount_inset_mm - insulator_length_mm/2 + overlap_mm - insulator_length_mm/2 + (mount_inset_mm*0.35) + (fin_thickness_mm/2) + (insulator_length_mm - mount_inset_mm*0.7 - fin_thickness_mm) * (i/(fin_count-1))])
        cylinder(r=fin_outer_diameter_mm/2, h=fin_thickness_mm, center=true);
    }
    
    // Heater Block
    translate([0, 0, -total_length_mm/2 + heater_block_height_mm/2])
      cube([heater_block_size_x_mm, heater_block_size_y_mm, heater_block_height_mm], center=true);
    
    // Nozzle Hex
    translate([0, 0, -total_length_mm/2 + heater_block_height_mm + nozzle_hex_height_mm/2 - overlap_mm])
      cylinder(r=nozzle_hex_diameter_mm/2, h=nozzle_hex_height_mm, center=true);
    
    // Nozzle Tip
    translate([0, 0, -total_length_mm/2 + heater_block_height_mm + nozzle_hex_height_mm + nozzle_tip_height_mm/2 - 2*overlap_mm])
      cylinder(r1=nozzle_hex_diameter_mm/2, r2=0, h=nozzle_tip_height_mm, center=true);
    
    // Resistor Wire Loop
    rotate([0, 0, 0])
      translate([heater_block_size_x_mm/2 + resistor_wire_offset_x_mm - overlap_mm, 0, -total_length_mm/2 + heater_block_height_mm/2])
        rotate_extrude() translate([resistor_wire_radius_mm, 0, 0]) circle(r=resistor_wire_thickness_mm/2);
  }
}

// PCB Mount - complete geometry
module pcb_mount() {
  color("DimGray") {
    // Mounting Plate
    translate([0, heater_block_size_y_mm/2 + (heater_block_height_mm*0.25)/2 - overlap_mm, -total_length_mm/2 + heater_block_height_mm*0.75])
      cube([heater_block_size_x_mm*1.2, heater_block_size_y_mm*0.8, heater_block_height_mm*0.25], center=true);
  }
}

// PCB Mount Assembly - complete geometry
module pcb_mount_assembly() {
  color("DimGray") {
    pcb_mount();
  }
}

// E3D Hot End Assembly - complete geometry
module e3d_hot_end_assembly() {
  color("Silver") {
    hot_end();
  }
}

// E3D Hot End - complete geometry
module e3d_hot_end() {
  color("Silver") {
    hot_end();
  }
}

// Assembly
module assembly() {
  e3d_hot_end_assembly();
  pcb_mount_assembly();
}

assembly();