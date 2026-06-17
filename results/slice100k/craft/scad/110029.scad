// Dimension-calibrated (target: 4.00 x 20.75 x 4.00 mm)
scale([0.935620, 0.933420, 0.644515])
{
// Parameters
L = 20.75; //[10.0:41.5:0.05]
W = 4.0; //[2.0:8.0:0.05]
H = 4.0; //[2.0:8.0:0.05]
body_d = 4.0; //[2.0:4.0:0.05]
slot_depth = 2.6; //[1.3:5.2:0.05]
slot_width = 2.0; //[1.0:3.6:0.05]
prong_thk = 1.0; //[0.6:1.8:0.05]
end_taper_len = 1.2; //[0.6:2.4:0.05]
tip_chamfer = 0.25; //[0.1:0.6:0.05]
overlap = 0.8; //[0.5:2.0:0.05]
taper_d_reduction = 0.5; //[0.2:1.0:0.05]
edge_break_r = 0.15; //[0.05:0.35:0.05]
slot_blend_r = 0.2; //[0.05:0.5:0.05]

// Main cylindrical body
module main_cylindrical_body() {
  rotate([0, 90, 0])
    cylinder(r=body_d/2, h=L, center=true);
}

// End transitions (taper or fillet)
module end_transitions_taper_or_fillet_A() {
  translate([-(L/2 - end_taper_len/2), 0, 0])
    rotate([0, 90, 0])
      cylinder(r1=body_d/2, r2=(body_d/2 - taper_d_reduction), h=end_taper_len, center=true);
}

module end_transitions_taper_or_fillet_B() {
  translate([(L/2 - end_taper_len/2), 0, 0])
    rotate([0, -90, 0])
      cylinder(r1=body_d/2, r2=(body_d/2 - taper_d_reduction), h=end_taper_len, center=true);
}

// Fork slots
module end_fork_slot_A() {
  translate([-(L/2 - slot_depth/2), 0, 0])
    cube([slot_depth + overlap, slot_width, H + 2*overlap], center=true);
}

module end_fork_slot_B() {
  translate([(L/2 - slot_depth/2), 0, 0])
    cube([slot_depth + overlap, slot_width, H + 2*overlap], center=true);
}

// Prongs
module prongs_end_A() {
  translate([-(L/2 - slot_depth/2), 0, 0])
    cube([slot_depth, W, H], center=true);
}

module prongs_end_B() {
  translate([(L/2 - slot_depth/2), 0, 0])
    cube([slot_depth, W, H], center=true);
}

// Prong tip chamfers or rounding
module prong_tip_chamfers_or_rounding() {
  translate([-(L/2 - tip_chamfer/2), 0, 0])
    cube([tip_chamfer + overlap, W + 2*overlap, H + 2*overlap], center=true);
}

module prong_tip_chamfers_or_rounding_B() {
  translate([(L/2 - tip_chamfer/2), 0, 0])
    cube([tip_chamfer + overlap, W + 2*overlap, H + 2*overlap], center=true);
}

// Small edge breaks on outer edges
module small_edge_breaks_on_outer_edges() {
  sphere(r=edge_break_r, center=true);
}

// Cosmetic fillet blends on slot edges
module cosmetic_fillet_blends_on_slot_edges() {
  sphere(r=slot_blend_r, center=true);
}

// Final assembly
module final_assembly() {
  difference() {
    union() {
      union() {
        main_cylindrical_body();
        end_transitions_taper_or_fillet_A();
        end_transitions_taper_or_fillet_B();
        prongs_end_A();
        prongs_end_B();
      }
      minkowski() {
        end_fork_slot_A();
        cosmetic_fillet_blends_on_slot_edges();
      }
      minkowski() {
        end_fork_slot_B();
        cosmetic_fillet_blends_on_slot_edges();
      }
    }
    prong_tip_chamfers_or_rounding();
    prong_tip_chamfers_or_rounding_B();
  }
}

// Apply small edge breaks
minkowski() {
  final_assembly();
  small_edge_breaks_on_outer_edges();
}
}
