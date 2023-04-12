
# release.sh script

This script created for automate the library releases.

<br/>

## Prerequisite

 - git bash installed
 - aws configured which have full access to the AWS S3 releases bucket

<br/>

## Run script

Clone the repo, do the changes and run the script. You can only pass patch, minor or major as parameters. Also you can only push changes from the 'main' branch. This file should be in pom.xml file level. 

<br/>

Run the below script in git bash.

<br/>

patch release,

```bash
  ./release.sh patch
```
or minor release,

```bash
  ./release.sh minor
```
or major release, 

```bash
  ./release.sh major
```

<br/>

After runnning the script, It will create new release and push it to the S3 bucket release folder and will create new snapshot and push it to the S3 bucket snapshot folder. After the changes will push to the git repo with a commit massage and it will create the release tag with new relese version.
