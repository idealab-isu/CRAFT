// Parameters
total_L = 66; //[33:132:1]
barrel_D = 6.8; //[3.4:13.6:0.1]
filament_D = 1.75; //[1:3:0.01]
bore_clearance = 0.25; //[0.1:0.6:0.01]
bore_D = 2; //[1.5:3.5:0.01]
barrel_L = 44; //[22:88:1]
nozzle_L = 12; //[6:24:1]
nozzle_tip_D = 7; //[4:12:0.1]
heater_block_L = 20; //[10:40:1]
heater_block_W = 16; //[8:32:1]
heater_block_H = 12; //[6:24:1]
heatbreak_L = 34; //[17:68:1]
heatbreak_D = 6.8; //[3.4:13.6:0.1]
overlap = 1; //[0.5:2:0.1]
nozzle_hex_AF = 7; //[5:12:0.1]
nozzle_hex_H = 6; //[3:12:0.5]
heater_cartridge_D = 6; //[3:10:0.1]
thermistor_D = 3; //[1.5:6:0.1]
mount_groove_D = 5.8; //[3:10:0.1]
mount_groove_L = 4; //[2:10:0.5]
fin_count = 6; //[3:12:1]
fin_OD = 12; //[8:24:0.5]
fin_thk = 1.2; //[0.6:3:0.1]
fin_gap = 2.2; //[1:5:0.1]
thread_OD = 6; //[4:10:0.1]
thread_L = 6; //[3:15:0.5]
chamfer_Delta = 1; //[0.5:2:0.1]

// Base Shapes
module hotend_barrel() {
  color("Silver")
  cylinder(r=barrel_D/2, h=total_L, center=true);
}

module heater_block() {
  color("DimGray")
  translate([0, 0, -total_L/2 + nozzle_L + heater_block_H/2])
  cube([heater_block_L, heater_block_W, heater_block_H], center=true);
}

module nozzle_tip() {
  color("Copper")
  translate([0, 0, -total_L/2 + nozzle_L/2])
  cylinder(r1=nozzle_tip_D/2, r2=0, h=nozzle_L, center=true);
}

module nozzle_hex_flats() {
  color("Brass")
  translate([0, 0, -total_L/2 + nozzle_L + nozzle_hex_H/2 - overlap])
  cube([nozzle_hex_AF, nozzle_hex_AF, nozzle_hex_H], center=true);
}

module heatbreak_transition() {
  color("Silver")
  translate([0, 0, -total_L/2 + nozzle_L + heater_block_H/2])
  cylinder(r1=barrel_D/2, r2=0, h=heater_block_H, center=true);
}

module threads() {
  color("Silver")
  translate([0, 0, -total_L/2 + nozzle_L + heater_block_H + thread_L/2 - overlap])
  cylinder(r=thread_OD/2, h=thread_L, center=true);
}

module cooling_fin(pos) {
  translate([0, 0, pos])
  cylinder(r=fin_OD/2, h=fin_thk, center=true);
}

module cooling_fins() {
  color("Silver")
  union() {
    for (i = [0:fin_count-1]) {
      cooling_fin(total_L/2 - (fin_thk/2) - overlap - i*(fin_thk + fin_gap));
    }
  }
}

module filament_bore() {
  translate([0, 0, 0])
  cylinder(r=bore_D/2, h=total_L + 2*overlap, center=true);
}

module heater_cartridge_hole() {
  rotate([90, 0, 0])
  translate([0, 0, -total_L/2 + nozzle_L + heater_block_H/2])
  cylinder(r=heater_cartridge_D/2, h=heater_block_W + 2*overlap, center=true);
}

module thermistor_hole() {
  rotate([0, 90, 0])
  translate([0, 0, -total_L/2 + nozzle_L + heater_block_H/2])
  cylinder(r=thermistor_D/2, h=heater_block_L + 2*overlap, center=true);
}

module mounting_groove() {
  translate([0, 0, total_L/2 - mount_groove_L/2 - 2*overlap])
  cylinder(r=barrel_D/2, h=mount_groove_L, center=true);
}

module mounting_groove_cut() {
  translate([0, 0, total_L/2 - mount_groove_L/2 - 2*overlap])
  cylinder(r=mount_groove_D/2, h=mount_groove_L + 2*overlap, center=true);
}

module chamfers_fillets() {
  translate([0, 0, -total_L/2 + chamfer_Delta/2])
  sphere(r=chamfer_Delta/2, center=true);
}

// Operations
module hotend_solids_union() {
  union() {
    hotend_barrel();
    heater_block();
    nozzle_tip();
    nozzle_hex_flats();
    heatbreak_transition();
    threads();
    cooling_fins();
    chamfers_fillets();
  }
}

module mounting_groove_diff() {
  difference() {
    mounting_groove();
    mounting_groove_cut();
  }
}

module hotend_with_mount_groove() {
  union() {
    hotend_solids_union();
    mounting_groove_diff();
  }
}

module hotend_bored() {
  difference() {
    hotend_with_mount_groove();
    filament_bore();
    heater_cartridge_hole();
    thermistor_hole();
  }
}

// Final Output
hotend_bored();