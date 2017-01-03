BGW-docker
==========

A containerized version of [BerkeleyGW](http://berkeleygw.org) for Linux and Mac.


Installation
------------

1. Install [docker](https://docker.com). On Linux, you can simply type
`sudo /bin/sh -c 'curl -sSL https://get.docker.com/ | sh'` or `sudo /bin/sh -c 'wget -qO- https://get.docker.com/ | sh'`.

If you are running on Linux, make sure your current user is a member of the `docker` group after the installation is finished:
`sudo usermod -aG docker $(whoami)`. This way, you won't need to be root to run docker. You will have to log out and back in for this to take effect!

2. Build a local, automatically-tuned version of bgw-docker:
```
docker build -t bgw https://github.com/BerkeleyGW/bgw-docker.git
```

3. Add the `bgw-docker` alias to your `.bashrc` (or `.zshrc`) and source it:
```
cat >> ~/.bashrc <<-'EOF'
alias bgw-docker='docker run --rm -v /:/host -e LOCAL_DIR=${PWD} -e LOCAL_USER_ID=$(id -u) -e LOCAL_GROUP_ID=$(id -g) -e OMP_NUM_THREADS=${OMP_NUM_THREADS:-1} bgw'
EOF
source ~/.bashrc
```

4. Make sure your build finished correctly. Type `docker images` and make sure there is a `bgw` repository.


Usage
-----

* In order to run BerkeleyGW with X MPI ranks, just use the syntax:
```
bgw-docker [mpirun -n X] <BerkeleyGW executable>
```

* You can run several parallel commands stored in, say, `script.sh`, with
`bgw-docker <./script.sh>`. This is slightly faster than running each command
with `bgw-docker`, since we reuse the same Docker container for all calculations.

* You can also use Y threads in the calculations with `export OMP_NUM_THREADS=Y`.
You can put this statement either outside or inside your call to `bgw-docker`.

* For example, to run the BerkeleyGW silicon example:
```
mkdir /tmp/bgw
cd /tmp/bgw
bgw-docker cp -R /opt/BerkeleyGW-1.2.0/examples/EPM/silicon .
cd silicon
bgw-docker ./script_0.sh
bgw-docker ./script_1.sh
bgw-docker ./script_2.sh
bgw-docker ./script_3.sh
```


License
-------

Both BGW-docker and BerkeleyGW are distributed under the BSD license.
See license.txt for more information.
