// Brushless DC motor (envelope-style) with stator Ø28.0mm and stator height 17.25mm
// One connected solid; no floating parts; no text/labels.

stator_diameter_mm = 28;          //[14:56:0.1]
stator_height_mm   = 17.25;       //[8.625:34.5:0.05]

shaft_diameter_mm          = 5;   //[2.5:10:0.1]
shaft_extension_front_mm   = 12;  //[6:24:0.5]
shaft_extension_rear_mm    = 0;   //[0:12:0.5]

airgap_radial_mm = 0.3;           //[0.1:1:0.05]

endbell_thickness_mm = 2;         //[1:4:0.1]

mount_hole_count = 4;             //[2:8:1]
mount_hole_diameter_mm = 3;       //[1.5:6:0.1]
mount_hole_circle_diameter_mm = 25; //[12.5:50:0.1]

mounting_face_thickness_mm = 2;   //[1:5:0.1]
mounting_face_outer_diameter_mm = 36; //[18:72:0.1]

bearing_seat_diameter_mm = 10;    //[6:20:0.1]
bearing_seat_length_mm   = 4;     //[2:10:0.1]

overlap_mm = 1;                   //[0.5:2:0.1]

// Optional side connector (kept but made motor-like and connected)
connector_diameter_mm = 10;       //[6:20:0.1]
connector_length_mm   = 8;        //[4:20:0.5]
connector_z_mm        = 0;        // centered on stator stack

$fn = 96;

// -------------------- Derived dimensions --------------------
stator_r = stator_diameter_mm/2;

// Typical 28mm-class outrunner can: can OD ~ stator OD + ~6mm
housing_outer_diameter_mm = stator_diameter_mm + 6; // ~3mm radial margin
housing_r = housing_outer_diameter_mm/2;

// Requested axial stack: stator height + endbells
motor_body_length_mm = stator_height_mm + 2*endbell_thickness_mm;

// Rotor bell (outer can) slightly larger than stator OD, inside housing
rotor_outer_diameter_mm = stator_diameter_mm + 2*airgap_radial_mm + 2.0;
rotor_r = rotor_outer_diameter_mm/2;
rotor_r_eff = min(rotor_r, housing_r - 0.6);

// Front mounting face at front
front_face_r = max(mounting_face_outer_diameter_mm/2, housing_r);

// Z references (centered motor body)
z_body_center = 0;
z_body_front  = z_body_center + motor_body_length_mm/2;
z_body_rear   = z_body_center - motor_body_length_mm/2;

z_front_endbell_center = z_body_front - endbell_thickness_mm/2;
z_rear_endbell_center  = z_body_rear + endbell_thickness_mm/2;

z_mount_face_center = z_body_front + mounting_face_thickness_mm/2 - overlap_mm;

// Shaft total length and center position
shaft_total_len = motor_body_length_mm + shaft_extension_front_mm + shaft_extension_rear_mm;
z_shaft_center  = (shaft_extension_front_mm - shaft_extension_rear_mm)/2;

// -------------------- Helpers --------------------
module radial_holes(count, pcd, hole_d, h, zc) {
  for (i = [0:count-1]) {
    rotate([0,0,i*360/count])
      translate([pcd/2, 0, zc])
        cylinder(d=hole_d, h=h, center=true, $fn=32);
  }
}

// -------------------- Motor model (single connected solid) --------------------
module bldc_motor() {
  difference() {
    union() {
      // Main can/housing (single cylinder defines the motor envelope)
      cylinder(r=housing_r, h=motor_body_length_mm, center=true);

      // Front mounting face/flange (connected with overlap)
      translate([0,0,z_mount_face_center])
        cylinder(r=front_face_r, h=mounting_face_thickness_mm, center=true);

      // Front bearing boss / seat envelope (connected)
      translate([0,0,z_front_endbell_center])
        cylinder(d=bearing_seat_diameter_mm, h=bearing_seat_length_mm, center=true);

      // Rotor bell hint (outer can region) - kept subtle and fully inside housing
      translate([0,0, 0])
        cylinder(r=rotor_r_eff, h=stator_height_mm/2 + overlap_mm, center=true);

      // Stator stack envelope (requested Ø and height) - overlaps to ensure connectivity
      cylinder(r=stator_r, h=stator_height_mm + overlap_mm, center=true);

      // Central shaft (through) - connected to bearing boss and body
      translate([0,0,z_shaft_center])
        cylinder(d=shaft_diameter_mm, h=shaft_total_len, center=true, $fn=64);

      // Side connector (motor wire exit), connected at housing edge with overlap
      translate([housing_r + connector_length_mm/2 - overlap_mm, 0, connector_z_mm])
        rotate([0,90,0])
          cylinder(d=connector_diameter_mm, h=connector_length_mm, center=true, $fn=48);
    }

    // Mounting holes (cut through mounting face + slightly into front end region)
    radial_holes(
      mount_hole_count,
      mount_hole_circle_diameter_mm,
      mount_hole_diameter_mm,
      mounting_face_thickness_mm + endbell_thickness_mm + 2*overlap_mm,
      z_mount_face_center
    );

    // Front shaft clearance recess (small)
    translate([0,0,z_mount_face_center])
      cylinder(d=shaft_diameter_mm + 1.0,
               h=mounting_face_thickness_mm + 2*overlap_mm,
               center=true, $fn=48);
  }
}

bldc_motor();