// Lichuan -80M02430B style servo motor (parametric, connected solid)
// Fixes:
// - Adds clearer rear housing + connector layout (two stacked boxes on one side)
// - Adds front-side small terminal/feature block (as seen in orthographic views)
// - Adds rear face pilot ring + center bore on rear (typical encoder/shaft stub detail)
// - Ensures ALL parts are connected via formula-based placement with overlap
// - Keeps ONE connected solid; no text/labels

$fn = 96;

// -------------------- Parameters --------------------
body_size = 80;                 //[40:160:1]  // square body width/height (X/Y)
body_length = 110;              //[55:220:1]  // main body length (Z)

body_corner_r = 2;              //[0:6:0.5]

front_face_thickness = 8;       //[4:16:1]    // front flange thickness (Z)
flange_size = 90;               //[60:130:1]  // front flange square size (X/Y)
flange_corner_r = 6;            //[0:12:0.5]  // flange corner rounding

pilot_diameter = 55;            //[27.5:110:0.5]
pilot_height = 2;               //[1:6:0.5]

mount_hole_diameter = 6.6;      //[3.3:13.2:0.1]
mount_hole_spacing = 65;        //[32.5:130:0.5]
mount_hole_boss_d = 14;         //[8:24:0.5]  // raised bosses around holes
mount_hole_boss_h = 2;          //[0:6:0.5]

shaft_diameter = 19;            //[9.5:38:0.5]
shaft_length = 40;              //[20:80:1]
shaft_step_diameter = 14;       //[7:28:0.5]
shaft_step_length = 10;         //[4:25:1]
shaft_thread_diameter = 10;     //[5:20:0.5]
shaft_thread_depth = 12;        //[6:25:1]

keyway_width = 5;               //[2:10:0.5]
keyway_depth = 2;               //[1:5:0.5]
keyway_length = 25;             //[10:60:1]

// Rear housing (encoder/brake area)
rear_encoder_diameter = 50;     //[25:100:0.5]
rear_encoder_length = 35;       //[18:70:1]
rear_cap_diameter = 56;         //[30:110:0.5]
rear_cap_length = 6;            //[2:15:0.5]

// Rear face pilot ring + center bore (visual identifying feature)
rear_pilot_diameter = 40;       //[20:80:0.5]
rear_pilot_height = 2;          //[1:6:0.5]
rear_center_bore_d = 8;         //[3:16:0.5]
rear_center_bore_depth = 6;     //[2:15:0.5]

// Rear connector boxes (stacked) on one side of rear housing
rear_connector_box_w = 28;      //[14:56:1]   // X (outward from motor)
rear_connector_box_h = 18;      //[9:36:1]    // Z
rear_connector_box_d = 16;      //[8:32:1]    // Y
rear_connector_standoff = 6;    //[3:15:1]    // gap from encoder cylinder surface (still connected via bridge)

// Bridge from encoder cylinder to connector boxes (ensures robust connectivity)
rear_connector_bridge_w = 8;    //[4:16:1]
rear_connector_bridge_h = 14;   //[6:28:1]
rear_connector_bridge_d = 12;   //[6:24:1]

// Front-side small feature block (seen as small tab in front/back views)
front_side_block_w = 8;         //[4:20:1]    // X outward
front_side_block_d = 10;        //[4:25:1]    // Y
front_side_block_h = 10;        //[4:25:1]    // Z
front_side_block_z = 0;         // centered on flange/body mid by default

// Cooling fins (small ribs on one side)
cooling_fin_count = 8;          //[0:16:1]
cooling_fin_thickness = 2;      //[1:5:0.5]  // Z thickness of each rib
cooling_fin_height = 2;         //[0:6:0.5]  // X protrusion
cooling_fin_margin = 10;        //[5:25:1]   // Z margin from ends

overlap = 1;                    //[0.5:2:0.1]

// -------------------- Helpers --------------------
module rounded_square_prism(size=[10,10,10], r=2, center=true) {
  // Minkowski rounded rectangle prism (kept modest for performance)
  minkowski() {
    cube([max(0.01,size[0]-2*r), max(0.01,size[1]-2*r), size[2]], center=center);
    cylinder(r=r, h=0.01, center=true);
  }
}

// -------------------- Main solids --------------------
module motor_body_housing() {
  rounded_square_prism([body_size, body_size, body_length], r=body_corner_r, center=true);
}

module front_flange() {
  translate([0,0, body_length/2 + front_face_thickness/2 - overlap])
    rounded_square_prism([flange_size, flange_size, front_face_thickness], r=flange_corner_r, center=true);
}

module front_mount_bosses() {
  for (sx = [-1,1], sy = [-1,1]) {
    translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2,
               body_length/2 + front_face_thickness - mount_hole_boss_h/2 - overlap])
      cylinder(r=mount_hole_boss_d/2, h=mount_hole_boss_h, center=true);
  }
}

module front_pilot_register() {
  translate([0, 0, body_length/2 + front_face_thickness - pilot_height/2 - overlap])
    cylinder(r=pilot_diameter/2, h=pilot_height, center=true);
}

module output_shaft() {
  union() {
    // Main shaft
    translate([0,0, body_length/2 + front_face_thickness + shaft_length/2 - overlap])
      cylinder(r=shaft_diameter/2, h=shaft_length, center=true);

    // Reduced step at tip
    translate([0,0, body_length/2 + front_face_thickness + shaft_length - shaft_step_length/2 - overlap])
      cylinder(r=shaft_step_diameter/2, h=shaft_step_length, center=true);

    // Threaded portion (visual)
    translate([0,0, body_length/2 + front_face_thickness + shaft_length - shaft_thread_depth/2 - overlap])
      cylinder(r=shaft_thread_diameter/2, h=shaft_thread_depth, center=true);
  }
}

module rear_encoder_housing() {
  union() {
    // Encoder cylinder
    translate([0,0, -body_length/2 - rear_encoder_length/2 + overlap])
      cylinder(r=rear_encoder_diameter/2, h=rear_encoder_length, center=true);

    // Rear cap
    translate([0,0, -body_length/2 - rear_encoder_length - rear_cap_length/2 + overlap])
      cylinder(r=rear_cap_diameter/2, h=rear_cap_length, center=true);

    // Rear face pilot ring (on very back face)
    translate([0,0, -body_length/2 - rear_encoder_length - rear_cap_length + rear_pilot_height/2 + overlap])
      cylinder(r=rear_pilot_diameter/2, h=rear_pilot_height, center=true);
  }
}

module rear_connectors() {
  // Place on +X side of rear encoder area, with a bridge to guarantee connection.
  // Z center aligned to encoder cylinder center.
  zc = -body_length/2 - rear_encoder_length/2 + overlap;

  // X positions derived from encoder radius and standoff; bridge spans from cylinder surface to box.
  x_cyl_surface = rear_encoder_diameter/2;
  x_bridge_c = x_cyl_surface + rear_connector_bridge_w/2 - overlap;
  x_box_c = x_cyl_surface + rear_connector_standoff + rear_connector_box_w/2 - overlap;

  union() {
    // Bridge block (touches cylinder and box)
    translate([x_bridge_c, 0, zc])
      cube([rear_connector_bridge_w, rear_connector_bridge_d, rear_connector_bridge_h], center=true);

    // Main connector box
    translate([x_box_c, 0, zc])
      cube([rear_connector_box_w, rear_connector_box_d, rear_connector_box_h], center=true);

    // Secondary smaller box stacked/offset, connected to main box
    translate([
      x_box_c - rear_connector_box_w*0.05, // slight shift but still connected
      rear_connector_box_d/2 + (rear_connector_box_d*0.9)/2 - overlap,
      zc
    ])
      cube([rear_connector_box_w*0.8, rear_connector_box_d*0.9, rear_connector_box_h*0.8], center=true);
  }
}

module front_side_feature_block() {
  // Small block on the side near the front flange (seen as a small tab in orthographic views).
  // Attach to +X side of flange/body region.
  x_c = flange_size/2 + front_side_block_w/2 - overlap;
  z_c = body_length/2 + front_face_thickness/2 + front_side_block_z - overlap;
  translate([x_c, 0, z_c])
    cube([front_side_block_w, front_side_block_d, front_side_block_h], center=true);
}

module cooling_fins() {
  // Side ribs along +X side of main body, connected to body
  if (cooling_fin_count > 0)
  union() {
    fin_span = body_length - 2*cooling_fin_margin;
    for (i = [0:cooling_fin_count-1]) {
      zpos = -body_length/2 + cooling_fin_margin + fin_span*((i+0.5)/cooling_fin_count);
      translate([body_size/2 + cooling_fin_height/2 - overlap, 0, zpos])
        cube([cooling_fin_height, body_size, cooling_fin_thickness], center=true);
    }
  }
}

// -------------------- Subtractions --------------------
module mounting_holes_pattern() {
  for (sx = [-1,1], sy = [-1,1]) {
    translate([sx*mount_hole_spacing/2, sy*mount_hole_spacing/2,
               body_length/2 + front_face_thickness/2 - overlap])
      cylinder(r=mount_hole_diameter/2,
               h=front_face_thickness + pilot_height + overlap*6,
               center=true);
  }
}

module shaft_keyway_cut() {
  zc = body_length/2 + front_face_thickness + keyway_length/2 - overlap;
  translate([0, (shaft_diameter/2 - keyway_depth/2), zc])
    cube([keyway_width, keyway_depth, keyway_length + overlap*4], center=true);
}

module shaft_center_bore_cut() {
  bore_r = max(1, shaft_thread_diameter/2 - 2);
  bore_h = shaft_thread_depth + overlap*6;
  translate([0,0, body_length/2 + front_face_thickness + shaft_length - shaft_thread_depth/2 - overlap])
    cylinder(r=bore_r, h=bore_h, center=true);
}

module rear_center_bore_cut() {
  // Bore into rear pilot/cap (visual)
  zc = -body_length/2 - rear_encoder_length - rear_cap_length + rear_center_bore_depth/2 + overlap;
  translate([0,0, zc])
    cylinder(r=rear_center_bore_d/2, h=rear_center_bore_depth + overlap*6, center=true);
}

// -------------------- Assembly --------------------
module motor_solid_pre_subtract() {
  union() {
    motor_body_housing();
    front_flange();
    front_mount_bosses();
    front_pilot_register();
    output_shaft();

    rear_encoder_housing();
    rear_connectors();

    front_side_feature_block();
    cooling_fins();
  }
}

module motor_final() {
  difference() {
    motor_solid_pre_subtract();
    mounting_holes_pattern();
    shaft_keyway_cut();
    shaft_center_bore_cut();
    rear_center_bore_cut();
  }
}

motor_final();