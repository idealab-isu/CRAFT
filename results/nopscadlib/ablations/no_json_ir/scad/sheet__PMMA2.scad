$fn = 96;

module acrylic_sheet(length=100, width=50, thickness=5, corner_radius=5) {
    // Clamp radius so geometry never inverts/vanishes
    r = min(corner_radius, length/2 - 0.01, width/2 - 0.01);

    // 2D rounded rectangle, then extrude to a single connected solid
    color([0.85, 0.95, 1.0, 0.25])  // acrylic-like translucency (preview/render)
    linear_extrude(height=thickness, center=true, convexity=10)
        offset(r=r)
            square([length - 2*r, width - 2*r], center=true);
}

acrylic_sheet(100, 50, 5, 5);