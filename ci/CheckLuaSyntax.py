from pathlib import Path
import subprocess,sys
# Compile tracked Lua files without executing them; NUL separators preserve file names.
files=subprocess.check_output(["git","ls-files","-z","--","*.lua"])
check=r"""local count,errors=0,0
local files=io.read("*a")
for path in files:gmatch("([^%z]+)%z") do
  count=count+1
  local chunk,message=loadfile(path)
  if not chunk then errors=errors+1;io.stderr:write(message,"\n") end
end
print(string.format("Lua syntax: %d files, %d errors",count,errors))
if count==0 or errors>0 then os.exit(1) end
"""
result=subprocess.run(["luajit","-e",check],input=files)
sys.exit(result.returncode)
