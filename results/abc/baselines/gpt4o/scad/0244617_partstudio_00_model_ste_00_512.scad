module block_with_boss() {
    // Dimensions
    block_length = 40;
    block_width = 20;
    block_height = 10;
    boss_diameter = 10;
    boss_height = 5;
    
    // Create block
    block = cube([block_length, block_width, block_height], center=true);
    
    // Create boss
    boss = translate([0, 0, block_height/2]) 
           cylinder(h=boss_height, d=boss_diameter, center=false, $fn=64);
    
    // Combine block and boss
    union() {
        block;
        boss;
    }
}

// Call the module
block_with_boss();