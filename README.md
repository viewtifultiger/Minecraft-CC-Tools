# Computer Craft: Tweaked - Kusanagi's Toolkit

A toolkit for the Minecraft mod, Computer Craft: Tweaked.

features:
  1. Tools:
     module context_builder: -> ghost
         creates context, validates for context table structures, and contains dig_config (digging configurations) and turtle_states (mining statistics such as fuel, blocks mined, facing direction, etc).
     module hole_2x2:
         methods include dig_hole_up, dig_hole_down, and dig_2x2_square that serve as configurable tools for automated vertical block-grid digging
  3. Scripts:
    - dig_2x2_hole
       * Automation: Creates a ghost and digs any number of 2x2 holes, avoids bedrock, and tracks ghost statistics -> prints ghost context
       * Efficiency: Once an iteration is complete the next square hole on the left/right will be mined from bottom-up every 2nd iteration
       * Configuration: Accepts shell coordinates, facing direction, next hole direction, and iterations (# of holes)
