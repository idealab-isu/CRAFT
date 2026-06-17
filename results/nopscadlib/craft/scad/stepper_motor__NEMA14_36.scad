// Parameters
face_width = 35.2; //[17.6:70.4:0.1]
body_length = 36; //[18:72:0.1]
shaft_diameter = 5; //[2.5:10:0.1]
shaft_length = 20; //[5:40:0.1]
front_face_thickness = 2; //[0.5:6:0.1]
mounting_hole_spacing = 26; //[13:52:0.1]
mounting_hole_diameter = 3.2; //[2:6:0.1]
overlap = 1; //[0.5:2:0.1]
ref_diameter = 0.8; //[0.4:2:0.1]
ref_length = 6; //[2:20:0.5]
ttrack_length = 60; //[30:120:1]
ttrack_pitch = 20; //[10:40:1]
rail_length = 80; //[40:160:1]
rail_pitch = 25; //[10:50:1]
rail_hole_count = 3; //[2:8:1]
marker_size = 2; //[1:5:0.1]
screw_shank_diameter = 3; //[2:6:0.1]
screw_length = 12; //[6:30:0.5]
washer_outer_diameter = 7; //[4:14:0.1]
washer_thickness = 1; //[0.5:3:0.1]
d_plug_diameter = 8; //[4:16:0.1]
d_plug_thickness = 2; //[1:6:0.1]
d_flat_depth = 1.5; //[0.5:4:0.1]

// Derived Z references (centered model)
z_body_front =  body_length/2;
z_plate_center = z_body_front + front_face_thickness/2 - overlap; // overlaps into body
z_plate_front  = z_plate_center + front_face_thickness/2;

// Ttrack Hole Positions (markers only; keep attached by intersecting plate/body)
module ttrack_hole_positions() {
  color("Silver")
  union() {
    translate([0, ttrack_length/2 - (ttrack_length - 2*ttrack_pitch)/2, z_body_front - marker_size/2])
      cube([marker_size, marker_size, marker_size], center=true);
    translate([0, ttrack_length/2 - (ttrack_length - 2*ttrack_pitch)/2 - ttrack_pitch, z_body_front - marker_size/2])
      cube([marker_size, marker_size, marker_size], center=true);
    translate([0, ttrack_length/2 - (ttrack_length - 2*ttrack_pitch)/2 - 2*ttrack_pitch, z_body_front - marker_size/2])
      cube([marker_size, marker_size, marker_size], center=true);
  }
}

// Screw and Washer (ensure they start inside the face plate by overlap)
module screw_and_washer() {
  color("DimGray")
  union() {
    // Screw: bottom slightly inside plate
    translate([mounting_hole_spacing/2, mounting_hole_spacing/2,
               z_plate_front + screw_length/2 - overlap])
      cylinder(r=screw_shank_diameter/2, h=screw_length, center=true);

    // Washer: slightly embedded into plate
    translate([mounting_hole_spacing/2, mounting_hole_spacing/2,
               z_plate_front - washer_thickness/2 - overlap])
      cylinder(r=washer_outer_diameter/2, h=washer_thickness, center=true);
  }
}

// Rail Hole Positions (markers only; keep attached by intersecting body)
module rail_hole_positions() {
  color("Silver")
  union() {
    translate([(-rail_pitch*(rail_hole_count-1)/2), 0, -body_length/2 + marker_size/2])
      cube([marker_size, marker_size, marker_size], center=true);
    translate([(-rail_pitch*(rail_hole_count-1)/2) + rail_pitch, 0, -body_length/2 + marker_size/2])
      cube([marker_size, marker_size, marker_size], center=true);
    translate([(-rail_pitch*(rail_hole_count-1)/2) + 2*rail_pitch, 0, -body_length/2 + marker_size/2])
      cube([marker_size, marker_size, marker_size], center=true);
  }
}

// D Plug D (secondary small cylinder/pin) - FIXED: embed into face plate so it cannot float
module d_plug_D() {
  color("Copper")
  difference() {
    // Centered so its back face penetrates the plate by 'overlap'
    translate([0, 0, z_plate_front + d_plug_thickness/2 - overlap])
      cylinder(r=d_plug_diameter/2, h=d_plug_thickness, center=true);

    // Flat cut
    translate([d_plug_diameter/2 - d_flat_depth, 0, z_plate_front + d_plug_thickness/2 - overlap])
      cube([d_plug_diameter, d_plug_diameter, d_plug_thickness + 2*overlap], center=true);
  }
}

// Ttrack Insert Hole Positions (markers only; keep attached by intersecting plate/body)
module ttrack_insert_hole_positions() {
  color("Silver")
  union() {
    translate([0, ttrack_length/2 - (ttrack_length - ttrack_pitch)/2, z_body_front - marker_size/2])
      cube([marker_size, marker_size, marker_size], center=true);
    translate([0, ttrack_length/2 - (ttrack_length - ttrack_pitch)/2 - ttrack_pitch, z_body_front - marker_size/2])
      cube([marker_size, marker_size, marker_size], center=true);
  }
}

// Motor Assembly (single connected solid via union; all parts overlap 1-2mm)
module assembly() {
  union() {

    // Motor Body
    color("Black")
      cube([face_width, face_width, body_length], center=true);

    // Front Face Plate with Holes (plate overlaps into body)
    color("Silver")
    difference() {
      translate([0, 0, z_plate_center])
        cube([face_width, face_width, front_face_thickness], center=true);

      union() {
        translate([ mounting_hole_spacing/2,  mounting_hole_spacing/2, z_plate_center])
          cylinder(r=mounting_hole_diameter/2, h=front_face_thickness + 2*overlap, center=true);
        translate([-mounting_hole_spacing/2,  mounting_hole_spacing/2, z_plate_center])
          cylinder(r=mounting_hole_diameter/2, h=front_face_thickness + 2*overlap, center=true);
        translate([-mounting_hole_spacing/2, -mounting_hole_spacing/2, z_plate_center])
          cylinder(r=mounting_hole_diameter/2, h=front_face_thickness + 2*overlap, center=true);
        translate([ mounting_hole_spacing/2, -mounting_hole_spacing/2, z_plate_center])
          cylinder(r=mounting_hole_diameter/2, h=front_face_thickness + 2*overlap, center=true);
      }
    }

    // Output Shaft (back face penetrates plate by overlap)
    color("Silver")
      translate([0, 0, z_plate_front + shaft_length/2 - overlap])
        cylinder(r=shaft_diameter/2, h=shaft_length, center=true);

    // Reference Geometries (kept connected by embedding into plate/body)
    color("Red")
    union() {
      translate([0, 0, z_plate_center])
        cylinder(r=ref_diameter/2, h=ref_length, center=true);
      translate([0, 0, z_plate_center])
        cube([marker_size, marker_size, front_face_thickness], center=true);
    }

    // Mandatory Components (all positioned to intersect body/plate)
    ttrack_hole_positions();
    screw_and_washer();
    rail_hole_positions();
    d_plug_D();                 // FIXED: no gap; embedded into plate
    ttrack_insert_hole_positions();
  }
}

assembly();