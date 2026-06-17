// Screwfix Essential unswitched UK mains socket (approximate) - single connected solid
// Fixes: adds recognizable UK socket front (L/N/E apertures + shutter/earth slot),
// corrects mounting hole orientation (vertical spacing), adds recessed socket well,
// keeps all parts connected with formula-based translations, includes rear cavity.

$fn = 72;

// ---------------- Parameters ----------------
plate_width = 86;            //[60:120]
plate_height = 86;           //[60:120]
plate_thickness = 9;         //[5:18]
plate_corner_r = 3.0;        //[1:8]

rear_width = 70;             //[50:100]
rear_height = 70;            //[50:100]
rear_depth = 28;             //[15:60]
rear_overlap = 1;            //[0.5:2]

mount_hole_spacing = 60.3;   //[50:80]  // vertical spacing (UK socket)
mount_hole_diameter = 3.5;   //[2.5:5]
counterbore_diameter = 7.5;  //[5.5:12]
counterbore_depth = 3;       //[1:6]

tolerance_clearance_mm = 0.2;//[0.0:0.6:0.05]

// Socket well (recess) on front
well_w = 50;                 //[40:60]
well_h = 50;                 //[40:60]
well_depth = 1.6;            //[0.8:3]
well_corner_r = 2.0;         //[0.5:6]

// UK pin apertures (approx)
pin_hole_depth = 14;         //[8:25]
ln_center_x = 11.1;          //[9:14]
ln_center_y = -11.1;         //[-14:-8]
earth_center_y = 11.1;       //[8:14]

ln_hole_width = 7.0;         //[5:10]
ln_hole_height = 4.5;        //[3:7]
earth_hole_width = 4.5;      //[3:7]
earth_hole_height = 8.5;     //[6:12]

// Shutter/guide details (subtle extra cutouts to look like a real socket)
shutter_w = 18;              //[12:26]
shutter_h = 10;              //[6:16]
shutter_depth = 1.2;         //[0.6:3]
earth_guide_w = 10;          //[6:16]
earth_guide_h = 4;           //[2:8]
earth_guide_depth = 1.2;     //[0.6:3]

// Rear cavity
include_back_cavity = true;
back_cavity_wall = 2.5;        //[1.5:5]
back_cavity_front_wall = 2.0;  //[1:5]

// ---------------- Helpers ----------------
module rounded_plate(w, h, t, r) {
  rr = min(r, min(w, h)/2 - 0.01);
  minkowski() {
    cube([w - 2*rr, h - 2*rr, t], center=true);
    cylinder(r=rr, h=0.01, center=true);
  }
}

module slot_hole(w, h, depth) {
  rr = min(w, h)/2;
  linear_extrude(height=depth, center=true)
    offset(r=rr)
      square([w - 2*rr, h - 2*rr], center=true);
}

// ---------------- Main geometry ----------------
module mains_socket_solid() {
  // Z positions computed from dimensions (no arbitrary offsets)
  plate_z = 0;
  rear_z  = -(plate_thickness/2 + rear_depth/2 - rear_overlap);

  union() {
    // Faceplate
    translate([0, 0, plate_z])
      rounded_plate(plate_width, plate_height, plate_thickness, plate_corner_r);

    // Rear housing (connected via overlap)
    translate([0, 0, rear_z])
      cube([rear_width, rear_height, rear_depth], center=true);

    // Subtle raised boss around socket area (connected)
    boss_w = 56;
    boss_h = 56;
    boss_t = 1.2;
    boss_r = 2.2;
    translate([0, 0, plate_thickness/2 - boss_t/2])
      rounded_plate(boss_w, boss_h, boss_t, boss_r);
  }
}

module mains_socket_cutouts() {
  front_z = plate_thickness/2;

  // Ensure pin holes cut through plate and into rear
  pin_depth = max(pin_hole_depth, plate_thickness + 2);
  pin_center_z = front_z - pin_depth/2 + 0.01;

  // Through holes for screws: go through entire assembly
  through_h = plate_thickness + rear_depth + 6;
  // Center so it intersects both plate and rear housing
  rear_z = -(plate_thickness/2 + rear_depth/2 - rear_overlap);
  assembly_center_z = (0 + rear_z) / 2;
  through_center_z = assembly_center_z;

  // Counterbores only in plate from front side
  cb_center_z = front_z - counterbore_depth/2 + 0.01;

  // Front recessed well
  well_center_z = front_z - well_depth/2 + 0.01;

  union() {
    // Recessed socket well
    translate([0, 0, well_center_z])
      rounded_plate(well_w, well_h, well_depth, well_corner_r);

    // UK pin apertures (L/N/E)
    translate([-ln_center_x, ln_center_y, pin_center_z])
      slot_hole(ln_hole_width + 2*tolerance_clearance_mm,
                ln_hole_height + 2*tolerance_clearance_mm,
                pin_depth);

    translate([ ln_center_x, ln_center_y, pin_center_z])
      slot_hole(ln_hole_width + 2*tolerance_clearance_mm,
                ln_hole_height + 2*tolerance_clearance_mm,
                pin_depth);

    translate([0, earth_center_y, pin_center_z])
      slot_hole(earth_hole_width + 2*tolerance_clearance_mm,
                earth_hole_height + 2*tolerance_clearance_mm,
                pin_depth);

    // Shutter/guide details (shallow) to avoid a "plain plate" look
    // Horizontal shutter slot above L/N
    translate([0, ln_center_y + (ln_hole_height/2 + shutter_h/2 + 1.2), front_z - shutter_depth/2 + 0.01])
      slot_hole(shutter_w, shutter_h, shutter_depth);

    // Small earth guide slot below earth aperture
    translate([0, earth_center_y - (earth_hole_height/2 + earth_guide_h/2 + 1.0), front_z - earth_guide_depth/2 + 0.01])
      slot_hole(earth_guide_w, earth_guide_h, earth_guide_depth);

    // Mounting holes (vertical spacing)
    for (y = [mount_hole_spacing/2, -mount_hole_spacing/2]) {
      translate([0, y, through_center_z])
        cylinder(r=mount_hole_diameter/2 + tolerance_clearance_mm,
                 h=through_h, center=true);

      translate([0, y, cb_center_z])
        cylinder(r=counterbore_diameter/2 + tolerance_clearance_mm,
                 h=counterbore_depth, center=true);
    }

    // Rear cavity (hollow inside rear housing)
    if (include_back_cavity) {
      cavity_w = rear_width  - 2*back_cavity_wall;
      cavity_h = rear_height - 2*back_cavity_wall;
      cavity_d = rear_depth  - back_cavity_wall - back_cavity_front_wall;

      // Rear housing front face Z:
      rear_front_z = rear_z + rear_depth/2;
      // Cavity center Z (leaves front wall thickness)
      cavity_center_z = rear_front_z - back_cavity_front_wall - cavity_d/2;

      translate([0, 0, cavity_center_z])
        cube([cavity_w, cavity_h, cavity_d], center=true);
    }
  }
}

// ---------------- Assembly ----------------
difference() {
  mains_socket_solid();
  mains_socket_cutouts();
}