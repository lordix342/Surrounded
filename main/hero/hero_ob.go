components {
  id: "controller"
  component: "/main/hero/hero.script"
}
embedded_components {
  id: "weapon_factory"
  type: "factory"
  data: "prototype: \"/main/weapons/weapon.go\"\n"
  ""
}
embedded_components {
  id: "sprite"
  type: "sprite"
  data: "default_animation: \"hero_main\"\n"
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
embedded_components {
  id: "aura_sprite"
  type: "sprite"
  data: "default_animation: \"aura_circle\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.035
  }
}
embedded_components {
  id: "fire_rim"
  type: "sprite"
  data: "default_animation: \"aura_fire\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.038
  }
}
embedded_components {
  id: "fire_wave_1"
  type: "sprite"
  data: "default_animation: \"aura_fire\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.039
  }
}
embedded_components {
  id: "fire_wave_2"
  type: "sprite"
  data: "default_animation: \"aura_fire\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.040
  }
}
embedded_components {
  id: "frost_wave_1"
  type: "sprite"
  data: "default_animation: \"aura_frost\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.041
  }
}
embedded_components {
  id: "frost_wave_2"
  type: "sprite"
  data: "default_animation: \"aura_frost\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.042
  }
}
embedded_components {
  id: "frost_wave_3"
  type: "sprite"
  data: "default_animation: \"aura_frost\"\n"
  "material: \"/builtins/materials/sprite.material\"\n"
  "textures {\n"
  "  sampler: \"texture_sampler\"\n"
  "  texture: \"/main/game.atlas\"\n"
  "}\n"
  ""
  position {
    z: 0.043
  }
}
embedded_components {
  id: "collisionobject"
  type: "collisionobject"
  data: "type: COLLISION_OBJECT_TYPE_KINEMATIC\n"
  "mass: 0.0\n"
  "friction: 0.1\n"
  "restitution: 0.0\n"
  "group: \"default\"\n"
  "mask: \"walls\"\n"
  "mask: \"enemy\"\n"
  "embedded_collision_shape {\n"
  "  shapes {\n"
  "    shape_type: TYPE_SPHERE\n"
  "    position {\n"
  "      y: -1.0\n"
  "    }\n"
  "    rotation {\n"
  "    }\n"
  "    index: 0\n"
  "    count: 1\n"
  "  }\n"
  "  data: 7.0\n"
  "}\n"
  ""
}
embedded_components {
  id: "camera"
  type: "camera"
  data: "aspect_ratio: 1.0\n"
  "fov: 0.7854\n"
  "near_z: -1.0\n"
  "far_z: 1000.0\n"
  "auto_aspect_ratio: 1\n"
  "orthographic_projection: 1\n"
  ""
}
