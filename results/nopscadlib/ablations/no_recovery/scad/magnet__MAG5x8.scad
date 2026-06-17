// Parameters
magnet_type = 0; //[0:10:1]
magnet_od = 20; //[10:40:1]
magnet_id = 5; //[0:20:1]
magnet_h = 5; //[2.5:10:0.5]
magnet_edge_r = 0.8; //[0:2:0.1]
eps = 0.6; //[0.2:2:0.1]

// Magnet - complete geometry
module magnet() {
  color([0.72, 0.45, 0.2]) { // Copper-like color for magnet
    difference() {
      // Outer profile with edge rounding
      linear_extrude(height=magnet_h, center=true) 
        offset(r=magnet_edge_r) 
        circle(r=magnet_od/2);
      
      // Inner bore
      if (magnet_id > 0) {
        linear_extrude(height=magnet_h + eps, center=true)
          circle(r=magnet_id/2);
      }
    }
  }
}

// Assembly
module assembly() {
  magnet();
}

assembly();