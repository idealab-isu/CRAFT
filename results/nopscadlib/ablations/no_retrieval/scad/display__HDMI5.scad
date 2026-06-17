// Parameters
pcb_L = 121; //[60.5:242:1]
pcb_W = 76; //[38:152:1]
pcb_T = 2.85; //[1.4:5.7:0.05]
pcb_offset_X = 0; //[-30:30:0.5]
pcb_offset_Y = 0; //[-30:30:0.5]
pcb_offset_Z = 1.9; //[0:10:0.1]
aperture_x1 = -54; //[-108:-27:0.5]
aperture_y1 = -30.225; //[-60.45:-15.1125:0.5]
aperture_x2 = 54; //[27:108:0.5]
aperture_y2 = 34.575; //[17.2875:69.15:0.5]
aperture_depth = 0.5; //[0.2:1.5:0.05]
touch_x1 = -58.7; //[-117.4:-29.35:0.5]
touch_y1 = -34; //[-68:-17:0.5]
touch_x2 = 58.7; //[29.35:117.4:0.5]
touch_y2 = 36.25; //[18.125:72.5:0.5]
touch_T = 1; //[0.4:2:0.05]
thread_L = 2; //[1:6:0.5]
ribbon_clear_x1 = -2.5; //[-10:0:0.5]
ribbon_clear_y1 = -39; //[-78:-19.5:0.5]
ribbon_clear_x2 = 10.5; //[0:21:0.5]
ribbon_clear_y2 = -33; //[-66:-16.5:0.5]
eps_overlap = 1; //[0.5:2:0.1]
corner_fillet_r = 3; //[1.5:8:0.5]
bezel_margin = 3; //[1:10:0.5]
bezel_T = 1.2; //[0.6:3:0.1]
bezel_window_margin = 1.5; //[0.5:5:0.1]
connector_depth = 12; //[6:30:1]
connector_height = 6; //[3:15:0.5]
connector_width = 14; //[7:30:0.5]

// Geometry
module pcb_main_body() {
  cube([pcb_L, pcb_W, pcb_T], center=true);
}

module display_aperture_cutout() {
  translate([((aperture_x1 + aperture_x2)/2), ((aperture_y1 + aperture_y2)/2), (pcb_T/2 - aperture_depth/2)])
    cube([(aperture_x2 - aperture_x1), (aperture_y2 - aperture_y1), aperture_depth + eps_overlap], center=true);
}

module touch_ribbon_clearance_keepout() {
  translate([((ribbon_clear_x1 + ribbon_clear_x2)/2), ((ribbon_clear_y1 + ribbon_clear_y2)/2), (pcb_T/2 + touch_T/2 - eps_overlap/2)])
    cube([(ribbon_clear_x2 - ribbon_clear_x1), (ribbon_clear_y2 - ribbon_clear_y1), touch_T + eps_overlap], center=true);
}

module touch_screen_layer() {
  translate([((touch_x1 + touch_x2)/2), ((touch_y1 + touch_y2)/2), (pcb_T/2 + touch_T/2 - eps_overlap)])
    cube([(touch_x2 - touch_x1), (touch_y2 - touch_y1), touch_T], center=true);
}

module mount_hole(position) {
  translate(position)
    cylinder(r=thread_L/2, h=pcb_T + 2*eps_overlap, center=true);
}

module corner_cut_cyl(position) {
  translate(position)
    cylinder(r=corner_fillet_r, h=pcb_T + 2*eps_overlap, center=true);
}

module corner_cut_box(position) {
  translate(position)
    cube([2*corner_fillet_r, 2*corner_fillet_r, pcb_T + 2*eps_overlap], center=true);
}

module bezel_outer() {
  translate([0, 0, (pcb_T/2 + bezel_T/2 - eps_overlap)])
    cube([pcb_L + 2*bezel_margin, pcb_W + 2*bezel_margin, bezel_T], center=true);
}

module bezel_window_cut() {
  translate([((aperture_x1 + aperture_x2)/2), ((aperture_y1 + aperture_y2)/2), (pcb_T/2 + bezel_T/2 - eps_overlap)])
    cube([(aperture_x2 - aperture_x1) - 2*bezel_window_margin, (aperture_y2 - aperture_y1) - 2*bezel_window_margin, bezel_T + 2*eps_overlap], center=true);
}

module connector_placeholder_1() {
  translate([0, (pcb_W/2 + connector_depth/2 - eps_overlap), (pcb_T/2 + connector_height/2 - eps_overlap)])
    cube([connector_width, connector_depth, connector_height], center=true);
}

module connector_placeholder_2() {
  translate([(pcb_L/2 + connector_depth/2 - eps_overlap), 0, (pcb_T/2 + connector_height/2 - eps_overlap)])
    rotate([0, 0, 90])
    cube([connector_width, connector_depth, connector_height], center=true);
}

// Operations
module corner_chamfer_cut(box, cyl) {
  difference() {
    box();
    cyl();
  }
}

module pcb_with_aperture() {
  difference() {
    pcb_main_body();
    display_aperture_cutout();
  }
}

module pcb_with_mount_holes() {
  difference() {
    pcb_with_aperture();
    mount_hole([(pcb_L/2 - 6), (pcb_W/2 - 6), 0]);
    mount_hole([(-pcb_L/2 + 6), (pcb_W/2 - 6), 0]);
    mount_hole([(-pcb_L/2 + 6), (-pcb_W/2 + 6), 0]);
    mount_hole([(pcb_L/2 - 6), (-pcb_W/2 + 6), 0]);
  }
}

module pcb_with_corner_fillets() {
  difference() {
    pcb_with_mount_holes();
    corner_chamfer_cut(() => corner_cut_box([(pcb_L/2 - corner_fillet_r), (pcb_W/2 - corner_fillet_r), 0]), 
                       () => corner_cut_cyl([(pcb_L/2 - corner_fillet_r), (pcb_W/2 - corner_fillet_r), 0]));
    corner_chamfer_cut(() => corner_cut_box([(-pcb_L/2 + corner_fillet_r), (pcb_W/2 - corner_fillet_r), 0]), 
                       () => corner_cut_cyl([(-pcb_L/2 + corner_fillet_r), (pcb_W/2 - corner_fillet_r), 0]));
    corner_chamfer_cut(() => corner_cut_box([(-pcb_L/2 + corner_fillet_r), (-pcb_W/2 + corner_fillet_r), 0]), 
                       () => corner_cut_cyl([(-pcb_L/2 + corner_fillet_r), (-pcb_W/2 + corner_fillet_r), 0]));
    corner_chamfer_cut(() => corner_cut_box([(pcb_L/2 - corner_fillet_r), (-pcb_W/2 + corner_fillet_r), 0]), 
                       () => corner_cut_cyl([(pcb_L/2 - corner_fillet_r), (-pcb_W/2 + corner_fillet_r), 0]));
  }
}

module bezel_outline() {
  difference() {
    bezel_outer();
    bezel_window_cut();
  }
}

module assembly_union_pre_offset() {
  union() {
    pcb_with_corner_fillets();
    touch_screen_layer();
    bezel_outline();
    connector_placeholder_1();
    connector_placeholder_2();
  }
}

translate([pcb_offset_X, pcb_offset_Y, pcb_offset_Z])
  assembly_union_pre_offset();