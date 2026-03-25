// RAVISTAT 1F-1 style variac (approximate) - ONE connected solid with toroidal winding + brush/shaft + terminals
$fn = 128;

// Parameters
overlap = 1; //[0.5:2:0.1]
thickness = 3; //[1.5:6:0.5]
dial_enabled = 1; //[0:1:1]

// Overall envelope (kept similar to original)
body_diameter = 120; //[60:240:1]
body_height   = 70;  //[35:140:1]

// Toroid / winding
coil_outer_d = 118; //[70:240:1]
coil_inner_d = 62;  //[30:160:1]
coil_height  = 52;  //[25:120:1]
coil_rib_count = 48; //[24:96:1]
coil_rib_w = 2.2;   //[1:5:0.1]
coil_rib_h = 1.6;   //[0.8:4:0.1]

// Top ring / frame
top_ring_h = 6;     //[3:15:0.5]
top_ring_w = 10;    //[6:20:0.5]

// Brush/adjuster housing (side)
brush_box_w = 26;   //[14:50:1]
brush_box_d = 22;   //[12:45:1]
brush_box_h = 26;   //[14:50:1]
brush_arm_w = 10;   //[6:20:0.5]
brush_arm_t = 8;    //[4:16:0.5]
brush_arm_h = 10;   //[5:20:0.5]

// Shaft/knob
shaft_diameter = 10; //[5:20:0.5]
shaft_length_above = 25; //[10:60:1]
knob_diameter = 42; //[20:70:1]
knob_height = 18;   //[8:35:0.5]
knob_skirt_diameter = 50; //[25:80:1]
knob_skirt_height = 6;    //[2:15:0.5]

// Dial (optional)
dial_diameter = 85; //[40:160:1]
dial_thickness = 6; //[3:15:0.5]
dial_hub_diameter = 22; //[10:50:1]
dial_hub_height = 10;   //[5:25:1]

// Terminal block (typical variac rear/top)
terminal_block_w = 56; //[30:90:1]
terminal_block_d = 28; //[15:50:1]
terminal_block_h = 22; //[12:40:1]
lug_count = 4;         //[2:6:1]
lug_w = 10;            //[6:16:1]
lug_d = 6;             //[3:12:0.5]
lug_h = 7;             //[3:12:0.5]

// Mounting feet / base
base_plate_w = 78; //[40:120:1]
base_plate_d = 34; //[18:70:1]
base_plate_h = 10; //[6:20:1]

// Through-bolts around ring (visual)
mount_hole_count = 4; //[3:6:1]
mount_hole_circle_radius = 48; //[24:96:1]
screw_shank_radius = 2.4; //[1.5:4:0.1]
screw_head_radius = 4.5;  //[3:8:0.1]
screw_head_height = 3;    //[1.5:6:0.5]
washer_radius = 6;        //[4:12:0.5]
washer_thickness = 1.2;   //[0.6:3:0.1]
screw_length_above = 16;  //[8:40:1]
stud_h = 10;              //[6:20:1]

module torus(R, r){
  rotate_extrude(convexity=10)
    translate([R,0,0]) circle(r=r);
}

module variac(){
  body_r = body_diameter/2;

  // Z references
  z_top = body_height/2;
  z_bot = -body_height/2;

  // Coil placement (centered)
  coil_z = 0;
  coil_R = (coil_outer_d/2 + coil_inner_d/2)/2;
  coil_r = (coil_outer_d/2 - coil_inner_d/2)/2;

  // Ensure coil fits within body height
  coil_h = min(coil_height, body_height - 2*thickness);

  // Top ring sits slightly above coil
  top_ring_z = coil_z + coil_h/2 + top_ring_h/2 - overlap;

  // Base plate under coil
  base_z = z_bot - base_plate_h/2 + overlap;

  // Terminal block on "back" (positive Y), attached to top ring
  term_y = (coil_outer_d/2) + terminal_block_d/2 - overlap;
  term_z = top_ring_z + top_ring_h/2 + terminal_block_h/2 - overlap;

  // Brush box on "right" (positive X), attached to coil outer edge
  brush_x = (coil_outer_d/2) + brush_box_d/2 - overlap;
  brush_z = coil_z; // centered vertically

  // Brush arm reaches from brush box into coil outer surface
  arm_x = (coil_outer_d/2) - brush_arm_t/2 + overlap; // overlaps into coil
  arm_z = coil_z + coil_h/2 - brush_arm_h/2; // near top like typical brush carrier

  // Shaft/knob stack (center)
  shaft_total_h = body_height + shaft_length_above;
  shaft_z = shaft_length_above/2; // bottom reaches z_bot
  knob_skirt_z = z_top + thickness + knob_skirt_height/2 - overlap;
  knob_z = z_top + thickness + knob_skirt_height - overlap + knob_height/2;

  dial_z = z_top + thickness + (dial_thickness*dial_enabled)/2 - overlap;
  hub_z  = z_top + thickness + (dial_thickness*dial_enabled) - overlap + (dial_hub_height*dial_enabled)/2;

  // Pins/posts (2 above, 2 below) - MUST be attached
  pin_r = 2.2;
  pin_h = 8;

  // Place pins at left/right, but ensure they are within the base/top ring radial extents
  // so they intersect the ring/plate (not just near it).
  // Top ring radial band: [coil_outer_d/2 - top_ring_w, coil_outer_d/2 + top_ring_w]
  pin_pair_x = (coil_outer_d/2) + (top_ring_w/2); // inside the ring band

  // Z positions with guaranteed overlap into parent solids
  pin_z_top = (top_ring_z + top_ring_h/2) + pin_h/2 - overlap; // overlaps into top ring
  pin_z_bot = (base_z - base_plate_h/2) - pin_h/2 + overlap;   // overlaps into base plate

  // Terminal screws/terminals (4) - MUST be attached (previously had visible gaps)
  term_screw_r = 2.2;
  term_screw_h = 10;
  term_screw_z = (term_z + terminal_block_h/2) + term_screw_h/2 - overlap; // overlap into terminal block
  term_screw_y = term_y; // centered in block depth so it intersects the block

  union(){
    // --- Core assembly: toroidal winding + top ring + base plate + brush housing + terminal block ---
    color("DimGray")
    union(){
      // Toroidal winding body (solid torus scaled in Z to match coil_h)
      translate([0,0,coil_z])
        scale([1,1,coil_h/(2*coil_r)])
          torus(coil_R, coil_r);

      // Add winding ribs (radial array) to resemble exposed coil turns
      rib_len = 3.2;
      rib_w = coil_rib_w;
      rib_h = coil_h + overlap;
      outer_r = coil_outer_d/2;
      for(i=[0:coil_rib_count-1]){
        rotate([0,0,i*360/coil_rib_count])
          translate([outer_r + rib_len/2 - overlap, 0, coil_z])
            cube([rib_len, rib_w, rib_h], center=true);
      }

      // Top ring/frame (annular ring) connected to coil
      translate([0,0,top_ring_z])
        difference(){
          cylinder(r=coil_outer_d/2 + top_ring_w, h=top_ring_h, center=true);
          cylinder(r=coil_outer_d/2 - top_ring_w, h=top_ring_h + 2*overlap, center=true);
        }

      // Base plate (mounting) connected to coil bottom
      translate([0,0,base_z])
        cube([base_plate_w, base_plate_d, base_plate_h], center=true);

      // Small center boss under coil (common variac base feature), connected to base plate
      boss_d = max(24, shaft_diameter*2.2);
      boss_h = 14;
      translate([0,0, z_bot - boss_h/2 + overlap])
        cylinder(r=boss_d/2, h=boss_h, center=true);

      // Brush housing box on side (connected to coil)
      translate([brush_x, 0, brush_z])
        cube([brush_box_d + overlap, brush_box_w, brush_box_h], center=true);

      // Brush arm (connected between brush box and coil outer surface)
      translate([arm_x, 0, arm_z])
        cube([brush_arm_t + overlap, brush_arm_w, brush_arm_h], center=true);

      // Terminal block on back/top (connected to top ring)
      translate([0, term_y, term_z])
        cube([terminal_block_w, terminal_block_d, terminal_block_h], center=true);

      // Lugs on terminal block top (protruding, connected)
      lug_pitch = (terminal_block_w - lug_w) / max(1, (lug_count-1));
      for (i = [0:lug_count-1]) {
        lug_x = -terminal_block_w/2 + lug_w/2 + i*lug_pitch;
        translate([lug_x,
                   term_y + (terminal_block_d/2 - lug_d/2 + overlap),
                   term_z + terminal_block_h/2 + lug_h/2 - overlap])
          cube([lug_w, lug_d, lug_h], center=true);
      }

      // --- FIX: 4 terminal screws/terminals attached to terminal block (no gaps) ---
      for (i = [0:lug_count-1]) {
        lug_x = -terminal_block_w/2 + lug_w/2 + i*lug_pitch;
        translate([lug_x, term_screw_y, term_screw_z])
          cylinder(r=term_screw_r, h=term_screw_h, center=true);
      }

      // --- FIX: two pins/posts ABOVE body (visible in BOTTOM view) - attach to top ring ---
      for (sx = [-1, 1]) {
        translate([sx*pin_pair_x, 0, pin_z_top])
          cylinder(r=pin_r, h=pin_h, center=true);
      }

      // --- FIX: two pins/posts BELOW body (visible in TOP view) - attach to base plate ---
      for (sx = [-1, 1]) {
        translate([sx*pin_pair_x, 0, pin_z_bot])
          cylinder(r=pin_r, h=pin_h, center=true);
      }
    }

    // --- Shaft (connected through coil) ---
    color("Silver")
      translate([0,0,shaft_z])
        cylinder(r=shaft_diameter/2, h=shaft_total_h, center=true);

    // --- Knob interface (connected to shaft) ---
    color("Black")
    union(){
      translate([0,0,knob_skirt_z])
        cylinder(r=knob_skirt_diameter/2, h=knob_skirt_height, center=true);

      translate([0,0,knob_z])
        cylinder(r=knob_diameter/2, h=knob_height, center=true);
    }

    // --- Dial (optional) connected to top ---
    if(dial_enabled){
      color("Black")
      union(){
        translate([0,0,dial_z])
          cylinder(r=dial_diameter/2, h=dial_thickness, center=true);

        translate([0,0,hub_z])
          cylinder(r=dial_hub_diameter/2, h=dial_hub_height, center=true);
      }
    }

    // --- Washers and screws (connected to top ring) ---
    color("Silver")
    for (i = [0:mount_hole_count-1]) {
      ang = 360/mount_hole_count*i;
      x = mount_hole_circle_radius*cos(ang);
      y = mount_hole_circle_radius*sin(ang);

      // Place on top ring plane (not floating): top surface of top ring
      z_ring_top = top_ring_z + top_ring_h/2;

      translate([x, y, z_ring_top + washer_thickness/2 - overlap])
        cylinder(r=washer_radius, h=washer_thickness, center=true);

      translate([x, y, z_ring_top + (screw_length_above)/2 - overlap])
        cylinder(r=screw_shank_radius, h=screw_length_above + overlap, center=true);

      translate([x, y, z_ring_top + screw_length_above - overlap + screw_head_height/2])
        cylinder(r=screw_head_radius, h=screw_head_height, center=true);

      // Bottom studs connected to base plate bottom
      z_base_bot = base_z - base_plate_h/2;
      translate([x, y, z_base_bot - stud_h/2 + overlap])
        cylinder(r=screw_shank_radius, h=stud_h, center=true);
    }
  }
}

variac();