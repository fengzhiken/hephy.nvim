local M = {}

local plugins_path = vim.fn.stdpath("data") .. "/site/pack/hephy/opt/"

M.plugins = {}

M.download = function(source)
  local name = vim.fn.fnamemodify(source, ":t")
  if vim.fn.isdirectory(plugins_path .. name) == 0 then print("Installing ", name)
    vim.fn.system({ "git", "clone", "--depth=1", "https://github.com/" .. source, plugins_path .. name })
  end
end

M.install_plugin = function(plugin)
  local name = ""
  local source = ""

  if type(plugin) == "table" then
    source = plugin[1]
    name = vim.fn.fnamemodify(source, ":t")

    M.plugins[name] = { source = source }

    local keys = vim.tbl_keys(plugin)
    if vim.tbl_contains(keys, "cmd") or vim.tbl_contains(keys, "ft") or vim.tbl_contains(keys, "event") or vim.tbl_contains(keys, "key") then
      M.plugins[name]["lazy"] = true
    end

    for ind, key in pairs(plugin) do
      if type(ind) == "string" then
        M.plugins[name][ind] = {}
        if type(key) == "table" then
          for _, val in pairs(key) do
            table.insert(M.plugins[name][ind], val)
          end
        elseif type(key) == "function" then
          M.plugins[name][ind] = key
        else
          table.insert(M.plugins[name][ind], key)
        end
      end
    end

    if vim.tbl_contains(vim.tbl_keys(plugin), "dependencies") then
        M.plugins[name]["dependencies"] = {}
      if type(plugin.dependencies) == "table" then
        for _, dependency in ipairs(plugin.dependencies) do
          table.insert(M.plugins[name]["dependencies"], dependency)
          M.download(dependency)
        end
      else
        table.insert(M.plugins[name]["dependencies"], plugin.dependencies)
        M.download(plugin.dependencies)
      end
    end

    M.download(source)
  else
    source = plugin
    name = vim.fn.fnamemodify(plugin, ":t")

    M.plugins[name] = { source = source }

    M.download(source)
  end
end

M.load_plugin_config = function(name)
  if type(M.plugins[name]["config"]) ~= "nil" then
    M.plugins[name]["config"]()
  end
end

M.load_plugin_dependencies = function(name)
  if type(M.plugins[name]["dependencies"]) ~= "nil" then
    for _, dependency in pairs(M.plugins[name]["dependencies"]) do
      local dep_name = vim.fn.fnamemodify(dependency, ":t")
      vim.cmd("packadd " .. dep_name)
    end
  end
end

M.lazy_load_cmd_type_plugin = function(name, plugin)
  for _, cmd in pairs(plugin.cmd) do
    vim.api.nvim_create_user_command(cmd, function()
      vim.api.nvim_del_user_command(cmd)
      M.load_plugin_dependencies(name)
      vim.cmd("packadd " .. name)
      M.plugins[name]["loaded"] = true
      M.load_plugin_config(name)
      vim.cmd(cmd)
    end, {})
  end
end

M.lazy_load_key_type_plugin = function(name, plugin)
  for _, key in pairs(plugin.key) do
    vim.keymap.set("n", key, function()
      vim.keymap.del("n", key)
      M.load_plugin_dependencies(name)
      vim.cmd("packadd " .. name)
      M.plugins[name]["loaded"] = true
      M.load_plugin_config(name)
      vim.api.nvim_input(vim.api.nvim_replace_termcodes(key, true, true, true))
    end, { noremap = true, silent = true })
  end
end

M.lazy_load_event_type_plugin = function(name, plugin)
  for _, event in pairs(plugin.event) do
    vim.api.nvim_create_autocmd(event, {
      callback = function(cmd_type)
        vim.api.nvim_del_autocmd(cmd_type.id)
        M.load_plugin_dependencies(name)
        vim.cmd("packadd " .. name)
        M.plugins[name]["loaded"] = true
        M.load_plugin_config(name)
      end
    })
  end
end

M.lazy_load_ft_type_plugin = function(name, plugin)
  vim.api.nvim_create_autocmd("FileType", {
    pattern = plugin.ft,
    callback = function(cmd_type)
      vim.api.nvim_del_autocmd(cmd_type.id)
      M.load_plugin_dependencies(name)
      vim.cmd("packadd " .. name)
      M.plugins[name]["loaded"] = true
      M.load_plugin_config(name)
    end
  })
end

M.lazy_load_plugin = function(name, plugin, keys)
  for _, key in pairs(keys) do
    if key == "cmd" then
      M.lazy_load_cmd_type_plugin(name, plugin)
    end
    if key == "key" then
      M.lazy_load_key_type_plugin(name, plugin)
    end
    if key == "event" then
      M.lazy_load_event_type_plugin(name, plugin)
    end
    if key == "ft" then
      M.lazy_load_ft_type_plugin(name, plugin)
    end
  end
end

M.load_plugin = function(name, plugin)
  local keys = vim.tbl_keys(plugin)
  M.plugins[name]["loaded"] = false

  if plugin.lazy then
    M.lazy_load_plugin(name, plugin, keys)
  else
    M.load_plugin_dependencies(name)

    vim.cmd("packadd " .. name)
    M.load_plugin_config(name)
    M.plugins[name]["loaded"] = true
  end
end

M.bootstrap = function()
  for name, plugin in pairs(M.plugins) do
    M.load_plugin(name, plugin)
  end
end

M.setup = function(plugins)
  if type(plugins) == "table" then
    for _, plugin in pairs(plugins) do
      M.install_plugin(plugin)
    end
  end
  M.bootstrap()
end

return M
