// Parameters
body_length = 3.0; //[1.5:6.0:0.1]
body_width = 1.4; //[0.7:2.8:0.1]
body_height = 1.0; //[0.5:2.0:0.1]
endcap_length = 0.35; //[0.15:0.8:0.05]
endcap_overlap = 0.6; //[0.2:1.5:0.1]
chamfer = 0.15; //[0.05:0.4:0.05]
mark_depth = 0.05; //[0.02:0.2:0.01]

// SMD Package Model
module smd_package() {
  // Main body
  color([0.85, 0.85, 0.8]) // Off-white for the main body
  difference() {
    union() {
      // Body with endcaps
      union() {
        translate([0, 0, 0])
          cube([body_length, body_width, body_height], center=true);
        
        // Metal endcaps
        color([0.8, 0.6, 0.2]) // Brass color for endcaps
        union() {
          translate([-(body_length/2 + endcap_length/2 - endcap_overlap), 0, 0])
            cube([endcap_length, body_width, body_height], center=true);
          translate([(body_length/2 + endcap_length/2 - endcap_overlap), 0, 0])
            cube([endcap_length, body_width, body_height], center=true);
        }
      }
    }
    
    // Chamfers
    translate([body_length/2 - chamfer/2, body_width/2 - chamfer/2, 0])
      cube([chamfer, chamfer, body_height], center=true);
    translate([body_length/2 - chamfer/2, -(body_width/2 - chamfer/2), 0])
      cube([chamfer, chamfer, body_height], center=true);
    translate([-(body_length/2 - chamfer/2), body_width/2 - chamfer/2, 0])
      cube([chamfer, chamfer, body_height], center=true);
    translate([-(body_length/2 - chamfer/2), -(body_width/2 - chamfer/2), 0])
      cube([chamfer, chamfer, body_height], center=true);
  }
}

// Render the complete SMD package
smd_package();