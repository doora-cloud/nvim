return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      virtual_text = true,
      diagnostics = true,
    },
    diagnostics = {
      virtual_text = true,
      virtual_lines = true,
      update_in_insert = false,
      underline = true,
      severity_sort = true,
    },
  },
}
