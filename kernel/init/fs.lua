---@class fs
fs = {}

---Checks whether a file exists
---@param p string
---@return boolean
function fs.exists(p)
    return kernel.disk.exists(p)
end

---Opens a file and returns its content
---@param p string
---@return string
function fs.readFile(p)
    if not fs.exists(p) then error('No such file or directory, '..tostring(p)) end
    local h = kernel.disk.open(p,'r')
    local content = kernel.disk.read(h,math.huge)
    kernel.disk.close(h)
    return content
end

---Returns a list containing all the files in a directory
---@param p string
---@return string[]
function fs.list(p)
    if not fs.exists(p) then error('No such file or directory, '..tostring(p)) end
    return kernel.disk.list(p)
end

---
---@param p string
---@return {size:number,isDirectory:boolean,isFile:boolean,lastModified:number}
function fs.info(p)
    if not fs.exists(p) then error('No such file or directory, '..tostring(p)) end
    local isdir = kernel.disk.isDirectory(p)
    return {
        size = kernel.disk.size(p),
        isDirectory = isdir,
        isFile = not isdir,
        lastModified = kernel.disk.lastModified(p)
    }
end