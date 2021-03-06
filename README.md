Clevo Fan Control Indicator for Debian / Ubuntu / Mint
======================================================

This program is an Ubuntu indicator to control the fan of Clevo laptops, using reversed-engineering port information from ECView.

It shows the CPU temperature on the left and the GPU temperature on the right, and a menu for manual control.

![Clevo Indicator Screen](http://i.imgur.com/ucwWxLq.png)



For command-line, use *-h* to display help, or a number representing percentage of fan duty to control the fan (from 40% to 100%).


Build and Install
-----------------

```shell
sudo apt-get install libappindicator3-dev libgtk-3-dev
git clone git@github.com:dbeniamine/clevo-indicator.git
cd clevo-indicator
make install
```

### Debian

On Debian `ec_sys.ko` is not built by default, you need to build it by yourself.

*Don't panic* there is a small helper to do it, just run :

    sudo ./build_module.sh

It is required to run this script after each kernel upgrade, to do it
automatically, just run :

    sudo cp build_module.sh /etc/kernel/postinst.d/

**Warning: ** I have not yet tested the automatic run of the script with
postinst.d, please report any problem.

Notes
-----

The executable has setuid flag on, but must be run by the current desktop user,
because only the desktop user is allowed to display a desktop indicator in
Ubuntu, while a non-root user is not allowed to control Clevo EC by low-level
IO ports. The setuid=root creates a special situation in which this program can
fork itself and run under two users (one for desktop/indicator and the other
for EC control), so you could see two processes in ps, and killing either one
of them would immediately terminate the other.

Be careful not to use any other program accessing the EC by low-level IO
syscalls (inb/outb) at the same time - I don't know what might happen, since
every EC actions require multiple commands to be issued in correct sequence and
there is no kernel-level protection to ensure each action must be completed
before other actions can be performed... The program also attempts to prevent
abortion while issuing commands by catching all termination signals except
SIGKILL - don't kill the indicator by "kill -9" unless absolutely necessary.

