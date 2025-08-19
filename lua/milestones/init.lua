local M = {}

function M.setup() end

function M.info_and_go()
  local word = vim.fn.expand("<cword>")
  local params = vim.lsp.util.make_position_params(0, "utf-16")

  -- 1) Hover (type/signature/doc first line)
  local hover = ""
  local hres = vim.lsp.buf_request_sync(0, "textDocument/hover", params, 300)
  if hres then
    for _, r in pairs(hres) do
      if r.result and r.result.contents then
        local lines = vim.lsp.util.convert_input_to_markdown_lines(r.result.contents) or {}
        if #lines > 0 then
          hover = (table.concat(lines, " "):gsub("\n", " "))
          if #hover > 140 then
            hover = hover:sub(1, 137) .. "..."
          end
          break
        end
      end
    end
  end

  -- 2) Kind (method/variable/function/…): pick the first workspace match
  local KIND = {
    [5] = "Class",
    [6] = "Method",
    [7] = "Property",
    [8] = "Field",
    [9] = "Constructor",
    [10] = "Enum",
    [11] = "Interface",
    [12] = "Function",
    [13] = "Variable",
    [22] = "EnumMember",
    [23] = "Struct",
    [25] = "Operator",
  }
  local kind_tag = ""
  local wres = vim.lsp.buf_request_sync(0, "workspace/symbol", { query = word }, 300)
  if wres then
    for _, r in pairs(wres) do
      local arr = r.result
      if type(arr) == "table" and arr[1] and arr[1].kind then
        kind_tag = "[" .. (KIND[arr[1].kind] or ("kind#" .. arr[1].kind)) .. "] "
        break
      end
    end
  end

  -- 3) Print + jump
  print(kind_tag .. word)
  vim.lsp.buf.definition()
end

return M
