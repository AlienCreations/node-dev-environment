installFromGit () {
  repo=$1
  githubUser=$2
  githubOrganization=$3

  echo "################################"
  echo "################################"
  echo "### Installing [${repo}] repo..."
  echo "################################"
  echo "################################"

  if [ -d ../"${repo}" ]; then
    cd ../"${repo}" || exit
    git add .
    git stash
    git checkout master
    git fetch origin
    git merge --ff-only origin/master
  else
    if [ -z ${githubUser} ]; then
      git clone git@github.com:"${githubOrganization}"/"${repo}".git ../"${repo}"
    else
      git clone https://"$githubUser"@github.com/"${githubOrganization}"/"${repo}".git ../"${repo}"
    fi
    cd ../"${repo}"/ || exit
  fi

  yarn install --force
}
