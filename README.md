# svn-backup2

Frugal Subversion backup solution inspired by [adamonduty/svn-backup](https://github.com/adamonduty/svn-backup).
Written and tested for Debian 12 in Bash but could be adapted to other systems.

## Installation

Install dependencies (Debian 12):
`apt install subversion wget`

Download and install to `/usr/local/bin/svn-backup2`:
`FILE=/usr/local/bin/svn-backup2 wget --output-file=${FILE} https://github.com/xor-gate/svn-backup2/raw/main/svn-backup2 && chmod 755 ${FILE} && chown root.root ${FILE}`

## Paths

* `/etc/svn-backup2.conf`: Configuration file (environment variables can be loaded from script with `source`)
* `/data/backup/svn-backup2/<reponame>.svnbackup2` (based on `SVNBACKUP2_BACKUP_PATH`)
* `/var/db/svn-backup2/<reponame>.state`
* `/var/log/svn-backup2.log`

## Config (`/etc/svn-backup2.conf`)

```
SVNBACKUP2_REPOSITORIES_PATH="/var/svn"
SVNBACKUP2_BACKUP_PATH="/data/backup/svn-backup2"
```

## Usage

```
 Usage: svn-backup2 [operation] <args>
    help                       Usage information
    version                    Version
    full                       Force full backup
    env                        Print environment variables
```

## Restoration

svn-backup2 generates simple subversion dumpfiles that can be loaded with
svnadmin.

Step 1: Create an empty repository
```
 svnadmin create /var/svn/repository_1
```
Step 2: Load the dumpfile
```
 svnadmin load /var/svn/repository_1 < repository_1.svnbackup2
```
Step 3: There is no step 3!

A simple bash command can load all repositories at once:

```
 find . -type f -name "*.svnbackup2" | while read i; do repository_name=`basename "$i" .svnbackup2`; svnadmin create "$repository_name" && zcat "$i" | svnadmin load "$repository_name"; done
```

# License

svn-backup2 is copyright 2024 by Jerry Jacobs and distributed under the terms of the MIT License (MIT). See the [LICENSE](LICENSE) file for further information.

## Alternatives

* [adamonduty/svn-backup](https://github.com/adamonduty/svn-backup) written in Ruby (defunc on Debian 12)
* [loresoft/SvnTools](https://github.com/loresoft/SvnTools) written in C#
* [subversion-tools](https://packages.debian.org/sid/subversion-tools) written in C/Perl
