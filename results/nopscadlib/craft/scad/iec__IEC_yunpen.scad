$fn = 64;

// ===== IEC filtered power inlet module (C14 style) =====
// Requested panel cutout: 40.0mm x 29.0mm
// Structural fix: ensure the expected part "iec" exists and is a single connected solid.
// Also increase overlap to 1.2mm and recalc Z placements so every part intersects.

panel_cutout_w = 40.0;
panel_cutout_h = 29.0;

flange_w = 50.0;
flange_h = 35.0;
flange_t = 3.0;

bezel_w  = 46.0;
bezel_h  = 33.0;
bezel_t  = 2.0;

body_depth = 22.0;
body_wall  = 2.0;

rear_can_w = 44.0;
rear_can_h = 34.0;
rear_can_d = 30.0;
rear_can_wall = 1.2;

// Use 1–2mm overlap to guarantee watertight unions
overlap = 1.2;

// --- IEC C14 opening (approx, for recognizable geometry)
c14_open_w = 27.5;
c14_open_h = 20.0;
c14_corner_r = 2.2;
c14_recess_depth = 4.0;

// --- Pin slots (approx)
slot_w = 6.2;
slot_h = 2.2;
slot_depth = 8.0;
slot_pitch_x = 14.0;
slot_pitch_y = 8.0;

// --- Mounting holes (typical flange holes)
screw_d = 3.5;
screw_pitch_x = 40.0;
screw_pitch_y = 0.0;

// --- Spade terminals (rear)
spade_w = 6.3;
spade_t = 0.8;
spade_len = 12.0;
spade_spacing_x = 14.0;
spade_spacing_y = 8.0;

// --- Recalculated Z positions (front face at z=0, positive z goes "back")
// Place parts so they overlap by 'overlap' at each interface.
z_flange_center = flange_t/2;

// Bezel overlaps flange by 'overlap'
z_bezel_center  = flange_t + bezel_t/2 - overlap;

// Body overlaps bezel by 'overlap'
z_body_center   = flange_t + bezel_t + body_depth/2 - 2*overlap;

// Rear can overlaps body by 'overlap'
z_rear_center   = flange_t + bezel_t + body_depth + rear_can_d/2 - 3*overlap;

// Rear face of rear can (for terminals)
z_rear_back_face = z_rear_center + rear_can_d/2;

// ===== Helpers =====
module rounded_rect_2d(w,h,r){
  r2 = min(r, min(w,h)/2);
  hull(){
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(w/2-r2), sy*(h/2-r2)]) circle(r=r2);
  }
}

// ===== Expected part: iec =====
module iec(){
  // Build a connected outer union, then subtract openings/holes.
  difference(){
    union(){
      // Front flange
      translate([0,0,z_flange_center])
        cube([flange_w, flange_h, flange_t], center=true);

      // Bezel (overlaps flange)
      translate([0,0,z_bezel_center])
        cube([bezel_w, bezel_h, bezel_t], center=true);

      // Main body outer (matches requested panel cutout + wall) (overlaps bezel)
      translate([0,0,z_body_center])
        cube([panel_cutout_w + 2*body_wall,
              panel_cutout_h + 2*body_wall,
              body_depth], center=true);

      // Rear filter can outer (overlaps body)
      translate([0,0,z_rear_center])
        cube([rear_can_w, rear_can_h, rear_can_d], center=true);

      // Spade terminals: ensure they intersect rear can by 'overlap'
      // Put their front face slightly inside the rear can back face.
      for (sx=[-1,1], sy=[-1,1]){
        translate([sx*spade_spacing_x/2,
                   sy*spade_spacing_y/2,
                   z_rear_back_face + spade_len/2 - overlap])
          cube([spade_w, spade_t, spade_len], center=true);
      }
    }

    // --- Hollow out rear can (leave wall thickness)
    translate([0,0,z_rear_center])
      cube([rear_can_w - 2*rear_can_wall,
            rear_can_h - 2*rear_can_wall,
            rear_can_d - 2*rear_can_wall], center=true);

    // --- Panel cutout passage through body (through-hole)
    translate([0,0,z_body_center])
      cube([panel_cutout_w,
            panel_cutout_h,
            body_depth + 2*overlap], center=true);

    // --- IEC C14 recessed opening in bezel
    // Cut from the front into the bezel by c14_recess_depth.
    // Center the cut within the bezel thickness, biased toward the front.
    translate([0,0, flange_t + bezel_t/2 - c14_recess_depth/2])
      linear_extrude(height=c14_recess_depth + 2*overlap, center=true)
        rounded_rect_2d(c14_open_w, c14_open_h, c14_corner_r);

    // --- Pin slots (3 slots: L, N, Earth)
    // Cut from front into bezel+body by slot_depth.
    translate_z_slots = flange_t + bezel_t/2 - slot_depth/2;
    for (sx=[-1,1]){
      translate([sx*slot_pitch_x/2,
                 -slot_pitch_y/2,
                 translate_z_slots])
        cube([slot_w, slot_h, slot_depth + 2*overlap], center=true);
    }
    translate([0,
               slot_pitch_y/2,
               translate_z_slots])
      cube([slot_w, slot_h, slot_depth + 2*overlap], center=true);

    // --- Mounting holes through flange+bezel
    // Center the drill through the combined thickness.
    z_hole_center = (flange_t + bezel_t)/2 - overlap/2;
    for (sx=[-1,1]){
      translate([sx*screw_pitch_x/2, screw_pitch_y/2, z_hole_center])
        cylinder(d=screw_d, h=flange_t + bezel_t + 2*overlap, center=true);
    }
  }
}

// Render the expected part
iec();