components {
  id: "script"
  component: "/main/fx/xp_gem.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"xp_gem\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.08
  }
}
