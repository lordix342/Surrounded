components {
  id: "controller"
  component: "/main/weapons/chest.script"
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"chest_closed\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.1
  }
}
