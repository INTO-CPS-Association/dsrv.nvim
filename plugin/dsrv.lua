if vim.g.loaded_dsrv_nvim == 1 then
  return
end
vim.g.loaded_dsrv_nvim = 1

require("dsrv").setup(vim.g.dsrv_nvim_config or {})
