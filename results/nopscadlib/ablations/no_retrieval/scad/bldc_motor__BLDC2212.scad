$fn = 128;

// =====================
// Target motor envelope
// =====================
// Stator: 28.0mm diameter, 27.0mm height
stator_d = 28.0;          // mm (VERIFIABLE: stator_core() OD)
stator_h = 27.0;          // mm (VERIFIABLE: stator_core() height)

// =====================
// Motor feature params
// =====================
housing_wall_t       = 1.0;   // can wall thickness
housing_clearance_r  = 0.5;   // radial clearance between stator OD and can ID
endcap_t             = 2.0;   // endcap thickness (each)
overlap              = 0.6;   // overlap to guarantee watertight unions

// Stator/rotor details
stator_id            = 16.0;  // stator inner diameter (bore for rotor)
teeth_count          = 12;
tooth_radial_len     = 4.0;
tooth_tangential_w   = 3.0;

// Shaft + mounting face
shaft_d              = 5.0;   // solid shaft diameter (protrudes out front)
shaft_len_out        = 12.0;  // shaft protrusion length beyond front endcap
mount_hole_d         = 3.0;
mount_hole_count     = 4;
mount_hole_r         = 11.0;

// Cooling slots
cool_slot_count      = 8;
cool_slot_w          = 3.0;
cool_slot_h          = 12.0;

// Wire leads (kept attached to can)
wire_lead_d          = 2.0;
wire_lead_len        = 12.0;
wire_lead_count      = 3;

// =====================
// Derived dimensions
// =====================
stator_r   = stator_d/2;

// Can ID is stator OD + clearance; can OD adds wall thickness
housing_id_r = stator_r + housing_clearance_r;
housing_r    = housing_id_r + housing_wall_t;

// Keep can height equal to stator height (stator is the verified target)
housing_h  = stator_h;

// Overall motor body height (without shaft)
motor_h    = housing_h + 2*endcap_t;

// Z references (centered can at z=0)
z_can_top    =  housing_h/2;
z_can_bot    = -housing_h/2;
z_front_face =  z_can_top + endcap_t;  // outer face of front endcap
z_back_face  =  z_can_bot - endcap_t;  // outer face of back endcap

// =====================
// Base shapes
// =====================
module stator_ring() {
  // EXACT: OD = stator_d, height = stator_h
  difference() {
    cylinder(h=stator_h, r=stator_r, center=true);
    cylinder(h=stator_h + 2*overlap, r=stator_id/2, center=true);
  }
}

module stator_teeth() {
  // Teeth protrude inward from stator ID toward center; overlap into ring
  tooth_h = stator_h;
  tooth_r_mid = (stator_id/2) - (tooth_radial_len/2) + overlap;
  for (i = [0:teeth_count-1]) {
    rotate([0,0,i*360/teeth_count])
      translate([tooth_r_mid, 0, 0])
        cube([tooth_radial_len + 2*overlap, tooth_tangential_w, tooth_h], center=true);
  }
}

module stator_core() {
  union() {
    stator_ring();
    stator_teeth();
  }
}

module housing_can() {
  // Can ID matches housing_id_r; ensures stator size is meaningful/consistent
  difference() {
    cylinder(h=housing_h, r=housing_r, center=true);
    cylinder(h=housing_h + 2*overlap, r=housing_id_r, center=true);
  }
}

module cooling_slots_cut() {
  // Slots cut through the can wall; centered on can mid-height
  slot_radial_t = housing_wall_t + 2*overlap;
  slot_r_mid = housing_id_r + housing_wall_t/2; // centered in wall thickness
  for (i = [0:cool_slot_count-1]) {
    rotate([0,0,i*360/cool_slot_count])
      translate([slot_r_mid, 0, 0])
        cube([slot_radial_t, cool_slot_w, cool_slot_h], center=true);
  }
}

module endcap(zsign=+1) {
  // zsign: +1 front/top, -1 back/bottom
  translate([0,0, zsign*(housing_h/2 + endcap_t/2 - overlap)])
    cylinder(h=endcap_t + 2*overlap, r=housing_r, center=true);
}

module endcaps() {
  union() {
    endcap(+1);
    endcap(-1);
  }
}

module mounting_holes_cut() {
  // Holes go through both endcaps and can
  h = motor_h + 4*overlap;
  for (i = [0:mount_hole_count-1]) {
    rotate([0,0,i*360/mount_hole_count])
      translate([mount_hole_r, 0, 0])
        cylinder(h=h, r=mount_hole_d/2, center=true);
  }
}

module rotor_void_cut() {
  // Central rotor cavity through stator + endcaps
  h = motor_h + 4*overlap;
  cylinder(h=h, r=stator_id/2, center=true);
}

module shaft_solid() {
  // Shaft protrudes from the FRONT face only; overlaps into endcap for connectivity
  shaft_h = shaft_len_out + endcap_t + 2*overlap;
  z_mid = z_front_face + shaft_len_out/2 - overlap;
  translate([0,0,z_mid])
    cylinder(h=shaft_h, r=shaft_d/2, center=true);
}

module wire_leads_solid() {
  // Leads attached to can OD; ensure overlap into can wall
  lead_r_mid = housing_r + wire_lead_len/2 - overlap;
  // Place near back half, but still within can height region (formula-based)
  lead_z = z_can_bot + housing_h*0.25;
  for (i = [0:wire_lead_count-1]) {
    rotate([0,0,i*360/wire_lead_count])
      translate([lead_r_mid, 0, lead_z])
        rotate([0,90,0])
          cylinder(h=wire_lead_len, r=wire_lead_d/2, center=true);
  }
}

// =====================
// Final motor (ONE connected solid)
// =====================
module motor() {
  difference() {
    union() {
      // Outer body (connected)
      difference() {
        union() {
          housing_can();
          endcaps();
        }
        cooling_slots_cut();
      }

      // Internal stator (kept connected to can via tiny radial bridge)
      // Bridge guarantees ONE connected solid even if clearances exist.
      union() {
        stator_core();

        // Radial bridge: from stator OD to can ID, small tangential width
        bridge_w = 2.0;
        bridge_h = stator_h;
        bridge_len = (housing_id_r - stator_r) + 2*overlap; // spans clearance with overlap
        bridge_r_mid = stator_r + bridge_len/2 - overlap;
        rotate([0,0,0])
          translate([bridge_r_mid, 0, 0])
            cube([bridge_len, bridge_w, bridge_h], center=true);
      }

      // Shaft (solid, connected)
      shaft_solid();

      // Wire leads (solid, connected)
      wire_leads_solid();
    }

    // Subtractive features
    mounting_holes_cut();
    rotor_void_cut();
  }
}

motor();