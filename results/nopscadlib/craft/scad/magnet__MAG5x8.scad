// Parameters
magnet_type = 0; //[0:10:1]
magnet_od = 20; //[10:40:1]
magnet_id = 5; //[0:20:1]
magnet_h = 5; //[2.5:10:0.5]
bore_clearance = 0.2; //[0:0.6:0.05]

// Magnet - complete geometry
module magnet() {
  color([0.8, 0.6, 0.2]) { // Brass-like color for the magnet
    difference() {
      // Outer cylinder
      cylinder(r=magnet_od/2, h=magnet_h, center=true);
      // Inner bore
      if (magnet_id > 0) {
        cylinder(r=(magnet_id + bore_clearance)/2, h=magnet_h + 2, center=true);
      }
    }
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();