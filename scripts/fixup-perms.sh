#!/bin/sh
# Script to set group to svn for read/write
SVN_REPOSITORIES=/srv/svn
chown -v -R root:svn ${SVN_REPOSITORIES}
find ${SVN_REPOSITORIES} -type d -exec chmod -v 770 {} \;
find ${SVN_REPOSITORIES} -type f -exec chmod -v 660 {} \;
