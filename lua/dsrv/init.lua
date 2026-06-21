local M = {}

local defaults = {
  lsp = {
    enable = true,
    cmd = { "dsrv-lsp" },
    root_markers = { "dsrv.toml", ".git" },
  },
  treesitter = {
    enable = true,
    register_parser = true,
    parser_url = nil,
  },
  runner = {
    checker_cmd = "trustworthiness_checker",
    parser = "lalr",
    language = "dsrv",
    default_input_extension = ".input",
    terminal_cmd = "botright split | terminal ",
  },
}

M.config = vim.deepcopy(defaults)

local function merge_config(opts)
  M.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
end

local function plugin_root()
  local source = debug.getinfo(1, "S").source:sub(2)
  return vim.fn.fnamemodify(source, ":h:h:h")
end

local function joinpath(...)
  if vim.fs and vim.fs.joinpath then
    return vim.fs.joinpath(...)
  end
  return table.concat({ ... }, "/")
end

local function executable_or_notify(cmd)
  local exe = type(cmd) == "table" and cmd[1] or cmd
  if vim.fn.executable(exe) == 1 then
    return true
  end
  vim.notify("DSRV executable not found: " .. exe, vim.log.levels.ERROR)
  return false
end

local function current_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file path", vim.log.levels.ERROR)
    return nil
  end
  return file
end

local function default_input_for(model_file)
  return vim.fn.fnamemodify(model_file, ":r") .. M.config.runner.default_input_extension
end

local function shellescape(value)
  return vim.fn.shellescape(value)
end

local function run_checker(model_file, input_file, semantics)
  local checker = M.config.runner.checker_cmd
  local checker_exe = type(checker) == "table" and checker[1] or checker
  if vim.fn.executable(checker_exe) ~= 1 and vim.fn.filereadable(checker_exe) ~= 1 then
    vim.notify("DSRV checker executable not found: " .. checker_exe, vim.log.levels.ERROR)
    return
  end

  if vim.fn.filereadable(input_file) ~= 1 then
    vim.notify("Input file not found: " .. input_file, vim.log.levels.ERROR)
    return
  end

  local cmd = table.concat({
    shellescape(checker_exe),
    "--parser",
    shellescape(M.config.runner.parser),
    "--language",
    shellescape(M.config.runner.language),
    "--semantics",
    shellescape(semantics),
    "--input-file",
    shellescape(input_file),
    shellescape(model_file),
  }, " ")

  vim.cmd(M.config.runner.terminal_cmd .. cmd)
end

function M.run_current_file()
  local model_file = current_file()
  if not model_file then
    return
  end
  run_checker(model_file, default_input_for(model_file), "untimed")
end

function M.run_with_types()
  local model_file = current_file()
  if not model_file then
    return
  end
  run_checker(model_file, default_input_for(model_file), "typed-untimed")
end

function M.run_with_input()
  local model_file = current_file()
  if not model_file then
    return
  end
  vim.ui.input({ prompt = "DSRV input file: ", default = default_input_for(model_file), completion = "file" }, function(input_file)
    if input_file and input_file ~= "" then
      run_checker(model_file, vim.fn.fnamemodify(input_file, ":p"), "untimed")
    end
  end)
end

function M.run_with_input_and_types()
  local model_file = current_file()
  if not model_file then
    return
  end
  vim.ui.input({ prompt = "DSRV input file: ", default = default_input_for(model_file), completion = "file" }, function(input_file)
    if input_file and input_file ~= "" then
      run_checker(model_file, vim.fn.fnamemodify(input_file, ":p"), "typed-untimed")
    end
  end)
end

function M.register_treesitter_parser()
  if not M.config.treesitter.register_parser then
    return
  end

  local ok, parsers = pcall(require, "nvim-treesitter.parsers")
  if not ok then
    return
  end

  local parser_config = parsers.get_parser_configs()
  local parser_url = M.config.treesitter.parser_url or "https://github.com/INTO-CPS-Association/tree-sitter-dsrv.git"
  parser_config.dsrv = parser_config.dsrv or {}
  parser_config.dsrv.install_info = {
    url = parser_url,
    files = { "src/parser.c" },
    branch = "main",
    generate_requires_npm = false,
    requires_generate_from_grammar = false,
  }
  parser_config.dsrv.filetype = "dsrv"
end

function M.start_lsp(bufnr)
  if not M.config.lsp.enable then
    return
  end

  local cmd = M.config.lsp.cmd
  if not executable_or_notify(cmd) then
    return
  end

  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local bufname = vim.api.nvim_buf_get_name(bufnr)
  local root_dir = nil

  if vim.fs and vim.fs.root then
    root_dir = vim.fs.root(bufname, M.config.lsp.root_markers)
  end
  root_dir = root_dir or vim.fn.getcwd()

  vim.lsp.start({
    name = "dsrv-lsp",
    cmd = cmd,
    root_dir = root_dir,
  }, { bufnr = bufnr })
end

function M.setup_commands()
  vim.api.nvim_create_user_command("DsrvRun", M.run_current_file, {
    desc = "Run current DSRV file with the default .input file",
    force = true,
  })
  vim.api.nvim_create_user_command("DsrvRunWithInput", M.run_with_input, {
    desc = "Run current DSRV file with a chosen input file",
    force = true,
  })
  vim.api.nvim_create_user_command("DsrvRunTyped", M.run_with_types, {
    desc = "Run current DSRV file with typed semantics and the default .input file",
    force = true,
  })
  vim.api.nvim_create_user_command("DsrvRunTypedWithInput", M.run_with_input_and_types, {
    desc = "Run current DSRV file with typed semantics and a chosen input file",
    force = true,
  })
end

function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup("dsrv.nvim", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "dsrv",
    callback = function(args)
      vim.bo[args.buf].commentstring = "// %s"
      vim.bo[args.buf].comments = "s:(*,m:*,e:*),://"

      if M.config.treesitter.enable then
        pcall(vim.treesitter.start, args.buf, "dsrv")
      end

      M.start_lsp(args.buf)
    end,
  })
end

function M.setup(opts)
  merge_config(opts)

  vim.filetype.add({
    extension = {
      dsrv = "dsrv",
    },
  })

  M.register_treesitter_parser()
  M.setup_commands()
  M.setup_autocmds()
end

return M
