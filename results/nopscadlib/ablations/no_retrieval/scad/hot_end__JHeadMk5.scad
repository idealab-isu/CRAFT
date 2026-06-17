// Parameters
total_length = 51.2; //[25.6:102.4:0.1]
barrel_diameter = 4.75; //[2.4:9.5:0.05]
filament_diameter = 1.75; //[1.0:3.0:0.05]
nozzle_length = 12.0; //[6.0:24.0:0.1]
nozzle_tip_diameter = 6.0; //[3.0:12.0:0.1]
heater_block_length = 20.0; //[10.0:40.0:0.1]
heater_block_width = 16.0; //[8.0:32.0:0.1]
heater_block_height = 12.0; //[6.0:24.0:0.1]
heatbreak_length = 8.0; //[4.0:16.0:0.1]
heatbreak_diameter = 4.75; //[2.4:9.5:0.05]
cooling_fins_count = 6; //[3:12:1]
cooling_fin_thickness = 1.2; //[0.6:2.4:0.1]
cooling_fin_diameter = 10.0; //[6.0:20.0:0.1]
cooling_fin_spacing = 1.6; //[0.8:3.2:0.1]
mounting_thread_length = 10.0; //[5.0:20.0:0.1]
mounting_thread_diameter = 6.0; //[3.0:12.0:0.1]
wrench_flat_width = 7.0; //[4.0:14.0:0.1]
wrench_flat_height = 3.0; //[1.5:6.0:0.1]
set_screw_hole_diameter = 3.0; //[1.5:6.0:0.1]
set_screw_hole_z_offset = 0.0; //[-3.0:3.0:0.1]
heater_cartridge_diameter = 6.0; //[3.0:10.0:0.1]
thermistor_diameter = 3.0; //[1.5:6.0:0.1]
hole_overlap = 1.0; //[0.5:2.0:0.1]
chamfer_size = 0.8; //[0.3:2.0:0.1]
rounding_radius = 0.6; //[0.2:1.5:0.1]

// Base Shapes
module barrel_body() {
  translate([0, 0, nozzle_length/2])
    cylinder(h=total_length - nozzle_length, r=barrel_diameter/2, center=true);
}

module heater_block_simplified() {
  translate([0, 0, nozzle_length + heater_block_height/2 - hole_overlap])
    cube([heater_block_length, heater_block_width, heater_block_height], center=true);
}

module heatbreak_transition() {
  translate([0, 0, nozzle_length + heater_block_height - hole_overlap + heatbreak_length/2])
    cylinder(h=heatbreak_length, r=heatbreak_diameter/2, center=true);
}

module mounting_threads() {
  translate([0, 0, nozzle_length + heater_block_height - hole_overlap + heatbreak_length + mounting_thread_length/2 - hole_overlap])
    cylinder(h=mounting_thread_length, r=mounting_thread_diameter/2, center=true);
}

module nozzle_tip() {
  translate([0, 0, nozzle_length/2])
    cylinder(h=nozzle_length, r1=nozzle_tip_diameter/2, r2=0, center=true);
}

module wrench_flats() {
  union() {
    translate([0, 0, nozzle_length - wrench_flat_height/2])
      cube([wrench_flat_width, nozzle_tip_diameter + 2*hole_overlap, wrench_flat_height], center=true);
    translate([0, 0, nozzle_length - wrench_flat_height/2])
      cube([nozzle_tip_diameter + 2*hole_overlap, wrench_flat_width, wrench_flat_height], center=true);
  }
}

module cooling_fins() {
  for (i = [0:cooling_fins_count-1]) {
    translate([0, 0, nozzle_length + heater_block_height - hole_overlap + heatbreak_length + mounting_thread_length - hole_overlap + cooling_fin_thickness/2 + i*(cooling_fin_thickness + cooling_fin_spacing)])
      cylinder(h=cooling_fin_thickness, r=cooling_fin_diameter/2, center=true);
  }
}

module filament_bore() {
  translate([0, 0, total_length/2])
    cylinder(h=total_length + 2*hole_overlap, r=filament_diameter/2, center=true);
}

module set_screw_holes() {
  union() {
    translate([heater_block_length/4, 0, nozzle_length + heater_block_height/2 - hole_overlap + set_screw_hole_z_offset])
      rotate([90, 0, 0])
      cylinder(h=heater_block_width + 2*hole_overlap, r=set_screw_hole_diameter/2, center=true);
    translate([-heater_block_length/4, 0, nozzle_length + heater_block_height/2 - hole_overlap + set_screw_hole_z_offset])
      rotate([90, 0, 0])
      cylinder(h=heater_block_width + 2*hole_overlap, r=set_screw_hole_diameter/2, center=true);
  }
}

module heater_cartridge_hole() {
  translate([0, 0, nozzle_length + heater_block_height/2 - hole_overlap])
    rotate([0, 90, 0])
    cylinder(h=heater_block_length + 2*hole_overlap, r=heater_cartridge_diameter/2, center=true);
}

module thermistor_hole() {
  translate([0, 0, nozzle_length + heater_block_height/2 - hole_overlap - heater_block_height/4])
    rotate([90, 0, 0])
    cylinder(h=heater_block_width + 2*hole_overlap, r=thermistor_diameter/2, center=true);
}

module chamfers_fillets_sphere() {
  sphere(r=rounding_radius);
}

// Main Assembly
module hotend_assembly() {
  difference() {
    union() {
      barrel_body();
      heater_block_simplified();
      heatbreak_transition();
      mounting_threads();
      nozzle_tip();
      cooling_fins();
      wrench_flats();
    }
    union() {
      filament_bore();
      set_screw_holes();
      heater_cartridge_hole();
      thermistor_hole();
    }
  }
}

// Final Output with Chamfers/Fillets
minkowski() {
  hotend_assembly();
  chamfers_fillets_sphere();
}