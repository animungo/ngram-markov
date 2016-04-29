-- Check if a file exists, http://stackoverflow.com/questions/11201262/how-to-read-data-from-a-file-in-lua
function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

grams = {}

-- Extract ngrams from string
function ngram(string, start, length)
  gram = string.sub(string, start, start + length - 1)
  
  if grams[gram] ~= nil then
    grams[gram] = grams[gram] + 1
  else
    grams[gram] = 1
  end
  
  if string.len(string) > start + length then
    ngram(string, start + 1, length)
  end
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

ngram(content, 1, 2)

for key,value in pairs(grams) do
  io.write(key .. ' ' .. value .. '\n')
end
