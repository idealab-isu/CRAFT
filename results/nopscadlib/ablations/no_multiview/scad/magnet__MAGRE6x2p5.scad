// Parameters
outer_diameter_mm = 6; //[3:12:0.1]
height_mm = 2; //[1:4:0.1]
bore_diameter_mm = 0; //[0:4:0.1]
edge_chamfer_mm = 0.2; //[0:0.8:0.05]
tolerance_mm = 0.1; //[0:0.3:0.01]
overlap_mm = 0.8; //[0.5:2:0.1]
flat_depth_mm = 0.6; //[0:2:0.05]
carrier_thickness_mm = 0.6; //[0:2:0.05]
carrier_radial_margin_mm = 1.0; //[0:3:0.1]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper color for magnet
    difference() {
      // Cylindrical magnet body with chamfers
      difference() {
        cylinder(r=outer_diameter_mm/2, h=height_mm, center=true);
        translate([0, 0, height_mm/2 - edge_chamfer_mm/2])
          cylinder(r1=outer_diameter_mm/2 + overlap_mm, r2=0, h=edge_chamfer_mm + overlap_mm, center=true);
        translate([0, 0, -height_mm/2 + edge_chamfer_mm/2])
          cylinder(r1=outer_diameter_mm/2 + overlap_mm, r2=0, h=edge_chamfer_mm + overlap_mm, center=true);
      }
      // Alignment flat
      if (flat_depth_mm > 0) {
        translate([outer_diameter_mm/2 - flat_depth_mm + outer_diameter_mm/2, 0, 0])
          cube([outer_diameter_mm, outer_diameter_mm + 2*overlap_mm, height_mm + 2*overlap_mm], center=true);
      }
      // Central bore
      if (bore_diameter_mm > 0) {
        cylinder(r=(bore_diameter_mm + tolerance_mm)/2, h=height_mm + 2*overlap_mm, center=true);
      }
    }
  }
}

// Protective sleeve/carrier disc
module carrier_disc() {
  if (carrier_thickness_mm > 0) {
    color([0.85, 0.85, 0.8]) { // Off-white for carrier
      translate([0, 0, height_mm/2 + carrier_thickness_mm/2 - overlap_mm])
        cylinder(r=outer_diameter_mm/2 + carrier_radial_margin_mm, h=carrier_thickness_mm, center=true);
    }
  }
}

// Assembly
module assembly() {
  magnet();
  carrier_disc();
}

assembly();