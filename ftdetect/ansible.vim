" Determine if normal YAML or Ansible YAML
" Language:        YAML (with Ansible)
" Maintainer:      Benji Fisher, Ph.D. <benji@FisherFam.org>
" Author:          Chase Colman <chase@colman.io>
" Version:         1.0
" Latest Revision: 2015-03-23
" URL:             https://github.com/chase/vim-ansible-yaml

" autocmd BufNewFile,BufRead *.yml,*.yaml,*/{group,host}_vars/*  call s:SelectAnsible("ansible")
autocmd BufNewFile,BufRead *.yml,*.yaml,*/{group,host}_vars/*  call s:check_ansible()
autocmd BufNewFile,BufRead hosts call s:SelectAnsible("ansible_hosts")

function! s:check_ansible()
    if getline(1) =~? '^#!.*ansible'
        setlocal filetype=ansible
    elseif ( glob('ansible.cfg') ==# 'ansible.cfg' )
        if expand('%:e') ==# 'yml'
            setlocal filetype=ansible
        endif
    else
        let l:next_line = getline(1)
        if l:next_line =~# '^---'
            let l:next_line = getline(2)
        endif
        if l:next_line =~# '\v^[ ]*-[ ]*(hosts|name):'
            setlocal filetype=ansible
        elseif l:next_line =~? 'ansible'
            setlocal filetype=ansible
        endif
    endif
endfunction

fun! s:SelectAnsible(fileType)
  " Bail out if 'filetype' is already set to "ansible".
  if index(split(&ft, '\.'), 'ansible') != -1
    return
  endif

  let fp = expand("<afile>:p")
  let dir = expand("<afile>:p:h")

  " Check if buffer is file under any directory of a 'roles' directory
  " or under any *_vars directory
  if fp =~ '/roles/.*\.y\(a\)\?ml$' || fp =~ '/\(group\|host\)_vars/'
    execute "set filetype=" . a:fileType . '.yaml'
    return
  endif

  " Check if subdirectories in buffer's directory match Ansible best practices
  if v:version < 704
    let directories=split(glob(fnameescape(dir) . '/{,.}*/', 1), '\n')
  else
    let directories=glob(fnameescape(dir) . '/{,.}*/', 1, 1)
  endif

  call map(directories, 'fnamemodify(v:val, ":h:t")')

  for dir in directories
    if dir =~ '\v^%(group_vars|host_vars|roles)$'
      execute "set filetype=" . a:fileType
      return
    endif
  endfor
endfun
