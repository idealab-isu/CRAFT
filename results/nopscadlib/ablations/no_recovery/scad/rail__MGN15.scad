// Parameters
rail_L = 100.0; //[50.0:200.0:1]
rail_W = 15.0; //[7.5:30.0:0.5]
rail_H = 10.0; //[5.0:20.0:0.5]

// Geometry
module rail_body() {
  color("Silver") // Aluminum-like appearance
  translate([0, 0, 0])
    cube([rail_W, rail_L, rail_H], center=true);
}

// Final Output
union() {
  rail_body();
}