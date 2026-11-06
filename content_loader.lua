local lyaml = require("lyaml")

local function multi_print(content)
  print(content)
  tex.print(content)
end

-- Function to load and parse YAML file
local function load_yaml_file(filename)
    -- Read the contents of the file
    local file = io.open(filename, "r")
    if not file then
        error("Could not open file " .. filename)
    end

    local content = file:read("*all")
    file:close()

    -- Parse YAML content
    local data = lyaml.load(content)
    return data
end

local function handle_level(data, index)
  local items = {}
  for i = index, #data do
    local item_type = type(data[i])
    if item_type == "string" then
      table.insert(items, string.format([[\cvitem{%s}]], data[i]))
    elseif item_type == "table" then
      for kk, vv in pairs(data[i]) do
        table.insert(items, string.format(
          [[\cvnesteditem{%s}{%s}]], kk, handle_level(vv, 1)
        ))
      end
    end
  end
  return table.concat(items, " ")
end


local function cvevent(yaml_data)
  for _, post in pairs(yaml_data) do
    local item_start_index = 4
    local summary = ""
    if type(post[item_start_index]) == "table" and post[item_start_index]["Summary"] then
      summary = post[item_start_index]["Summary"][1]
      item_start_index = item_start_index + 1
    end
    multi_print(string.format(
      [[\cvevent{%s}{%s}{%s}{%s}{%s}]],
      post[3], post[1], post[2], summary, handle_level(post, item_start_index)
    ))
  end
end

local function handle_metadata_level(key, value, element, unpack)
  local element_family_flat = flatten_metadata(value, false)
  if unpack then
    multi_print(string.format([[\metadatarow{%s}{%s}]], key, element_family_flat))
  else
    table.insert(element, string.format([[\metadataentry{%s}{%s}]], key, element_family_flat))
  end
end



function flatten_metadata(subject, unpack)
  if type(subject) == "table" then
    if unpack then
      multi_print("\\begin{cvmetadata}")
    end
    local element = {}
    for k, v in pairs(subject) do
      if type(k) == "number" then
        if type(v) == "table" then
          for ki, vi in pairs(v) do
            handle_metadata_level(ki, vi, element, unpack)
          end
        else
          table.insert(element, v)
        end
      else
        handle_metadata_level(k, v, element, unpack)
      end
    end
    
    if unpack then
      multi_print("\\end{cvmetadata}")
    end

    return table.concat(element, "\\metadataseparator{}")
  else
    return subject
  end
end

local function get_profile_text(profile, field)
  local value = profile[field]
  if type(value) ~= "string" or not value:match("%S") then
    return ""
  end
  return value
end

local function create_profile_header(profile)
  multi_print(string.format(
    [[\profileheader{%s}{%s}{%s}{%s}]],
    profile.residence,
    profile.email,
    profile.phone,
    profile.name
  ))
end

local function simple_list(yaml_data)
  multi_print("\\begin{bibsection}")
  for k, v in pairs(yaml_data) do
    multi_print(string.format(
      [[\publicationentry{%s}{%s}]], v["author"], v["title"]
    ))
  end
  multi_print("\\end{bibsection}")
end

--require("lldebugger").start()
local yaml_data = load_yaml_file(spec)

-- Load the YAML file and print the parsed data
if target == "education" or target == "experience" then
  cvevent(yaml_data[target])
elseif target == "metasection" then
  flatten_metadata(yaml_data[target], true)
elseif target == "profile" then
  create_profile_header(yaml_data[target])
elseif target == "headline" then
  token.set_macro("profileheadline", get_profile_text(yaml_data["profile"], "headline"))
  token.set_macro("profilespecializations", get_profile_text(yaml_data["profile"], "specializations"))
elseif target == "image" then
  local image = get_profile_text(yaml_data["profile"], "image")
  if image ~= "" and image:sub(1, 1) ~= "/" then
    image = (spec:match("^(.*[/])") or "") .. image
  end
  token.set_macro("profileimage", image)
elseif target == "summary_statement" then
  multi_print(yaml_data["profile"]["summary"])
elseif target == "publications" then
  simple_list(yaml_data[target])
end
