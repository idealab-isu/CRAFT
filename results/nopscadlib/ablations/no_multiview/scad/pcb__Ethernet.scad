// A 3D printer control board, 33.8mm x 37.5mm, 1.6mm thick
// Structural fix: make the base ONLY a thin PCB (1.6mm) with through mounting holes.
// Keep the overall silhouette clean and board-like. No thick housing/steps.
// All geometry is a single connected solid (PCB + optional very thin silkscreen layer).

$fn = 64;

// ---------------- Parameters ----------------
pcb_length    = 37.5;
pcb_width     = 33.8;
pcb_thickness = 1.6;

corner_radius = 2.0;

mount_hole_diameter      = 3.2;
mount_hole_edge_offset_x = 3.5;
mount_hole_edge_offset_y = 3.5;

// Extra cut height to guarantee through-holes even with CGAL tolerances
hole_through_extra = 1.0;

// Optional: very thin top layer to hint "PCB" (kept subtle; does not change board thickness meaningfully)
silkscreen_thickness = 0.2;

// Small overlap to ensure union is watertight (silkscreen intersects PCB)
overlap = 0.6;

// ---------------- Helpers ----------------
module rounded_rect_2d(l, w, r){
  r2 = min(r, min(l,w)/2);
  hull() {
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(l/2 - r2), sy*(w/2 - r2)]) circle(r=r2);
  }
}

module pcb_plate(){
  linear_extrude(height=pcb_thickness, center=true)
    rounded_rect_2d(pcb_length, pcb_width, corner_radius);
}

module mount_hole(){
  cylinder(h=pcb_thickness + hole_through_extra, r=mount_hole_diameter/2, center=true);
}

module silkscreen_layer(){
  // Slightly inset from edges; very thin; intersects PCB for single solid
  cube([pcb_length - 2, pcb_width - 2, silkscreen_thickness], center=true);
}

// ---------------- Model ----------------
module pcb_with_holes(){
  difference() {
    pcb_plate();

    // 4 mounting holes (through-cut)
    for (sx=[-1,1], sy=[-1,1])
      translate([sx*(pcb_length/2 - mount_hole_edge_offset_x),
                 sy*(pcb_width/2  - mount_hole_edge_offset_y),
                 0])
        mount_hole();
  }
}

module control_board(){
  union() {
    pcb_with_holes();

    // Optional subtle top layer (kept thin and intersecting so it's one solid)
    translate([0, 0, pcb_thickness/2 + silkscreen_thickness/2 - overlap])
      silkscreen_layer();
  }
}

// Final output
color([0.0, 0.4, 0.2]) control_board();