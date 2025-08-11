local dap = require('dap')

-- Set up explicit log file
dap.set_log_level('TRACE')

local options = {}

-- UI configuration
local dap_ui_status_ok, dapui = pcall(require, "dapui")
if dap_ui_status_ok then
  options.dapui = {
    layouts = {
      {
        elements = {
          'scopes',
          'breakpoints',
          'stacks',
          'watches',
        },
        size = 40,
        position = 'left',
      },
      {
        elements = {
          'repl',
          'console',
        },
        size = 10,
        position = 'bottom',
      },
    },
  }

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end
end

-- Function to find the executable path
local function find_executable()
    -- Check if build.zig exists
    if vim.fn.filereadable('build.zig') == 1 then
        -- Build the project
        print("Building project with 'zig build'...")
        local build_result = vim.fn.system('zig build')
        if vim.v.shell_error ~= 0 then
            print("Build failed: " .. build_result)
            return nil
        end
        -- Look for the executable in zig-out/bin
        local bin_dir = vim.fn.getcwd() .. '/zig-out/bin'
        if vim.fn.isdirectory(bin_dir) == 1 then
            -- Get the project name from the current directory
            local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
            local executable_path = bin_dir .. '/' .. project_name
            if vim.fn.executable(executable_path) == 1 then
                print("Found executable: " .. executable_path)
                return executable_path
            end
            -- If not found by project name, try to find any executable
            local files = vim.fn.readdir(bin_dir)
            for _, file in ipairs(files) do
                local full_path = bin_dir .. '/' .. file
                if vim.fn.executable(full_path) == 1 then
                    print("Found executable: " .. full_path)
                    return full_path
                end
            end
        end
        print("No executable found in zig-out/bin")
        return nil
    else
        -- Fallback to single file compilation
        local file_path = vim.fn.expand('%:p')
        local output_path = vim.fn.expand('%:p:r')
        -- Build with debug info
        local build_cmd = 'zig build-exe -O Debug ' .. file_path
        print("Building single file with command: " .. build_cmd)
        local result = vim.fn.system(build_cmd)
        if vim.v.shell_error ~= 0 then
            print("Build failed: " .. result)
            return nil
        end
        print("Build successful. Program path: " .. output_path)
        return output_path
    end
end

-- LLDB configuration for Zig
options.adapters = {
    lldb = {
        type = 'executable',
        command = '/usr/bin/lldb-dap-18', -- Adjust this path if needed
        name = 'lldb'
    }
}

options.configurations = {
    zig = {
        {
            name = 'Launch Zig Debug',
            type = 'lldb',
            request = 'launch',
            program = find_executable,
            cwd = '${workspaceFolder}',
            stopOnEntry = false, -- Changed to false to avoid stopping at _start
            stopAtEntry = false, -- Additional setting to prevent stopping at entry
            runInTerminal = false,
            initCommands = {
                'settings set target.disable-aslr false', -- Help with source mapping
                'b main', -- Set a breakpoint at main automatically
            },
            args = {},
        },
    }
}

-- Debug signs configuration
options.signs = {
    DapBreakpoint = { text = "●", texthl = "DapBreakpoint" },
    DapBreakpointCondition = { text = "◆", texthl = "DapBreakpointCondition" },
    DapLogPoint = { text = "◆", texthl = "DapLogPoint" },
    DapStopped = { text = "▶", texthl = "DapStopped" },
}

vim.cmd([[
    hi DapBreakpoint guifg=#993939
    hi DapBreakpointCondition guifg=#F7B737
    hi DapLogPoint guifg=#61AFEF
    hi DapStopped guifg=#98C379
]])

-- Apply signs
for name, sign in pairs(options.signs) do
    vim.fn.sign_define(name, sign)
end

-- Apply signs
for name, sign in pairs(options.signs) do
    vim.fn.sign_define(name, sign)
end

return options
