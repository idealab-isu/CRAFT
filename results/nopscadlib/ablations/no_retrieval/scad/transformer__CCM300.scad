// Parameters
body_L = 120; //[60:240:1]
body_W = 88; //[44:176:1]
body_H = 120; //[60:240:1]
base_thk = 3; //[1.5:6:0.5]
base_overhang = 5; //[2:12:1]
mount_hole_d = 6.5; //[3:10:0.5]
mount_hole_spacing_L = 90; //[45:180:1]
mount_hole_spacing_W = 60; //[30:120:1]
overlap = 1; //[0.5:2:0.5]
fillet_r = 6; //[2:12:1]
lam_rib_thk = 2; //[1:4:0.5]
lam_rib_depth = 1.5; //[0.5:4:0.5]
lam_rib_count = 7; //[3:15:1]
terminal_L = 50; //[25:100:1]
terminal_W = 18; //[10:40:1]
terminal_H = 16; //[8:30:1]
terminal_offset_from_top = 18; //[8:40:1]
wire_d = 4; //[2:8:0.5]
wire_len = 35; //[15:80:1]
wire_count = 4; //[2:8:1]
wire_spacing = 8; //[4:16:1]
label_L = 60; //[30:120:1]
label_W = 40; //[20:88:1]
label_thk = 1.5; //[0.8:4:0.1]
label_offset_from_top = 35; //[10:70:1]

// Transformer Body with Fillets
module transformer_body_fillet() {
  minkowski() {
    cube([body_L - 2*fillet_r, body_W - 2*fillet_r, body_H - 2*fillet_r], center=true);
    sphere(r=fillet_r, center=true);
  }
}

// Mounting Base with Holes
module mounting_base_with_holes() {
  difference() {
    cube([body_L + 2*base_overhang, body_W + 2*base_overhang, base_thk], center=true);
    for (x = [-1, 1])
      for (y = [-1, 1])
        translate([x * mount_hole_spacing_L/2, y * mount_hole_spacing_W/2, 0])
          cylinder(r=mount_hole_d/2, h=base_thk + 2*overlap, center=true);
  }
}

// Lamination Ribs
module lamination_detail() {
  union() {
    for (i = [0:lam_rib_count-1]) {
      translate([0, body_W/2 - lam_rib_depth/2 + overlap, -(lam_rib_count-1)/2 * (body_H - 2*fillet_r)/(lam_rib_count-1) + i*(body_H - 2*fillet_r)/(lam_rib_count-1)])
        cube([body_L - 2*fillet_r, lam_rib_depth, lam_rib_thk], center=true);
    }
  }
}

// Wire Leads
module wire_leads() {
  union() {
    for (i = [-1.5, -0.5, 0.5, 1.5]) {
      translate([i * wire_spacing, body_W/2 + terminal_W + wire_len/2 - overlap, body_H/2 - terminal_offset_from_top])
        rotate([90, 0, 0])
          cylinder(r=wire_d/2, h=wire_len, center=true);
    }
  }
}

// Terminal Block
module terminal_block() {
  translate([0, body_W/2 + terminal_W/2 - overlap, body_H/2 - terminal_offset_from_top - terminal_H/2])
    cube([terminal_L, terminal_W, terminal_H], center=true);
}

// Label Plate
module label_plate() {
  translate([0, body_W/2 + label_thk/2 - overlap, body_H/2 - label_offset_from_top - label_W/2])
    cube([label_L, label_thk, label_W], center=true);
}

// Complete Transformer
module transformer_complete_union() {
  union() {
    mounting_base_with_holes();
    transformer_body_fillet();
    terminal_block();
    wire_leads();
    lamination_detail();
    label_plate();
  }
}

// Final Output
transformer_complete_union();