// Parameters
length = 15; //[8:30:1]
outer_diameter = 10; //[5:20:0.5]
inner_diameter = 6; //[3:18:0.5]
forced_id = 0; //[0:18:0.5]
center = 1; //[0:1:1]
eps = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.2, 0.2, 0.2]) { // Neoprene color
    difference() {
      // Outer tube
      cylinder(h=length + 2*eps, r=outer_diameter/2, center=true);
      // Inner bore
      cylinder(h=length + 4*eps, r=((forced_id>0)?forced_id:inner_diameter)/2, center=true);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, ((center>0)?0:(length/2))]) tubing();
}

assembly();