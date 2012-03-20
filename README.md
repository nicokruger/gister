Gister
------
Gister is a utility to download gists from github, and show their contents, save them to a file, or execute them with arguments.

The idea being that you can store handy scripts online, or play around with other peoples' scripts, etc.

Usage
-----
Clone the repo, put the .sh somewhere on your path, and give it execute permissions.

Playing
-------
Go into a git repository, and type the following:
 
    gister.sh -x nicokruger foreach - $(gister.sh -s nicokruger count-files) | xargs gister.sh -x nicokruger simple-gnuplot.sh -

This will get a couple of gists from github, and generate a gnuplot graph plotting the amount of files in the git repository over time.

Other stuff to do:

    gister.sh -x nicokruger 8ball.rb

More to be added later.

Note: obviously it is potentially dangerous to execute aribtrary code from 3rd party sources. Especially be wary of running ANY script as root. I cannot be held responsible if you destroy your data and/or your computer/life.
 
