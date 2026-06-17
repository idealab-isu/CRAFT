// Parameters
magnet_type = 0; //[0:2:1]
magnet_od_t0 = 10; //[5:20:1]
magnet_id_t0 = 0; //[0:8:1]
magnet_h_t0 = 3; //[2:6:1]
magnet_r_t0 = 0.5; //[0.2:1.5:0.1]
magnet_od_t1 = 12; //[6:24:1]
magnet_id_t1 = 5; //[1:12:1]
magnet_h_t1 = 3; //[2:8:1]
magnet_r_t1 = 0.5; //[0.2:1.5:0.1]
magnet_od_t2 = 20; //[10:40:1]
magnet_id_t2 = 0; //[0:16:1]
magnet_h_t2 = 10; //[5:20:1]
magnet_r_t2 = 1; //[0.2:3:0.1]
magnet_od = 12; //[6:24:1]
magnet_id = 5; //[0:12:1]
magnet_h = 3; //[2:20:1]
bore_clearance = 0.2; //[0.0:0.6:0.05]

// Magnet module
module magnet() {
  color([0.8, 0.6, 0.2]) { // Brass-like color for magnet
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