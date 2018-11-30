
################################################################################
#### this rst is really now a shell script that can be run 
################################################################################

#### over time will put all my github (and bitbucket) repos cloning here
#### for now, run as:
#### cat ~tin/PSG/git.setup.gh.sh | egrep -v "^$|^#"
#### and cut-n-paste output, pausing in places that may ask for password...


# assume script is in the psg/ dir 
#cd ..

# nah, going forward, always setup a new dir :)
### in WSL setup, precreate:

useC_tin=0
useC_tin=$(uname -a  | grep -c Microsoft)  # this should be 1 in wsl ubuntu bash


##WslEnv=True
##if [[ x${WslEnv} == xTrue ]]; then
#useC_tin=1  # in select WSL/bash env wehre I don't want things multiple time in home of cygwin, moba, etc.
if [[ ${useC_tin} -eq 1 ]]; then
	echo "useC_tin is true, in WSL"
	cd /mnt/c/tin
	[[ -e tin-gh ]] || mkdir tin-gh
	cd ~
	[[ -e tin-gh ]] || ln -s /mnt/c/tin/tin-gh .	# this cmd need to run in wsl bash prompt  NOT cygwin. (cyz of /mnt/c)
	[[ -e C_tin  ]] || ln -s /mnt/c/tin ./C_tin
fi
MyGitDir=~/tin-gh	# could be a link (mostly in win/wsl)
[[ -e $MyGitDir ]] || mkdir $MyGitDir
cd $MyGitDir


echo "current dir, where git clone(s) will take place is: (^C within 30 sec to cancel--or may need to press ENTER...)"
ls -ld ~/tin-gh
pwd
pwd -P
#sleep 15
read WaitForEnter

#exit 666



########################
### config settings ####
########################

## create fn, and eval a param, don't always want to run this...  but it is essentially idempotent...
#git clone https://tin6150@github.com/tin6150/psg

[[ -d $MyGitDir/psg ]] || mkdir $MyGitDir/psg
cd $MyGitDir/psg
## config need to write to some .git...   create a fn for this?

git config --global user.email "sn+newbox@grumpyxmas.com"             # FIXME++ change this to machine specific settings to get better idea of where commits, 
                                                        # merges are done, but don't display well on bitbucket :(
git config --global user.name tin6150
## in bitbucket, need username to match what bitbucket.org has in record for it to prompt for pwd
git config --global credential.helper 'cache --timeout=36000'
git config --global github.user   tin6150
git config --global alias.lol "log --oneline --graph --decorate"                # create alias "git lol"   # logd
git config --global merge.conflictstyle diff3            # cmd diff tool, make file w/ <<<< |||| >>>>, bearable
#git config merge.conflictstyle diff3            # cmd diff tool, make file w/ <<<< |||| >>>>, bearable


#cd ..

run_git_clone() 
{
	########################
	#### tin6150 github ####
	########################

	cd $MyGitDir

	git clone https://tin6150@github.com/tin6150/psg
	echo "may need password..."

	git clone https://tin6150@github.com/tin6150/bofhbot

	git clone https://tin6150@github.com/tin6150/singularity
	### many random programming bits, eg knime, dataTables/panda, jQuery, mpi, etc
	git clone https://tin6150@github.com/tin6150/inet-dev-class
	### boston housing price ML 
	git clone https://tin6150@github.com/tin6150/machine-learning-nanodegree.git

	### VMware tools as ansible role fork (so as not get updte unless manually checked)
	### actually trying to do subtree merging under CF_BK/Ansible/roles
	### git clone https://github.com/tin6150/ansible-role-vmwaretools

	### old projects
	git clone https://tin6150@github.com/tin6150/db4cpa
	git clone https://tin6150@github.com/tin6150/taxonomy_reporter
	git clone https://tin6150@github.com/tin6150/pyspark
	git clone https://tin6150@github.com/tin6150/taxo-spark

	### singularity container dev or not posting to singularity-hub.org 
	git clone https://tin6150@github.com/tin6150/singhub      

	### contributed to singularityware web doc
	git clone https://tin6150@github.com/tin6150/singularityware.github.io

	### singularity-hub container definitions
	git clone https://tin6150@github.com/tin6150/circos.git
	git clone https://tin6150@github.com/tin6150/knime
	git clone https://tin6150@github.com/tin6150/dell_idracadm
	git clone https://tin6150@github.com/tin6150/biolab-orange/
	git clone https://tin6150@github.com/tin6150/perf_tools
	git clone https://tin6150@github.com/tin6150/cuda
	git clone https://tin6150@github.com/tin6150/boinc-client.git

        ##############################
        #### tin6150@github gitst ####
        ##############################

        git clone https://gist.github.com/e271e5d3bef6d93ebc6817170ddd2456.git # census2mapbox.rst


	############################
	#### formerly in tin-bb ####
	############################

	# run from a parent dir eg ~/tin-bb 
	# cd ..
	git clone https://tin6150@bitbucket.org/tin6150/blpriv
	echo "may ask for password..."
	git clone https://tin6150@bitbucket.org/tin6150/spark
	git clone https://tin6150@bitbucket.org/tin6150/predpriv.git


	###########################
	#### tin@lbl bitbucket ####
	###########################

	# run from a parent dir eg ~/tin-bbb 
	# cd ..
	git clone https://sn5050@bitbucket.org/sn5050/ansible-dev
	git clone https://sn5050@bitbucket.org/berkeleylab/unified-vnfs.git

	## biositting tool, collab with ETA Ling Jin, Tyler Huntington
	# 1.1 GB repo , maybe data deleted.  
	#~ git clone https://sn5050@bitbucket.org/olgakavvada/biositing_tool.git 
	# forked , bb interface is significantly diff than github :(
	#+ git clone https://sn5050@bitbucket.org/sn5050/biositing_tool_test.git
	# no GIS_data subdir yet...


	##########################
	#### hpcs-cf git repo ####
	##########################
	# git clone git@hpcs-cf.lbl.gov:/remote/ansible.git 
	#cd ~/tin-gh; ssh-agent bash -c 'ssh-add ~/.ssh/id_rsa ; git clone git@hpcs-cf.lbl.gov:/remote/ansible.git' # this prompt for ssh-key pw then git@hpcs-cf pw :(
	cd ~/tin-gh; ssh-agent bash -c 'ssh-add ~/.ssh/id_dsa ; git clone git@hpcs-cf.lbl.gov:/remote/ansible.git'
	cd ~/tin-gh/ansible ; ssh-agent bash -c 'ssh-add ~/.ssh/id_dsa ; git pull' # somehow n0013.ares git 1.7 need this method


	#  cuda is dup, can be ignored

	#################################################################
	#### public repos, not owned by me ####
	#### but these are likely to be reused in other system
	#### and there is really no need to store them in other location
	#### i should be able to tell what's mine and what's not, 
	#### especially with this centralized git clone file
	#################################################################


	#git clone git://github.com/jonas/tig.git	# https://www.tecmint.com/tig-a-commandline-browser-for-git-repositories/ # in apt-get
	git clone https://github.com/dlab-berkeley/machine-learning-in-R   # d-lab ML in R

} # end-run_git_clone()





create_links() 
{

	############################################################
	############################################################
	#### create sym links that I have in most places now
	############################################################
	############################################################


	# don't use tab below or cut-n-paste may engage tab completion.
	#GIT_DIR=$(pwd)
	#### previos approach created symlink in home dir
	#### useful, but would need more.
	#-- block below should take care of this.
	#--GIT_DIR=$MyGitDir
	#--cd ~
	#--ln -s ${GIT_DIR}/bofhbot            ~/BOFHbot
	#--ln -s ${GIT_DIR}/psg                ~/PSG
	#--cd $GIT_DIR	# ie cd back



	####WSL/bash env need additional link from ghDir (or multiple homes)
	# don't use tab below or cut-n-paste may engage tab completion.
	#### for WSL/bash, want link in C_tin
	#if [[ x${useC_tin} == xTrue ]]; then
	if [[ ${useC_tin} -eq 1 ]]; then
		GIT_DIR="./tin-gh"
		cd ~/C_tin
	else
		# even in wsl, may want this in /home/$USERNAME, extra set of links, should not be too confusing...
		GIT_DIR=$MyGitDir # ie export GIT_DIR="./tin-gh" , which should  still exist in ~, maybe link in wsl
		cd ~
	fi
	# actually, always wants links in ~ ; in wsl, add link to C_tin.
	# thus, above if is obsolete.
	# using for loop below instead.  ## ++ untested at this point

	#
	for LinkBase in ~/C_tin ~; do
		[[ -e $LinkBase ]] || continue # ie, skip the rest if dir/link existance is FALSE 
		cd $LinkBase
		# create links below only if they don't already exist
		[[ -L CF_BK        ]] || ln -s ${GIT_DIR}/blpriv/cf_bk              ./CF_BK
		[[ -L NOTE         ]] || ln -s ${GIT_DIR}/blpriv/note               ./NOTE
		[[ -L HPCS_toolkit ]] || ln -s ${GIT_DIR}/blpriv/hpcs_toolkit       ./HPCS_toolkit
		[[ -L BOFHbot      ]] || ln -s ${GIT_DIR}/bofhbot                   ./BOFHbot
		[[ -L PSG          ]] || ln -s ${GIT_DIR}/psg                       ./PSG
		[[ -L ~/PSG        ]] || ln -s ${GIT_DIR}/psg                       ~/PSG		## historically created links with absolute PATH at ~
		cd $GIT_DIR	# ie cd back
	done

} # end-create_links()


macOS_setup()
{

	# refer to https://github.com/geerlingguy/mac-dev-playbook
	# need ansible installed (eg use psg/script/sh/bootstart...sh)

	xcode-select --install
	cd $MyGitDir
	git clone https://github.com/geerlingguy/mac-dev-playbook.git
	cd mac-dev-playbook
	ansible-galaxy install -r requirements.yml
	#### roles/ dir created in . to store galaxy data
	ansible-playbook main.yml -i inventory -K 	# inventory is just localhost

	## analyze, but okay to try on new laptop :):
	## My dotfiles are also installed into the current user's home directory, including the .osx dotfile for configuring many aspects of macOS for better performance and ease of use. You can disable dotfiles management by setting configure_dotfiles: no in your configuration.

}


#### sometime links creation breaks and don't need to run clone again.
#### ++ FIXME, enable whatever fn that wants to be run
#+run_git_clone
create_links

#macOS_setup ## cmd tried, but fn untested.

#### PS:
#### git clone should be in the right place
#### but sym links for mobaXterm and maybe cygwin may not work yet
#### in wsl/ubuntu/bash should be fine...
#### too messy, too many env.  setup by and or just use C_tin as needed
#### spending too much time on a not so serious problem.


