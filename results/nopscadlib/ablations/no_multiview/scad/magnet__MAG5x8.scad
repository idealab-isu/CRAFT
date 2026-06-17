// Parameters
magnet_type = 0; //[0:20:1]
magnet_od = 20; //[10:40:1]
magnet_h = 5; //[2.5:10:0.5]
magnet_id = 0; //[0:20:1]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper color for the magnet
    difference() {
      // Outer body of the magnet
      cylinder(r=magnet_od/2, h=magnet_h, center=true, $fn=64);
      // Inner bore (if any)
      if (magnet_id > 0) {
        cylinder(r=magnet_id/2, h=magnet_h + 2, center=true, $fn=64);
      }
    }
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();