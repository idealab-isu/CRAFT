// Parameters
total_length = 3.5; //[1.75:7:0.1]
scale = 0.0368421053; //[0.0184210526:0.0736842106:0.0001]
wall_t = 0.0736842106; //[0.0368421053:0.1473684212:0.01]
base_outer_L = 3.5; //[1.75:7:0.1]
base_outer_W = 2.3947368421; //[1.1973684211:4.7894736842:0.1]
base_outer_H = 1.0315789474; //[0.5157894737:2.0631578948:0.05]
lid_outer_H = 0.4421052632; //[0.2210526316:0.8842105264:0.05]
internal_clearance_Z = 0.2210526316; //[0.1105263158:0.4421052632:0.02]
pcb_L = 3.1315789474; //[1.5657894737:6.2631578948:0.1]
pcb_W = 2.0631578948; //[1.0315789474:4.1263157896:0.1]
pcb_t = 0.0589473684; //[0.0294736842:0.1178947368:0.005]
standoff_h = 0.2210526316; //[0.1105263158:0.4421052632:0.02]
standoff_od = 0.2210526316; //[0.1105263158:0.4421052632:0.02]
standoff_hole_d = 0.0994736842; //[0.0497368421:0.1989473684:0.01]
mount_hole_pitch_X = 2.1368421053; //[1.0684210526:4.2736842106:0.05]
mount_hole_pitch_Y = 1.8052631579; //[0.9026315789:3.6105263158:0.05]
mount_hole_edge_offset_X = 0.1289473684; //[0.0644736842:0.2578947368:0.01]
mount_hole_edge_offset_Y = 0.1289473684; //[0.0644736842:0.2578947368:0.01]
gpio_slot_L = 1.9157894737; //[0.9578947368:3.8315789474:0.05]
gpio_slot_H = 0.2947368421; //[0.1473684211:0.5894736842:0.02]
gpio_slot_edge_clearance = 0.0736842106; //[0.0368421053:0.1473684212:0.01]
cutout_clearance = 0.0221052632; //[0.0110526316:0.0442105264:0.005]
usb_c_cutout_W = 0.3684210526; //[0.1842105263:0.7368421052:0.02]
usb_c_cutout_H = 0.1657894737; //[0.0828947368:0.3315789474:0.02]
micro_hdmi_cutout_W = 0.2947368421; //[0.1473684211:0.5894736842:0.02]
micro_hdmi_cutout_H = 0.1473684211; //[0.0736842106:0.2947368422:0.02]
av_cutout_D = 0.2578947368; //[0.1289473684:0.5157894736:0.02]
av_cutout_H = 0.2578947368; //[0.1289473684:0.5157894736:0.02]
usb_stack_cutout_W = 1.1052631579; //[0.5526315789:2.2105263158:0.05]
usb_stack_cutout_H = 0.5894736842; //[0.2947368421:1.1789473684:0.05]
eth_cutout_W = 0.6263157895; //[0.3131578947:1.252631579:0.05]
eth_cutout_H = 0.5157894737; //[0.2578947368:1.0315789474:0.05]
microsd_slot_W = 0.5157894737; //[0.2578947368:1.0315789474:0.05]
microsd_slot_H = 0.1105263158; //[0.0552631579:0.2210526316:0.01]
vent_slot_W = 0.0921052632; //[0.0460526316:0.1842105264:0.01]
vent_slot_L = 0.7368421053; //[0.3684210526:1.4736842106:0.05]
vent_slot_pitch = 0.1842105263; //[0.0921052632:0.3684210526:0.02]
lip_depth = 0.0552631579; //[0.0276315789:0.1105263158:0.005]
lip_height = 0.1105263158; //[0.0552631579:0.2210526316:0.01]
overlap = 0.0368421053; //[0.0184210526:0.0736842106:0.005]
port_cutout_depth = 0.1842105263; //[0.0921052632:0.3684210526:0.02]
pcb_cavity_clearance_xy = 0.0736842106; //[0.0368421053:0.1473684212:0.01]
feet_recess_d = 0.1842105263; //[0.0921052632:0.3684210526:0.02]
feet_recess_h = 0.0368421053; //[0.0184210526:0.0736842106:0.005]
snap_w = 0.1105263158; //[0.0552631579:0.2210526316:0.01]
snap_t = 0.0368421053; //[0.0184210526:0.0736842106:0.005]
snap_h = 0.1105263158; //[0.0552631579:0.2210526316:0.01]

// Base Outer
module base_outer() {
  translate([0, 0, base_outer_H/2])
    cube([base_outer_L, base_outer_W, base_outer_H], center=true);
}

// Base Inner Cavity
module base_inner_cavity() {
  translate([0, 0, wall_t + (base_outer_H-wall_t)/2])
    cube([base_outer_L-2*wall_t, base_outer_W-2*wall_t, base_outer_H-wall_t], center=true);
}

// PCB Cavity
module pcb_cavity() {
  translate([0, 0, wall_t + (standoff_h+pcb_t+internal_clearance_Z)/2])
    cube([pcb_L+2*pcb_cavity_clearance_xy, pcb_W+2*pcb_cavity_clearance_xy, standoff_h+pcb_t+internal_clearance_Z], center=true);
}

// Standoff Cylinder
module standoff_cyl() {
  translate([0, 0, wall_t + standoff_h/2 - overlap])
    cylinder(r=standoff_od/2, h=standoff_h, center=true);
}

// Standoff Hole
module standoff_hole() {
  translate([0, 0, wall_t + standoff_h/2 - overlap])
    cylinder(r=standoff_hole_d/2, h=standoff_h + 2*overlap, center=true);
}

// Lid Outer
module lid_outer() {
  translate([0, 0, base_outer_H + lid_outer_H/2 - overlap])
    cube([base_outer_L, base_outer_W, lid_outer_H], center=true);
}

// Lid Inner Cavity
module lid_inner_cavity() {
  translate([0, 0, base_outer_H + wall_t + (lid_outer_H-wall_t)/2 - overlap])
    cube([base_outer_L-2*wall_t, base_outer_W-2*wall_t, lid_outer_H-wall_t], center=true);
}

// Lip Ring Outer
module lip_ring_outer() {
  translate([0, 0, base_outer_H - lip_height/2 + overlap])
    cube([base_outer_L-2*wall_t+2*lip_depth, base_outer_W-2*wall_t+2*lip_depth, lip_height], center=true);
}

// Lip Ring Inner
module lip_ring_inner() {
  translate([0, 0, base_outer_H - lip_height/2 + overlap])
    cube([base_outer_L-2*wall_t, base_outer_W-2*wall_t, lip_height + 2*overlap], center=true);
}

// USB-C Cutout
module usb_c_cutout() {
  translate([-base_outer_L/2 + port_cutout_depth/2 + overlap, -base_outer_W/4, wall_t + (usb_c_cutout_H + 2*cutout_clearance)/2])
    cube([port_cutout_depth, usb_c_cutout_W + 2*cutout_clearance, usb_c_cutout_H + 2*cutout_clearance], center=true);
}

// Micro HDMI Cutout
module micro_hdmi_cutout() {
  translate([-base_outer_L/2 + port_cutout_depth/2 + overlap, -base_outer_W/4 + (micro_hdmi_cutout_W + 2*cutout_clearance + vent_slot_pitch), wall_t + (micro_hdmi_cutout_H + 2*cutout_clearance)/2])
    cube([port_cutout_depth, micro_hdmi_cutout_W + 2*cutout_clearance, micro_hdmi_cutout_H + 2*cutout_clearance], center=true);
}

// AV Cutout
module av_cutout() {
  translate([-base_outer_L/2 + port_cutout_depth/2 + overlap, base_outer_W/4, wall_t + (av_cutout_H + 2*cutout_clearance)/2])
    rotate([0, 90, 0])
    cylinder(r=(av_cutout_D + 2*cutout_clearance)/2, h=port_cutout_depth, center=true);
}

// USB Stack Cutout
module usb_stack_cutout() {
  translate([base_outer_L/2 - port_cutout_depth/2 - overlap, -base_outer_W/6, wall_t + (usb_stack_cutout_H + 2*cutout_clearance)/2])
    cube([port_cutout_depth, usb_stack_cutout_W + 2*cutout_clearance, usb_stack_cutout_H + 2*cutout_clearance], center=true);
}

// Ethernet Cutout
module eth_cutout() {
  translate([base_outer_L/2 - port_cutout_depth/2 - overlap, base_outer_W/4, wall_t + (eth_cutout_H + 2*cutout_clearance)/2])
    cube([port_cutout_depth, eth_cutout_W + 2*cutout_clearance, eth_cutout_H + 2*cutout_clearance], center=true);
}

// MicroSD Cutout
module microsd_cutout() {
  translate([base_outer_L/6, -base_outer_W/2 + port_cutout_depth/2 + overlap, wall_t + (microsd_slot_H + 2*cutout_clearance)/2])
    cube([microsd_slot_W + 2*cutout_clearance, port_cutout_depth, microsd_slot_H + 2*cutout_clearance], center=true);
}

// GPIO Slot
module gpio_slot() {
  translate([0, base_outer_W/2 - port_cutout_depth/2 - overlap, base_outer_H - lip_height - (gpio_slot_H + 2*cutout_clearance)/2])
    cube([gpio_slot_L + 2*cutout_clearance, port_cutout_depth, gpio_slot_H + 2*cutout_clearance], center=true);
}

// Vent Slot Top
module vent_slot_top() {
  translate([0, 0, base_outer_H + lid_outer_H - wall_t/2])
    cube([vent_slot_L, vent_slot_W, wall_t + 2*overlap], center=true);
}

// Vent Slot Side
module vent_slot_side() {
  translate([0, base_outer_W/2 - port_cutout_depth/2 - overlap, base_outer_H/2])
    cube([vent_slot_L, port_cutout_depth, vent_slot_W], center=true);
}

// Feet Recess
module feet_recess() {
  translate([0, 0, feet_recess_h/2])
    cylinder(r=feet_recess_d/2, h=feet_recess_h, center=true);
}

// Snap Tab
module snap_tab() {
  translate([base_outer_L/2 - wall_t/2, 0, base_outer_H - snap_h/2])
    cube([snap_t, snap_w, snap_h], center=true);
}

// Base Shell
module base_shell() {
  difference() {
    base_outer();
    base_inner_cavity();
  }
}

// Base with Standoffs
module base_with_standoffs() {
  union() {
    base_shell();
    translate([-mount_hole_pitch_X/2, -mount_hole_pitch_Y/2, 0]) standoff_cyl();
    translate([mount_hole_pitch_X/2, -mount_hole_pitch_Y/2, 0]) standoff_cyl();
    translate([-mount_hole_pitch_X/2, mount_hole_pitch_Y/2, 0]) standoff_cyl();
    translate([mount_hole_pitch_X/2, mount_hole_pitch_Y/2, 0]) standoff_cyl();
  }
}

// Base with Standoffs Drilled
module base_with_standoffs_drilled() {
  difference() {
    base_with_standoffs();
    translate([-mount_hole_pitch_X/2, -mount_hole_pitch_Y/2, 0]) standoff_hole();
    translate([mount_hole_pitch_X/2, -mount_hole_pitch_Y/2, 0]) standoff_hole();
    translate([-mount_hole_pitch_X/2, mount_hole_pitch_Y/2, 0]) standoff_hole();
    translate([mount_hole_pitch_X/2, mount_hole_pitch_Y/2, 0]) standoff_hole();
  }
}

// Base with Ports
module base_with_ports() {
  difference() {
    base_with_standoffs_drilled();
    usb_c_cutout();
    micro_hdmi_cutout();
    av_cutout();
    usb_stack_cutout();
    eth_cutout();
    microsd_cutout();
    gpio_slot();
  }
}

// Base with Feet Recesses
module base_with_feet_recesses() {
  difference() {
    base_with_ports();
    translate([-(base_outer_L/2 - feet_recess_d/2 - wall_t), -(base_outer_W/2 - feet_recess_d/2 - wall_t), 0]) feet_recess();
    translate([(base_outer_L/2 - feet_recess_d/2 - wall_t), -(base_outer_W/2 - feet_recess_d/2 - wall_t), 0]) feet_recess();
    translate([-(base_outer_L/2 - feet_recess_d/2 - wall_t), (base_outer_W/2 - feet_recess_d/2 - wall_t), 0]) feet_recess();
    translate([(base_outer_L/2 - feet_recess_d/2 - wall_t), (base_outer_W/2 - feet_recess_d/2 - wall_t), 0]) feet_recess();
  }
}

// Lip Ring
module lip_ring() {
  difference() {
    lip_ring_outer();
    lip_ring_inner();
  }
}

// Base Complete
module base_complete() {
  union() {
    base_with_feet_recesses();
    lip_ring();
  }
}

// Lid Shell
module lid_shell() {
  difference() {
    lid_outer();
    lid_inner_cavity();
  }
}

// Lid with Top Vents
module lid_with_top_vents() {
  difference() {
    lid_shell();
    union() {
      translate([-vent_slot_pitch, 0, 0]) vent_slot_top();
      translate([0, 0, 0]) vent_slot_top();
      translate([vent_slot_pitch, 0, 0]) vent_slot_top();
    }
  }
}

// Lid Complete
module lid_complete() {
  difference() {
    lid_with_top_vents();
    union() {
      translate([-vent_slot_pitch, 0, 0]) vent_slot_side();
      translate([0, 0, 0]) vent_slot_side();
      translate([vent_slot_pitch, 0, 0]) vent_slot_side();
    }
  }
}

// Base with Snaps
module base_with_snaps() {
  union() {
    base_complete();
    translate([0, -base_outer_W/4, 0]) snap_tab();
    translate([0, base_outer_W/4, 0]) snap_tab();
  }
}

// Case Complete
module case_complete() {
  union() {
    base_with_snaps();
    lid_complete();
  }
}

// Final Output
case_complete();