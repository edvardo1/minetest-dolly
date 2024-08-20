-- the following code was borrowed then modified from advtrains in 2024-08-20
--   changes include changing variable names to fit the rest of the code
--   and include every slot even if it is empty
-- advtrains inventory serialization helper (c) 2017 orwell96
local function serialize_inventory(inventory)
   local serialized_inventory = {}

   local lists = inventory:get_lists()
   for list_name, list in pairs(lists) do
      serialized_inventory[list_name] = {}
      for index, item in ipairs(list) do
         local item_string = item:to_string()
         serialized_inventory[list_name][index] = item_string
      end
   end

   return minetest.serialize(serialized_inventory)
end

local function deserialize_inventory(serialized_inventory, inventory)
   local deserialized_lists = minetest.deserialize(serialized_inventory)
   if deserialized_lists then
      inventory:set_lists(deserialized_lists)
      return true
   end
   return false
end
-- end of borrowed/modified code

local function get_dolly_texture_and_name(node_name) 
   local dolly_textures = {
      ["mcl_chests:chest_small"] = {"dolly_chest.png", "Dolly with Chest"},
      ["default:chest"]          = {"dolly_chest.png", "Dolly with Chest"}
   }

   local texture_name = dolly_textures[node_name]
   if not texture_name then
      texture_name = {"dolly_unknown.png", "Dolly with ????"}
   end

   local texture = texture_name[1]
   local name = texture_name[2]

   return texture, name
end

minetest.register_tool(
   "dolly:dolly",
   {
      description = "Dolly",
      inventory_image = "dolly_empty.png",

      tool_capabilities = {
         full_punch_interval = 1,
         max_drop_level = 1,
         groupcaps = {
            cracky = {times = {[1] = 9999, [2] = 9999, [3] = 9999}, uses = 0, maxlevel = 0},
            crumbly = {times = {[1] = 9999, [2] = 9999, [3] = 9999}, uses = 0, maxlevel = 0},
            snappy = {times = {[1] = 9999, [2] = 9999, [3] = 9999}, uses = 0, maxlevel = 0},
         },
         damage_groups = {fleshy=2},
      },

      on_place = function(itemstack, user, pointed_thing)
         local itemstack_meta = itemstack:get_meta()

         if itemstack_meta:get_string("carrying") == "true" then
            local nodedata = itemstack_meta:get_string("nodedata")
            local invdata  = itemstack_meta:get_string("invdata")
            itemstack_meta:set_string("carrying", "false")

            itemstack_meta:set_string("inventory_image", "dolly_empty.png")
            itemstack_meta:set_string("wield_image", "dolly_empty.png")
            itemstack_meta:set_string("description", "Dolly")

            local node = minetest.deserialize(nodedata)

            minetest.set_node(pointed_thing.above, node)

            local inv = minetest.get_inventory({ type="node", pos=pointed_thing.above })
            if inv then
               deserialize_inventory(invdata, inv)
            end

            user:get_inventory():set_stack("main", user:get_wield_index(), itemstack)
         else
            local node = minetest.get_node(pointed_thing.under)

            local conversion_table = {
               ["mcl_chests:chest_left"] = "mcl_chests:chest_small",
               ["mcl_chests:chest_right"] = "mcl_chests:chest_small",
               ["mcl_chests:trapped_chest_left"] = "mcl_chests:chest_small",
               ["mcl_chests:trapped_chest_right"] = "mcl_chests:chest_small",
               ["mcl_chests:chest_small"] = "mcl_chests:chest_small",
            }

            if conversion_table[node.name] then
               node.name = conversion_table[node.name]
            end

            local inv = minetest.get_inventory({ type = "node", pos=pointed_thing.under })

            if node.name ~= nil and inv then

               local nodedata = minetest.serialize(node)
               local invdata = serialize_inventory(inv)

               itemstack_meta:set_string("nodedata", nodedata)
               itemstack_meta:set_string("invdata", invdata)
               itemstack_meta:set_string("carrying", "true")

               local texture, name = get_dolly_texture_and_name(node.name)
               itemstack_meta:set_string("inventory_image", texture)
               itemstack_meta:set_string("wield_image", texture)
               itemstack_meta:set_string("description", name)

               minetest.remove_node(pointed_thing.under)
            end
         end

         user:get_inventory():set_stack("main", user:get_wield_index(), itemstack)
      end
})

if minetest.get_modpath("default") then
   minetest.register_craft({
         output = "dolly:dolly",
         recipe = {
            { "default:stick", "", "default:stick" },
            { "default:stick", "", "default:stick" },
            { "default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
         }
   })
end

if minetest.get_modpath("mcl_core") then
   minetest.register_craft({
         output = "dolly:dolly",
         recipe = {
            { "mcl_core:stick", "", "mcl_core:stick" },
            { "mcl_core:stick", "", "mcl_core:stick" },
            { "mcl_core:iron_ingot", "mcl_core:iron_ingot", "mcl_core:iron_ingot"}
         }
   })
end
