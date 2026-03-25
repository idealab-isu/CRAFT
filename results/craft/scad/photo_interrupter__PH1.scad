// Photo interrupter (U-slot opto) - single connected solid with fork + pins + base/PCB
// STRUCTURAL FIXES:
// 1) Add missing "photo interrupter" fork body (already present) and ensure it is attached to base with overlap
// 2) Fix floating/disconnected pins: make pins start INSIDE the base (1-2mm) and extend downward
// 3) Ensure ALL parts are in one union() and overlap slightly for watertight connectivity

// Parameters
overall_width = 20; //[10:40:1]   // X
overall_depth = 10; //[5:20:1]    // Y
overall_height = 15; //[8:30:1]   // Z (body above base)
gap_width = 3; //[1.5:8:0.5]     // X opening (slot width between legs)
gap_depth = 6; //[3:20:1]         // Y slot depth (how far the slot goes into the body)
gap_height = 10; //[5:20:1]       // Z opening height (from bottom of body upward)
bridge_thickness = 2; //[1:6:0.5] // Z thickness of top bridge above slot
leg_thickness = 2; //[1:6:0.5]    // X thickness of each fork leg

base_thickness = 2; //[1:6:0.5]   // Z base
mount_hole_diameter = 2.5; //[1.5:6:0.1]
mount_hole_spacing = 10; //[6:20:1]

pcb_thickness = 1.6; //[0.8:3.2:0.1]
pcb_margin = 2; //[1:6:0.5]
pcb_enabled = 1; //[0:1:1]

pin_count = 4; //[2:6:1]
pin_d = 0.8; //[0.4:1.2:0.05]
pin_pitch = 2.54; //[1.27:5.08:0.01]
pin_len = 6; //[3:12:0.5]
pin_row_y = 0; // centered row

overlap = 1; //[0.5:2:0.1]

// Derived / safety clamps
eps = 0.01;

body_w = max(6, overall_width);
body_d = max(4, overall_depth);
body_h = max(6, overall_height);

base_w = body_w;
base_d = body_d;

slot_w = min(gap_width, max(eps, body_w - 2*leg_thickness - eps));
slot_d = min(gap_depth, max(eps, body_d - eps));
slot_h = min(gap_height, max(eps, body_h - bridge_thickness - eps));

leg_t = min(leg_thickness, max(eps, (body_w - slot_w)/2 - eps));
bridge_t = min(bridge_thickness, max(eps, body_h - slot_h - eps));

pin_r = pin_d/2;
pins_span = (pin_count-1)*pin_pitch;
pins_x0 = -pins_span/2;

// --- Z references (base centered at Z=0) ---
base_top_z =  base_thickness/2;
base_bot_z = -base_thickness/2;

// PCB placement: overlap into base so it is fused
pcb_center_z = base_bot_z - pcb_thickness/2 + overlap;

// Fork/body placement: overlap into base so it is fused
body_center_z = base_top_z + body_h/2 - overlap;

// Pins placement (CRITICAL FIX):
// Make the TOP of each pin sit INSIDE the base by 'overlap' (not merely touching).
// This guarantees the pins are physically attached to the base (and PCB if enabled).
pins_top_z    = base_bot_z + overlap;     // inside base by overlap (since base_bot_z is bottom face)
pins_center_z = pins_top_z - pin_len/2;   // so pin extends downward from inside base

module photo_interrupter() {
  union() {

    // PCB (optional) - fused to base with overlap
    if (pcb_enabled) {
      color([0.0, 0.4, 0.2])
      translate([0, 0, pcb_center_z])
        cube([base_w + 2*pcb_margin, base_d + 2*pcb_margin, pcb_thickness], center=true);
    }

    // Base plate with mounting holes
    color([0.15, 0.2, 0.35])
    difference() {
      cube([base_w, base_d, base_thickness], center=true);

      for (sx = [-1, 1])
        translate([sx*mount_hole_spacing/2, 0, 0])
          cylinder(h=base_thickness + 2*overlap, r=mount_hole_diameter/2, center=true, $fn=48);
    }

    // Photo interrupter body (U-shaped fork) with through-slot open at the front (Y-)
    // Attached to base with overlap
    color([0.15, 0.2, 0.35])
    translate([0, 0, body_center_z])
    difference() {
      // Outer body
      cube([body_w, body_d, body_h], center=true);

      // Slot: open from bottom up to slot_h, and open from front face into the body by slot_d
      translate([0,
                 -body_d/2 + slot_d/2 + eps,          // start at front face (Y-)
                 -body_h/2 + slot_h/2 - eps])         // start at bottom of body
        cube([slot_w, slot_d + 2*eps, slot_h + 2*overlap], center=true);
    }

    // Leads/pins - attached by embedding their top into the base by 'overlap'
    color([0.75, 0.75, 0.75])
    for (i = [0:pin_count-1]) {
      x = pins_x0 + i*pin_pitch;
      translate([x, pin_row_y, pins_center_z])
        cylinder(h=pin_len, r=pin_r, center=true, $fn=24);
    }
  }
}

photo_interrupter();