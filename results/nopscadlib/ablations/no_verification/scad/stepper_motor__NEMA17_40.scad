// Parameters
face_width = 42.3; //[21.15:84.6:0.1]
face_thickness = 3.0; //[1.5:6.0:0.1]
body_length = 40.0; //[20.0:80.0:0.1]
body_width = 42.3; //[21.15:84.6:0.1]
rear_cap_thickness = 2.5; //[1.0:6.0:0.1]
shaft_diameter = 5.0; //[2.5:10.0:0.1]
shaft_length = 20.0; //[10.0:40.0:0.1]
boss_diameter = 22.0; //[11.0:44.0:0.1]
boss_thickness = 2.0; //[1.0:6.0:0.1]
mount_hole_spacing = 31.0; //[15.5:62.0:0.1]
mount_hole_diameter = 3.2; //[2.0:6.0:0.1]
overlap = 1.0; //[0.5:2.0:0.1]
grill_hole_diameter = 3.0; //[1.5:6.0:0.1]
grill_margin = 6.0; //[3.0:12.0:0.1]
grill_rows = 3; //[1:6:1]
grill_cols = 3; //[1:6:1]
rail_hole_diameter = 4.0; //[2.0:8.0:0.1]
rail_hole_spacing_x = 20.0; //[10.0:40.0:0.1]
rail_hole_spacing_y = 10.0; //[5.0:30.0:0.1]
d_plug_length = 18.0; //[9.0:36.0:0.1]
d_plug_width = 12.0; //[6.0:24.0:0.1]
d_plug_rad = 2.0; //[1.0:5.0:0.1]
d_plug_thickness = 3.0; //[1.5:8.0:0.1]
screw_diameter = 3.0; //[2.0:6.0:0.1]
screw_length = 8.0; //[4.0:20.0:0.1]
washer_diameter = 7.0; //[4.0:14.0:0.1]
washer_thickness = 1.0; //[0.5:3.0:0.1]

// Modules
module grill_hole_positions() {
  color("DimGray") {
    for (i = [0:grill_cols-1]) {
      for (j = [0:grill_rows-1]) {
        translate([
          -(face_width - 2*grill_margin)/2 + (face_width - 2*grill_margin)/(grill_cols) * (i + 0.5),
          -(face_width - 2*grill_margin)/2 + (face_width - 2*grill_margin)/(grill_rows) * (j + 0.5),
          -body_length/2 - rear_cap_thickness/2 + overlap
        ])
        cylinder(r=grill_hole_diameter/2, h=rear_cap_thickness + overlap*2, center=true);
      }
    }
  }
}

module d_plug_D() {
  color("Silver") {
    translate([0, 0, -body_length/2 - rear_cap_thickness - d_plug_thickness/2 + overlap])
    linear_extrude(height=d_plug_thickness, center=true) {
      offset(r=d_plug_rad) {
        polygon(points=[
          [-d_plug_length/2, -d_plug_width/2],
          [d_plug_length/2, -d_plug_width/2],
          [d_plug_length/2, d_plug_width/2],
          [-d_plug_length/2, d_plug_width/2]
        ]);
      }
    }
  }
}

module motor_shaft() {
  color("Silver") {
    translate([0, 0, body_length/2 + face_thickness + boss_thickness + shaft_length/2 - overlap])
    cylinder(r=shaft_diameter/2, h=shaft_length, center=true);
  }
}

module screw_and_washer() {
  color("Black") {
    translate([mount_hole_spacing/2, mount_hole_spacing/2, body_length/2 + face_thickness/2 + screw_length/2 - overlap])
    cylinder(r=screw_diameter/2, h=screw_length, center=true);
    translate([mount_hole_spacing/2, mount_hole_spacing/2, body_length/2 + face_thickness/2 + washer_thickness/2 - overlap])
    cylinder(r=washer_diameter/2, h=washer_thickness, center=true);
  }
}

module rail_hole_positions() {
  color("DimGray") {
    translate([rail_hole_spacing_x/2, rail_hole_spacing_y/2, 0])
    cylinder(r=rail_hole_diameter/2, h=body_length + face_thickness + rear_cap_thickness + overlap*2, center=true);
    translate([-rail_hole_spacing_x/2, rail_hole_spacing_y/2, 0])
    cylinder(r=rail_hole_diameter/2, h=body_length + face_thickness + rear_cap_thickness + overlap*2, center=true);
  }
}

module assembly() {
  color("Black") {
    // Motor Body
    translate([0, 0, 0])
    cube([body_width, body_width, body_length], center=true);
    
    // Front Face
    translate([0, 0, body_length/2 + face_thickness/2 - overlap])
    cube([face_width, face_width, face_thickness], center=true);
    
    // Shaft Boss
    translate([0, 0, body_length/2 + face_thickness + boss_thickness/2 - overlap])
    cylinder(r=boss_diameter/2, h=boss_thickness, center=true);
    
    // Rear Cap
    translate([0, 0, -body_length/2 - rear_cap_thickness/2 + overlap])
    cube([body_width, body_width, rear_cap_thickness], center=true);
  }
  
  // Components
  motor_shaft();
  grill_hole_positions();
  d_plug_D();
  screw_and_washer();
  rail_hole_positions();
}

assembly();