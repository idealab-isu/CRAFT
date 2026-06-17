// Parameters
length = 15; //[8:30:1]
forced_id = 0; //[0:10:1]
center = 1; //[0:1:1]
original_id = 2.0; //[1.0:6.0:0.5]
original_od = 3.2; //[1.6:12.0:0.5]
eps = 0.8; //[0.5:2.0:0.1]

// Derived parameters
id = (forced_id > 0) ? forced_id : original_id;
od = original_od + id - original_id;

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) {
    difference() {
      // Outer diameter profile
      cylinder(r=od/2, h=length + 2*eps, center=true);
      // Inner bore
      cylinder(r=id/2, h=length + 4*eps, center=true);
    }
  }
}

// Sleeved Resistor - complete geometry
module sleeved_resistor() {
  color([0.2, 0.2, 0.2]) {
    // Resistor body
    cylinder(r=1.5, h=5, center=true);
    // Leads
    translate([0, 0, -5]) cylinder(r=0.5, h=10, center=true);
  }
}

// Assembly
module assembly() {
  translate([0, 0, center ? 0 : length/2]) tubing();
  translate([0, 0, center ? 0 : length/2]) sleeved_resistor();
}

assembly();