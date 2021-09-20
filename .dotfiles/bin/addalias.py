#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys

ERR_SAME = "You have same alias, try different."
SUCCESS = "Success!"

class Operations:
    def __init__(self):
        self.bash_file = os.path.expanduser("~/.oh-my-zsh/custom/added_aliases.zsh")
        self.path = os.path.realpath(__file__)
        self.install_dir = os.path.expanduser("~/.local/share/addalias")
        self.install_path = os.path.join(self.install_dir, __file__)

    def check(self, lines, alias):
        for line in lines:
            if line.startswith("alias " + alias + "="):
                return False
        return True

    def add_alias(self, alias, command):
        with open(self.bash_file, 'a+') as f:
            if self.check(f.readlines(), alias):
                txt = ""
                if str(command).startswith("'") and str(command).endswith("'"):
                    txt = "alias %s=%s\n" % (alias, command)
                else:
                    txt = "alias %s='%s'\n" % (alias, command)
                f.write(txt)
                print SUCCESS
                return True
            else:
                return False

    def delete(self, alias):
        #TODO: delete by id
        f = open(self.bash_file, "r")
        lines = f.readlines()
        f.close()

        f = open(self.bash_file,"w")

        for line in lines:
            if not line.startswith("alias " + alias + "="):
                f.write(line)

        f.close()
        print SUCCESS

    def aliaslist(self):
        aliases = []
        if not os.path.isfile(self.bash_file):
            open(self.bash_file, 'a').close()
        with open(self.bash_file, 'r') as f:
            for line in f.readlines():
                if line.startswith("alias"):
                    cmdline = line.replace("alias", "", 1).strip()
                    aliases.append(cmdline)
        return  aliases


    def print_aliases(self):
        i = 0
        for line in self.aliaslist():
            print "[" + str(i) + "] " + line
            i += 1

    def install(self):
        import shutil

        if not os.path.exists(self.install_dir): os.mkdir(self.install_dir)
        if os.path.isfile(self.install_path): os.remove(self.install_path)

        shutil.copyfile(self.path, self.install_path)
        self.add_alias("addalias", "python " + self.install_path)
        print "\tnow you can use 'addalias -parameters'"
        print "\tbefore using you have to close this terminal window and reopen"
        print "\tfor example"
        print '\t\taddalias -add "my-alias" "my-command"'

    def uninstall(self):
        self.delete("addalias")
        os.remove(self.install_path)
        os.rmdir(self.install_dir)
        print SUCCESS



operations = Operations()



def main(argv = None):
    if argv is None:
        argv = sys.argv

    number = len(argv)

    if number == 1:
        print 'try typing --help'

    elif number == 2:
        if argv[1] == '--help':
            print ""
            print '\tusage:'
            print '\t\tadd new alias:   python addalias.py -add "<title>" "<alias>"'
            print '\t\tremove alias:    python addalias.py -rm "<title>"'
            print '\t\tlist aliases:    python addalias.py -list'
            print '\t\tinstall:         python addalias.py --install (Installs for only this user)'
            print '\t\tuninstall:       addalias --uninstall         (If you installed with --install command, use this to uninstall)'
            print ""
            print "\t\texample:"
            print '\t\t\tpython addalias.py -add "myalias" "my-real-command"'
            print '\t\t\tpython addalias.py -rm "myalias"'
            print ""
            print "\t\tif you installed the script, you can write 'addalias' instead of  'python addalias.py'"
            print ""

        elif argv[1] == "-list":
            operations.print_aliases()

        elif argv[1] == "--install":
            operations.install()

        elif argv[1] == "--uninstall":
            operations.uninstall()

        else:
            print 'wrong usage, try typing --help'

    elif number == 3 and argv[1] == "-rm":
        operations.delete(argv[2])

    elif number == 4 and argv[1] == "-add":
        if not operations.add_alias(argv[2], argv[3]):
            print ERR_SAME

    else:
        print 'wrong usage, try typing --help'

if __name__ == '__main__':
    main()
