'''
SimpleBuilder
------
A simple c builder

* License: MIT
* Runtime: Python 3.8.10
''' # 这个项目有屎山代码的雏形了……
from os import system
from os.path import join,isfile,basename
from traceback import print_exc as pexc
import json
import time
import sys
import re

__version__ = "2024.08.06-2223"

outdir = ''
reps = {}
fmt = r'^[A-Za-z_][A-Za-z0-9_]*$'
conf_vars = {}

def info(*a):print("INFO:",*a)
def warn(*a):print("WARN:",*a)
def error(*a):print("ERROR:",*a)
def exc():return repr(sys.exc_info()[1])

def fmtstr(string:str):
    rep = {
        '${tick}':str(time.time_ns()),
        '${outdir}':outdir
    }
    for k,v in conf_vars.items():
        rep['${var.%s}'%k] = v
    for k,v in reps.items():
        rep[k] = v
    for k,v in rep.items():
        string = string.replace(k,v)
    return string

# item.%s.type
# item.%s.out
# item.%s.src
# item.%s.ld
# item.%s.ld_o
# item.%s.ld_m

def outfile(dir,src:str):
    #return join(dir,src.replace('/','!').replace('\\','!'))
    return join(dir,"%s.o"%hex(hash(src)))

def start(data:dict):
    global outdir,reps,conf_vars
    if type(data) == dict:        
        if 'outdir' in data and 'command1' in data and \
           'command2' in data and 'var' in data and 'items' in data:
            outdir = data['outdir']
            _cmd1 = data['command1']
            _cmd2 = data['command2']
            var = data['var']
            items = data['items']
            if type(outdir)==str and type(_cmd1)==list and\
               type(_cmd2)==list and type(var)==dict and type(items)==dict:
                commands = []
                for vn,vd in var.items():
                    if not re.match(fmt,vn):
                        error("var syntax error:",vn)
                        return 1
                    conf_vars[vn] = vd
                for c in _cmd1:
                    commands.append(fmtstr(c))
                for item_name,item_conf in items.items():
                    if not re.match(fmt,item_name):
                        error("item syntax error:",vn)
                    if 'type' in item_conf and 'src' in item_conf:# and 'includes' in item_conf:# and 'compiler_argv' in item_conf:
                        typ = item_conf['type']
                        src = item_conf['src']
                        #incs = item_conf['includes']
                        if type(typ)==str and type(src)==str:                              
                            of = outfile(outdir,src)
                            reps['${item.%s.src}'%item_name] = src
                            reps['${item.%s.type}'%item_name] = typ
                            reps['${item.%s.out}'%item_name] = of
                            if typ == 'c' or typ == 'cpp':
                                argv = ''
                                if 'compiler_argv' in item_conf:
                                    argv = item_conf['compiler_argv']
                                    commands.append('%s %s -c "%s" -o "%s"'%('gcc'if typ=='c'else'g++',argv,src,of))
                                else:
                                    commands.append('%s -c "%s" -o "%s"'%('gcc'if typ=='c'else'g++',src,of))
                                ldos = []
                                if 'includes' in item_conf:
                                    incs = item_conf['includes']
                                    if type(incs) == dict:
                                        for s,t in incs.items():
                                            o = outfile(outdir,s)
                                            if t == 'asm':
                                                commands.append('nasm -o "%s" "%s"'%(o,s))
                                            elif t == 'asm-elf':
                                                commands.append('nasm -felf -o "%s" "%s"'%(o,s))
                                            else:
                                                if argv:
                                                    commands.append('%s %s -c "%s" -o "%s"'%('gcc'if t=='c'else'g++',argv,s,o))
                                                else:
                                                    commands.append('%s -c "%s" -o "%s"'%('gcc'if t=='c'else'g++',s,o))
                                            ldos.append(o)
                                if 'ld_o' in item_conf:
                                    os = ' '.join(['"%s"'%i for i in ldos])
                                    os = '"%s" %s'%(of,os)
                                    ld_o = fmtstr(item_conf['ld_o'])
                                    reps['${item.%s.ld_o}'%item_name] = ld_o
                                    if 'ld' in item_conf:
                                        reps['${item.%s.ld}'%item_name] = item_conf['ld']
                                        if 'ld_m' in item_conf:
                                            reps['${item.%s.ld_m}'%item_name] = item_conf['ld_m']
                                            commands.append("ld -m \"%s\" \"-T%s\" -o \"%s\" %s"%(item_conf['ld_m'],item_conf['ld'],ld_o,os))
                                        else:
                                            commands.append("ld \"-T%s\" -o \"%s\" %s"%(item_conf['ld'],ld_o,os))
                                    else:
                                        reps['${item.%s.ld}'%item_name] = item_conf['ld']
                                        if 'ld_m' in item_conf:
                                            reps['${item.%s.ld_m}'%item_name] = item_conf['ld_m']
                                            commands.append("ld -m \"%s\" -o \"%s\" %s"%(item_conf['ld_m'],ld_o,os))
                                        else:
                                            commands.append("ld -o \"%s\" %s"%(ld_o,os))
                            elif typ=='asm':
                                commands.append('nasm -o "%s" "%s"'%(of,src))
                            else:
                                error("Unknown type:",typ)
                                return 3
                for c in _cmd2:
                    commands.append(fmtstr(c))
                for cmd in commands:
                    print('Run:',cmd)
                    r = system(cmd)
                    if r:
                        error("Command error:",r)
                        return 3
                else:
                    print("Success")
                    return 0
            else:
                error("Invaild data")

def main():
    print(__version__)
    method = ''
    config = ''
    data:object
    if len(sys.argv) == 2 or len(sys.argv) == 3:
        config = sys.argv[1]
        if len(sys.argv) == 3:
            method = sys.argv[2]
    elif isfile('build.json'):
        config = 'build.json'
    elif not isfile(config):
        error("Config %s not found"%config)
        return 1
    else:
        error("Config not found")
        return 1
    try:
        ucm = ''
        with open(config,'r',encoding='utf-8') as f:
            data = json.load(f)
        if type(data) != dict:
            raise TypeError("Invalid data")
        if method:
            try:return start(data[method])
            except:
                pexc()
                error("Undefined error")
                return 256
        for m in data.keys():
            print("Method:",m)
        try:
            #ucm = 'build'
            ucm = input('Choice a method: ')
        except (KeyboardInterrupt,EOFError):
            print("exit")
            return 0
        try:return start(data[ucm])
        except:
            pexc()
            error("Undefined error")
            return 256
    except:
        error(exc())
        return 1
    
if __name__ == "__main__":
    sys.exit(main() or 0)