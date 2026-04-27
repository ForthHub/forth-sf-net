
## `comp.lang.forth.repository` (2000-2003)

The purpose of the
https://forth.sourceforge.net/
platform was to document
existing Forth usage that
were discussed in the `comp.lang.forth` newsgroup.

This Git repository was imported from the CVS repository
at https://sourceforge.net/p/forth/code/
with normalization of line endings.

The commands are as follows.
```bash
# Download CVS repo, see https://sourceforge.net/p/forth/code/
wget 'https://sourceforge.net/code-snapshots/cvs/f/fo/forth.zip'
unzip forth.zip
mv forth forth-sf-net.cvs
rm forth.zip

# Import history to Git from CVS
mkdir forth-sf-net && cd $_
git init
find ../forth-sf-net.cvs/ | cvs-fast-export | git fast-import
git checkout

# Normalize line endings
git filter-repo --force --replace-text <(echo 'regex: \r\r\n==> '; echo 'regex:\r(\n)?==>\n'; echo 'regex:[ \t\v\f]+\n==>\n')
# NB: in a few places where "\r\r\n" is used, it is not needed at all

# Set the upsteram and push
git remote add origin git@github.com:ForthHub/forth-sf-net.git
git push -u origin master
cd ..
```

Additional tools used:
  - [cvs-fast-export](https://gitlab.com/esr/cvs-fast-export)
  - [git-filter-repo](https://github.com/newren/git-filter-repo)
