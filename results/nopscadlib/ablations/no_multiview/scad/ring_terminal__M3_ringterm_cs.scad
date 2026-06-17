// Parameters
t = 1.5; //[0.8:3:0.1]
w = 8; //[4:16:0.5]
od = 12; //[6:24:0.5]
id = 6.5; //[3:13:0.5]
l = 28; //[14:56:1]
crimp = 12; //[0:24:1]
angle = 45; //[0:90:1]
transition_length = 1; //[0.5:3:0.1]
hole_d = 3.5; //[0:8:0.5]
overlap = 1; //[0.5:2:0.1]
barrel_wall = 0.8; //[0.4:1.6:0.1]
barrel_od = 8; //[5:16:0.5]
tab_end_d = 8; //[4:16:0.5]

// Ring Terminal - complete geometry
module ring_terminal() {
  color("Silver") {
    // Ring Lug Body
    linear_extrude(height=t, center=true) {
      polygon(points=[
        [-od/2, 0],
        [od/2, 0],
        [w/2, -(l - od/2)],
        [-w/2, -(l - od/2)]
      ]);
    }
    
    // Ring Hole
    translate([0, 0, 0])
      cylinder(r=id/2, h=t + 2*overlap, center=true);
    
    // Tab or Neck Extension
    linear_extrude(height=t, center=true) {
      polygon(points=[
        [-w/2, -(od/2 - overlap)],
        [w/2, -(od/2 - overlap)],
        [w/2, -(l - od/2)],
        [-w/2, -(l - od/2)]
      ]);
    }
  }
}

// Ring Terminal Assembly - complete geometry
module ring_terminal_assembly() {
  color("Silver") {
    // Crimp Barrel Outer
    translate([0, -(od/2 + crimp/2 - overlap), w/2])
      rotate([90, 0, 0])
      cylinder(r=barrel_od/2, h=crimp, center=true);
    
    // Crimp Barrel Inner
    translate([0, -(od/2 + crimp/2 - overlap), w/2])
      rotate([90, 0, 0])
      cylinder(r=(barrel_od/2 - barrel_wall), h=crimp + 2*transition_length + 2*overlap, center=true);
    
    // Transition Fillet or Hull Blend
    translate([0, -(od/2 + transition_length/2 - overlap), w/2])
      cube([w, transition_length, w], center=true);
    
    // Bent Tab Plate
    translate([0, -(od/2 + (l - od/2)/2 - overlap), t/2 - overlap])
      cube([w, (l - od/2), t], center=true);
    
    // Bent Tab End Round
    translate([0, -(l - tab_end_d/2), 0])
      cylinder(r=tab_end_d/2, h=t, center=true);
    
    // Optional Aux Hole in Tab
    translate([0, -(l - tab_end_d/2), 0])
      cylinder(r=hole_d/2, h=t + 2*overlap, center=true);
  }
}

// Assembly
module assembly() {
  ring_terminal();
  ring_terminal_assembly();
}

assembly();