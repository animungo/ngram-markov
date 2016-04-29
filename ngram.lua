-- Check if a file exists, http://stackoverflow.com/questions/11201262/how-to-read-data-from-a-file-in-lua
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function register_gram_with_predecessor(table, predecessor, gram)
  if table[predecessor] ~= nil then
    if table[predecessor][gram] ~= nil then
      table[predecessor][gram] = table[predecessor][gram] + 1
    else
      table[predecessor][gram] = 1
    end
  else
    table[predecessor] = {}
    table[predecessor][gram] = 1
  end
end

function output_table(filename, table)
  io.output(filename)
  
  for predecessor, grams in pairs(table) do
    io.write(predecessor .. ':\n')
    
    for gram, value in pairs(grams) do
      io.write('  ' .. gram .. ': ' .. value .. '\n')
    end
  end
  
  io.output(io.stdout)
end

-- Check if script is used correctly
if arg[1] == nil or file_exists(arg[1]) == false then
	io.write('Usage: lua SCRIPTFILENAME INPUTFILENAME' .. '\n')
	os.exit()
end

-- Set input to specific file
io.input('input.txt');

-- Read complete file and remove linebreaks
content = string.gsub(io.read('*all'), '\n', '')

start = 1
starters = {}
grams = {}

lastgram3 = nil
lastgram2 = nil

while start < string.len(content) do
  gram3 = string.sub(content, start, start + 2)
  gram2 = string.sub(gram3, 1, 2)
  starter = string.sub(gram2, 1, 1)
  
  if lastgram3 ~= nil then
    register_gram_with_predecessor(grams, lastgram3, gram3)
    register_gram_with_predecessor(grams, lastgram3, gram2)
  end
  
  if lastgram2 ~= nil then
    register_gram_with_predecessor(grams, lastgram2, gram3)
    register_gram_with_predecessor(grams, lastgram2, gram2)
  end
  
  register_gram_with_predecessor(starters, starter, gram3)
  register_gram_with_predecessor(starters, starter, gram2)
    
  lastgram3 = gram3
  lastgram2 = gram2
  
  start = start + 1
end

output_table('starters', starters)
output_table('grams', grams)
