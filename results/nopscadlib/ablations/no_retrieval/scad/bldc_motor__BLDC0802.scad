$fn = 128;

// =====================
// Parameters (mm)
// =====================
// Requested stator size (explicit and verifiable)
stator_diameter = 11.5;   // OD
stator_height   = 9.5;    // stack height

// Motor "can" / rotor housing (slightly larger than stator)
can_wall              = 0.6;
air_gap               = 0.25;
can_outer_diameter    = stator_diameter + 2*(air_gap + can_wall); // recognizable cylindrical can
can_height            = stator_height + 1.2;                      // slightly taller than stator

// Endbells / faces
endbell_thickness     = 1.0;
endbell_diameter      = can_outer_diameter + 1.0; // small lip

// Shaft
shaft_diameter        = 1.5;
shaft_front_length    = 6.0;   // protruding
shaft_back_length     = 3.0;   // small rear nub

// Mounting pattern (front face)
mount_hole_diameter        = 1.2;
mount_hole_circle_diameter = 9.0;
mount_hole_count           = 4;

// Stator slots (visual cue)
slot_count = 9;
slot_width = 0.8;
slot_depth = 1.0;

// Wire leads
wire_lead_diameter = 0.9;
wire_lead_length   = 8.0;
wire_spacing       = 1.4;

// Connectivity overlap
overlap = 0.25;

// =====================
// Derived
// =====================
stator_r = stator_diameter/2;
can_or   = can_outer_diameter/2;
can_ir   = can_or - can_wall;

motor_stack_h = can_height + 2*endbell_thickness;

// Z references (centered motor)
z_can_center = 0;
z_front_face = can_height/2 + endbell_thickness/2;   // endbell center
z_back_face  = -z_front_face;

// =====================
// Modules
// =====================
module can_shell() {
  // Hollow can (difference), but still one connected solid once endbells/shaft/leads are unioned
  difference() {
    cylinder(r=can_or, h=can_height, center=true);
    // inner cavity slightly shorter to avoid coplanar faces with endbells
    cylinder(r=can_ir, h=can_height - 2*overlap, center=true);
  }
}

module endbell(zc) {
  translate([0,0,zc])
    cylinder(r=endbell_diameter/2, h=endbell_thickness, center=true);
}

module stator_core() {
  // Stator is explicitly the requested size: 11.5mm OD x 9.5mm height
  // Slight overlap into endbells for guaranteed connectivity in union
  cylinder(r=stator_r, h=stator_height + 2*overlap, center=true);
}

module stator_with_slots() {
  difference() {
    stator_core();
    for (i = [0:slot_count-1]) {
      rotate([0,0,i*360/slot_count])
        // cut from OD inward
        translate([stator_r - slot_depth/2 + overlap, 0, 0])
          cube([slot_depth + 2*overlap, slot_width, stator_height + 4*overlap], center=true);
    }
  }
}

module shaft() {
  // Shaft passes through motor and protrudes front/back
  total_len = motor_stack_h + shaft_front_length + shaft_back_length;
  // Center shaft so front protrusion is longer than back
  zc = (shaft_front_length - shaft_back_length)/2;
  translate([0,0,zc])
    cylinder(r=shaft_diameter/2, h=total_len, center=true);
}

module mount_holes() {
  r = mount_hole_circle_diameter/2;
  for (a = [0:mount_hole_count-1]) {
    ang = a*360/mount_hole_count;
    translate([r*cos(ang), r*sin(ang), z_front_face])
      cylinder(r=mount_hole_diameter/2, h=endbell_thickness + 4*overlap, center=true);
  }
}

module wire_lead(yoff) {
  // Leads exit radially from the can OD and overlap into the endbell for connectivity
  // Place on back endbell region
  x_center = can_or + wire_lead_length/2 - overlap;
  zc = z_back_face; // centered on back endbell
  translate([x_center, yoff, zc])
    rotate([0,90,0])
      cylinder(r=wire_lead_diameter/2, h=wire_lead_length, center=true);
}

module motor_solid() {
  union() {
    // Can + endbells (recognizable BLDC can motor)
    can_shell();
    endbell(z_front_face);
    endbell(z_back_face);

    // Stator inside (requested dimensions)
    stator_with_slots();

    // Shaft through center
    shaft();

    // Leads (3-phase)
    wire_lead(-wire_spacing);
    wire_lead(0);
    wire_lead(wire_spacing);
  }
}

module motor_complete() {
  difference() {
    motor_solid();
    // Mount holes on front face only (typical)
    mount_holes();
  }
}

// =====================
// Output
// =====================
motor_complete();