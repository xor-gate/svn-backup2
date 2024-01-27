# svn-backup2

The `svn-backup2` application is a frugal Subversion backup solution inspired by [adamonduty/svn-backup](https://github.com/adamonduty/svn-backup).
Orignally written and tested for Debian 12 in Bash but could be adapted to other systems.

It creates and updates a single file per repository and consists of multiple gzip compressed archives. It is sha256 checksumed to
detect bit-rot before appending a new incremental backup. This is possible because `svnadmin load` is able to load from a stream of multiple gzip dumps. 
At first run it generates a full-backup and runs `svnadmin verify`.

This script is designed to be run as root. But it is possible when correct permissions are given to run as non-root user.

Features and limitations:

 * Only supports one subversion root path which can contain multiple repositories
 * Single repository backup file for simplicity of restoration and efficient offsite backup transfering with `rsync`
 * Can only restore the whole backup file into an empty repository

## Installation

Install dependencies on Debian Linux 12:

`apt install subversion curl`

Download and install to `/usr/local/bin/svn-backup2` in oneline with curl:

`FILE=/usr/local/bin/svn-backup2 curl -o ${FILE} https://github.com/xor-gate/svn-backup2/raw/main/svn-backup2 && chmod -v 755 ${FILE} && chown -v root:root ${FILE}`

## Paths

* `/etc/svn-backup2.conf`: Configuration file
* `/var/log/svn-backup2.log`: Logfile
* `/srv/svn`: Subversion repositories root path (configurable)
* `/srv/svn-backup2/<repository name>.svnbackup2`: Backup file (multiple concatinated gzip files) (configurable)
* `/var/tmp/svn-backup2/<repository name>.state`: State of a single repository backup

## Configuration file (`/etc/svn-backup2.conf`)

The file is a set of shell environment variables. It will be created on first run
with the following defaults:

```
SVNBACKUP2_CFG_REPOSITORIES_PATH="/srv/svn"
SVNBACKUP2_CFG_BACKUP_PATH="/srv/svn-backup2"
```

## Repository backup state file

A single repository backup state file is a dump of `SVNBACKUP2_REPO_STATE_*` environment variables

Example:

```
SVNBACKUP2_REPO_STATE_CHECKSUM=a911966efe3b069c970ae5511e4a3e6c169bf993e9a3443d841d5d9002447388
SVNBACKUP2_REPO_STATE_LAST_BACKUP_DURATION=1
SVNBACKUP2_REPO_STATE_LAST_BACKUP_END_TIME=1706279396
SVNBACKUP2_REPO_STATE_LAST_BACKUP_START_TIME=1706279396
SVNBACKUP2_REPO_STATE_YOUNGEST=0
```

## Usage

```
Usage: svn-backup2 [operation] <args>
  none                            All repositories are checked and backuped
  version                         Print the version
  full [<repository name> | all]  Force full backup on given repository or "all"
```

## Restoration

svn-backup2 generates simple subversion dumpfiles that can be stream loaded into
`svnadmin load`.

Step 1: Create an empty repository

```
svnadmin create /srv/svn/repository_1
```

Step 2: Uncompress the dumpfile as stream and load into svnadmin

```
zcat /srv/svn-backup2/repository_1.svnbackup2 | svnadmin load /srv/svn/repository_1
```

Step 3: There is no step 3!

A simple shell command can load all repositories at once:

```
find . -type f -name "*.svnbackup2" | while read i; do repository_name=`basename "$i" .svnbackup2`; svnadmin create "$repository_name" && zcat "$i" | svnadmin load "$repository_name"; done
```

# License

svn-backup2 is copyright 2024 by Jerry Jacobs and distributed under the terms of the MIT License. See the [LICENSE](LICENSE) file for further information.

## Alternatives

* [adamonduty/svn-backup](https://github.com/adamonduty/svn-backup) written in Ruby (defunc on Debian 12)
* [loresoft/SvnTools](https://github.com/loresoft/SvnTools) written in C#
* [ghstwhl/SVNBackup](https://github.com/ghstwhl/SVNBackup) written in Perl
* [gcraig/SVNBackup](https://github.com/gcraig/SVNBackup) written in Python
* [subversion-tools](https://packages.debian.org/sid/subversion-tools) multiple tools written in C/Perl
* [avalax/svnbackup](https://github.com/avalax/svnbackup) shell script using svn-hot-backup
