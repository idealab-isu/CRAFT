// Parameters
length = 15; //[8:30:1]
outer_diameter = 10; //[5:20:1]
inner_diameter = 8; //[4:18:1]
forced_inner_diameter = 0; //[0:18:1]
center = 1; //[0:1:1]
overlap = 1; //[0.5:2:0.5]
end_face_thickness = 0.5; //[0.2:2:0.1]

// Tubing - complete geometry
module tubing() {
  color([0.85, 0.85, 0.8]) {
    // Tubing shell
    difference() {
      translate([0, 0, center == 1 ? 0 : length / 2])
        cylinder(h=length, r=outer_diameter / 2, center=true, $fn=64);
      translate([0, 0, center == 1 ? 0 : length / 2])
        cylinder(h=length + 2 * overlap, r=(forced_inner_diameter > 0 ? forced_inner_diameter : inner_diameter) / 2, center=true, $fn=64);
    }
    
    // End face rings
    union() {
      translate([0, 0, (center == 1 ? length / 2 : length) - end_face_thickness / 2])
        difference() {
          cylinder(h=end_face_thickness, r=outer_diameter / 2, center=true, $fn=64);
          cylinder(h=end_face_thickness + 2 * overlap, r=(forced_inner_diameter > 0 ? forced_inner_diameter : inner_diameter) / 2, center=true, $fn=64);
        }
      translate([0, 0, (center == 1 ? -length / 2 : 0) + end_face_thickness / 2])
        difference() {
          cylinder(h=end_face_thickness, r=outer_diameter / 2, center=true, $fn=64);
          cylinder(h=end_face_thickness + 2 * overlap, r=(forced_inner_diameter > 0 ? forced_inner_diameter : inner_diameter) / 2, center=true, $fn=64);
        }
    }
  }
}

// Assembly
module assembly() {
  tubing();
}

assembly();