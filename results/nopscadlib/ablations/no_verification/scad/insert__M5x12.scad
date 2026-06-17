// Parameters
outer_diameter_mm = 12; //[6:24:0.1]
length_mm = 10; //[5:20:0.1]
screw_diameter_mm = 5; //[2.5:10:0.1]
thread_pitch_mm = 0.8; //[0.4:1.6:0.05]
tolerance_mm = 0.2; //[0.05:0.6:0.05]
pilot_hole_diameter_mm = 4.2; //[3.5:5:0.05]
knurl_depth_mm = 0.6; //[0.3:1.2:0.05]
knurl_pitch_mm = 1.2; //[0.6:2.4:0.1]
rib_width_mm = 0.8; //[0.4:1.6:0.05]
rib_height_mm = 8; //[4:16:0.1]
top_chamfer_mm = 1; //[0.5:2:0.1]
bottom_chamfer_mm = 1; //[0.5:2:0.1]
overlap_mm = 0.8; //[0.5:2:0.1]

// Threaded Insert - complete geometry
module threaded_insert() {
  color("Brass") {
    // Insert Body
    difference() {
      union() {
        // Main body
        translate([0, 0, 0])
          cylinder(r=outer_diameter_mm/2, h=length_mm, center=true, $fn=64);
        
        // Knurl ribs
        outer_knurl_or_ribs();
      }
      
      // Lead-in chamfer
      translate([0, 0, length_mm/2 - top_chamfer_mm/2])
        rotate([180, 0, 0])
        cylinder(r1=outer_diameter_mm/2 + knurl_depth_mm, r2=0, h=top_chamfer_mm, center=true, $fn=64);
      
      // Installation-end chamfer
      translate([0, 0, -length_mm/2 + bottom_chamfer_mm/2])
        cylinder(r1=outer_diameter_mm/2 + knurl_depth_mm, r2=0, h=bottom_chamfer_mm, center=true, $fn=64);
    }
    
    // Internal thread or tap bore
    translate([0, 0, 0])
      cylinder(r=(pilot_hole_diameter_mm + tolerance_mm)/2, h=length_mm + 2*overlap_mm, center=true, $fn=64);
  }
}

// Knurl ribs
module outer_knurl_or_ribs() {
  union() {
    for (i = [0 : floor((3.141592653589793 * outer_diameter_mm) / knurl_pitch_mm) - 1]) {
      rotate([0, 0, i * 360 / floor((3.141592653589793 * outer_diameter_mm) / knurl_pitch_mm)])
        translate([outer_diameter_mm/2 + knurl_depth_mm - overlap_mm, 0, 0])
        cube([knurl_depth_mm*2, rib_width_mm, rib_height_mm], center=true);
    }
  }
}

// Assembly
module assembly() {
  threaded_insert();
}

assembly();