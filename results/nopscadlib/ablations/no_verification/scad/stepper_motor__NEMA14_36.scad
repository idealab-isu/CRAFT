$fn = 64;

// Parameters (mm)
face_width = 35.2;                 //[17.6:70.4:0.1]
body_length = 36.0;                //[18.0:72.0:0.1]
front_face_thickness = 3.0;        //[1.5:6.0:0.1]
corner_radius = 2.0;               //[0.5:4.0:0.1]

shaft_diameter = 5.0;              //[2.5:10.0:0.1]
shaft_length = 20.0;               //[10.0:40.0:0.1]

mounting_hole_spacing = 26.0;      //[13.0:52.0:0.1]
mounting_hole_diameter = 3.2;      //[2.0:6.0:0.1]
mounting_hole_depth = 6.0;         //[3.0:12.0:0.1]

mounting_hole_overlap = 1.0;       //[0.5:2.0:0.1]
shaft_overlap = 1.0;               //[0.5:2.0:0.1]

grill_hole_diameter = 2.0;         //[1.0:4.0:0.1]
grill_gap = 2.0;                   //[1.0:6.0:0.1]
grill_area_scale = 0.7;            //[0.4:0.9:0.05]

rail_hole_diameter = 3.0;          //[2.0:6.0:0.1]
rail_hole_spacing_x = 20.0;        //[10.0:40.0:0.1]
rail_hole_spacing_y = 10.0;        //[5.0:20.0:0.1]

d_plug_length = 12.0;              //[6.0:24.0:0.1]
d_plug_width = 8.0;                //[4.0:16.0:0.1]
d_plug_rad = 1.0;                  //[0.5:2.0:0.1]

screw_diameter = 3.0;              //[2.0:6.0:0.1]
screw_length = 8.0;                //[4.0:16.0:0.1]
washer_outer_diameter = 7.0;       //[4.0:14.0:0.1]
washer_thickness = 1.0;            //[0.5:2.0:0.1]

marker_z_offset = 0.5;             //[0.2:2.0:0.1]

// Derived positions (Z axis: front face at z=0, body extends to negative z, shaft to positive z)
front_z0 = 0;
front_center_z = -front_face_thickness/2;
body_center_z  = -(front_face_thickness + body_length/2);
back_face_z    = -(front_face_thickness + body_length);

// Helpers
module rounded_box_xy(size=[10,10,10], r=1, center=true) {
  // Rounded in XY, flat in Z (fast + robust)
  // size = [x,y,z]
  linear_extrude(height=size[2], center=center)
    offset(r=r)
      square([size[0]-2*r, size[1]-2*r], center=true);
}

module motor_body_solid() {
  // One connected solid: front plate + main body fused with slight overlap
  overlap = 0.2;

  union() {
    // Main body (36mm) behind the face
    translate([0,0, body_center_z])
      rounded_box_xy([face_width, face_width, body_length], r=corner_radius, center=true);

    // Front face plate (3mm) at the front
    translate([0,0, front_center_z + overlap/2])
      rounded_box_xy([face_width, face_width, front_face_thickness + overlap], r=corner_radius, center=true);
  }
}

module mounting_holes_cut() {
  // 4-hole pattern, clearly visible, cut from the front face into the body
  // Start slightly in front of face and go past required depth to guarantee cut
  cut_h = mounting_hole_depth + 2*mounting_hole_overlap;
  cut_center_z = -(mounting_hole_depth/2) + mounting_hole_overlap; // spans from z=+overlap to z=-depth-overlap

  for (x = [-1, 1])
    for (y = [-1, 1])
      translate([x*mounting_hole_spacing/2, y*mounting_hole_spacing/2, cut_center_z])
        cylinder(r=mounting_hole_diameter/2, h=cut_h, center=true);
}

module grill_holes_cut() {
  // Simple 2x2 grill holes on the face (shallow)
  area = face_width * grill_area_scale;
  for (x = [-1, 1])
    for (y = [-1, 1])
      translate([x*area/4, y*area/4, -front_face_thickness/2])
        cylinder(r=grill_hole_diameter/2, h=front_face_thickness + 0.4, center=true);
}

module rail_holes_cut() {
  // Optional face holes (shallow)
  for (x = [-1, 1])
    for (y = [-1, 1])
      translate([x*rail_hole_spacing_x/2, y*rail_hole_spacing_y/2, -front_face_thickness/2])
        cylinder(r=rail_hole_diameter/2, h=front_face_thickness + 0.4, center=true);
}

module d_plug_boss() {
  // Small raised boss on the face (adds visible feature but stays connected)
  boss_h = front_face_thickness/2;
  translate([0, 0, -boss_h/2])  // sits on the face, extends slightly outward (negative z is into body; so keep it on face plane)
    linear_extrude(height=boss_h, center=true)
      offset(r=d_plug_rad)
        square([d_plug_length, d_plug_width], center=true);
}

module motor_shaft_solid() {
  // Shaft protruding from front face (positive z)
  translate([0,0, (shaft_length + shaft_overlap)/2 - shaft_overlap/2])
    cylinder(r=shaft_diameter/2, h=shaft_length + shaft_overlap, center=true);
}

module screw_and_washer_bosses() {
  // Add bosses (not separate parts) at all 4 mounting holes to make pattern visible
  // These are small raised cylinders on the face, connected to the body.
  boss_overlap = 0.2;
  washer_h = washer_thickness + boss_overlap;
  screw_h  = screw_length;

  for (x = [-1, 1])
    for (y = [-1, 1]) {
      // Washer boss: sits on face and protrudes outward (+z)
      translate([x*mounting_hole_spacing/2, y*mounting_hole_spacing/2, washer_h/2 - boss_overlap/2])
        cylinder(r=washer_outer_diameter/2, h=washer_h, center=true);

      // Screw head boss: smaller, on top of washer
      translate([x*mounting_hole_spacing/2, y*mounting_hole_spacing/2, washer_h + screw_h/2 - boss_overlap/2])
        cylinder(r=screw_diameter/2, h=screw_h, center=true);
    }
}

module assembly() {
  // ONE connected solid: everything unioned, holes subtracted
  difference() {
    union() {
      motor_body_solid();
      motor_shaft_solid();
      d_plug_boss();
      screw_and_washer_bosses();
    }
    mounting_holes_cut();
    grill_holes_cut();
    rail_holes_cut();
  }
}

assembly();