$fn = 128;

// -------------------- Requested stator size (verifiable) --------------------
stator_d = 9.0;   // mm (EXACT)
stator_h = 8.0;   // mm (EXACT)

// -------------------- Motor outer can (kept slightly larger than stator) ----
can_d = 10.0;     // mm
can_h = stator_h; // mm (same overall height as stator for easy verification)

// -------------------- Shaft -------------------------------------------------
shaft_d   = 1.5;  // mm
shaft_len = 14.0; // mm (total, centered)

// -------------------- Construction -----------------------------------------
endcap_thk   = 1.0;  // mm
shell_wall   = 0.6;  // mm
radial_clear = 0.2;  // mm
overlap      = 0.4;  // mm (guarantee connectivity)

// -------------------- Mounting holes ---------------------------------------
mount_hole_d     = 1.2; // mm
mount_hole_count = 4;
mount_circle_d   = 7.0; // mm

// -------------------- Bearings (visual) ------------------------------------
bearing_od  = 4.0; // mm
bearing_thk = 1.0; // mm

// -------------------- Wires ------------------------------------------------
wire_d        = 0.8; // mm
wire_len      = 6.0; // mm
wire_offset_z = 1.5; // mm

// -------------------- Internal stator/rotor visual features ----------------
// (kept inside the 9mm stator cylinder so stator diameter remains exact)
tooth_count   = 12;
tooth_depth   = 0.7;  // radial depth of tooth into bore
tooth_width   = 0.9;  // tangential width
tooth_h       = stator_h - 0.6; // keep slight margin from end faces
stator_bore_d = 4.2;  // inner bore diameter (visual)
rotor_core_d  = stator_bore_d - 2*radial_clear; // rotor inside bore

// -------------------- Derived ----------------------------------------------
stator_r = stator_d/2;
can_r    = can_d/2;

// -------------------- Primitives -------------------------------------------
module stator_body_exact() {
  // EXACT requested stator envelope: 9.0mm diameter, 8.0mm height
  cylinder(r=stator_r, h=stator_h, center=true);
}

module stator_teeth_visual() {
  // Teeth protrude inward from stator inner radius; unioned with stator.
  // All geometry stays within stator_r.
  inner_r = stator_bore_d/2;
  tooth_len = tooth_depth + overlap; // overlap into stator ring for connectivity

  union() {
    // Stator ring (outer = stator_r, inner = inner_r)
    difference() {
      cylinder(r=stator_r, h=stator_h, center=true);
      cylinder(r=inner_r, h=stator_h + 2*overlap, center=true);
    }

    // Teeth (inward)
    for (i = [0:tooth_count-1]) {
      rotate([0,0,i*360/tooth_count])
        translate([inner_r - tooth_len/2 + overlap, 0, 0])
          cube([tooth_len, tooth_width, tooth_h], center=true);
    }
  }
}

module rotor_core_visual() {
  // Simple rotor core inside stator bore (visual only)
  cylinder(r=rotor_core_d/2, h=stator_h - 2*endcap_thk, center=true);
}

module can_shell() {
  // Outer can as a hollow cylinder (connected to endcaps via overlap)
  difference() {
    cylinder(r=can_r, h=can_h, center=true);
    cylinder(r=can_r - shell_wall, h=can_h + 2*overlap, center=true);
  }
}

module endcaps() {
  union() {
    translate([0,0, can_h/2 - endcap_thk/2 + overlap/2])
      cylinder(r=can_r, h=endcap_thk + overlap, center=true);
    translate([0,0,-can_h/2 + endcap_thk/2 - overlap/2])
      cylinder(r=can_r, h=endcap_thk + overlap, center=true);
  }
}

module motor_shaft() {
  cylinder(r=shaft_d/2, h=shaft_len, center=true);
}

module bearing_ring() {
  difference() {
    cylinder(r=bearing_od/2, h=bearing_thk, center=true);
    cylinder(r=shaft_d/2 + radial_clear, h=bearing_thk + 2*overlap, center=true);
  }
}

module bearing_details() {
  // Place bearings just inside endcaps; overlap ensures connectivity
  z_top =  can_h/2 - endcap_thk - bearing_thk/2 + overlap;
  z_bot = -can_h/2 + endcap_thk + bearing_thk/2 - overlap;
  union() {
    translate([0,0, z_top]) bearing_ring();
    translate([0,0, z_bot]) bearing_ring();
  }
}

module wire_lead() {
  rotate([0,90,0]) cylinder(r=wire_d/2, h=wire_len, center=true);
}

module wire_leads() {
  // Ensure wires intersect the can by pushing inner end slightly inside can radius
  x_pos = can_r + wire_len/2 - overlap;
  union() {
    translate([x_pos, 0,  wire_offset_z]) wire_lead();
    translate([x_pos, 0, -wire_offset_z]) wire_lead();
    translate([x_pos, wire_d*1.5, 0])     wire_lead();
  }
}

module mounting_holes() {
  hole_h = can_h + 4*overlap;
  for (i = [0:mount_hole_count-1]) {
    ang = i * 360/mount_hole_count;
    rotate([0,0,ang])
      translate([mount_circle_d/2, 0, 0])
        cylinder(r=mount_hole_d/2, h=hole_h, center=true);
  }
}

// -------------------- Assembly (ONE connected solid) ------------------------
module motor_solid_preholes() {
  union() {
    // Outer can
    can_shell();
    endcaps();

    // Internal stator (exact envelope) with visible teeth; overlaps can interior
    // Keep stator centered and same height as can for verifiable dimensions.
    stator_teeth_visual();

    // Rotor core (visual) inside stator bore
    rotor_core_visual();

    // Shaft passes through (intersects endcaps/bearings)
    motor_shaft();

    // Bearings (visual) intersect endcaps/shaft
    bearing_details();

    // Wires connected to can
    wire_leads();
  }
}

// Final: subtract mounting holes (still one connected solid)
difference() {
  motor_solid_preholes();
  mounting_holes();
}