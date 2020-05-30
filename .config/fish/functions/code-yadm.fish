# Defined in - @ line 1
function code-yadm --wraps='GIT_WORK_TREE=~ GIT_DIR=~/.config/yadm/repo.git code ~' --description 'alias code-yadm=GIT_WORK_TREE=~ GIT_DIR=~/.config/yadm/repo.git code ~'
  GIT_WORK_TREE=~ GIT_DIR=~/.config/yadm/repo.git code ~ $argv;
end
