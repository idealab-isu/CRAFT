// Parameters
sheet_length = 600; //[300:1200:1]
sheet_width = 400; //[200:800:1]
sheet_thickness = 18; //[9:36:1]
edge_chamfer = 1.5; //[0.5:3:0.1]
corner_rounding = 6; //[2:12:0.5]
label_thickness = 0.6; //[0.2:1.5:0.1]
label_length = 60; //[30:120:1]
label_width = 20; //[10:50:1]
connect_overlap = 1; //[0.5:2:0.1]

// MDF Sheet Panel with Corner Rounding and Edge Chamfer
module mdf_sheet_panel() {
  color([0.85, 0.85, 0.8]) {
    // Base panel
    translate([0, 0, 0])
      cube([sheet_length, sheet_width, sheet_thickness], center=true);

    // Corner rounding
    for (x = [-1, 1], y = [-1, 1]) {
      translate([x * (sheet_length/2 - corner_rounding), y * (sheet_width/2 - corner_rounding), 0])
        cylinder(r=corner_rounding, h=sheet_thickness, center=true);
    }

    // Edge chamfer approximation
    offset(r=edge_chamfer) {
      translate([0, 0, 0])
        cube([sheet_length - 2*corner_rounding, sheet_width - 2*corner_rounding, sheet_thickness], center=true);
    }
  }
}

// Material Label
module material_label() {
  color([0.1, 0.1, 0.6]) {
    translate([sheet_length/2 - label_length/2 - connect_overlap, 
               sheet_width/2 - label_width/2 - connect_overlap, 
               sheet_thickness/2 + label_thickness/2 - connect_overlap])
      cube([label_length, label_width, label_thickness], center=true);
  }
}

// Final Model
union() {
  mdf_sheet_panel();
  material_label();
}