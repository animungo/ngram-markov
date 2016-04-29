--[[
      "External" functions
--]]

-- Check if a file exists, http://stackoverflow.com/questions/11201262/how-to-read-data-from-a-file-in-lua
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

-- Sum the values of a table, http://stackoverflow.com/questions/8695378/how-to-sum-a-table-of-numbers-in-lua
function sum(t)
  local sum = 0
  for k, v in pairs(t) do
    sum = sum + v
  end
  
  return sum
end



--[[
      Own functions
--]]

--[[
      Store a gram in a table linked to its predecessor and with the absolute amount of occurences in the input text
      
      The resulting table looks like follows:
        table: [
          predecessor: [
            gram: absolute frequency
          ]
        ]
--]]
function register_gram_with_predecessor(table, predecessor, gram)
  -- Check if we alrady have a table for this predecessor
  if table[predecessor] ~= nil then
    -- Check if we already have a value for the gram
    if table[predecessor][gram] ~= nil then
      -- Increase the value for the gram
      table[predecessor][gram] = table[predecessor][gram] + 1
    else
      -- Create the value for the gram
      table[predecessor][gram] = 1
    end
  else
    -- Create table for predecessor and value for gram
    table[predecessor] = {}
    table[predecessor][gram] = 1
  end
end

-- Output a table with "depth" 2 to a file
function output_table(table, filename)
  -- Output to stdout when no filename is provided
  if filename ~= nil then
    io.output(filename)
  end
  
  -- Iterate outer level
  for predecessor, grams in pairs(table) do
    -- Output predecessor currently iterating over
    io.write(predecessor .. ':\n')
    
    -- Iterate inner level
    for gram, value in pairs(grams) do
      -- Output gram and associated value
      io.write('  ' .. gram .. ': ' .. value .. '\n')
    end
  end
  
  io.output(io.stdout)
end

--[[
      Script initialization
--]]

-- Check if script is used correctly
if arg[1] == nil or arg[2] == nil or file_exists(arg[1]) == false  or string.len(arg[2]) ~= 1 then
	io.write('Usage: lua ngram.lua INPUTFILE STARTCHAR GRAMDIVIDER' .. '\n' .. '  INPUTFILE - The file to use' .. '\n' .. '  STARTCHAR - The char to start the markov process with' .. '\n' .. '  GRAMDIVIDER - Optional divider char/string to divide the grams in the output')
	os.exit()
end

-- Read everything from io.stdio and remove linebreaks
io.input(arg[1])
content = string.gsub(io.read('*all'), '\n', ' ')

-- Check if input is long enough
if string.len(content) < 100 then
  io.write('[ERROR] Please provide a sufficiently long input on stdio. It should be at least 100 chars long!')
  os.exit()
end

-- Set default value for divider, if none is provided
divider = ''
if arg[3] ~= nil then
  divider = arg[3]
end

-- Iterate over input to extract grams
starters = {} -- Table that links starters to possible following grams
grams = {}    -- Table that links grams to possible following grams

lastgram3 = nil   -- Helper variable to store 3 gram that is in front of current grams
lastgram2 = nil   -- Helper variable to store 2 gram that is in front of current grams

-- Extract grams and starters (first chars)
for start = 1, string.len(content) do
  -- Extract grams, only extract 3gram from whole string
  gram3 = string.sub(content, start, start + 2)
  gram2 = string.sub(gram3, 1, 2)
  starter = string.sub(gram2, 1, 1)
  
  -- Store extracted grams linked to preceding 3gram
  if lastgram3 ~= nil then
    register_gram_with_predecessor(grams, lastgram3, gram3)
    register_gram_with_predecessor(grams, lastgram3, gram2)
  end
  
  -- Store extracted grams linked to preceding 2gram
  if lastgram2 ~= nil then
    register_gram_with_predecessor(grams, lastgram2, gram3)
    register_gram_with_predecessor(grams, lastgram2, gram2)
  end
  
  -- Store extracted grams linked to starting char
  register_gram_with_predecessor(starters, starter, gram3)
  register_gram_with_predecessor(starters, starter, gram2)
  
  -- Extract preceding 3gram
  if start > 3 then
    lastgram3 = string.sub(content, start - 2, start)
  end
  
  -- Extract preceding 2gram
  if start > 2 then
    lastgram2 = string.sub(content, start - 1, start)
  end
end

-- Initialize possible following grams from start chars
possible_grams = starters[arg[2]]

-- Check if start char is possible
if possible_grams == nil then
  io.write('[ERR] "' .. arg[2] .. '" is not a possible start char. Possible chars are:\n')
  
  -- List possible start chars
  for char, grams in pairs(starters) do
    io.write(char .. ' ')
  end
  os.exit()
end

-- Use current time as seed for random number generator, not really necessary
math.randomseed(os.time())

-- Execute the markov process
for i = 1, 1000 do
  -- Get total amount of linked grams
  limit = sum(possible_grams)
  
  -- Generate random
  random = math.random(limit)
  
  -- Find succeeding gram
  summed_values = 0
  for gram, value in pairs(possible_grams) do
    -- Iterate over possible grams and add the current value to the sum
    summed_values = summed_values + value
    
    -- If random number is now smaller than the sum we have found our succeeding gram
    if random <= summed_values then
      -- Output gram
      io.write(gram, divider)
      
      -- Next possible grams are the grams that followed to the current gram in our input text
      possible_grams = grams[gram]
      
      if possible_grams == nil then 
        -- Output error and exit if there are no possible grams
        -- DEAD END p(X | gram) = 0
        io.write('\n\n[ERR] Reached a dead end! "' .. gram .. '" does not have possible successors!')
      
        os.exit()     
      end
      break
    end
  end
end

-- Output the tables to files for debugging
output_table(starters, 'outputs/starters')
output_table(grams, 'outputs/grams')
