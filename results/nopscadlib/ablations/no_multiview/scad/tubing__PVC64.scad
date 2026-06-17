// Parameters
length = 15; //[8:30:1]
outer_diameter = 10; //[5:20:0.5]
inner_diameter = 8; //[3:18:0.5]
forced_inner_diameter = 0; //[0:18:0.5]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) { // PVC-like color
    difference() {
      // Outer tube
      cylinder(r=outer_diameter/2, h=length, center=true);
      // Inner bore
      cylinder(r=((forced_inner_diameter > 0) ? forced_inner_diameter : inner_diameter) / 2, 
               h=length + overlap * 2, center=true);
    }
  }
}

// Assembly
module assembly() {
  translate([0, 0, ((center > 0) ? 0 : length / 2)]) tubing();
}

assembly();