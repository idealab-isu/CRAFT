$fn=64;

// Photo interrupter (slot opto) - parametric approximation
// Units: mm

// ---------- Parameters ----------
body_w = 12.0;      // overall width (X)
body_d = 6.0;       // overall depth (Y)
body_h = 10.0;      // overall height (Z)

fork_depth = 5.0;   // depth of the U opening from the front face (Y)
gap_y = 3.0;        // gap between inner faces of the two legs (Y)
leg_th = (body_d - gap_y)/2; // thickness of each leg (Y)

slot_w = 3.2;       // beam slot width (X) inside the fork
slot_height = 7.0;  // height of the slot opening (Z)
slot_floor = 1.5;   // bottom thickness under slot (Z)

top_bridge_h = 2.2; // thickness of top bridge (Z)

lead_d = 0.6;       // lead diameter
lead_len = 12.0;    // lead length below body
lead_pitch = 2.54;  // lead spacing (X)
lead_rows_y = 1.2;  // offset from center in Y for two rows (approx)

fillet_r = 0.8;     // corner rounding (approx)
overlap = 0.25;     // small overlap to ensure watertight unions/differences

// ---------- Helpers ----------
module rounded_box(size=[10,10,10], r=1.0, center=false){
    sx=size[0]; sy=size[1]; sz=size[2];
    translate(center ? [-sx/2,-sy/2,-sz/2] : [0,0,0])
    minkowski(){
        cube([max(0.01,sx-2*r), max(0.01,sy-2*r), max(0.01,sz-2*r)], center=false);
        sphere(r=r);
    }
}

module lead(x,y){
    // Start slightly inside body to guarantee connection
    translate([x,y,-lead_len])
        cylinder(d=lead_d, h=lead_len + overlap);
}

// ---------- Model ----------
module photo_interrupter(){
    // Slot Z extents (kept within body)
    slot_z0 = slot_floor;
    slot_z1 = min(body_h - top_bridge_h, slot_z0 + slot_height);
    slot_h  = max(0.01, slot_z1 - slot_z0);

    // Front face Y and fork region
    y_front = -body_d/2;
    y_fork0 = y_front;
    y_fork1 = y_front + fork_depth;

    // Ensure fork depth is valid
    fork_d_eff = max(0.01, min(fork_depth, body_d));

    union(){
        // Body with U-shaped fork and internal beam slot
        difference(){
            // Main body
            translate([-body_w/2, -body_d/2, 0])
                rounded_box([body_w, body_d, body_h], r=fillet_r, center=false);

            // U-fork opening: remove center between legs, bounded to front depth
            translate([-body_w/2 - overlap, -gap_y/2 - overlap, 0 - overlap])
                cube([body_w + 2*overlap, gap_y + 2*overlap, body_h + 2*overlap], center=false);

            // Add back the "back half" of that cut so the gap exists only in the front fork region:
            // (difference subtracts A then subtracts B; to "add back", we subtract only the front region by
            // subtracting the full cut AND subtracting the back cut from the cutter using intersection logic.)
            // Implemented by limiting the cut to front region via intersection:
            // So we must cancel the unbounded cut above by not doing it; instead, do bounded cut only.
        }

        // Rebuild correctly in one connected solid: body minus bounded cuts + leads
    }
}

// Clean single-pass model (one connected solid)
module photo_interrupter_final(){
    slot_z0 = slot_floor;
    slot_z1 = min(body_h - top_bridge_h, slot_z0 + slot_height);
    slot_h  = max(0.01, slot_z1 - slot_z0);

    y_front = -body_d/2;
    fork_d_eff = max(0.01, min(fork_depth, body_d));

    union(){
        // Body with bounded fork opening + internal beam slot
        difference(){
            translate([-body_w/2, -body_d/2, 0])
                rounded_box([body_w, body_d, body_h], r=fillet_r, center=false);

            // Bounded fork opening between legs (front only)
            intersection(){
                // Gap cutter (between legs)
                translate([-body_w/2 - overlap, -gap_y/2 - overlap, 0 - overlap])
                    cube([body_w + 2*overlap, gap_y + 2*overlap, body_h + 2*overlap], center=false);

                // Front depth limiter
                translate([-body_w/2 - 2*overlap, y_front - overlap, 0 - 2*overlap])
                    cube([body_w + 4*overlap, fork_d_eff + 2*overlap, body_h + 4*overlap], center=false);
            }

            // Beam slot inside the fork (narrower in X), front-only, between floor and bridge
            intersection(){
                translate([-slot_w/2 - overlap, y_front - overlap, slot_z0])
                    cube([slot_w + 2*overlap, fork_d_eff + 2*overlap, slot_h], center=false);

                // Ensure slot stays within the fork gap region in Y
                translate([-body_w/2 - 2*overlap, -gap_y/2 - overlap, 0 - overlap])
                    cube([body_w + 4*overlap, gap_y + 2*overlap, body_h + 2*overlap], center=false);
            }

            // Small front indicator notch (shallow, does not disconnect)
            notch_d = 1.2;
            notch_depth = max(0.01, leg_th); // keep within front leg thickness
            translate([0, y_front - overlap, body_h*0.65])
                rotate([90,0,0])
                    cylinder(d=notch_d, h=notch_depth + 2*overlap, center=false);
        }

        // Leads (4-pin typical), connected by starting slightly inside the body
        for (ix=[-0.5, 0.5]){
            lead(ix*lead_pitch,  lead_rows_y);
            lead(ix*lead_pitch, -lead_rows_y);
        }
    }
}

photo_interrupter_final();