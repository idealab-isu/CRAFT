// Brushless DC Motor (BLDC) - 23mm stator diameter, 12mm stator height
// One connected solid. All translate() values derived from dimensions (no arbitrary offsets).

// Parameters
stator_diameter_mm = 23.0;          //[11.5:46.0:0.5]
stator_height_mm   = 12.0;          //[6.0:24.0:0.5]
stator_bore_diameter_mm = 5.0;      //[2.5:10.0:0.25]

shaft_diameter_mm  = 2.0;           //[0.5:5.0:0.1]
shaft_above_mm     = 10.0;          //[2.0:30.0:0.5]
shaft_below_mm     = 2.0;           //[0.0:10.0:0.5]

can_wall_mm        = 1.0;           //[0.6:2.0:0.1]
can_extra_radius_mm= 1.0;           //[0.0:3.0:0.1]
bell_lip_mm        = 1.0;           //[0.5:2.5:0.1]

base_thickness_mm  = 2.0;           //[1.0:5.0:0.25]
base_extra_radius_mm = 2.0;         //[0.0:6.0:0.25]

mount_hole_count   = 4;             //[2:8]
mount_hole_d_mm    = 2.2;           //[1.5:4.0:0.1]
mount_pcd_mm       = 16.0;          //[10.0:22.0:0.5]
mount_boss_d_mm    = 4.6;           //[3.0:7.0:0.1]
mount_boss_h_mm    = 1.2;           //[0.6:3.0:0.1]

wire_exit_d_mm     = 3.0;           //[1.5:6.0:0.1]
wire_exit_len_mm   = 6.0;           //[2.0:12.0:0.5]
wire_exit_z_from_back_mm = 3.0;     //[1.0:8.0:0.5]

vent_slot_count    = 8;             //[0:16]
vent_slot_w_mm     = 2.0;           //[1.0:4.0:0.1]
vent_slot_h_mm     = 4.0;           //[2.0:8.0:0.25]
vent_slot_depth_mm = 0.8;           //[0.4:2.0:0.1]

connect_overlap_mm = 0.6;           //[0.2:2.0:0.1]
$fn = 128;

module bldc_motor() {
    stator_r = stator_diameter_mm/2;
    stator_h = stator_height_mm;

    // Outer can/bell (slightly larger than stator)
    can_r_outer = stator_r + can_extra_radius_mm;
    can_r_inner = max(stator_r + 0.2, can_r_outer - can_wall_mm);
    can_h = stator_h + 2*bell_lip_mm;

    // Rear base plate (endbell)
    base_r = can_r_outer + base_extra_radius_mm;
    base_h = base_thickness_mm;

    // Z layout: stator centered at z=0
    base_z = -stator_h/2 - base_h/2 + connect_overlap_mm; // overlaps into stator/can
    can_z  = 0;

    // Shaft
    shaft_h_total = stator_h + shaft_above_mm + shaft_below_mm;
    shaft_z = (shaft_above_mm - shaft_below_mm)/2;

    // Front hub / rotor face detail
    hub_r = max(stator_bore_diameter_mm/2 + 1.2, stator_r*0.35);
    hub_h = max(0.8, bell_lip_mm*1.2);
    hub_z = stator_h/2 + hub_h/2 - connect_overlap_mm;

    // Front bell lip ring (gives recognizable bell edge)
    lip_r_outer = can_r_outer;
    lip_r_inner = max(lip_r_outer - max(0.8, can_wall_mm*1.2), hub_r + 0.6);
    lip_h = max(0.8, bell_lip_mm);
    lip_z = stator_h/2 + lip_h/2 - connect_overlap_mm;

    // Rear bearing boss (inside base, but solid and connected)
    rear_boss_r = max(stator_bore_diameter_mm/2 + 1.0, shaft_diameter_mm/2 + 1.2);
    rear_boss_h = max(1.2, base_h*0.8);
    rear_boss_z = base_z + base_h/2 - rear_boss_h/2 + connect_overlap_mm;

    // Mount bosses on rear base (solid bumps)
    boss_r = mount_boss_d_mm/2;
    boss_h = mount_boss_h_mm;
    boss_z = base_z + base_h/2 + boss_h/2 - connect_overlap_mm;

    // Wire exit (solid grommet-like cylinder) on rear side, connected to base
    wire_r = wire_exit_d_mm/2;
    wire_len = wire_exit_len_mm;
    wire_z = base_z - base_h/2 + wire_exit_z_from_back_mm; // measured from back face of base
    wire_x = base_r - wire_len/2 + connect_overlap_mm;      // starts at base outer edge and protrudes outward

    // Vent slots on can (subtractive), placed on side wall
    slot_count = vent_slot_count;
    slot_w = vent_slot_w_mm;
    slot_h = vent_slot_h_mm;
    slot_depth = vent_slot_depth_mm;
    slot_r = can_r_outer - slot_depth/2; // centered in wall thickness
    slot_z = 0; // centered on stator

    union() {
        // Base plate with mounting holes (holes are subtractive but base remains connected)
        translate([0,0,base_z])
        difference() {
            cylinder(r=base_r, h=base_h, center=true);

            // Mounting holes on PCD
            for (i = [0:mount_hole_count-1]) {
                rotate([0,0,i*360/mount_hole_count])
                    translate([mount_pcd_mm/2, 0, 0])
                        cylinder(r=mount_hole_d_mm/2, h=base_h + 2*connect_overlap_mm, center=true);
            }
        }

        // Mounting bosses (solid) around holes
        for (i = [0:mount_hole_count-1]) {
            rotate([0,0,i*360/mount_hole_count])
                translate([mount_pcd_mm/2, 0, boss_z])
                    cylinder(r=boss_r, h=boss_h, center=true);
        }

        // Rear bearing boss (solid)
        translate([0,0,rear_boss_z])
            cylinder(r=rear_boss_r, h=rear_boss_h, center=true);

        // Wire exit (solid) connected to base
        translate([wire_x, 0, wire_z])
            rotate([0,90,0])
                cylinder(r=wire_r, h=wire_len, center=true);

        // Can/bell with vent slots (hollow + slots subtracted)
        translate([0,0,can_z])
        difference() {
            // Outer can
            cylinder(r=can_r_outer, h=can_h, center=true);

            // Hollow interior
            cylinder(r=can_r_inner, h=can_h + 2*connect_overlap_mm, center=true);

            // Vent slots (cut through outer wall only)
            if (slot_count > 0)
                for (i = [0:slot_count-1]) {
                    rotate([0,0,i*360/slot_count])
                        translate([slot_r, 0, slot_z])
                            cube([slot_depth + 2*connect_overlap_mm, slot_w, slot_h], center=true);
                }
        }

        // Stator core (ring) inside can (solid ring)
        difference() {
            cylinder(r=stator_r, h=stator_h, center=true);
            cylinder(r=stator_bore_diameter_mm/2, h=stator_h + 2*connect_overlap_mm, center=true);
        }

        // Front hub (solid)
        translate([0,0,hub_z])
            cylinder(r=hub_r, h=hub_h, center=true);

        // Front bell lip ring (solid ring) to suggest rotor/bell edge
        translate([0,0,lip_z])
        difference() {
            cylinder(r=lip_r_outer, h=lip_h, center=true);
            cylinder(r=lip_r_inner, h=lip_h + 2*connect_overlap_mm, center=true);
        }

        // Shaft (solid)
        translate([0,0,shaft_z])
            cylinder(r=shaft_diameter_mm/2, h=shaft_h_total, center=true);
    }
}

bldc_motor();